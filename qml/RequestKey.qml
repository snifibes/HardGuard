import QtQuick
import QtQuick.Layouts
Item {
    id: requestKeyPage
    Rectangle {
        id: requestkeyRec
        color: "transparent"
        radius: 10
        border.width: 2
        border.color: "darkgray"
        width: Math.min(parent.width - 10, 400)
        height: Math.min(parent.height, 200)
        anchors.centerIn: parent
        GridLayout{
            rows: 4
            columns: 1
            anchors.fill: parent
            Text {
                id: passError
                text: qsTr("Неверный пароль")
                font.pixelSize: 14
                color: "red"
                visible: false
                Layout.row: 1
                Layout.alignment: Qt.AlignHCenter
            }
            Text{
                id: passText
                text: "Пароль"
                font.pixelSize: Math.max(12, parent.width / 16)
                color: Theme.textColor()
                Layout.row: 0
                Layout.leftMargin: 10
            }
            InputField {
                id: textInputBorder
                Layout.row: 2
                Layout.leftMargin: 10
                Layout.preferredWidth: parent.width - 60
                mode: TextInput.Password
            }
            CustomButton{
                buttonText: "◉"
                fontSize: Math.max(12, parent.width / 16)
                height: textInputBorder.height
                Layout.row: 2
                Layout.rightMargin: 10
                Layout.preferredWidth: 35
                Layout.alignment: Qt.AlignRight
                onClickAction: function(){
                    textInputBorder.mode = textInputBorder.mode === TextInput.Password ? TextInput.Normal : TextInput.Password
                }
            }
            CustomButton {
                id: confirmKeyButton
                buttonText: "ОК"
                fontSize: Math.max(12, parent.width / 16)
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: parent.width / 2 - 20
                Layout.rightMargin: 10
                Layout.row: 3
                onClickAction: function() {
                    if(manager.comparePassword(textInputBorder.inputText)){
                        stackView.push("Passwords.qml");
                    }
                    else{
                        passError.visible = true
                    }
                }
            }

            CustomButton {
                id: cancelRequest
                buttonText: "Отмена"
                fontSize: Math.max(12, parent.width / 16)
                Layout.preferredWidth: parent.width / 2 - 20
                Layout.leftMargin: 10
                Layout.row: 3
                onClickAction: function() {
                    stackView.pop();
                }
            }
        }
    }
}


