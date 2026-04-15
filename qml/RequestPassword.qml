import QtQuick
import QtQuick.Layouts
Item {
    Rectangle {
        id: requestkeyRec
        color: "transparent"
        radius: 10
        border.width: 2
        border.color: "darkgray"
        width: Math.min(parent.width - 10, 400)
        height: Math.min(parent.height, 250)
        anchors.centerIn: parent
        GridLayout{
            rows: 5
            columns: 1
            anchors.fill: parent
            Text{
                id: reqPasText
                text: "Придумайте пароль"
                font.pixelSize: Math.max(12, parent.width / 16)
                color: Theme.textColor()
                Layout.row: 0
                Layout.leftMargin: 10
            }

            InputField {
                id: textInputBorder
                mode: TextInput.Password
                Layout.row: 1
                Layout.leftMargin: 10
                Layout.preferredWidth: parent.width - 20
            }
            Text{
                id: repPasText
                text: "Повторите пароль"
                font.pixelSize: Math.max(12, parent.width / 16)
                Layout.row: 2
                Layout.leftMargin: 10
                color: Theme.textColor()
            }

            InputField {
                id: textRepeatInputBorder
                Layout.row: 3
                Layout.leftMargin: 10
                Layout.preferredWidth: parent.width - 20
                mode: TextInput.Password
            }

            CustomButton {
                id: confirmPassword
                buttonText: "ОК"
                fontSize: Math.max(12, parent.width / 16)
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: parent.width / 2 - 20
                Layout.rightMargin: 10
                Layout.bottomMargin: 10
                Layout.row: 4
                onClickAction: function() {
                    if(textInputBorder.inputText === textRepeatInputBorder.inputText){
                        if(textInputBorder.textLength >= 12){
                            manager.setPassword(textInputBorder.inputText);
                            stackView.push("Passwords.qml");
                        }
                        else{
                            newPasswordError.visible = false
                            lengthPassError.visible = true
                        }
                    }
                    else{
                        lengthPassError.visible = false
                        newPasswordError.visible = true
                    }

                }
            }

            CustomButton {
                id: cancelRequest
                buttonText: "Отмена"
                fontSize: Math.max(12, parent.width / 16)
                Layout.preferredWidth: parent.width / 2 - 20
                Layout.leftMargin: 10
                Layout.bottomMargin: 10
                Layout.row: 4
                onClickAction: function() {
                    stackView.pop();
                }
            }
        }
    }
    Text{
        id: newPasswordError
        color: "red"
        text: "Придуманный пароль не совпадает с повторным"
        anchors{
            bottom: requestkeyRec.top
            horizontalCenter: requestkeyRec.horizontalCenter
        }
        font.pixelSize: 14
        visible: false
    }

    Text{
        id: lengthPassError
        color: "red"
        text: "Пароль должен быть длиной от 12 символов"
        anchors{
            bottom: requestkeyRec.top
            horizontalCenter: requestkeyRec.horizontalCenter
        }
        font.pixelSize: 14
        visible: false
    }
}


