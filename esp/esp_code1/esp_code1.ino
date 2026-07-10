#include <Arduino.h>
#include <LittleFS.h>
#include <ArduinoJson.h>

// Структура кадра CAN-шины
struct CanFrame {
    uint32_t id;
    uint8_t length;
    uint8_t data[8]; 
};

// Переменные для хранения готовых физических значений
struct Signals {
    float rpm;
    float speed;
    float coolant;
    float fuel;
} signals;

// Глобальный объект JSON-документа
JsonDocument doc;

// Функция загрузки карты из файла
void loadCANMap()
{
    File file = LittleFS.open("/can_map.json", "r");
    if (!file) {
        Serial.println("[ОШИБКА] Файл /can_map.json не найден!");
        return;
    }

    doc.clear();
    DeserializationError error = deserializeJson(doc, file);
    file.close();

    if (error) {
        Serial.printf("[ОШИБКА JSON]: %s\n", error.c_str());
        return;
    }

    doc.shrinkToFit();
    Serial.println("[УСПЕХ] CAN-карта успешно загружена в память.");
}

// Функция парсинга входящего CAN-кадра по правилам из JSON
void processFrameFromJSON(CanFrame &frame)
{
    JsonObject frames = doc["frames"];
    
    // Переводим ID кадра в строковый HEX-формат (например, 0x186) строго в нижнем регистре
    char idStr[10];
    sprintf(idStr, "0x%x", frame.id); 

    // Ищем этот ID в нашей JSON-карте
    JsonArray arr = frames[idStr];
    if (arr.isNull()) return; // Если такого ID в конфигурации нет, игнорируем пакет

    // Проходим по всем сигналам, описанным для этого ID
    for (JsonObject signal : arr)
    {
        String target = signal["target"];

        if (target == "rpm")
        {
            // Собираем 2 байта (Big Endian: data[0] - старший, data[1] - младший)
            uint16_t raw = (frame.data[0] << 8) | frame.data[1];
            signals.rpm = raw * 0.125;
        }

        if (target == "speed")
        {
            signals.speed = frame.data[0] * 0.01;
        }

        if (target == "coolant")
        {
            signals.coolant = frame.data[0] - 40;
        }
    }
}

// Реальная или тестовая функция чтения шины
bool readCAN(CanFrame &frame)
{
    // Сюда вы позже подставите код вашей CAN-библиотеки (например, ESP32-TWAI-CAN или mcp2515)
    // Пример: return TWAI_read_frame(&frame);
    return false; 
}

void setup()
{
    Serial.begin(115200);
    delay(1000);

    Serial.println("\n--- ЗАПУСК СИСТЕМЫ CAN-ДЕКОДЕРА ---");

    if (!LittleFS.begin(true)) {
        Serial.println("[КРИТИЧЕСКАЯ ОШИБКА] Ошибка LittleFS!");
        return;
    }

    loadCANMap();
}

void loop()
{
    CanFrame frame;

    // Когда появится реальное железо, этот блок начнет читать шину:
    if (readCAN(frame))
    {
        processFrameFromJSON(frame);
    }
    
    // --- ВРЕМЕННЫЙ ТЕСТ ДЛЯ ПРОВЕРКИ ВСЕХ ТРЕХ ID ИЗ ВАШЕГО JSON ---
    
    // 1. Тестируем RPM (ID: 0x186) -> Ожидаем 3000 RPM
    frame.id = 0x186;
    uint16_t rawRpm = 3000 / 0.125; // = 24000
    frame.data[0] = rawRpm >> 8;
    frame.data[1] = rawRpm & 0xFF;
    processFrameFromJSON(frame);

    // 2. Тестируем Скорость (ID: 0x354) -> Пусть в data[0] лежит число 120, ожидаем 1.20 км/ч (по вашему фактору 0.01)
    frame.id = 0x354;
    frame.data[0] = 120; 
    processFrameFromJSON(frame);

    // 3. Тестируем Температуру (ID: 0x551) -> Пусть в data[0] лежит 130, ожидаем 90°C (130 - 40)
    frame.id = 0x551;
    frame.data[0] = 130; 
    processFrameFromJSON(frame);

    // Выводим результаты в Serial раз в секунду
    Serial.printf("ДАННЫЕ: RPM: %.2f | Скорость: %.2f | ОЖ: %.1f°C\n", 
                  signals.rpm, signals.speed, signals.coolant);

    delay(1000);
}
