#ifndef FFMPEGHANDEL_H
#define FFMPEGHANDEL_H
#include <QProcess>
#include <QObject>

class ffmpeghandel : public QObject
{
    Q_OBJECT
public:
    explicit ffmpeghandel(QObject *parent = nullptr);
    static QObject * getInstance();

    Q_INVOKABLE QString sourceCommand;
    QString getSourceCommand() const;
    void setSourceCommand(const QString &newSourceCommand);

    Q_INVOKABLE QString delFileUrl;
    QString getDelFileUrl() const;
    void setDelFileUrl(const QString &newDelFileUrl);

    Q_INVOKABLE QString videoFileUrl;
    QString getVideoFileUrl() const;
    void setVideoFileUrl(const QString &newVidepFileUrl);



    QString getFfmpeg_Version() const;
    void setFfmpeg_Version(const QString &newFfmpeg_Version);

    QString getLogMessage() const;
    void setLogMessage(const QString &newLogMessage);

    QString getVideo_Duration() const;
    void setVideo_Duration(const QString &newVideo_Duration);

    QString getVideo_Total_Duration() const;
    void setVideo_Total_Duration(const QString &newVideo_Total_Duration);


public slots:
    void ffmpeg_Process();
    void check_Ffmpeg_Version();
    void on_Start_Encoding();
    void on_Cancel_Encoding();
    void get_Video_Info();

signals:

    void sourceCommandChanged();
    void delFileUrlChanged();
    void videoFileUrlChanged();
    void ffmpeg_VersionChanged();
    void logMessageChanged();
    void video_DurationChanged();
    void video_Total_DurationChanged();


private:
    QProcess ffmpeg_process;
    QString ffmpeg_Version;
    QString logMessage;
    QString video_Duration;
    QString video_Total_Duration;
    QString qprocess_Program_Name;
    QString qprocess_Command_Name;

    Q_PROPERTY(QString sourceCommand READ getSourceCommand WRITE setSourceCommand NOTIFY sourceCommandChanged FINAL)
    Q_PROPERTY(QString delFileUrl READ getDelFileUrl WRITE setDelFileUrl NOTIFY delFileUrlChanged FINAL)
    Q_PROPERTY(QString videoFileUrl READ getVideoFileUrl WRITE setVideoFileUrl NOTIFY videoFileUrlChanged FINAL)
    Q_PROPERTY(QString ffmpeg_Version READ getFfmpeg_Version WRITE setFfmpeg_Version NOTIFY ffmpeg_VersionChanged FINAL)
    Q_PROPERTY(QString logMessage READ getLogMessage WRITE setLogMessage NOTIFY logMessageChanged FINAL)
    Q_PROPERTY(QString video_Duration READ getVideo_Duration WRITE setVideo_Duration NOTIFY video_DurationChanged FINAL)
    Q_PROPERTY(QString video_Total_Duration READ getVideo_Total_Duration WRITE setVideo_Total_Duration NOTIFY video_Total_DurationChanged FINAL)
};
#endif // FFMPEGHANDEL_H
