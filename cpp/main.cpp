#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QMetaObject>
#include "h/QmlClipboardAdapter.h"
#include "h/AccountsManager.h"
#include "h/QrCodeImageProvider.h"
#include "h/CodeDecoderVideoSink.h"

#ifdef Q_OS_ANDROID
#include <6.9.0/QtCore/private/qandroidextras_p.h>

bool checkPermission(QString permissionString){
    auto r = QtAndroidPrivate::checkPermission(permissionString).result();
    if (r == QtAndroidPrivate::Denied)
    {
        r = QtAndroidPrivate::requestPermission(permissionString).result();
        if (r == QtAndroidPrivate::Denied)
            return false;
    }
    return true;
}
#endif



int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/HardGuard/qml/main.qml"));

    QmlClipboardAdapter clipBoard;
    engine.rootContext()->setContextProperty("clipBoard", &clipBoard);

    AccountManager manager;
    engine.rootContext()->setContextProperty("manager", &manager);

    engine.addImageProvider("qrcodeprovider", new QrCodeImageProvider(&manager));

    qmlRegisterSingletonType(QUrl("qrc:/qml/qml/Theme.qml"), "Theme", 1, 0, "Theme");

    CodeDecoderVideoSink decoder;
    engine.rootContext()->setContextProperty("codeDecoder", &decoder);

    QObject::connect(&decoder, &CodeDecoderVideoSink::tagFound, &manager, &AccountManager::onDataReceived);

    QObject context;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    QObject::connect(&app, &QCoreApplication::aboutToQuit, &context, [&]() {
        QList<QObject*> rootObjects = engine.rootObjects();
        QObject *passItem = rootObjects.first()->findChild<QObject*>("passitem");
        if (passItem) {
            QMetaObject::invokeMethod(passItem, "saveAccounts");
        }
    });
    engine.load(url);

#ifdef Q_OS_ANDROID
    checkPermission("android.permission.CAMERA");
    checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    checkPermission("android.permission.MANAGE_EXTERNAL_STORAGE");
#endif

    return app.exec();
}
