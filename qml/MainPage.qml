import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
Item {
    GridLayout {
        id: menu
        columns: 1
        rowSpacing: 15
        anchors.centerIn: parent

        Image {
            Layout.preferredHeight: 150
            Layout.preferredWidth: 220
            Layout.alignment: Qt.AlignHCenter
            source: Theme.currentTheme === Theme.dark ?
                    "qrc:/img/whiteLogo.png" : "qrc:/img/blackLogo.png"
        }

        CustomButton {
            buttonText: "Аккаунты"
            Layout.preferredHeight: 55
            Layout.preferredWidth: 130
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            onClickAction: function() {
                if (manager.findDataFile()) {
                    stackView.push("RequestKey.qml");
                } else {
                    stackView.push("RequestPassword.qml");
                }
            }
        }

        CustomButton {
            buttonText: "Генератор паролей"
            Layout.preferredHeight: 55
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            onClickAction: function() {
                stackView.push("PasswordGenerator.qml");
            }
        }

        CustomButton {
            buttonText: "О программе"
            Layout.preferredHeight: 55
            Layout.preferredWidth: 180
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            onClickAction: function() {
                stackView.push("AboutProgram.qml");
            }
        }

        CustomButton {
            buttonText: "Выход"
            Layout.preferredHeight: 55
            Layout.preferredWidth: 100
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            onClickAction: function() {
                Qt.quit();
            }
        }

        SwitchDelegate {
            id: control
            activeFocusOnTab: true
            checked: Theme.currentTheme === Theme.light
            Layout.preferredHeight: 55
            Layout.preferredWidth: 150
            Layout.fillWidth: true
            Layout.fillHeight: true

            onCheckedChanged: Theme.toggleTheme()

            contentItem: Text {
                text: qsTr("Тема")
                font.pixelSize: 24
                color: Theme.textColor()
                horizontalAlignment: Text.AlignHCenter
                rightPadding: 50
            }

            indicator: Rectangle {
                implicitWidth: 48
                implicitHeight: 26
                x: control.width - width - 50
                y: height / 2
                radius: 13
                color: control.checked ? "black" : "white"
                border.color: control.checked ? "black" : "darkgray"

                Rectangle {
                    x: control.checked ? parent.width - width : 0
                    width: 26
                    height: 26
                    radius: 13
                    color: "#ffffff"
                    border.color: control.checked ? "black" : "darkgray"
                }
            }
            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                visible: control.down || control.highlighted
                color: control.down ? "transparent" : "transparent"
            }
        }
    }
}

