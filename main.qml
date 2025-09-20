import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtQml 2.15
import QtMultimedia


ApplicationWindow {
    id: mainWindow
    title:"MergeSub"
    width: 1000
    height: 700
    minimumWidth: 800
    minimumHeight: 600
    color: "#1e1f2a"
    visible: true

    // 状态变量
    property bool processing: false
    property bool previewMode: false
    property int selectedTab: 0
    property string ffmpegVersion: ""
    property string mergeSubVersion: "0.0.1"
    property string progressBar_Value: "0%"
    property bool tcpConnected: false
    property string tcpPort: ""
    property string videoCurrentDuration: "00:00:00"
    property string videoDuration: "01:12:00"
    property string videoTotalSeconds: "0"
    property string videoCurrentSeconds: "0"
    property string seekTime: "00:00:00"
    property string seekTimeSeconds: "0"
    property string  sourceVideoCodec: ""
    property string  sourceVideoWidth: ""
    property string  sourceVideoHeight: ""
    property string  sourceVideoFrameRate: "30"
    property int port: 0

    Component.onCompleted: {
        FfmpegWorker.check_Ffmpeg_Version();
        ffmpegVersion = FfmpegWorker.ffmpeg_Version
    }

    // 文件对话框
    FileDialog {
        id: videoFileDialog
        title: "选择视频文件"
        nameFilters: ["视频文件 (*.mp4 *.mkv *.avi *.mov *.flv *.wmv)"]
        onAccepted: {
            videoPath.text = getLocalPath(selectedFile)
            // 获取视频信息
            FfmpegWorker.videoFileUrl = videoPath.text
            FfmpegWorker.get_Video_Info()
        }
    }

    FileDialog {
        id: subtitleFileDialog
        title: qsTr("选择字幕文件")
        nameFilters: [qsTr("字幕文件 (*.srt *.ass *.vtt *.ssa *.sub)")]
        onAccepted:{
            subtitlePath.text = getLocalPath(selectedFile)
        }
    }

    FolderDialog {
        id: saveFileDialog
        title: "保存输出文件"
        onAccepted: outputPath.text = getLocalPath(currentFolder)
    }



    // 主布局
    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        // 左侧控制面板
        Rectangle {
            id: controlPanel
            SplitView.preferredWidth: 350
            SplitView.minimumWidth: 300
            color: "#252836"
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // 标题区域
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Image {
                        source: ""
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        fillMode: Image.PreserveAspectFit
                    }

                    Label {
                        text: "MergeSub"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#6c5ce7"
                        Layout.fillWidth: true
                    }

                    Button {
                        text: previewMode ? "退出预览" : "视频预览"
                        onClicked: {
                            generateCommandPreview();
                        }
                        background: Rectangle {
                            color: previewMode ? "#e74c3c" : "#3498db"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // 选项卡
                TabBar {
                    id: tabBar
                    Layout.fillWidth: true
                    background: Rectangle { color: "transparent" }

                    TabButton {
                        text: "文件设置"
                        width: implicitWidth
                        background: Rectangle {
                            color: selectedTab === 0 ? "#6c5ce7" : "transparent"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: selectedTab === 0 ? "white" : "#b2bec3"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: selectedTab = 0
                    }
                    TabButton {
                        text: "视频设置"
                        width: implicitWidth
                        background: Rectangle {
                            color: selectedTab === 1 ? "#6c5ce7" : "transparent"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: selectedTab === 1 ? "white" : "#b2bec3"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: selectedTab = 1
                    }
                    TabButton {
                        text: "音频设置"
                        width: implicitWidth
                        background: Rectangle {
                            color: selectedTab === 2 ? "#6c5ce7" : "transparent"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: selectedTab === 2 ? "white" : "#b2bec3"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: selectedTab = 2
                    }
                    /*TabButton {
                        text: "字幕设置"
                        width: implicitWidth
                        background: Rectangle {
                            color: selectedTab === 3 ? "#6c5ce7" : "transparent"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: selectedTab === 3 ? "white" : "#b2bec3"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: selectedTab = 3
                    }*/
                    TabButton {
                        text: "软件设置"
                        width: implicitWidth
                        background: Rectangle {
                            color: selectedTab === 3 ? "#6c5ce7" : "transparent"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: selectedTab === 3 ? "white" : "#b2bec3"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: selectedTab = 3
                    }
                }

                // 选项卡内容
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: selectedTab

                    // 文件设置
                    ColumnLayout {
                        spacing: 15

                        GroupBox {
                            title: "输入文件"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#2d3043"
                                radius: 6
                            }
                            label: Label {
                                text: parent.title
                                color: "#dfe6e9"
                                font.bold: true
                                leftPadding: 5
                            }

                            GridLayout {
                                columns: 3
                                width: parent.width

                                // 视频文件
                                Label {
                                    text: "视频文件:"
                                    color: "#b2bec3"
                                }
                                TextField {
                                    id: videoPath
                                    placeholderText: "选择视频文件..."
                                    Layout.fillWidth: true
                                    color: "#dfe6e9"
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                }
                                Button {
                                    icon.source: ""
                                    onClicked: videoFileDialog.open()
                                    background: Rectangle {
                                        color: "#6c5ce7"
                                        radius: 4
                                    }
                                }

                                // 字幕文件
                                Label {
                                    text: "字幕文件:"
                                    color: "#b2bec3"
                                }
                                TextField {
                                    id: subtitlePath
                                    placeholderText: "选择字幕文件..."
                                    Layout.fillWidth: true
                                    color: "#dfe6e9"
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                }
                                Button {
                                    icon.source: ""
                                    onClicked: subtitleFileDialog.open()
                                    background: Rectangle {
                                        color: "#6c5ce7"
                                        radius: 4
                                    }
                                }
                            }
                        }

                        GroupBox {
                            title: "输出设置"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#2d3043"
                                radius: 6
                            }
                            label: Label {
                                text: parent.title
                                color: "#dfe6e9"
                                font.bold: true
                                leftPadding: 5
                            }

                            GridLayout {
                                columns: 3
                                width: parent.width

                                // 输出文件
                                Label {
                                    text: "输出文件夹:"
                                    color: "#b2bec3"
                                }
                                TextField {
                                    id: outputPath
                                    placeholderText: "选择输出位置..."
                                    Layout.fillWidth: true
                                    color: "#dfe6e9"
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                }
                                Button {
                                    icon.source: ""
                                    onClicked: saveFileDialog.open()
                                    background: Rectangle {
                                        color: "#6c5ce7"
                                        radius: 4
                                    }
                                }

                                Label {
                                    text: "输出文件名:"
                                    color: "#b2bec3"
                                }
                                TextField {
                                    id: outputName
                                    placeholderText: "输出文件名"
                                    Layout.fillWidth: true
                                    color: "#dfe6e9"
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                }
                                Item {
                                    //站个位置
                                }

                                // 输出格式
                                Label {
                                    text: "输出格式:"
                                    color: "#b2bec3"
                                }
                                ComboBox {
                                    id: formatCombo
                                    model: ["MKV", "MP4", "AVI", "MOV", "FLV"]
                                    currentIndex: 0
                                    Layout.fillWidth: true
                                    Layout.columnSpan: 2
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.currentText
                                        color: "#dfe6e9"
                                        leftPadding: 10
                                    }
                                }
                            }
                        }
                        /*GroupBox{
                            title: "测试"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#2d3043"
                                radius: 6
                            }
                            label: Label {
                                text: parent.title
                                color: "#dfe6e9"
                                font.bold: true
                                leftPadding: 5
                            }
                            Text {
                                visible: previewMode
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 10
                                text: "TCP状态: " + (tcpConnected ? "已连接" : "未连接") +
                                      "\n端口: " + tcpPort
                                color: tcpConnected ? "green" : "red"
                                font.pixelSize: 12
                            }
                        }
                        GroupBox {
                            title: "任务预设"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#2d3043"
                                radius: 6
                            }
                            label: Label {
                                text: parent.title
                                color: "#dfe6e9"
                                font.bold: true
                                leftPadding: 5
                            }

                            GridLayout {
                                columns: 2
                                width: parent.width

                                // 预设
                                ComboBox {
                                    id: presetCombo
                                    model: ["默认设置", "高质量", "小文件", "快速压制", "自定义"]
                                    currentIndex: 0
                                    Layout.fillWidth: true
                                    Layout.columnSpan: 2
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.currentText
                                        color: "#dfe6e9"
                                        leftPadding: 10
                                    }

                                    onCurrentIndexChanged: {
                                        switch(presetCombo.currentIndex) {
                                        case 0: // 默认设置
                                            videoCodec.currentIndex = 0;
                                            videoQuality.value = 27;
                                            videoPreset.currentIndex = 3;
                                            break;

                                        case 1: // 高质量
                                            videoCodec.currentIndex = 1;
                                            videoQuality.value = 22;
                                            videoPreset.currentIndex = 5;
                                            break;

                                        case 2: // 小文件
                                            videoCodec.currentIndex = 1;
                                            videoQuality.value = 28;
                                            videoPreset.currentIndex = 2;
                                            widthInput.text = "1280";
                                            heightInput.text = "720";
                                            break;

                                        case 3: // 快速压制
                                            videoCodec.currentIndex = 0;
                                            videoQuality.value = 25;
                                            videoPreset.currentIndex = 0;
                                            break;
                                        }
                                    }
                                }

                                // 预设描述
                                Label {
                                    text: "描述:"
                                    color: "#b2bec3"
                                }
                                Label {
                                    text: {
                                        switch(presetCombo.currentIndex) {
                                        case 0: return "平衡质量和文件大小";
                                        case 1: return "最佳质量，文件较大";
                                        case 2: return "较小文件，质量可接受";
                                        case 3: return "快速处理，质量一般";
                                        default: return "自定义设置";
                                        }
                                    }
                                    color: "#dfe6e9"
                                    Layout.fillWidth: true
                                }
                            }
                        }*/
                    }

                    // 视频设置
                    ColumnLayout {
                        spacing: 15

                        GroupBox {
                            title: "编码设置"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#2d3043"
                                radius: 6
                            }
                            label: Label {
                                text: parent.title
                                color: "#dfe6e9"
                                font.bold: true
                                leftPadding: 5
                            }
                            ColumnLayout{
                                width: parent.width

                                GridLayout {
                                    columns: 2
                                    width: parent.width

                                    // 视频编码器
                                    Label {
                                        text: "视频编码器:"
                                        color: "#b2bec3"
                                    }
                                    ComboBox {
                                        id: videoCodec
                                        model: ["H.264 (AVC)", "H.265 (HEVC)", "原始流"]
                                        currentIndex: 2
                                        Layout.fillWidth: true
                                        background: Rectangle {
                                            color: "#1e1f2a"
                                            border.color: "#6c5ce7"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: parent.currentText
                                            color: "#dfe6e9"
                                            leftPadding: 10
                                        }
                                    }
                                }
                                //H246参数设置
                                GridLayout {
                                    columns: 2
                                    width: parent.width

                                    Label {
                                        text: "码率控制:"
                                        color: "#b2bec3"
                                    }
                                    ComboBox {
                                        id: rateControlModels
                                        model: ["恒定质量模式 (CRF)","目标码率模式 (ABR)"]
                                        currentIndex: 0
                                        Layout.fillWidth: true

                                        background: Rectangle {
                                            color: "#1e1f2a"
                                            border.color: "#6c5ce7"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: parent.currentText
                                            color: "#dfe6e9"
                                            leftPadding: 10
                                        }
                                    }
                                }

                                GridLayout {
                                    columns: 2
                                    width: parent.width

                                    Label {
                                        text: "编码预设:"
                                        color: "#b2bec3"
                                    }
                                    ComboBox {
                                        id: videoPreset
                                        model: ["超快", "非常快", "较快", "中等", "慢", "非常慢"]
                                        currentIndex: 3
                                        Layout.fillWidth: true
                                        background: Rectangle {
                                            color: "#1e1f2a"
                                            border.color: "#6c5ce7"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: parent.currentText
                                            color: "#dfe6e9"
                                            leftPadding: 10
                                        }
                                    }
                                }

                                GridLayout {
                                    columns: 3
                                    width: parent.width
                                    visible: {
                                        rateControlModels.currentIndex === 0
                                    }

                                    Label {
                                        text: "CRF参数:"
                                        color: "#b2bec3"
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Slider {
                                            id: videoQuality
                                            from: 0
                                            to: 51
                                            value: 23
                                            stepSize: 1
                                            Layout.fillWidth: true
                                            background: Rectangle {
                                                x: parent.leftPadding
                                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                                implicitWidth: 200
                                                implicitHeight: 6
                                                width: parent.availableWidth
                                                height: implicitHeight
                                                radius: 3
                                                color: "#1e1f2a"

                                                Rectangle {
                                                    width: parent.width * parent.parent.visualPosition
                                                    height: parent.height
                                                    color: "#6c5ce7"
                                                    radius: 3
                                                }
                                            }

                                            handle: Rectangle {
                                                x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                                implicitWidth: 16
                                                implicitHeight: 16
                                                radius: 8
                                                color: "#6c5ce7"
                                                border.color: "#f3f3f3"
                                            }
                                        }
                                        Label {
                                            text: videoQuality.value
                                            color:"#b2bec3"
                                            Layout.preferredWidth: 30
                                        }
                                    }
                                }

                                GridLayout {
                                    columns: 3
                                    width: parent.width
                                    visible: {
                                        rateControlModels.currentIndex === 1
                                    }

                                    Label {
                                        text: "码率："
                                        color: "#b2bec3"
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Slider {
                                            id: videoBitrate
                                            from: 0
                                            to: 65
                                            value: 0
                                            stepSize: 1
                                            Layout.fillWidth: true
                                            background: Rectangle {
                                                x: parent.leftPadding
                                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                                implicitWidth: 200
                                                implicitHeight: 6
                                                width: parent.availableWidth
                                                height: implicitHeight
                                                radius: 3
                                                color: "#1e1f2a"

                                                Rectangle {
                                                    width: parent.width * parent.parent.visualPosition
                                                    height: parent.height
                                                    color: "#6c5ce7"
                                                    radius: 3
                                                }
                                            }

                                            handle: Rectangle {
                                                x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                                implicitWidth: 16
                                                implicitHeight: 16
                                                radius: 8
                                                color: "#6c5ce7"
                                                border.color: "#f3f3f3"
                                            }
                                        }
                                        Label {
                                            text: videoBitrate.value
                                            color:"#b2bec3"
                                            Layout.preferredWidth: 30
                                        }
                                    }
                                }
                                /*
                                GridLayout{
                                    Label {
                                        visible: videoCodec.currentIndex === 0 || videoCodec.currentIndex === 1
                                        text: "档次:"
                                        color: "#b2bec3"
                                    }
                                    ComboBox {
                                        id: profilelH264Modes
                                        model: ["baseline","main","high"]
                                        currentIndex: 2
                                        visible: videoCodec.currentIndex === 0
                                        Layout.fillWidth: true

                                        background: Rectangle {
                                            color: "#1e1f2a"
                                            border.color: "#6c5ce7"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: parent.currentText
                                            color: "#dfe6e9"
                                            leftPadding: 10
                                        }
                                    }
                                    ComboBox {
                                        id: profilelH265Modes
                                        model: ["main","main10"]
                                        currentIndex: 0
                                        visible: videoCodec.currentIndex === 1
                                        Layout.fillWidth: true

                                        background: Rectangle {
                                            color: "#1e1f2a"
                                            border.color: "#6c5ce7"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: parent.currentText
                                            color: "#dfe6e9"
                                            leftPadding: 10
                                        }
                                    }
                                }


                                GridLayout {
                                    Label {
                                        text: "帧率设置:"
                                        color: "#b2bec3"
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Slider {
                                            id: videoFrameRate
                                            from: 0
                                            to: 200
                                            value: 29.97
                                            stepSize: 1
                                            Layout.fillWidth: true
                                            background: Rectangle {
                                                x: parent.leftPadding
                                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                                implicitWidth: 200
                                                implicitHeight: 6
                                                width: parent.availableWidth
                                                height: implicitHeight
                                                radius: 3
                                                color: "#1e1f2a"

                                                Rectangle {
                                                    width: parent.width * parent.parent.visualPosition
                                                    height: parent.height
                                                    color: "#6c5ce7"
                                                    radius: 3
                                                }
                                            }

                                            handle: Rectangle {
                                                x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                                implicitWidth: 16
                                                implicitHeight: 16
                                                radius: 8
                                                color: "#6c5ce7"
                                                border.color: "#f3f3f3"
                                            }
                                        }
                                        Label {
                                            text: videoFrameRate.value
                                            color:"#b2bec3"
                                            Layout.preferredWidth: 30
                                        }
                                    }

                                }
                                */
                                GridLayout{
                                    Label {
                                        text: "分辨率:"
                                        color: "#b2bec3"
                                    }
                                    ColumnLayout {
                                        spacing: 5

                                        // 输入框行
                                        RowLayout {
                                            spacing: 5
                                            TextField {
                                                id: widthInput
                                                text: "1920"
                                                color: "#dfe6e9"
                                                Layout.preferredWidth: 60
                                                background: Rectangle {
                                                    color: "#1e1f2a"
                                                    border.color: "#6c5ce7"
                                                    radius: 4
                                                }
                                            }
                                            Label {
                                                text: "×"
                                                color: "#b2bec3"
                                            }
                                            TextField {
                                                id: heightInput
                                                text: "1080"
                                                color: "#dfe6e9"
                                                Layout.preferredWidth: 60
                                                background: Rectangle {
                                                    color: "#1e1f2a"
                                                    border.color: "#6c5ce7"
                                                    radius: 4
                                                }
                                            }
                                        }

                                        // 按钮行（在输入框正下方）
                                        RowLayout {
                                            spacing: 5
                                            Button {
                                                text: "原始"
                                                onClicked: {
                                                    widthInput.text = FfmpegWorker.sourceVideoWidth;
                                                    heightInput.text = FfmpegWorker.sourceVideoHeight;
                                                }
                                                background: Rectangle {
                                                    color: "#2d3436"
                                                    radius: 4
                                                }
                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "#dfe6e9"
                                                }
                                            }
                                            Button {
                                                text: "720p"
                                                onClicked: {
                                                    widthInput.text = "1280";
                                                    heightInput.text = "720";
                                                }
                                                background: Rectangle {
                                                    color: "#2d3436"
                                                    radius: 4
                                                }
                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "#dfe6e9"
                                                }
                                            }
                                            Button {
                                                text: "1080p"
                                                onClicked: {
                                                    widthInput.text = "1920";
                                                    heightInput.text = "1080";
                                                }
                                                background: Rectangle {
                                                    color: "#2d3436"
                                                    radius: 4
                                                }
                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "#dfe6e9"
                                                }
                                            }

                                        }
                                    }

                                }
                            }
                        }
                    }

                    // 音频设置
                    ColumnLayout {
                        spacing: 15
                        GroupBox {
                            title: "音频编码设置"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#2d3043"
                                radius: 6
                            }
                            label: Label {
                                text: parent.title
                                color: "#dfe6e9"
                                font.bold: true
                                leftPadding: 5
                            }

                            GridLayout {
                                columns: 2
                                width: parent.width

                                // 音频编码器
                                Label {
                                    text: "音频编码器:"
                                    color: "#b2bec3"
                                }
                                ComboBox {
                                    id: audioCodec
                                    model: ["AAC", "MP3", "FLAC", "原始流"]
                                    currentIndex: 3
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.currentText
                                        color: "#dfe6e9"
                                        leftPadding: 10
                                    }
                                }

                                // 音频质量
                                Label {
                                    text: "音频质量:"
                                    color: "#b2bec3"
                                }
                                ComboBox {
                                    id: audioQuality
                                    model: ["中等 (128k)", "高质量 (192k)", "高保真 (256k)", "无损"]
                                    currentIndex: 1
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.currentText
                                        color: "#dfe6e9"
                                        leftPadding: 10
                                    }
                                }
                            }
                        }
                    }

                    // 字幕设置
                    /*ColumnLayout {
                        spacing: 15
                        GroupBox {
                            title: "字幕设置"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#2d3043"
                                radius: 6
                            }
                            label: Label {
                                text: parent.title
                                color: "#dfe6e9"
                                font.bold: true
                                leftPadding: 5
                            }

                            GridLayout {
                                columns: 2
                                width: parent.width

                                // 字幕编码
                                Label {
                                    text: "字幕编码:"
                                    color: "#b2bec3"
                                }
                                ComboBox {
                                    id: subtitleCodec
                                    model: ["原始流", "SRT", "ASS", "WebVTT"]
                                    currentIndex: 0
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.currentText
                                        color: "#dfe6e9"
                                        leftPadding: 10
                                    }
                                }

                                // 字幕样式
                                Label {
                                    text: "字幕样式:"
                                    color: "#b2bec3"
                                }
                                ComboBox {
                                    id: subtitleStyle
                                    model: ["默认", "电影黑边", "底部居中", "自定义"]
                                    currentIndex: 0
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.currentText
                                        color: "#dfe6e9"
                                        leftPadding: 10
                                    }
                                }
                            }
                        }
                    }*/

                    // 软件设置
                    ColumnLayout {
                        spacing: 15
                        GroupBox {
                            title: "软件设置"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#2d3043"
                                radius: 6
                            }
                            label: Label {
                                text: parent.title
                                color: "#dfe6e9"
                                font.bold: true
                                leftPadding: 5
                            }

                            GridLayout {
                                columns: 2
                                width: parent.width

                                // 硬件加速
                                Label {
                                    text: qsTr("语言:")
                                    color: "#b2bec3"
                                }
                                ComboBox {
                                    id: windowLanguages
                                    model: ["中文"]
                                    currentIndex: 0
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.currentText
                                        color: "#dfe6e9"
                                        leftPadding: 10
                                    }
                                    onCurrentIndexChanged:{
                                        translator.mergesub_load(windowLanguages.currentIndex);
                                    }

                                }

                                // 线程数
                                Label {
                                    text: "主题【暂未实现】:"
                                    color: "#b2bec3"
                                }
                                ComboBox {
                                    id: threadCount
                                    model: ["自动", "1", "2", "4", "8", "12", "16"]
                                    currentIndex: 0
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: "#1e1f2a"
                                        border.color: "#6c5ce7"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.currentText
                                        color: "#dfe6e9"
                                        leftPadding: 10
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 右侧预览和日志区域
        SplitView {
            orientation: Qt.Vertical
            SplitView.fillWidth: true

            // 预览区域
            Rectangle {
                id: previewArea
                SplitView.preferredHeight: 400
                SplitView.minimumHeight: 200
                color: "#12131a"

                // 预览内容框架
                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.9, 16 * 50)
                    height: Math.min(parent.height * 0.9, 9 * 50)
                    color: "#000000"
                    border.color: "#6c5ce7"
                    border.width: 2
                    radius: 4

                    // 视频预览区域
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 10
                        color: "#1a1b26"
                        radius: 2

                        MediaPlayer {
                            id:mediaplayer
                            source:tcpPort
                            videoOutput: videoOutput
                            audioOutput:audioOutput


                            onErrorOccurred: function(error, errorString) {
                                console.log("MediaPlayer error:", error, errorString);
                                // 尝试重新连接
                                if (previewMode) {
                                    reconnectTimer.start();
                                }
                            }

                            onPlaybackStateChanged: {
                                if (playbackState === MediaPlayer.StoppedState && previewMode) {
                                    // 播放停止但仍在预览模式，尝试重新连接
                                    reconnectTimer.start();
                                }
                            }
                        }

                        VideoOutput {
                            id: videoOutput
                            anchors.fill: parent
                        }
                        AudioOutput{
                            id:audioOutput
                        }

                        Timer {
                            id: reconnectTimer
                            interval: 2000 // 2秒后重连
                            onTriggered: {
                                if (previewMode && !tcpConnected) {
                                    mediaplayer.source = tcpPort;
                                    mediaplayer.play();
                                }
                            }
                        }

                        // 无水印时的提示
                        Text {
                            anchors.centerIn: parent
                            text: previewMode ? "" : "视频预览区域"
                            color: "#6c5ce7"
                            font.pixelSize: 24
                            opacity: 0.3
                        }
                    }
                }
                // 预览信息显示
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    height: 40
                    color: "#1a1b26"
                    radius: 4
                    opacity: 0.8

                    Slider {
                        id: progressSlider
                        width: parent.width
                        anchors {
                            left: videoinfo.right
                            right: playinfo.left
                            margins: 20
                        }
                        from: 0 // 最小值
                        to:videoTotalSeconds
                        stepSize: 1
                        value: Number(videoCurrentSeconds) + Number(seekTimeSeconds)


                        // 当用户拖动滑块时，跳转到相应位置
                        onPressedChanged: {
                            if (!pressed) {
                                progressSlider.value =  videoTotalSeconds * progressSlider.position
                                progressSlider.value = parseInt(progressSlider.value)
                                seekTimeSeconds = progressSlider.value

                                var hours = Math.floor(seekTimeSeconds / 3600);
                                var minutes = Math.floor((seekTimeSeconds % 3600) / 60);
                                var seconds = Math.floor(seekTimeSeconds % 60);
                                seekTime =
                                        hours.toString().padStart(2, '0') + ":" +
                                        minutes.toString().padStart(2, '0') + ":" +
                                        seconds.toString().padStart(2, '0');

                                commandPreview();
                            }
                        }
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5

                        Label {
                            id:videoinfo
                            text: `${widthInput.text}×${heightInput.text} | ${videoCodec.currentText} | ${FfmpegWorker.videoFrameRate}FPS `
                            color: "#dfe6e9"
                        }

                        Label {
                            id:playinfo
                            text: videoCurrentDuration+"/"+videoDuration
                            color: "#dfe6e9"
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }

            // 日志和进度区域
            Rectangle {
                id: logArea
                SplitView.minimumHeight: 150
                color: "#252836"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // 进度条
                    ProgressBar {
                        id: progressBar
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        value: FfmpegWorker ? FfmpegWorker.progress : 0
                        visible: processing
                        background: Rectangle {
                            implicitHeight: 20
                            color: "#1e1f2a"
                            radius: 10
                        }
                        contentItem: Item {
                            implicitHeight: 20
                            Rectangle {
                                width: progressBar.visualPosition * parent.width
                                height: parent.height
                                radius: 10
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#6c5ce7" }
                                    GradientStop { position: 1.0; color: "#a29bfe" }
                                }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: processing ? Math.round(progressBar.value * 100) + "%" : "准备就绪"
                                color: "white"
                                font.bold: true
                            }
                        }
                    }

                    // 操作按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Button {
                            text: "开始压制"
                            enabled: !processing && videoPath.text && outputPath.text
                            onClicked: startProcessing()
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                color: parent.enabled ? "#00b894" : "#636e72"
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "取消"
                            enabled: processing
                            onClicked: cancelProcessing()
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                color: parent.enabled ? "#e74c3c" : "#636e72"
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "生成命令行"
                            onClicked: generateCommand()
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                color: "#6c5ce7"
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "清除日志"
                            onClicked: logText.text = ""
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                color: "#f39c12"
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // 日志区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f2a"
                        radius: 6
                        border.color: "#6c5ce7"
                        border.width: 1

                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 5
                            clip: true

                            TextArea {
                                id: logText
                                text: "MergeSub FFmpeg压制工具已启动\n准备处理任务..."
                                color: "#dfe6e9"
                                font.family: "Consolas"
                                cursorPosition: text.length
                                font.pixelSize: 12
                                readOnly: true
                                wrapMode: Text.Wrap
                                background: null
                            }
                        }
                    }
                }
            }
        }
    }

    // 状态栏
    Rectangle {
        id: statusBar
        anchors.bottom: parent.bottom
        width: parent.width
        height: 25
        color: "#15161e"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                text: processing ? "状态: 处理中..." : "状态: 空闲"
                color: processing ? "#00b894" : "#dfe6e9"
                font.pixelSize: 12
            }

            Label {
                text: FfmpegWorker ? FfmpegWorker.statusMessage : "初始化中..."
                color: "#dfe6e9"
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.leftMargin: 20
            }

            Label {
                text: ffmpegVersion + " | " + "MergeSub: "+mergeSubVersion
                color: "#6c5ce7"
                font.pixelSize: 12
                Layout.alignment: Qt.AlignRight
                Layout.leftMargin: 20
            }
        }
    }


    // FFmpeg处理逻辑
    function startProcessing() {
        if (processing) return;

        // 验证输入
        if (!videoPath.text || !outputPath.text) {
            logText.text += "错误: 请选择视频文件和输出位置\n";
            return;
        }
        processing = true;
        progressBar.value = 0;
        generateCommand()
        logText.text += "开始处理任务...\n";
        // 调用C++后端
        FfmpegWorker.on_Start_Encoding();
        FfmpegWorker.logMessageChanged();
    }

    function cancelProcessing() {
        if (processing) {
            FfmpegWorker.delFileUrl = `"${outputPath.text}/output.${formatCombo.currentText.toLowerCase()}"`;
            FfmpegWorker.on_Cancel_Encoding();
            processing = false;
            logText.text += "处理已取消\n";
        }
    }

    function generateCommand() {
        const command = get_Encoding_Command();
        FfmpegWorker.sourceCommand = command;
        logText.text += `\n生成的FFmpeg命令:\n${command}\n`;
    }

    function get_Encoding_Command(){
        let command = buildFFmpegCommand();
        if(outputName.text !== ""){
            command += `"${outputPath.text}/${outputName.text}.${formatCombo.currentText.toLowerCase()}"`;
        }else{
            command += `"${outputPath.text}/output.${formatCombo.currentText.toLowerCase()}"`;
        }
        return command;
    }

    function get_Encoding_Preview_Command(){
        let command_Preview = "-ss "+seekTime+" " +"-itsoffset "+seekTime+" "
        command_Preview += buildFFmpegCommand();
        command_Preview += "-f mpegts tcp://127.0.0.1:" + port + "?listen";
        FfmpegWorker.sourceCommandPreview = command_Preview;
    }

    function buildFFmpegCommand() {
        // 根据用户设置构建FFmpeg命令
        let cmd = "-i ";
        cmd += `"${videoPath.text}" `;

        // 音视频编码设置
        if(videoCodec.currentIndex === 2 && audioCodec.currentIndex === 3){
            // 添加字幕
            if (subtitlePath.text !== "") {
                cmd += `-vf ass="${subtitlePath.text}" `;
                cmd += `-c:v ${getVideoCodec()} `
                cmd += `-c:a copy `
            }else{
                cmd += `-c copy `
            }
        }else if(videoCodec.currentIndex === 2 && audioCodec.currentIndex !== 3){
            // 添加字幕
            if (subtitlePath.text !== "") {
                cmd += `-vf ass="${subtitlePath.text}" `;
                cmd += `-c:v ${getVideoCodec()} `;
            }else{
                cmd += `-c:v copy `
            }
            //音频设置
            cmd += `-c:a ${getAudioCodec()} -b:a ${getAudioQuality()} `;
        }else if(audioCodec.currentIndex === 3 && videoCodec.currentIndex !== 2){
            // 添加字幕
            if (subtitlePath.text !== "") {
                cmd += `-vf ass="${subtitlePath.text}" `;
            }

            cmd += `-c:v ${getVideoCodec()} `
            //当选择恒定质量模式后执行
            if(rateControlModels.currentIndex === 0){
                cmd += `-crf ${videoQuality.value} `
            }
            //当选择目标码率模式后执行
            else if(rateControlModels.currentIndex === 1){
                cmd += `-b:v ${videoBitrate.value}m `
            }
            //设置preset速度
            if(videoPreset.currentIndex !== 3){
                cmd += `-preset ${getVideoPreset()} `
            }

            cmd += `-c:a copy `

        }else if(videoCodec.currentIndex !== 2 && audioCodec.currentIndex !== 3){

            // 添加字幕
            if (subtitlePath.text !== "") {
                cmd += `-vf ass="${subtitlePath.text}" `;
            }

            cmd += `-c:v ${getVideoCodec()} `
            //当选择恒定质量模式后执行
            if(rateControlModels.currentIndex === 0){
                cmd += `-crf ${videoQuality.value} `
            }
            //当选择目标码率模式后执行
            else if(rateControlModels.currentIndex === 1){
                cmd += `-b:v ${videoBitrate.value}m `
            }
            //设置preset速度
            if(videoPreset.currentIndex !== 3){
                cmd += `-preset ${getVideoPreset()} `
            }

            cmd += `-c:a ${getAudioCodec()} -b:a ${getAudioQuality()} `;
        }

        //分辨率设置
        sourceVideoWidth = FfmpegWorker.sourceVideoWidth;
        sourceVideoHeight = FfmpegWorker.sourceVideoHeight;
        if (widthInput.text !== sourceVideoWidth || heightInput.text !== sourceVideoHeight) {
            cmd += `-s "${widthInput.text}*${heightInput.text}" `;
        }
        return cmd;
    }

    //选择编码器

    function getVideoCodec() {
        switch(videoCodec.currentIndex) {
        case 0: return "libx264";
        case 1: return "libx265";
        case 2: return  FfmpegWorker.sourceVideoCodec
        default: return FfmpegWorker.sourceVideoCodec
        }
    }

    function getAudioCodec() {
        switch(audioCodec.currentIndex) {
        case 0: return "aac";
        case 1: return "libmp3lame";
        case 2: return "flac"
        case 3: return FfmpegWorker.sourceMusicCodec
        default: return FfmpegWorker.sourceMusicCodec
        }
    }

    function getAudioQuality(){
        switch(audioQuality.currentIndex) {
        case 0: return "128k";
        case 1: return "192k";
        case 2: return "256k";
        default: return "192k";
        }
    }

    function getVideoPreset() {
        switch(videoPreset.currentIndex) {
        case 0: return "ultrafast";
        case 1: return "veryfast";
        case 2: return "faster";
        case 3: return "medium";
        case 4: return "slow";
        case 5: return "veryslow";
        default: return "medium";
        }
    }

    function getLocalPath(fileUrl) {
        const url = Qt.createQmlObject('import QtQuick 2.0; QtObject {}', mainWindow)
        const localPath = Qt.resolvedUrl(fileUrl).toString()

        // 移除 file:// 前缀
        if (localPath.startsWith("file://")) {
            if (Qt.platform.os === "windows" && localPath.length > 8 && localPath[8] === ':') {
                return localPath.substring(8)
            }
            return localPath.substring(7)
        }
    }


    function generateCommandPreview(){
        if (previewMode) {
            // 退出预览模式
            FfmpegWorker.on_Cancel_Encoding_Preview();
            previewMode = false;
            tcpConnected = false;
            mediaplayer.stop();
            mediaplayer.source = "";
            videoCurrentDuration = "00:00:00"
            return;
        }

        FfmpegWorker.get_Video_Info();
        commandPreview();
    }

    function commandPreview(){

        FfmpegWorker.on_Cancel_Encoding_Preview();
        mediaplayer.stop();
        mediaplayer.source = "";

        // 获取未使用的端口
        FfmpegWorker.getUnusedPort();
        port = 25465
        if(mediaplayer.playbackState !== MediaPlayer.PlayingState){
            port = 45374
        }else if(port == 45374 && mediaplayer.playbackState !== MediaPlayer.PlayingState){
            port = 32545
        }else if (port == 32545 &&mediaplayer.playbackState !== MediaPlayer.PlayingState){
            port = 25143
        }else if(port == 25143 &&mediaplayer.playbackState !== MediaPlayer.PlayingState){
            port = 45652
        }else{
            port = 36545
        }
        // 生成FFmpeg命令
        get_Encoding_Preview_Command();

        // 设置TCP地址
        tcpPort = "tcp://127.0.0.1:" + port;

        // 启动编码和TCP服务器
        FfmpegWorker.on_Encoding_Preview();
        previewMode = true;

        // 延迟一会儿再尝试连接，给服务器启动时间
        connectDelayTimer.start();
    }

    Timer {
        id: connectDelayTimer
        interval: 1000 // 1秒后尝试连接
        onTriggered: {
            FfmpegWorker.get_Video_Info();
            mediaplayer.source = tcpPort;
            mediaplayer.play();
        }
    }

    // 监听TCP连接状态
    Connections {
        target: FfmpegWorker
        function onTcpServerStarted(success, error) {
            if (success) {
                console.log("TCP server started successfully");
            } else {
                console.log("TCP server failed to start:", error);
                previewMode = false;
            }
        }

        function onClientConnected() {
            console.log("TCP client connected");
            tcpConnected = true;
        }

        function onClientDisconnected() {
            console.log("TCP client disconnected");
            mainWindow.tcpConnected = false;
        }

        onFfmpeg_VersionChanged: {
            ffmpegVersion = "FFmpeg: " + FfmpegWorker.ffmpeg_Version
        }

        onLogMessageChanged: {
            logText.text += FfmpegWorker.logMessage;
            progressBar.value = timeStringToSeconds(FfmpegWorker.video_Duration)/timeStringToSeconds(FfmpegWorker.video_Total_Duration);
            progressBar_Value = Math.round(progressBar.value*100)+"%"
            if(progressBar_Value === "100%"){
                processing = false;
                logText.text += "处理完成! 输出文件: " +`"${outputPath.text}/output.${formatCombo.currentText.toLowerCase()}"`+ "\n";
            }
        }


        onVideo_Total_DurationChanged:{
            videoDuration =timeStringtoVideoDuration(FfmpegWorker.video_Total_Duration);
            videoTotalSeconds = timeStringToSeconds(FfmpegWorker.video_Total_Duration)
        }
        onVideo_Current_DurationChanged:{
            videoCurrentDuration =timeStringtoVideoDuration(FfmpegWorker.video_Current_Duration);
            videoCurrentSeconds = timeStringToSeconds(FfmpegWorker.video_Current_Duration)
        }

        onVideoFileUrlChanged:{
            // 如果正在预览，则先退出预览模式
            if (previewMode) {
                FfmpegWorker.on_Cancel_Encoding_Preview();
                previewMode = false;
                tcpConnected = false;
                mediaplayer.stop();
                mediaplayer.source = "";
                videoCurrentDuration = "00:00:00";
            }
            FfmpegWorker.get_Video_Info();
        }

        function timeStringtoVideoDuration(timeString){
            const timeRegex = /^(\d{2}):(\d{2}):(\d{2}\.\d+)$/;
            const match = timeString.match(timeRegex);

            if (!match) return null;

            const hours = parseInt(match[1]);
            const minutes = parseInt(match[2]);
            const seconds = parseInt(match[3]);

            return [
                        hours.toString().padStart(2, '0'),
                        minutes.toString().padStart(2, '0'),
                        seconds.toString().padStart(2, '0')
                    ].join(':');
        }

        function timeStringToSeconds(timeString) {
            const timeRegex = /^(\d{2}):(\d{2}):(\d{2}\.\d+)$/;
            const match = timeString.match(timeRegex);

            if (!match) return null;

            const hours = parseInt(match[1]);
            const minutes = parseInt(match[2]);
            const seconds = parseInt(match[3]);

            return Math.round(hours * 3600 + minutes * 60 + seconds);
        }

        function onProcessingFinished(success, outputFile) {
            if (success) {
                logText.text += "处理完成! 输出文件: " + outputFile + "\n";
            } else {
                logText.text += "处理失败\n";
            }
        }

    }
}
