pragma Singleton
import QtQuick

QtObject {
    id: themeManager
    property int light: 0
    property int dark: 1

    property int currentTheme: dark

    function toggleTheme() {
        currentTheme = (currentTheme === light) ? dark : light;
    }

    function backgroundColor() {
        return currentTheme === dark ? "black" : "white";
    }

    function textColor() {
        return currentTheme === dark ? "white" : "black";
    }

    function borderColor() {
        return currentTheme === dark ? "white" : "black";
    }
}
