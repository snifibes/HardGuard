QT += quick multimedia concurrent core-private
CONFIG += c++17
SOURCES += \
        cpp/AccountsManager.cpp \
        cpp/UserAccounts.cpp \
        cpp/main.cpp

resources.files = qml/main.qml
resources.prefix = /$${TARGET}
RESOURCES += resources \
    img.qrc \
    qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    qml/AboutProgram.qml \
    qml/CustomButton.qml \
    qml/CustomPopup.qml \
    qml/ExportFromQR.qml \
    qml/ImportFromQR.qml \
    qml/InputField.qml \
    qml/MainPage.qml \
    qml/PasswordGenerator.qml \
    qml/Passwords.qml \
    qml/RequestKey.qml \
    qml/RequestKeyFromFile.qml \
    qml/RequestKeyFromQr.qml \
    qml/RequestPassword.qml \
    qml/SetNewPassword.qml \
    qml/Theme.qml \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle.properties \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml \
    android/res/xml/qtprovider_paths.xml

HEADERS += \
    h/AccountsManager.h \
    h/CodeDecoderVideoSink.h \
    h/QmlClipboardAdapter.h \
    h/QrCodeImageProvider.h \
    h/UserAccounts.h

win32::RC_FILE = icon.rc

contains(ANDROID_TARGET_ARCH,arm64-v8a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android
}

include(src/QZXing.pri)
