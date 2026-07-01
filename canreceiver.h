#pragma once

#include <QObject>
#include <QThread>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlEngine>
#include <windows.h> // Стандартная библиотека Windows для COM-порта

class CanReceiver : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(double rpm          READ rpm          NOTIFY rpmChanged)
    Q_PROPERTY(double speed        READ speed        NOTIFY speedChanged)
    Q_PROPERTY(int    gear         READ gear         NOTIFY gearChanged)
    Q_PROPERTY(double coolant      READ coolant      NOTIFY coolantChanged)
    Q_PROPERTY(double fuel         READ fuel         NOTIFY fuelChanged)
    Q_PROPERTY(bool   lightWarning READ lightWarning NOTIFY lightWarningChanged)

public:
    explicit CanReceiver(QObject *parent = nullptr);
    ~CanReceiver();
    double fuel()         const { return m_fuel; }
    double rpm()          const { return m_rpm; }
    double speed()        const { return m_speed; }
    int    gear()         const { return m_gear; }
    double coolant()      const { return m_coolant; }
    bool   lightWarning() const { return m_lightWarning; }

signals:
    void fuelChanged();
    void rpmChanged();
    void speedChanged();
    void gearChanged();
    void coolantChanged();
    void lightWarningChanged();

private:
    void listenPort(); // Метод чтения в фоне

    HANDLE hSerial = INVALID_HANDLE_VALUE;
    bool m_running = true;
    std::string m_buffer;

    double m_rpm          = 800.0;
    double m_speed        = 0.0;
    int    m_gear         = 1;
    double m_coolant      = 20.0;
    double m_fuel         = 100.0;
    bool   m_lightWarning = false;
};
