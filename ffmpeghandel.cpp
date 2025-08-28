#include "ffmpeghandel.h"
#include <QProcess>
#include <QDebug>
#include <QRegularExpression>
#include <QFile>
#include <QTextBlock>
#include <QSystemTrayIcon>

ffmpeghandel::ffmpeghandel(QObject* parent) : QObject(parent) {
    connect(&ffmpeg_process, &QProcess::finished, [this]() {
        ffmpeg_process.close();
    });
    connect(&ffmpeg_process,SIGNAL(readyReadStandardOutput()),this,SLOT(ffmpeg_Process()));
    connect(&ffmpeg_process,SIGNAL(readyReadStandardError()),this,SLOT(ffmpeg_Process()));
}

QObject *ffmpeghandel::getInstance()
{
    static ffmpeghandel * obj = new ffmpeghandel();
    return obj;
}

//参数sourceCommand定义;
QString ffmpeghandel::getSourceCommand() const
{
    return sourceCommand;
}

void ffmpeghandel::setSourceCommand(const QString &newSourceCommand)
{
    if (sourceCommand == newSourceCommand)
        return;
    sourceCommand = newSourceCommand;
    emit sourceCommandChanged();
}

//参数delFileUrl定义;
QString ffmpeghandel::getDelFileUrl() const
{
    return delFileUrl;
}

void ffmpeghandel::setDelFileUrl(const QString &newDelFileUrl)
{
    if (delFileUrl == newDelFileUrl)
        return;
    delFileUrl = newDelFileUrl;
    emit delFileUrlChanged();
}

//参数videoFileUrl定义;
QString ffmpeghandel::getVideoFileUrl() const
{
    return videoFileUrl;
}

void ffmpeghandel::setVideoFileUrl(const QString &newVidepFileUrl)
{
    if (videoFileUrl == newVidepFileUrl)
        return;
    videoFileUrl = newVidepFileUrl;
    emit videoFileUrlChanged();
}

QString ffmpeghandel::getFfmpeg_Version() const
{
    return ffmpeg_Version;
}

void ffmpeghandel::setFfmpeg_Version(const QString &newFfmpeg_Version)
{
    if (ffmpeg_Version == newFfmpeg_Version)
        return;
    ffmpeg_Version = newFfmpeg_Version;
    emit ffmpeg_VersionChanged();
}


//调用本机ffmpeg执行信号,方便其他不同信号调用
void ffmpeghandel::ffmpeg_Process()
{
    ffmpeg_process.start(qprocess_Program_Name,QProcess::splitCommand(qprocess_Command_Name));
    QByteArray output = ffmpeg_process.readAllStandardOutput();
    QByteArray outputerror = ffmpeg_process.readAllStandardError();
    QString content;

    if(qprocess_Program_Name == "ffmpeg" && qprocess_Command_Name == sourceCommand){
        content = QString::fromUtf8(outputerror);
        setLogMessage(content);
        QRegularExpression timeRegex("time=(\\d{2}:\\d{2}:\\d{2}\\.\\d+)");
        QRegularExpressionMatch match = timeRegex.match(content);
        if (match.hasMatch()) {
            setVideo_Duration(match.captured(1));

        }
    }
    else if(qprocess_Program_Name == "ffmpeg" && qprocess_Command_Name == "-version"){
        content = QString::fromUtf8(output);
        QRegularExpression versionRegex("(\\d+\\.\\d+(\\.\\d+)?(\\.\\d+)?)");
        QRegularExpressionMatch match = versionRegex.match(content);
        if (match.hasMatch()) {
            setFfmpeg_Version(match.captured(1));
        }
    }
    else{
        content = QString::fromUtf8(outputerror);
        QRegularExpression durationRegex("Duration: (\\d{2}:\\d{2}:\\d{2}\\.\\d+)");
        QRegularExpressionMatch match = durationRegex.match(content);
        if (match.hasMatch()) {
            setVideo_Total_Duration(match.captured(1));
        }
    }
}

//程序启动时获取ffmpeg版本号
void ffmpeghandel::check_Ffmpeg_Version()
{
    qprocess_Program_Name = "ffmpeg";
    qprocess_Command_Name = "-version";
    ffmpeghandel::ffmpeg_Process();

}

//点击开始压制按钮后执行信号on_Start_Encoding()
void ffmpeghandel::on_Start_Encoding()
{
    qprocess_Program_Name = "ffmpeg";
    qprocess_Command_Name = sourceCommand;
    ffmpeghandel::ffmpeg_Process();
}

//点击取消按钮后执行信号on_Cancel_Encoding()
void ffmpeghandel::on_Cancel_Encoding()
{
    if (ffmpeg_process.state() == QProcess::Running) {
        ffmpeg_process.terminate();
        if (!ffmpeg_process.waitForFinished(1000)) {
            ffmpeg_process.kill();
        }
    }
    QFile::remove(delFileUrl.replace('"', ""));
}

//选择视频文件后执行信号get_Video_Info()
void ffmpeghandel::get_Video_Info()
{
    qprocess_Program_Name = "ffprobe";
    qprocess_Command_Name = videoFileUrl;
    ffmpeghandel::ffmpeg_Process();
}


QString ffmpeghandel::getVideo_Total_Duration() const
{
    return video_Total_Duration;
}

void ffmpeghandel::setVideo_Total_Duration(const QString &newVideo_Total_Duration)
{
    if (video_Total_Duration == newVideo_Total_Duration)
        return;
    video_Total_Duration = newVideo_Total_Duration;
    emit video_Total_DurationChanged();
}

QString ffmpeghandel::getVideo_Duration() const
{
    return video_Duration;
}

void ffmpeghandel::setVideo_Duration(const QString &newVideo_Duration)
{
    if (video_Duration == newVideo_Duration)
        return;
    video_Duration = newVideo_Duration;
    emit video_DurationChanged();
}

QString ffmpeghandel::getLogMessage() const
{
    return logMessage;
}

void ffmpeghandel::setLogMessage(const QString &newLogMessage)
{
    if (logMessage == newLogMessage)
        return;
    logMessage = newLogMessage;
    emit logMessageChanged();
}



