import QtQuick

Rectangle {
    id: inputFieldRec
    property alias inputText: inputFieldInput.text
    property int textLength: 0
    property int mode: TextInput.Normal
    property int inputTextWidth: 150
    width: inputTextWidth
    height: 35
    color: "transparent"
    border.width: 2
    border.color: "darkgray"
    radius: 5
    TextInput {
        activeFocusOnTab: true
        id: inputFieldInput
        width: parent.width - 10
        height: parent.height - 10
        color: Theme.textColor()
        font.pixelSize: 18
        echoMode: mode
        anchors.centerIn: parent
        wrapMode: TextInput.NoWrap
        horizontalAlignment: TextInput.AlignLeft
        clip: true
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
        onTextChanged: {
            text = text.replace(/[^a-zA-Z0-9!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?`~]/g, "")
            textLength = text.length
        }
        onFocusChanged: {
            if (focus) {
                inputFieldRec.border.color = Theme.borderColor()
                inputFieldRec.border.width = 3
            }
            else{
                inputFieldRec.border.color = "darkgray";
                inputFieldRec.border.width = 2;
            }
        }
    }
}
