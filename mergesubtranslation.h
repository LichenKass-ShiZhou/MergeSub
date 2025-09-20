#ifndef MERGESUBTRANSLATION_H
#define MERGESUBTRANSLATION_H

#include <QObject>
#include <QTranslator>
#include <QQmlEngine>

class MergeSubTranslation : public QObject
{
    Q_OBJECT

public:
    static MergeSubTranslation* getInstance(QQmlEngine *engine);
    Q_INVOKABLE void mergesub_load(int index);
private:
    explicit MergeSubTranslation(QQmlEngine *engine);
    QTranslator * mergesub_translator;
    QQmlEngine * mergesub_engine;
signals:
};

#endif // MERGESUBTRANSLATION_H
