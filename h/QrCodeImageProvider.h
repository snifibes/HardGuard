#ifndef QRCODEIMAGEPROVIDER_H
#define QRCODEIMAGEPROVIDER_H
#include <QQuickImageProvider>
#include <QImage>
#include <QFile>
#include <QZXing.h>
#include "h/AccountsManager.h"

class QrCodeImageProvider : public QQuickImageProvider {
public:
    QrCodeImageProvider(AccountManager *manager) : QQuickImageProvider(QQuickImageProvider::Image), manager(manager) {}

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override {
        Q_UNUSED(requestedSize);
        Q_UNUSED(id);
        QImage qrCode = manager->saveQrCode();

        if (size)
            *size = qrCode.size();
        return qrCode;
    }

private:
    AccountManager *manager;
};
#endif // QRCODEIMAGEPROVIDER_H
