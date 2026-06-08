#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <carcontroller.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<CarController>("Automotive.Core", 1, 0, "CarController");

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
