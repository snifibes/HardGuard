import QtQuick
import QtQuick.Controls
Popup {
    property int popupWidth
    property int popupHeight
    property int popupHeightAnimation
    property var popupX
    property var popupY
    property int popupClosePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    id: popupStart
    width: popupWidth
    height: popupHeight
    x: popupX
    y: popupY
    modal: true
    focus: true
    closePolicy: popupClosePolicy
    palette.active.mid: "darkgray"
    palette.active.window: Theme.backgroundColor()
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 350; easing.type: Easing.OutQuad }
        NumberAnimation { property: "popupHeight"; from: popupHeightAnimation/2; to: popupHeightAnimation; duration: 150; easing.type: Easing.OutQuad }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.OutQuad }
        NumberAnimation { property: "popupHeight"; from: popupHeightAnimation; to: popupHeightAnimation/2; duration: 350; easing.type: Easing.OutQuad }
    }
    background: Rectangle{
        color: Theme.backgroundColor()
        border.width: 2
        border.color: "darkgray"
        radius: 10
    }
}
