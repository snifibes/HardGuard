import QtQuick
import QtQuick.Layouts
Item {
    property string generatedPassword: ""
    property int num
    function generatePassword(length) {
        var charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+\-=[\]{};':\"\\|,.<>/?`~"
        var password = ""
        for (var i = 0; i < length; i++) {
            var randomIndex = Math.floor(Math.random() * charset.length)
            password += charset[randomIndex]
        }
        return password
    }
    Rectangle {
        id: requestkeyRec
        color: "transparent"
        radius: 10
        border.width: 2
        border.color: "darkgray"
        width: Math.min(parent.width, 400)
        height: Math.min(parent.height, 200)
        anchors.centerIn: parent
        GridLayout{
            anchors.fill: parent
            rows: 4
            columns: 2
            Text{
                text: "Длина пароля:"
                font.pixelSize: Math.max(12, parent.width / 16)
                color: Theme.textColor()
                Layout.row: 0
                Layout.column: 0
                Layout.leftMargin: 10
            }
            InputField{
                id: lengthInputBorder
                Layout.preferredWidth: parent.width/5
                Layout.row: 0
                Layout.column: 1
                Layout.leftMargin: 10
            }

            Text{
                text: "Генератор пароля"
                font.pixelSize: Math.max(12, parent.width / 16)
                color: Theme.textColor()
                Layout.row: 1
                Layout.column: 0
                Layout.columnSpan: 2
                Layout.leftMargin: 10
            }
            InputField {
                id: textInputBorder
                Layout.preferredWidth: parent.width - 20
                Layout.row: 2
                Layout.column: 0
                Layout.columnSpan: 2
                Layout.leftMargin: 10
            }

            CustomButton {
                id: copy
                buttonText: "Копировать"
                onClickAction: function() {
                    clipBoard.setText(textInputBorder.inputText)
                }
                Layout.row: 3
                Layout.column: 0
                Layout.preferredWidth: 150
                Layout.leftMargin: 10
                Layout.fillWidth: true
                fontSize: Math.max(12, parent.width / 18)
            }

            CustomButton {
                buttonText: "Сгенерировать"
                Layout.row: 3
                Layout.column: 1
                Layout.preferredWidth: 200
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.fillWidth: true
                fontSize: Math.max(12, parent.width / 18)
                onClickAction: function() {
                    num = parseInt(lengthInputBorder.inputText)
                    if(num > 7 && num <= 100){
                        lengthPassError.visible = false
                        generatedPassword = generatePassword(num)
                        textInputBorder.inputText = generatedPassword
                    }
                    else{
                        lengthPassError.visible = true
                    }
                }
            }
        }
    }
    Text{
        id: lengthPassError
        color: "red"
        text: "Пароль должен быть длиной от 8 до 100 символов"
        anchors{
            top: requestkeyRec.bottom
            horizontalCenter: requestkeyRec.horizontalCenter
        }
        font.pixelSize: 14
        visible: false
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
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            onClickAction: function() {
                stackView.pop();
            }
        }
    }

}


