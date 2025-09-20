#include "ffmpegthreads.h"
#include <QDebug>
#include <QRegularExpression>
#include <QFile>
#include <QStandardPaths>
#include <QRandomGenerator>


ffmpegThreads::ffmpegThreads(QObject *parent): QObject{parent}
{

    tcpServer = nullptr;
    clientSocket = nullptr;
    socketPort = "0";

    // 使用 Qt::DirectConnection 确保在正确的线程中执行
    connect(&FFMPEG_Process, &QProcess::finished, this, [this]() {
        FFMPEG_Process.close();
    }, Qt::DirectConnection);

    connect(&FFMPEG_Process, &QProcess::readyReadStandardOutput, this, &ffmpegThreads::ffmpeg_Process);
    connect(&FFMPEG_Process, &QProcess::readyReadStandardError, this, &ffmpegThreads::ffmpeg_Process);
}


QObject *ffmpegThreads::getInstance()
{
    static ffmpegThreads * obj = new ffmpegThreads();
    return obj;
}

QString ffmpegThreads::getFfmpeg_Version() const
{
    return ffmpeg_Version;
}

void ffmpegThreads::setFfmpeg_Version(const QString &newFfmpeg_Version)
{
    if (ffmpeg_Version == newFfmpeg_Version)
        return;
    ffmpeg_Version = newFfmpeg_Version;
    emit ffmpeg_VersionChanged();
}

//参数sourceCommand定义;
QString ffmpegThreads::getSourceCommand() const
{
    return sourceCommand;
}

void ffmpegThreads::setSourceCommand(const QString &newSourceCommand)
{
    if (sourceCommand == newSourceCommand)
        return;
    sourceCommand = newSourceCommand;
    emit sourceCommandChanged();
}

QString ffmpegThreads::getVideoFrameRate() const
{
    return videoFrameRate;
}

void ffmpegThreads::setVideoFrameRate(const QString &newVideoFrameRate)
{
    if (videoFrameRate == newVideoFrameRate)
        return;
    videoFrameRate = newVideoFrameRate;
    emit videoFrameRateChanged();
}

QString ffmpegThreads::getSourceMusicCodec() const
{
    return sourceMusicCodec;
}

void ffmpegThreads::setSourceMusicCodec(const QString &newSourceMusicCodec)
{
    if (sourceMusicCodec == newSourceMusicCodec)
        return;
    sourceMusicCodec = newSourceMusicCodec;
    emit sourceMusicCodecChanged();
}

QString ffmpegThreads::getSourceVideoCodec() const
{
    return sourceVideoCodec;
}

void ffmpegThreads::setSourceVideoCodec(const QString &newSourceVideoCodec)
{
    if (sourceVideoCodec == newSourceVideoCodec)
        return;
    sourceVideoCodec = newSourceVideoCodec;
    emit sourceVideoCodecChanged();
}

QString ffmpegThreads::getSourceVideoHeight() const
{
    return sourceVideoHeight;
}

void ffmpegThreads::setSourceVideoHeight(const QString &newSourceVideoHeight)
{
    if (sourceVideoHeight == newSourceVideoHeight)
        return;
    sourceVideoHeight = newSourceVideoHeight;
    emit sourceVideoHeightChanged();
}

QString ffmpegThreads::getSourceVideoWidth() const
{
    return sourceVideoWidth;
}

void ffmpegThreads::setSourceVideoWidth(const QString &newSourceVideoWidth)
{
    if (sourceVideoWidth == newSourceVideoWidth)
        return;
    sourceVideoWidth = newSourceVideoWidth;
    emit sourceVideoWidthChanged();
}

//参数delFileUrl定义;
QString ffmpegThreads::getDelFileUrl() const
{
    return delFileUrl;
}

void ffmpegThreads::setDelFileUrl(const QString &newDelFileUrl)
{
    if (delFileUrl == newDelFileUrl)
        return;
    delFileUrl = newDelFileUrl;
    emit delFileUrlChanged();
}

//参数videoFileUrl定义;
QString ffmpegThreads::getVideoFileUrl() const
{
    return videoFileUrl;
}

void ffmpegThreads::setVideoFileUrl(const QString &newVidepFileUrl)
{
    if (videoFileUrl == newVidepFileUrl)
        return;
    videoFileUrl = newVidepFileUrl;
    emit videoFileUrlChanged();
}

QString ffmpegThreads::getUnusedPort()
{
    // 尝试多个端口，直到找到可用的
    for (int i = 0; i < 10; i++) {
        int port = QRandomGenerator::global()->bounded(10000, 60000);

        // 检查端口是否可用
        QTcpServer testServer;
        if (testServer.listen(QHostAddress::LocalHost, port)) {
            testServer.close();
            setSocketPort(QString::number(port));
            return QString::number(port);
        }
    }

    // 如果找不到可用端口，使用默认值
    qWarning() << "Could not find available port, using default 19083";
    setSocketPort("19083");
    return "19083";
}

QString ffmpegThreads::getSourceCommandPreview() const
{
    return sourceCommandPreview;
}

void ffmpegThreads::setSourceCommandPreview(const QString &newSourceCommandPreview)
{
    if (sourceCommandPreview == newSourceCommandPreview)
        return;
    sourceCommandPreview = newSourceCommandPreview;
    emit sourceCommandPreviewChanged();
}

void ffmpegThreads::mergesubMessage(const QString &title, const QString &body, const QString &icon, int timeout)
{
    QDBusConnection mergeSub = QDBusConnection::sessionBus();
    if(!mergeSub.isConnected()){
        qWarning() << "无法连接到D-Bus会话总线："<< mergeSub.lastError().message();
    }

    mergeSub_Message = QDBusMessage::createMethodCall(
        "org.freedesktop.Notifications",
        "/org/freedesktop/Notifications",
        "org.freedesktop.Notifications",
        "Notify"
        );
    QString appName = "MergeSub";
    uint replacesId = 0;
    QVariantMap hints;
    QStringList actions;
    mergeSub_Message << appName
                     << replacesId
                     << icon
                     << title
                     << body
                     << actions
                     << hints
                     << timeout;

    QDBusMessage reply = mergeSub.call(mergeSub_Message);

    if (reply.type() == QDBusMessage::ErrorMessage) {
        qWarning() << "D-Bus 调用失败:" << reply.errorName() << reply.errorMessage();
    }

    // 处理返回值（通知ID），如果需要的话
    if (reply.arguments().count() > 0) {
        quint32 notificationId = reply.arguments().at(0).toUInt();
        qDebug() << "通知发送成功，ID:" << notificationId;
    } else {
        qDebug() << "通知发送成功（未返回ID）。";
    }
}


bool ffmpegThreads::startTcpServer()
{
    if (tcpServer) {
        tcpServer->close();
        delete tcpServer;
        tcpServer = nullptr;
    }

    tcpServer = new QTcpServer(this);

    // 连接新连接信号
    connect(tcpServer, &QTcpServer::newConnection, this, &ffmpegThreads::onNewConnection);

    // 尝试监听指定端口
    if (!tcpServer->listen(QHostAddress::LocalHost, socketPort.toInt())) {
        QString error = tcpServer->errorString();
        qDebug() << "Failed to start TCP server on port" << socketPort << ":" << error;
        emit tcpServerStarted(false, error);

        // 尝试使用备用端口
        if (socketPort != "19083") {
            qDebug() << "Trying fallback port 19083";
            setSocketPort("19083");
            return startTcpServer();
        }

        return false;
    }

    qDebug() << "TCP server started on port:" << socketPort;
    emit tcpServerStarted(true);
    return true;
}

QString ffmpegThreads::getVideo_Current_Duration() const
{
    return video_Current_Duration;
}

void ffmpegThreads::setVideo_Current_Duration(const QString &newVideo_Current_Duration)
{
    if (video_Current_Duration == newVideo_Current_Duration)
        return;
    video_Current_Duration = newVideo_Current_Duration;
    emit video_Current_DurationChanged();
}

void ffmpegThreads::onNewConnection()
{
    if (clientSocket) {
        // 已有连接，拒绝新连接
        QTcpSocket *newSocket = tcpServer->nextPendingConnection();
        newSocket->close();
        newSocket->deleteLater();
        return;
    }

    clientSocket = tcpServer->nextPendingConnection();
    connect(clientSocket, &QTcpSocket::disconnected, this, &ffmpegThreads::onClientDisconnected);

    qDebug() << "Client connected to TCP server";
    emit clientConnected();

    // 立即开始读取和转发FFmpeg输出（如果FFmpeg已经在运行）
    if (FFMPEG_Process.state() == QProcess::Running) {
        // 读取并发送所有已缓冲的输出
        QByteArray data = FFMPEG_Process.readAllStandardOutput();
        if (!data.isEmpty() && clientSocket->state() == QAbstractSocket::ConnectedState) {
            clientSocket->write(data);
            clientSocket->flush();
        }

        data = FFMPEG_Process.readAllStandardError();
        if (!data.isEmpty() && clientSocket->state() == QAbstractSocket::ConnectedState) {
            clientSocket->write(data);
            clientSocket->flush();
        }
    }
}
void ffmpegThreads::onClientDisconnected()
{
    if (clientSocket) {
        clientSocket->deleteLater();
        clientSocket = nullptr;
        qDebug() << "Client disconnected from TCP server";
        emit clientDisconnected();
    }

}

QString ffmpegThreads::getSocketPort() const
{
    return socketPort;
}

void ffmpegThreads::setSocketPort(const QString newSocketPort)
{
    if (socketPort == newSocketPort)
        return;
    socketPort = newSocketPort;
    emit socketPortChanged();
}



// 修改预览编码方法
void ffmpegThreads::on_Encoding_Preview()
{
    // 先启动TCP服务器
    if (!startTcpServer()) {
        qDebug() << "Failed to start TCP server";
        return;
    }

    // 设置FFmpeg命令
    qprocess_Program_Name = "ffmpeg";
    qprocess_Command_Name = sourceCommandPreview;

    if (FFMPEG_Process_Preview.state() == QProcess::Running) {
        FFMPEG_Process_Preview.terminate();
        if (!FFMPEG_Process_Preview.waitForFinished(1000)) {
            FFMPEG_Process_Preview.kill();
        }
    }

    // 启动FFmpeg进程
    FFMPEG_Process_Preview.start(qprocess_Program_Name, QProcess::splitCommand(qprocess_Command_Name));

    if (!FFMPEG_Process_Preview.waitForStarted()) {
        qDebug() << "Failed to start FFmpeg process";
        return;
    }

    qDebug() << "FFmpeg preview process started";

    // 连接FFmpeg输出到TCP客户端
    connect(&FFMPEG_Process_Preview, &QProcess::readyReadStandardOutput, [this]() {
        if (clientSocket && clientSocket->state() == QAbstractSocket::ConnectedState) {
            QByteArray data = FFMPEG_Process_Preview.readAllStandardOutput();
            clientSocket->write(data);
            clientSocket->flush();
        }
    });

    connect(&FFMPEG_Process_Preview, &QProcess::readyReadStandardError, [this]() {
        if (clientSocket && clientSocket->state() == QAbstractSocket::ConnectedState) {
            QByteArray data = FFMPEG_Process_Preview.readAllStandardError();
            clientSocket->write(data);
            clientSocket->flush();
        }

        // 记录错误信息
        QString errorOutput = QString::fromUtf8(FFMPEG_Process_Preview.readAllStandardError());
        qDebug() << "FFmpeg error:" << errorOutput;;
        QRegularExpression timeRegex("time=(\\d{2}:\\d{2}:\\d{2}\\.\\d+)");
        QRegularExpressionMatch match = timeRegex.match(errorOutput);
        if (match.hasMatch()) {
            setVideo_Current_Duration(match.captured(1));
        }
    });

    // 处理进程结束
    connect(&FFMPEG_Process_Preview, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            [this](int exitCode, QProcess::ExitStatus exitStatus) {
                qDebug() << "FFmpeg preview process finished with code:" << exitCode;
                if (exitCode != 0) {
                    qDebug() << FFMPEG_Process_Preview.exitStatus();
                    qDebug() << "FFmpeg preview process exited with error";
                }
            });
    qDebug() << FFMPEG_Process_Preview.state();
    qDebug() << sourceCommandPreview;
}
//调用本机ffmpeg执行信号,方便其他不同信号调用
void ffmpegThreads::ffmpeg_Process()
{

    if (QThread::currentThread() != this->thread()) {
        // 如果不在主线程，使用 QMetaObject::invokeMethod 切换到主线程
        QMetaObject::invokeMethod(this, "ffmpeg_Process", Qt::QueuedConnection);
        return;
    }

    FFMPEG_Process.start(qprocess_Program_Name,QProcess::splitCommand(qprocess_Command_Name));
    QByteArray output = FFMPEG_Process.readAllStandardOutput();
    QByteArray outputerror = FFMPEG_Process.readAllStandardError();
    QString content;

    if(qprocess_Program_Name == "ffmpeg" && qprocess_Command_Name == sourceCommand){
        content = QString::fromUtf8(outputerror);
        setLogMessage(content);
        qDebug() << content;
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
    else if(qprocess_Program_Name == "ffprobe" && qprocess_Command_Name == videoFileUrl){
        content = QString::fromUtf8(outputerror);
        qDebug() << "Video info:" << content;
        QRegularExpression durationRegex("Duration: (\\d{2}:\\d{2}:\\d{2}\\.\\d+)");
        QRegularExpression videoSizeRegex("Video:.*?, (\\d+)x(\\d+)");
        QRegularExpression videoCodecRegex("Video: ([^,]+)");
        QRegularExpression audioCodecRegex("Audio: ([^,]+)");
        QRegularExpression fpsRegex("\\b(\\d+(?:\\.\\d+)?)\\s?(?:fps|tbr)\\b");

        QRegularExpressionMatch match = durationRegex.match(content);
        if (match.hasMatch()) {
            setVideo_Total_Duration(match.captured(1));
        }
        QRegularExpressionMatch sizeMatch = videoSizeRegex.match(content);
        if (sizeMatch.hasMatch()) {
            setSourceVideoWidth(sizeMatch.captured(1));
            setSourceVideoHeight(sizeMatch.captured(2));
            qDebug() << "Video size:" << sourceVideoWidth << "x" << sourceVideoHeight;
        }

        QRegularExpressionMatch fpsMatch = fpsRegex.match(content);
        if (fpsMatch.hasMatch()) {
            QString fpsValue = fpsMatch.captured(1);
            setVideoFrameRate(fpsValue);
            qDebug() << "Video FPS:" << fpsValue;
        }

        QRegularExpressionMatch videoCodecMatch = videoCodecRegex.match(content);
        if (videoCodecMatch.hasMatch()) {
            QString rawVideoCodec = videoCodecMatch.captured(1);
            qDebug() << "Raw video codec:" << rawVideoCodec;

            // 提取基础编码名称（去除括号中的内容）
            QString baseCodec = rawVideoCodec.split(' ').first().toLower();

            // 定义视频编码映射表
            static QMap<QString, QString> videoCodecMap = {
                {"h264", "libx264"},
                {"h265", "libx265"},
                {"hevc", "libx265"},
                {"vp9", "libvpx-vp9"},
                {"av1", "libaom-av1"},
                {"mpeg4", "mpeg4"},
                {"mpeg2", "mpeg2video"},
                {"mjpeg", "mjpeg"},
                {"prores", "prores"},
                {"dnxhd", "dnxhd"}
            };

            // 查找映射
            if (videoCodecMap.contains(baseCodec)) {
                setSourceVideoCodec(videoCodecMap.value(baseCodec));
            } else {
                // 如果没有找到映射，使用原始编码名称
                setSourceVideoCodec(baseCodec);
            }

            qDebug() << "Mapped video codec:" << sourceVideoCodec;
        }

        // 获取音频编码并进行映射
        QRegularExpressionMatch audioCodecMatch = audioCodecRegex.match(content);
        if (audioCodecMatch.hasMatch()) {
            QString rawAudioCodec = audioCodecMatch.captured(1);
            qDebug() << "Raw audio codec:" << rawAudioCodec;

            // 提取基础编码名称（去除括号中的内容）
            QString baseCodec = rawAudioCodec.split(' ').first().toLower();

            // 定义音频编码映射表
            static QMap<QString, QString> audioCodecMap = {
                {"aac", "aac"},
                {"mp3", "libmp3lame"},
                {"ac3", "ac3"},
                {"flac", "flac"},
                {"opus", "libopus"},
                {"vorbis", "libvorbis"},
                {"pcm", "pcm_s16le"}
            };

            // 查找映射
            if (audioCodecMap.contains(baseCodec)) {
                sourceMusicCodec = audioCodecMap.value(baseCodec);
            } else {
                sourceMusicCodec = baseCodec;
            }

            qDebug() << "Mapped audio codec:" << sourceMusicCodec;
        }
    }
    else{
        content = QString::fromUtf8(outputerror);
    }
}

//程序启动时获取ffmpeg版本号
void ffmpegThreads::check_Ffmpeg_Version()
{
    qprocess_Program_Name = "ffmpeg";
    qprocess_Command_Name = "-version";
    ffmpegThreads::ffmpeg_Process();
}

//点击开始压制按钮后执行信号on_Start_Encoding()
void ffmpegThreads::on_Start_Encoding()
{
    qprocess_Program_Name = "ffmpeg";
    qprocess_Command_Name = sourceCommand;
    ffmpegThreads::ffmpeg_Process();
}

//点击取消按钮后执行信号on_Cancel_Encoding()
void ffmpegThreads::on_Cancel_Encoding()
{
    if (FFMPEG_Process.state() == QProcess::Running) {
        FFMPEG_Process.terminate();
        if (!FFMPEG_Process.waitForFinished(1000)) {
            FFMPEG_Process.kill();
        }
    }
    QFile::remove(delFileUrl.replace('"', ""));
}
void ffmpegThreads::on_Cancel_Encoding_Preview()
{
    if (FFMPEG_Process_Preview.state() == QProcess::Running) {
        FFMPEG_Process_Preview.terminate();
        if (!FFMPEG_Process_Preview.waitForFinished(1000)) {
            FFMPEG_Process_Preview.kill();
        }
    }

    if (tcpServer) {
        tcpServer->close();
        delete tcpServer;
        tcpServer = nullptr;
    }

    if (clientSocket) {
        clientSocket->close();
        clientSocket->deleteLater();
        clientSocket = nullptr;
    }
}

//选择视频文件后执行信号get_Video_Info()
void ffmpegThreads::get_Video_Info()
{
    qprocess_Program_Name = "ffprobe";
    qprocess_Command_Name = videoFileUrl;
    ffmpegThreads::ffmpeg_Process();
}



QString ffmpegThreads::getVideo_Total_Duration() const
{
    return video_Total_Duration;
}

void ffmpegThreads::setVideo_Total_Duration(const QString &newVideo_Total_Duration)
{
    if (video_Total_Duration == newVideo_Total_Duration)
        return;
    video_Total_Duration = newVideo_Total_Duration;
    emit video_Total_DurationChanged();
}

QString ffmpegThreads::getVideo_Duration() const
{
    return video_Duration;
}

void ffmpegThreads::setVideo_Duration(const QString &newVideo_Duration)
{
    if (video_Duration == newVideo_Duration)
        return;
    video_Duration = newVideo_Duration;
    emit video_DurationChanged();
}

QString ffmpegThreads::getLogMessage() const
{
    return logMessage;
}

void ffmpegThreads::setLogMessage(const QString &newLogMessage)
{
    if (logMessage == newLogMessage)
        return;
    logMessage = newLogMessage;
    emit logMessageChanged();
}

