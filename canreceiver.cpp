#include "canreceiver.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QThread>

CanReceiver::CanReceiver(QObject *parent)
    : QObject(parent)
{
    QThread *thread = QThread::create([this]()
                                      {
                                          listenPort();
                                      });
    thread->start();
}

CanReceiver::~CanReceiver()
{
    m_running=false;
    if(hSerial != INVALID_HANDLE_VALUE)
        CloseHandle(hSerial);
}

void CanReceiver::listenPort()
{
    std::string port="\\\\.\\COM5";
    hSerial = CreateFileA(
        port.c_str(),
        GENERIC_READ,
        0,
        NULL,
        OPEN_EXISTING,
        0,
        NULL);
    if(hSerial==INVALID_HANDLE_VALUE)
    {
        qWarning()<<"ESP32 не найдена";
        return;
    }
    DCB dcb={0};
    dcb.DCBlength=sizeof(dcb);
    GetCommState(hSerial,&dcb);
    dcb.BaudRate=CBR_115200;
    dcb.ByteSize=8;
    dcb.StopBits=ONESTOPBIT;
    dcb.Parity=NOPARITY;
    SetCommState(hSerial,&dcb);
    char buffer[256];
    DWORD read;
    while(m_running)
    {
        if(ReadFile(
                hSerial,
                buffer,
                sizeof(buffer)-1,
                &read,
                NULL)
            &&
            read>0)
        {
            buffer[read]=0;
            m_buffer+=buffer;
            size_t pos;
            while((pos=m_buffer.find('\n'))!=std::string::npos)
            {
                std::string line=
                    m_buffer.substr(0,pos);
                m_buffer.erase(0,pos+1);
                processJson(line);
            }
        }
        Sleep(10);
    }
}

void CanReceiver::processJson(const std::string &line)
{
    QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(line));

    if (!doc.isObject())
        return;

    QJsonObject obj = doc.object();

    if (obj.contains("rpm")) {
        double v = obj["rpm"].toDouble();
        if (v != m_rpm) { m_rpm = v; emit rpmChanged(); }
    }
    if (obj.contains("speed")) {
        double v = obj["speed"].toDouble();
        if (v != m_speed) { m_speed = v; emit speedChanged(); }
    }
    if (obj.contains("coolant")) {
        double v = obj["coolant"].toDouble();
        if (v != m_coolant) { m_coolant = v; emit coolantChanged(); }
    }
    if (obj.contains("fuel")) {
        double v = obj["fuel"].toDouble();
        if (v != m_fuel) { m_fuel = v; emit fuelChanged(); }
    }

    if (obj.contains("highBeam")) {
        bool v = obj["highBeam"].toInt() != 0;
        if (v != m_highBeam) { m_highBeam = v; emit highBeamChanged(); }
    }
    if (obj.contains("lowBeam")) {
        bool v = obj["lowBeam"].toInt() != 0;
        if (v != m_lowBeam) { m_lowBeam = v; emit lowBeamChanged(); }
    }
    if (obj.contains("turnLeft")) {
        bool v = obj["turnLeft"].toInt() != 0;
        if (v != m_turnLeft) { m_turnLeft = v; emit turnLeftChanged(); }
    }
    if (obj.contains("turnRight")) {
        bool v = obj["turnRight"].toInt() != 0;
        if (v != m_turnRight) { m_turnRight = v; emit turnRightChanged(); }
    }

    if (obj.contains("checkEngine")) {
        bool v = obj["checkEngine"].toInt() != 0;
        if (v != m_checkEngine) { m_checkEngine = v; emit checkEngineChanged(); }
    }
    if (obj.contains("oilPressure")) {
        bool v = obj["oilPressure"].toInt() != 0;
        if (v != m_oilPressure) { m_oilPressure = v; emit oilPressureChanged(); }
    }
    if (obj.contains("batteryWarning")) {
        bool v = obj["batteryWarning"].toInt() != 0;
        if (v != m_batteryWarning) { m_batteryWarning = v; emit batteryWarningChanged(); }
    }
    if (obj.contains("absWarning")) {
        bool v = obj["absWarning"].toInt() != 0;
        if (v != m_absWarning) { m_absWarning = v; emit absWarningChanged(); }
    }
    if (obj.contains("steeringWarning")) {
        bool v = obj["steeringWarning"].toInt() != 0;
        if (v != m_steeringWarning) { m_steeringWarning = v; emit steeringWarningChanged(); }
    }
    if (obj.contains("escWarning")) {
        bool v = obj["escWarning"].toInt() != 0;
        if (v != m_escWarning) { m_escWarning = v; emit escWarningChanged(); }
    }
    if (obj.contains("doorsWarning")) {
        bool v = obj["doorsWarning"].toInt() != 0;
        if (v != m_doorsWarning) { m_doorsWarning = v; emit doorsWarningChanged(); }
    }
    if (obj.contains("seatbelt")) {
        bool v = obj["seatbelt"].toInt() != 0;
        if (v != m_seatbelt) { m_seatbelt = v; emit seatbeltChanged(); }
    }
    if (obj.contains("handBrake")) {
        bool v = obj["handBrake"].toInt() != 0;
        if (v != m_handBrake) { m_handBrake = v; emit handBrakeChanged(); }
    }
    if (obj.contains("position")) {
        bool v = obj["position"].toInt() != 0;
        if (v != m_position) { m_position = v; emit positionChanged(); }
    }
    if (obj.contains("fogFront")) {
        bool v = obj["fogFront"].toInt() != 0;
        if (v != m_fogFront) { m_fogFront = v; emit fogFrontChanged(); }
    }
    if (obj.contains("fogRear")) {
        bool v = obj["fogRear"].toInt() != 0;
        if (v != m_fogRear) { m_fogRear = v; emit fogRearChanged(); }
    }
    if (obj.contains("odometer")) {
        double v = obj["odometer"].toDouble();
        if (v != m_odometer) { m_odometer = v; emit odometerChanged(); }
    }
    if (obj.contains("gear")) {
        QString v = obj["gear"].toString();
        if (v != m_gear) { m_gear = v; emit gearChanged(); }
    }
}
