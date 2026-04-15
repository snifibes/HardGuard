import QtQuick
import QtMultimedia
import QtQuick.Layouts

Item {
    MediaDevices {
        id: mediaDevices
    }
    Camera {
        id: camera
        cameraDevice: mediaDevices.defaultVideoInput
        active: true
    }
    CaptureSession {
        camera: camera
        videoOutput: videoOutput
    }
    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
    }

    Component.onCompleted:{
        codeDecoder.videoSink = videoOutput.videoSink
    }

    RowLayout {
        id: menu
        spacing: 10
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 10
        CustomButton {
            id: cancelRequest
            buttonText: "Назад"
            backgroundColor: Theme.backgroundColor()
            buttonWidth: 100
            anchors.leftMargin: 10
            onClickAction: function() {
                stackView.pop();
            }
        }
    }

    Connections {
        target: codeDecoder
        onQrCodeDetected: {
            camera.active = false;
            Qt.callLater(() => {
                stackView.push("RequestKeyFromQr.qml");
            });
        }
    }
}
