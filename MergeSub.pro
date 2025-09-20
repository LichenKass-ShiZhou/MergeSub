QT += quick core widgets dbus network multimedia

SOURCES += \
        ffmpegthreads.cpp \
        main.cpp \
        mergesubtranslation.cpp

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += resources \
    Languages.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = main.qml

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    ffmpegthreads.h \
    mergesubtranslation.h

TRANSLATIONS += \
    Languages/MergeSub_zh_CN.ts \
    Languages/MergeSub_en_US.ts
