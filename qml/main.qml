import QtQuick
import QtQuick.Controls
import "qrc:/qml/"
import Theme 1.0
Window {
    id: mainWindow
    width: 800
    height: 600
    title: qsTr("HardGuard")
    visible: true
    color:{
        Theme.backgroundColor()
    }
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "/qml/qml/MainPage.qml"
    }
    Behavior on color {
        ColorAnimation {
            duration: 500
        }
    }
}
