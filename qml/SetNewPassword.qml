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
        height: Math.min(parent.height, 320)
        anchors.centerIn: parent
        GridLayout{
            rowSpacing: 5
            rows: 7
            columns: 1
            anchors.fill: parent
            Text{
                id: oldPass
                text: "Старый пароль"
                Layout.row: 0
                Layout.column: 0
                font.pixelSize: Math.max(12, parent.width / 16)
                color: Theme.textColor()
                Layout.leftMargin: 10
            }

            InputField {
                id: oldInputBorder
                Layout.row: 1
                Layout.column: 0
                mode: TextInput.Password
                Layout.leftMargin: 10
                Layout.preferredWidth: parent.width - 20
            }

            Text{
                id: reqPasText
                text: "Новый пароль"
                Layout.row: 2
                Layout.column: 0
                font.pixelSize: Math.max(12, parent.width / 16)
                color: Theme.textColor()
                Layout.leftMargin: 10
            }

            InputField {
                id: textInputBorder
                Layout.row: 3
                Layout.column: 0
                mode: TextInput.Password
                Layout.leftMargin: 10
                Layout.preferredWidth: parent.width - 20
            }
            Text{
                id: repPasText
                text: "Повторите пароль"
                Layout.row: 4
                Layout.column: 0
                font.pixelSize: Math.max(12, parent.width / 16)
                color: Theme.textColor()
                Layout.leftMargin: 10
            }

            InputField {
                id: textRepeatInputBorder
                Layout.row: 5
                Layout.column: 0
                Layout.leftMargin: 10
                mode: TextInput.Password
                Layout.preferredWidth: parent.width - 20
            }
            CustomButton {
                buttonText: "ОК"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 6
                Layout.column: 0
                Layout.rightMargin: 10
                Layout.bottomMargin: 10
                Layout.preferredWidth: parent.width / 2 - 20
                Layout.alignment: Qt.AlignRight
                onClickAction: function() {
                    if(manager.comparePassword(oldInputBorder.inputText)){
                        if(textInputBorder.inputText === textRepeatInputBorder.inputText){
                            if(textInputBorder.textLength >= 12){
                                manager.setPassword(textInputBorder.inputText);
                                stackView.pop();
                            }
                            else{
                                oldPasswordError.visible = false
                                newPasswordError.visible = false
                                lengthPassError.visible = true
                            }
                        }
                        else{
                            oldPasswordError.visible = false
                            lengthPassError.visible = false
                            newPasswordError.visible = true
                        }
                    }
                    else{
                        newPasswordError.visible = false
                        lengthPassError.visible = false
                        oldPasswordError.visible = true
                    }
                }
            }

            CustomButton {
                id: cancelRequest
                buttonText: "Отмена"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 6
                Layout.column: 0
                Layout.leftMargin: 10
                Layout.bottomMargin: 10
                Layout.preferredWidth: parent.width / 2 - 20
                Layout.alignment: Qt.AlignLeft
                onClickAction: function() {
                    stackView.pop();
                }
            }
        }
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

    Text{
        id: oldPasswordError
        color: "red"
        text: "Введеный пароль не соответствует действующему"
        anchors{
            bottom: requestkeyRec.top
            horizontalCenter: requestkeyRec.horizontalCenter
        }
        font.pixelSize: 14
        visible: false
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
}



