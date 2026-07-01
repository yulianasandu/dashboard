#include "canreceiver.h"
#include <QDebug>
#include <QtConcurrent/QtConcurrent>

CanReceiver::CanReceiver(QObject *parent) : QObject(parent)
{
    // Запускаем опрос порта в фоновом режиме, чтобы QML-интерфейс не тормозил
    QtConcurrent::run([this]() {
        this->listenPort();
    });
}

CanReceiver::~CanReceiver()
{
    m_running = false;
    if (hSerial != INVALID_HANDLE_VALUE) {
        CloseHandle(hSerial);
    }
}

void CanReceiver::listenPort()
{
    // 1. Сначала пробуем открыть конкретно COM5, так как мы точно знаем, что ESP32 там
    std::string targetPort = "\\\\.\\COM5";
    hSerial = CreateFileA(targetPort.c_str(), GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

    // 2. Если вдруг порт изменился, перебираем порты от 10 до 2 (пропускаем системный COM1)
    if (hSerial == INVALID_HANDLE_VALUE) {
        for (int i = 10; i >= 2; --i) {
            std::string portName = "\\\\.\\COM" + std::to_string(i);
            hSerial = CreateFileA(portName.c_str(), GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
            if (hSerial != INVALID_HANDLE_VALUE) {
                qDebug() << "ESP32 успешно найдена на порту: COM" << i;
                break;
            }
        }
    } else {
        qDebug() << "ESP32 успешно найдена на приоритетном порту: COM5";
    }

    if (hSerial == INVALID_HANDLE_VALUE) {
        qWarning() << "Плата ESP32 не обнаружена ни на одном рабочем COM-порту!";
        return;
    }

    // Настройка параметров порта (115200 бод, как в прошивке)
    DCB dcbSerialParams = { 0 };
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    GetCommState(hSerial, &dcbSerialParams);
    dcbSerialParams.BaudRate = CBR_115200;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;
    SetCommState(hSerial, &dcbSerialParams);

    char szBuff[256];
    DWORD dwBytesRead = 0;

    while (m_running) {
        if (ReadFile(hSerial, szBuff, sizeof(szBuff) - 1, &dwBytesRead, NULL) && dwBytesRead > 0) {
            szBuff[dwBytesRead] = '\0';
            m_buffer += szBuff;

            // Обработка строк по символу переноса '\n'
            size_t pos;
            while ((pos = m_buffer.find('\n')) != std::string::npos) {
                std::string line = m_buffer.substr(0, pos);
                m_buffer.erase(0, pos + 1);

                // Переводим стандартную строку в QByteArray для парсинга JSON в Qt
                QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(line));
                if (!doc.isNull() && doc.isObject()) {
                    QJsonObject obj = doc.object();

                    // Обновляем данные интерфейса
                    if (obj.contains("rpm")) {
                        double val = obj["rpm"].toDouble();
                        if (m_rpm != val) { m_rpm = val; emit rpmChanged(); }
                    }
                    if (obj.contains("speed")) {
                        double val = obj["speed"].toDouble();
                        if (m_speed != val) { m_speed = val; emit speedChanged(); }
                    }
                    if (obj.contains("gear")) {
                        int val = obj["gear"].toInt();
                        if (m_gear != val) { m_gear = val; emit gearChanged(); }
                    }
                    if (obj.contains("coolant")) {
                        double val = obj["coolant"].toDouble();
                        if (m_coolant != val) { m_coolant = val; emit coolantChanged(); }
                    }
                    if (obj.contains("fuel")) {
                        double val = obj["fuel"].toDouble();
                        if (m_fuel != val) { m_fuel = val; emit fuelChanged(); }
                    }
                    if (obj.contains("lights")) {
                        bool val = obj["lights"].toInt() > 0;
                        if (m_lightWarning != val) { m_lightWarning = val; emit lightWarningChanged(); }
                    }
                }
            }
        }
        Sleep(10); // Небольшая пауза, чтобы не перегружать процессор компьютера
    }
}
