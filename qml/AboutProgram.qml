import QtQuick
import QtQuick.Layouts
Item {
    Rectangle{
        id: requestkeyRec
        color: "transparent"
        radius: 10
        border.width: 2
        border.color: "darkgray"
        width: Math.min(parent.width - 10, 500)
        height: Math.min(parent.height, 300)
        anchors.centerIn: parent
        GridLayout{
            rows: 4
            rowSpacing: 10
            Text{
                id: txtAbout
                Layout.row: 0
                Layout.leftMargin: 10
                Layout.topMargin: 10
                text:"О программе"
                font.pixelSize: 24
                color: Theme.textColor()
            }
            Text {
                Layout.row: 1
                Layout.leftMargin: 10
                text: qsTr("Название: HardGuard")
                font.pixelSize: 18
                color: Theme.textColor()
            }

            Text {
                Layout.row: 2
                Layout.leftMargin: 10
                text: qsTr("Назначение: Безопасное хранение\nучетных данных")
                font.pixelSize: 18
                color: Theme.textColor()
            }
            Text {
                Layout.row: 3
                Layout.leftMargin: 10
                text: qsTr("Версия: 1.0")
                font.pixelSize: 18
                color: Theme.textColor()
            }
        }
        CustomButton {
            buttonText: "ОК"
            buttonWidth: 150
            anchors.right: requestkeyRec.right
            anchors.bottom: requestkeyRec.bottom
            anchors.rightMargin: 10
            anchors.bottomMargin: 10
            onClickAction: function() {
                stackView.pop()
            }
        }
    }
}

