#ifndef FFMPEGTHREADS_H
#define FFMPEGTHREADS_H

#include <QObject>
#include <QProcess>
#include <QThread>
#include <QTcpServer>
#include <QtDBus>
#include <QTcpSocket>
#include <QHostAddress>


class ffmpegThreads : public QObject
{
    Q_OBJECT

public:
    explicit ffmpegThreads(QObject *parent = nullptr);
    static QObject * getInstance();

    Q_INVOKABLE QString ffmpeg_Version;

    Q_INVOKABLE QString sourceCommand;
    QString getSourceCommand() const;
    void setSourceCommand(const QString &newSourceCommand);

    Q_INVOKABLE QString delFileUrl;
    Q_INVOKABLE QString sourceVideoWidth;
    Q_INVOKABLE QString sourceVideoHeight;
    Q_INVOKABLE QString sourceVideoCodec;
    Q_INVOKABLE QString sourceMusicCodec;
    Q_INVOKABLE QString videoFrameRate;
    QString getDelFileUrl() const;
    void setDelFileUrl(const QString &newDelFileUrl);

    Q_INVOKABLE QString videoFileUrl;
    QString getVideoFileUrl() const;
    void setVideoFileUrl(const QString &newVidepFileUrl);


    Q_INVOKABLE QString sourceCommandPreview;
    Q_INVOKABLE QString getUnusedPort();

    QString getSocketPort() const;
    void setSocketPort(const QString newSocketPort);


    QString getLogMessage() const;
    void setLogMessage(const QString &newLogMessage);

    QString getVideo_Duration() const;
    void setVideo_Duration(const QString &newVideo_Duration);

    QString getVideo_Total_Duration() const;
    void setVideo_Total_Duration(const QString &newVideo_Total_Duration);


    QString getSourceCommandPreview() const;
    void setSourceCommandPreview(const QString &newSourceCommandPreview);


    QString getFfmpeg_Version() const;
    void setFfmpeg_Version(const QString &newFfmpeg_Version);


    QString getVideo_Current_Duration() const;
    void setVideo_Current_Duration(const QString &newVideo_Current_Duration);

    QString getSourceVideoWidth() const;
    void setSourceVideoWidth(const QString &newSourceVideoWidth);

    QString getSourceVideoHeight() const;
    void setSourceVideoHeight(const QString &newSourceVideoHeight);

    QString getSourceVideoCodec() const;
    void setSourceVideoCodec(const QString &newSourceVideoCodec);

    QString getSourceMusicCodec() const;
    void setSourceMusicCodec(const QString &newSourceMusicCodec);

    QString getVideoFrameRate() const;
    void setVideoFrameRate(const QString &newVideoFrameRate);

public slots:
    void ffmpeg_Process();
    void check_Ffmpeg_Version();
    void on_Start_Encoding();
    void on_Cancel_Encoding();
    void on_Cancel_Encoding_Preview();
    void on_Encoding_Preview();
    void get_Video_Info();
    void mergesubMessage(const QString &title, const QString &body, const QString &icon = "", int timeout = -1);
    Q_INVOKABLE bool startTcpServer();


signals:
    void sourceCommandChanged();
    void delFileUrlChanged();
    void videoFileUrlChanged();
    void ffmpeg_VersionChanged();
    void logMessageChanged();
    void video_DurationChanged();
    void video_Total_DurationChanged();
    void sourceCommandPreviewChanged();
    void socketPortChanged();
    void tcpServerStarted(bool success, QString error = "");
    void clientConnected();
    void clientDisconnected();

    void video_Current_DurationChanged();

    void sourceVideoWidthChanged();

    void sourceVideoHeightChanged();

    void sourceVideoCodecChanged();

    void sourceMusicCodecChanged();

    void videoFrameRateChanged();

private:
    QThread ffmpegThread;
    QProcess FFMPEG_Process;
    QProcess FFMPEG_Process_Preview;
    QDBusMessage mergeSub_Message;
    QTcpServer server;
    QString logMessage;
    QString video_Duration;
    QString video_Current_Duration;
    QString video_Total_Duration;
    QString qprocess_Program_Name;
    QString qprocess_Command_Name;
    QTcpServer *tcpServer;
    QTcpSocket *clientSocket;
    QString socketPort;

    Q_PROPERTY(QString sourceCommand READ getSourceCommand WRITE setSourceCommand NOTIFY sourceCommandChanged FINAL)
    Q_PROPERTY(QString delFileUrl READ getDelFileUrl WRITE setDelFileUrl NOTIFY delFileUrlChanged FINAL)
    Q_PROPERTY(QString videoFileUrl READ getVideoFileUrl WRITE setVideoFileUrl NOTIFY videoFileUrlChanged FINAL)
    Q_PROPERTY(QString logMessage READ getLogMessage WRITE setLogMessage NOTIFY logMessageChanged FINAL)
    Q_PROPERTY(QString video_Duration READ getVideo_Duration WRITE setVideo_Duration NOTIFY video_DurationChanged FINAL)
    Q_PROPERTY(QString video_Total_Duration READ getVideo_Total_Duration WRITE setVideo_Total_Duration NOTIFY video_Total_DurationChanged FINAL)
    Q_PROPERTY(QString sourceCommandPreview READ getSourceCommandPreview WRITE setSourceCommandPreview NOTIFY sourceCommandPreviewChanged FINAL)
    Q_PROPERTY(QString ffmpeg_Version READ getFfmpeg_Version WRITE setFfmpeg_Version NOTIFY ffmpeg_VersionChanged FINAL)


    Q_PROPERTY(QString socketPort READ getSocketPort WRITE setSocketPort NOTIFY socketPortChanged FINAL)

    Q_PROPERTY(QString video_Current_Duration READ getVideo_Current_Duration WRITE setVideo_Current_Duration NOTIFY video_Current_DurationChanged FINAL)

    Q_PROPERTY(QString sourceVideoWidth READ getSourceVideoWidth WRITE setSourceVideoWidth NOTIFY sourceVideoWidthChanged FINAL)

    Q_PROPERTY(QString sourceVideoHeight READ getSourceVideoHeight WRITE setSourceVideoHeight NOTIFY sourceVideoHeightChanged FINAL)

    Q_PROPERTY(QString sourceVideoCodec READ getSourceVideoCodec WRITE setSourceVideoCodec NOTIFY sourceVideoCodecChanged FINAL)

    Q_PROPERTY(QString sourceMusicCodec READ getSourceMusicCodec WRITE setSourceMusicCodec NOTIFY sourceMusicCodecChanged FINAL)

    Q_PROPERTY(QString videoFrameRate READ getVideoFrameRate WRITE setVideoFrameRate NOTIFY videoFrameRateChanged FINAL)

private slots:
    void onNewConnection();
    void onClientDisconnected();
};

#endif // FFMPEGTHREADS_H
