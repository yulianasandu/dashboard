#pragma once

#include <QObject>
#include <QTimer>

class CarController : public QObject
{
    Q_OBJECT

    // --- Основные показания ---
    Q_PROPERTY(double rpm      READ rpm      NOTIFY rpmChanged)
    Q_PROPERTY(double speed    READ speed    NOTIFY speedChanged)
    Q_PROPERTY(int    gear     READ gear     NOTIFY gearChanged)

    // --- Поворотники и аварийка ---
    Q_PROPERTY(bool leftBlinker  READ leftBlinker  NOTIFY leftBlinkerChanged)
    Q_PROPERTY(bool rightBlinker READ rightBlinker NOTIFY rightBlinkerChanged)
    Q_PROPERTY(bool leftBlinkerOn  READ leftBlinkerOn  NOTIFY leftBlinkerOnChanged)
    Q_PROPERTY(bool rightBlinkerOn READ rightBlinkerOn NOTIFY rightBlinkerOnChanged)

public:
    explicit CarController(QObject *parent = nullptr);

    // Геттеры
    double rpm()      const { return m_rpm; }
    double speed()    const { return m_speed; }
    int    gear()     const { return m_gear; }
    bool   leftBlinker()    const { return m_leftBlinker; }
    bool   rightBlinker()   const { return m_rightBlinker; }
    bool   leftBlinkerOn()  const { return m_leftBlinkerOn; }
    bool   rightBlinkerOn() const { return m_rightBlinkerOn; }

public slots:
    // Вызываются из QML при нажатии клавиш
    void setThrottle(bool pressed);
    void setBrake(bool pressed);
    void toggleLeftBlinker();
    void toggleRightBlinker();
    void toggleHazard();

signals:
    void rpmChanged();
    void speedChanged();
    void gearChanged();
    void leftBlinkerChanged();
    void rightBlinkerChanged();
    void leftBlinkerOnChanged();
    void rightBlinkerOnChanged();

private slots:
    void physicsUpdate();    // 60 FPS — основной цикл
    void blinkerTick();      // 500 мс — мигание

private:
    void updateGear();

    // Таймеры
    QTimer *m_physicsTimer  = nullptr;
    QTimer *m_blinkerTimer  = nullptr;

    // Физика
    double m_rpm   = 800.0;
    double m_speed = 0.0;
    int    m_gear  = 1;
    bool   m_throttle = false;
    bool   m_brake    = false;

    // Состояние поворотников (включён ли режим)
    bool m_leftBlinker  = false;
    bool m_rightBlinker = false;
    bool m_hazard       = false;

    // Текущее мигающее состояние (on/off)
    bool m_leftBlinkerOn  = false;
    bool m_rightBlinkerOn = false;
    bool m_blinkerPhase   = false; // общая фаза мигания

    // Константы физики
    static constexpr double RPM_IDLE     = 800.0;
    static constexpr double RPM_REDLINE  = 6000.0;
    static constexpr double RPM_ACCEL    = 3500.0; // скорость набора оборотов
    static constexpr double RPM_DECEL    = 2000.0;
    static constexpr double MAX_SPEED    = 200.0;
    static constexpr double DT           = 1.0 / 60.0; // шаг времени
};
