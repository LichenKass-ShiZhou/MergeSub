#include "mergesubtranslation.h"
#include <QCoreApplication>
#include <QQmlEngine>

MergeSubTranslation *MergeSubTranslation::getInstance(QQmlEngine *engine)
{
    static MergeSubTranslation obj(engine);
    return &obj;
}

void MergeSubTranslation::mergesub_load(int index)
{
    if(index == 0){
        if (!mergesub_translator->load(":/Languages/MergeSub_zh_CN.qm")) {
            qWarning() << "Failed to load translation file: MergeSub_en_US.qm";
        }
    } else {
        if (!mergesub_translator->load(":/Languages/MergeSub_en_US.qm")) {
            qWarning() << "Failed to load translation file: MergeSub_en_US.qm";
        }
    }
    mergesub_engine->retranslate();
}

MergeSubTranslation::MergeSubTranslation(QQmlEngine *engine)
{
    mergesub_translator = new QTranslator();
    mergesub_engine = engine;
    QCoreApplication::installTranslator(mergesub_translator);
}
