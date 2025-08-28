#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <ffmpeghandel.h>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    ffmpeghandel ffmpeg_handel;
    engine.rootContext()->setContextProperty("ffmpeghandel",&ffmpeg_handel);
    qmlRegisterSingletonInstance("FfmpegHandel",1,0,"FfmpegHandel",ffmpeghandel::getInstance());
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("MergeSub", "Main");

    return app.exec();
}
