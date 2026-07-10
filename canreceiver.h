#pragma once

#include <QObject>
#include <QQmlEngine>
#include <windows.h>
#include <string>
#include <QString>


class CanReceiver : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString gear READ gear NOTIFY gearChanged)

    Q_PROPERTY(double rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(double coolant READ coolant NOTIFY coolantChanged)
    Q_PROPERTY(double fuel READ fuel NOTIFY fuelChanged)
    Q_PROPERTY(double odometer READ odometer NOTIFY odometerChanged)

    Q_PROPERTY(bool highBeam READ highBeam NOTIFY highBeamChanged)
    Q_PROPERTY(bool lowBeam READ lowBeam NOTIFY lowBeamChanged)
    Q_PROPERTY(bool turnLeft READ turnLeft NOTIFY turnLeftChanged)
    Q_PROPERTY(bool turnRight READ turnRight NOTIFY turnRightChanged)

    // ==== НОВОЕ ====
    Q_PROPERTY(bool checkEngine     READ checkEngine     NOTIFY checkEngineChanged)
    Q_PROPERTY(bool oilPressure     READ oilPressure     NOTIFY oilPressureChanged)
    Q_PROPERTY(bool batteryWarning  READ batteryWarning  NOTIFY batteryWarningChanged)
    Q_PROPERTY(bool absWarning      READ absWarning      NOTIFY absWarningChanged)
    Q_PROPERTY(bool steeringWarning READ steeringWarning NOTIFY steeringWarningChanged)
    Q_PROPERTY(bool escWarning      READ escWarning      NOTIFY escWarningChanged)
    Q_PROPERTY(bool doorsWarning    READ doorsWarning    NOTIFY doorsWarningChanged)
    Q_PROPERTY(bool seatbelt        READ seatbelt        NOTIFY seatbeltChanged)
    Q_PROPERTY(bool handBrake       READ handBrake       NOTIFY handBrakeChanged)
    Q_PROPERTY(bool position READ position NOTIFY positionChanged)
    Q_PROPERTY(bool fogFront READ fogFront NOTIFY fogFrontChanged)
    Q_PROPERTY(bool fogRear  READ fogRear  NOTIFY fogRearChanged)


public:

    explicit CanReceiver(QObject *parent=nullptr);
    ~CanReceiver();

    QString gear() const { return m_gear; }

    double rpm() const { return m_rpm; }
    double speed() const { return m_speed; }
    double coolant() const { return m_coolant; }
    double fuel() const { return m_fuel; }
    double odometer() const { return m_odometer; }

    bool highBeam() const { return m_highBeam; }
    bool lowBeam() const { return m_lowBeam; }
    bool turnLeft() const { return m_turnLeft; }
    bool turnRight() const { return m_turnRight; }

    // ==== НОВОЕ ====
    bool checkEngine() const { return m_checkEngine; }
    bool oilPressure() const { return m_oilPressure; }
    bool batteryWarning() const { return m_batteryWarning; }
    bool absWarning() const { return m_absWarning; }
    bool steeringWarning() const { return m_steeringWarning; }
    bool escWarning() const { return m_escWarning; }
    bool doorsWarning() const { return m_doorsWarning; }
    bool seatbelt() const { return m_seatbelt; }
    bool handBrake() const { return m_handBrake; }
    bool position() const { return m_position; }
    bool fogFront() const { return m_fogFront; }
    bool fogRear()  const { return m_fogRear; }


signals:

    void rpmChanged();
    void speedChanged();
    void coolantChanged();
    void fuelChanged();
    void odometerChanged();
    void gearChanged();

    void highBeamChanged();
    void lowBeamChanged();
    void turnLeftChanged();
    void turnRightChanged();

    // ==== НОВОЕ ====
    void checkEngineChanged();
    void oilPressureChanged();
    void batteryWarningChanged();
    void absWarningChanged();
    void steeringWarningChanged();
    void escWarningChanged();
    void doorsWarningChanged();
    void seatbeltChanged();
    void handBrakeChanged();
    void positionChanged();
    void fogFrontChanged();
    void fogRearChanged();

private:

    void listenPort();
    void processJson(const std::string &line);


    HANDLE hSerial = INVALID_HANDLE_VALUE;

    bool m_running = true;

    std::string m_buffer;

    QString m_gear = "D";

    double m_rpm = 800;
    double m_speed = 0;
    double m_coolant = 20;
    double m_fuel = 0;
    double m_odometer = 0;

    bool m_highBeam = false;
    bool m_lowBeam = false;
    bool m_turnLeft = false;
    bool m_turnRight = false;

    // ==== НОВОЕ ====
    bool m_checkEngine = false;
    bool m_oilPressure = false;
    bool m_batteryWarning = false;
    bool m_absWarning = false;
    bool m_steeringWarning = false;
    bool m_escWarning = false;
    bool m_doorsWarning = false;
    bool m_seatbelt = false;
    bool m_handBrake = false;
    bool m_position = false;
    bool m_fogFront = false;
    bool m_fogRear  = false;
};
