#include <Arduino.h>

struct CanFrame
{
    uint32_t id;
    uint8_t length;
    uint8_t data[8];
};

struct Signals {
  float rpm;
  float speed;
  float coolant;
  float fuel;
  bool lights;
};

Signals signals;

enum Mode {
  SIMULATION,
  REAL_CAN,
  LOG_ONLY
};

Mode mode = SIMULATION;  // потом поменяешь одной строкой

// Переменные для точной математической модели физики движения
float fuel = 100.0; // Уровень топлива в процентах (100% — полный бак)
float rpm_raw = 800.0;
float speed = 0.0;
float coolant = 20.0;
int gear = 1;
bool accelerating = true;
bool useRealCAN = false;   // пока трансивера нет
bool debugCAN = true;

// Переменная для таймера отправки без задержек (delay)
unsigned long lastTime = 0;

// ---------- Будущий CAN Parser ----------

void processCanFrame(const CanFrame &frame)
{
    // ─── DEBUG LOGGER (как CANalyzer) ───
    if (debugCAN)
    {
        Serial.print("CAN ID: 0x");
        Serial.print(frame.id, HEX);
        Serial.print(" DATA: ");

        for (int i = 0; i < frame.length; i++)
        {
            Serial.print(frame.data[i], HEX);
            Serial.print(" ");
        }

        Serial.println();
    }

    // ─── DECODER LAYER ───
    switch(frame.id)
    {
        case 0x186:
            signals.rpm = (frame.data[0] << 8 | frame.data[1]) * 0.125;
            break;

        case 0x354:
            signals.speed = frame.data[0];   // пока упрощённо
            break;

        case 0x481:
            signals.lights = frame.data[0];
            break;

        default:
            // неизвестный CAN ID (важно для Logan!)
            break;
    }
}

bool readCAN(CanFrame &frame)
{
    return false; // пока нет трансивера
}

void logCAN(const CanFrame &frame)
{
  Serial.print("CAN ID: 0x");
  Serial.print(frame.id, HEX);
  Serial.print(" | DATA: ");

  for (int i = 0; i < frame.length; i++)
  {
    Serial.print(frame.data[i], HEX);
    Serial.print(" ");
  }

  Serial.println();
}

/*void decodeCAN(const CanFrame &frame)
{
  switch(frame.id)
  {
    case 0x186:
      signals.rpm = (frame.data[0] << 8 | frame.data[1]) * 0.125;
      break;

    case 0x354:
      signals.speed = frame.data[0]; // упрощённо
      break;

    case 0x481:
      signals.lights = frame.data[0];
      break;
  }
}*/

CanFrame createRpmFrame(uint16_t rpmValue)
{
    CanFrame frame;

    frame.id = 0x186;
    frame.length = 8;

    uint16_t raw = rpmValue * 8; // factor = 0.125

    frame.data[0] = (raw >> 8) & 0xFF;
    frame.data[1] = raw & 0xFF;

    for(int i = 2; i < 8; i++)
        frame.data[i] = 0;

    return frame;
}

void setup() {
  // Инициализируем USB-порт на скорость 115200 (эту же скорость слушает наш Qt)
  Serial.begin(115200);
  
  // Даем плате 1 секунду на стабилизацию питания при подключении к USB
  delay(1000); 
  
  Serial.println("\n--- Эмулятор проводного CAN-Gateway запущен ---");
  Serial.println("Данные транслируются в USB-порт...");
}

void loop() {
  // Отправка пакетов строго каждые 20 мс (50 Гц)
  if (millis() - lastTime >= 20) {
    lastTime = millis();

    // ─── МАТЕМАТИЧЕСКАЯ МОДЕЛЬ ───
    if (accelerating) {
      rpm_raw += 65.0 - (gear * 5);
      speed += (rpm_raw / 1500.0) * (0.8 / max(gear, 1));

      if (rpm_raw >= 6200.0) {
        gear++;
        rpm_raw = 3800.0;

        if (gear > 6) {
          gear = 6;
          accelerating = false;
        }
      }
    } else {
      rpm_raw -= 45.0;
      speed -= 0.4;

      if (speed <= 0) {
        speed = 0;
        gear = 1;
        rpm_raw = 800.0;
        accelerating = true;
      }
      else if (rpm_raw <= 2200.0 && gear > 1) {
        gear--;
        rpm_raw = 4500.0;
      }
    }

    // ─── ОГРАНИЧЕНИЯ ───
    rpm_raw = constrain(rpm_raw, 800.0, 6500.0);
    speed   = constrain(speed, 0.0, 200.0);

    // ─── CAN СЛОЙ (SIM / REAL) ───
    CanFrame frame;

    if (mode == REAL_CAN)
    {
      if (readCAN(frame))
      processCanFrame(frame);
    } else if (mode == SIMULATION)
    {
      CanFrame simFrame = createRpmFrame((uint16_t)rpm_raw);
      processCanFrame(simFrame);
    } else if (mode == LOG_ONLY)
    {
      if (readCAN(frame))
        logCAN(frame);
    }

    // ─── ФИЗИКА ОСТАЛЬНЫХ ПАРАМЕТРОВ ───
    if (coolant < 90.0) {
      coolant += 0.005;
    }

    if (speed > 10.0 && fuel > 0.0) {
      fuel -= 0.002;
    }
    else if (fuel <= 0.0) {
      fuel = 100.0;
    }

  signals.rpm = rpm_raw;
  signals.speed = speed;
  signals.coolant = coolant;
  signals.fuel = fuel;
  signals.lights = true;

  // ─── JSON ДЛЯ QT ───
  String json = "{\"rpm\":" + String((int)signals.rpm) +
            ",\"speed\":" + String((int)signals.speed) +
            ",\"gear\":" + String(gear) +
            ",\"coolant\":" + String((int)coolant) +
            ",\"fuel\":" + String((int)fuel) +
            ",\"lights\":" + String(signals.lights ? 1 : 0) + "}";

    Serial.println(json);
  }
}