import QtQuick
Rectangle {
    width: buttonWidth
    height: buttonHeight
    radius: buttonRadius
    color: backgroundColor
    border.width: 2
    border.color: borderColor
    property string borderColor: "darkgray"
    property string backgroundColor: "transparent"
    property string buttonText: ""
    property int buttonWidth: 50
    property int buttonHeight: 45
    property var onClickAction: null
    property int fontSize: 24
    property int buttonRadius: 10
    activeFocusOnTab: true
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (onClickAction) onClickAction()
        }
        onEntered: {
            parent.border.color = Theme.borderColor()
            parent.border.width = 4
        }
        onExited: {
            parent.border.color = "darkgray"
            parent.border.width = 2
        }
    }

    Text {
        text: buttonText
        font.pixelSize: fontSize
        color: Theme.textColor()
        anchors.centerIn: parent
    }
    onFocusChanged: {
        if (focus) {
            border.color = Theme.borderColor()
            border.width = 4
        }
        else{
            border.color = "darkgray";
            border.width = 2;
        }
    }
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
           if (onClickAction) onClickAction()
       }
    }
}
