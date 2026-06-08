#include "carcontroller.h"
#include <QtMath>

CarController::CarController(QObject *parent)
    : QObject(parent)
{
    // --- Таймер физики: 60 FPS ---
    m_physicsTimer = new QTimer(this);
    m_physicsTimer->setInterval(static_cast<int>(DT * 1000)); // ~16 мс
    connect(m_physicsTimer, &QTimer::timeout, this, &CarController::physicsUpdate);
    m_physicsTimer->start();

    // --- Таймер мигания: 500 мс ---
    m_blinkerTimer = new QTimer(this);
    m_blinkerTimer->setInterval(500);
    connect(m_blinkerTimer, &QTimer::timeout, this, &CarController::blinkerTick);
    m_blinkerTimer->start();
}

// ─────────────────────────────────────────────────────────────
//  СЛОТЫ — управление из QML
// ─────────────────────────────────────────────────────────────

void CarController::setThrottle(bool pressed)
{
    m_throttle = pressed;
}

void CarController::setBrake(bool pressed)
{
    m_brake = pressed;
}

void CarController::toggleLeftBlinker()
{
    // Аварийка имеет приоритет — игнорируем одиночные поворотники
    if (m_hazard) return;

    m_leftBlinker = !m_leftBlinker;
    if (m_leftBlinker) m_rightBlinker = false; // взаимное исключение

    emit leftBlinkerChanged();
    emit rightBlinkerChanged();
}

void CarController::toggleRightBlinker()
{
    if (m_hazard) return;

    m_rightBlinker = !m_rightBlinker;
    if (m_rightBlinker) m_leftBlinker = false;

    emit leftBlinkerChanged();
    emit rightBlinkerChanged();
}

void CarController::toggleHazard()
{
    m_hazard = !m_hazard;

    if (m_hazard) {
        // Включить оба, выключить одиночные
        m_leftBlinker  = true;
        m_rightBlinker = true;
    } else {
        // Выключить всё
        m_leftBlinker  = false;
        m_rightBlinker = false;
        m_leftBlinkerOn  = false;
        m_rightBlinkerOn = false;
        emit leftBlinkerOnChanged();
        emit rightBlinkerOnChanged();
    }

    emit leftBlinkerChanged();
    emit rightBlinkerChanged();
}

// ─────────────────────────────────────────────────────────────
//  ОСНОВНОЙ ФИЗИЧЕСКИЙ ТИК (60 FPS)
// ─────────────────────────────────────────────────────────────

void CarController::physicsUpdate()
{
    const double prevRpm   = m_rpm;
    const double prevSpeed = m_speed;
    const int    prevGear  = m_gear;

    // 1. Обороты
    if (m_throttle && !m_brake) {
        m_rpm += RPM_ACCEL * DT;
    } else if (m_brake) {
        m_rpm -= RPM_DECEL * 2.0 * DT;
    } else {
        // Накат: медленно падаем к холостым
        m_rpm -= RPM_DECEL * DT;
    }

    // Отсечка (redline)
    m_rpm = qBound(RPM_IDLE, m_rpm, RPM_REDLINE);

    // 2. Передача
    updateGear();

    // 3. Скорость — зависит от оборотов и передачи
    //    Каждая следующая передача даёт меньшую тягу, но выше максимум
    const double gearRatio[6] = {0, 0.28, 0.52, 0.72, 0.86, 1.0};
    double targetSpeed = (m_rpm / RPM_REDLINE) * MAX_SPEED * gearRatio[m_gear];

    if (m_brake) {
        // Торможение — быстрее снижаем скорость
        m_speed -= 40.0 * DT;
    } else {
        // Плавное сближение с целевой скоростью
        double diff = targetSpeed - m_speed;
        m_speed += diff * 2.5 * DT;
    }

    m_speed = qBound(0.0, m_speed, MAX_SPEED);

    // 4. Эмитим изменения только если значения реально изменились
    if (!qFuzzyCompare(m_rpm, prevRpm))     emit rpmChanged();
    if (!qFuzzyCompare(m_speed, prevSpeed)) emit speedChanged();
    if (m_gear != prevGear)                 emit gearChanged();
}

// ─────────────────────────────────────────────────────────────
//  АВТОМАТИЧЕСКАЯ КОРОБКА ПЕРЕДАЧ
// ─────────────────────────────────────────────────────────────

void CarController::updateGear()
{
    // Пороги переключения: [вверх, вниз] в об/мин для каждой передачи
    struct GearThreshold { double upshift; double downshift; };
    const GearThreshold thresholds[6] = {
        {0,      0},       // 0 — не используется
        {3000,   0},       // 1 → 2
        {3200,   1200},    // 2 → 3 / 2 → 1
        {3400,   1300},    // 3 → 4 / 3 → 2
        {3600,   1400},    // 4 → 5 / 4 → 3
        {RPM_REDLINE, 1500}// 5 — максимум
    };

    int newGear = m_gear;

    if (m_gear < 5 && m_rpm >= thresholds[m_gear].upshift) {
        newGear = m_gear + 1;
    } else if (m_gear > 1 && m_rpm <= thresholds[m_gear].downshift) {
        newGear = m_gear - 1;
    }

    m_gear = newGear;
}

// ─────────────────────────────────────────────────────────────
//  ТИК ПОВОРОТНИКОВ (500 мс)
// ─────────────────────────────────────────────────────────────

void CarController::blinkerTick()
{
    m_blinkerPhase = !m_blinkerPhase;

    bool newLeft  = m_leftBlinker  ? m_blinkerPhase : false;
    bool newRight = m_rightBlinker ? m_blinkerPhase : false;

    if (newLeft != m_leftBlinkerOn) {
        m_leftBlinkerOn = newLeft;
        emit leftBlinkerOnChanged();
    }
    if (newRight != m_rightBlinkerOn) {
        m_rightBlinkerOn = newRight;
        emit rightBlinkerOnChanged();
    }
}
