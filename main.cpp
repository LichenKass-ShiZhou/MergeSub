#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <ffmpegthreads.h>
#include <QThread>
#include <QQmlContext>
#include "mergesubtranslation.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    ffmpegThreads FfmpegWorker;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("translator",MergeSubTranslation::getInstance(&engine));
    engine.rootContext()->setContextProperty("FfmpegWorker",&FfmpegWorker);
    qmlRegisterSingletonInstance("FfmpegWorker",1,0,"FfmpegWorker",ffmpegThreads::getInstance());
    const QUrl url(QStringLiteral("qrc:/MergeSub/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
