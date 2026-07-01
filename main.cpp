#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <carcontroller.h>
#include <canreceiver.h> // 1. Подключаем новый заголовочник

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Регистрируем старый контроллер симуляции
    qmlRegisterType<CarController>("Automotive.Core", 1, 0, "CarController");

    // 2. Регистрируем новый сетевой приемник как Синглтон в том же неймспейсе
    qmlRegisterSingletonType<CanReceiver>("Automotive.Core", 1, 0, "CanReceiver",
                                          [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                              Q_UNUSED(engine)
                                              Q_UNUSED(scriptEngine)
                                              return new CanReceiver();
                                          });

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("dashboard", "Main");

    return app.exec();
}
