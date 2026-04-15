import QtQuick
import QtQuick.Layouts

Item {
    Rectangle{
        id: whiteRec
        color: "white"
        width: Math.min(parent.width - 20, 410)
        height: whiteRec.width
        anchors.centerIn: parent
        Image {
            id: qrCodeImage
            source: "image://qrcodeprovider/data"
            width: parent.width - 10
            height: parent.height - 10
            anchors.centerIn: parent
            cache: false
        }
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
            buttonWidth: 100
            onClickAction: function() {
                stackView.pop();
            }
        }
    }

    Connections{
        target: manager
        onQrChanged: {
            qrError.visible = false
            whiteRec.visible = true
            qrCodeImage.visible = true
            qrCodeImage.source = "";
            Qt.callLater(() => {
                if (qrCodeImage){
                    qrCodeImage.source = "image://qrcodeprovider/data";
                }
            });
        }
        onQrCodeEmpty:{
            qrError.visible = true
            whiteRec.visible = false
            qrCodeImage.visible = false
        }
    }

    Text {
        id: qrError
        text: qsTr("Слишком много аккаунтов,\n   нельзя экспортировать\n    с помощью QR-кода")
        anchors.centerIn: parent
        font.pixelSize: Math.max(12, parent.width / 16)
        color: "red"
        visible: false
    }
}
