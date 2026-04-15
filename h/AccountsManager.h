#ifndef ACCOUNTMANAGER_H
#define ACCOUNTMANAGER_H

#include <QObject>
#include <QString>
#include <vector>
#include <QList>
#include <QPointer>
#include <QVariantMap>
#include <QImage>
#include "h/UserAccounts.h"
#include <QVideoFrame>
#include <QVideoSink>
#include <QUrl>
class AccountManager : public QObject {
    Q_OBJECT
public:
    explicit AccountManager(QObject *parent = nullptr) : QObject(parent){}
    Q_INVOKABLE void addAccount(const QString &platform, const QString &login, const QString &password);
    Q_INVOKABLE void saveToFile(const std::string& filename, const std::string& plaintext, const uint32_t* key);
    Q_INVOKABLE std::string loadFromFile(const std::string& filename, const uint32_t* key);
    Q_INVOKABLE std::vector<UserAccounts> getAccounts() const;
    Q_INVOKABLE void callSaveToFile();
    Q_INVOKABLE void callSaveToFileUrl();
    Q_INVOKABLE void callLoadFromFile();
    Q_INVOKABLE void callLoadFromFileUrl(const QUrl &url);
    Q_INVOKABLE void deleteAccounts();
    Q_INVOKABLE void setPassword(const QString newPassword);
    Q_INVOKABLE bool findDataFile();
    Q_INVOKABLE bool comparePassword(const QString &inputPassword);
    Q_INVOKABLE bool comparePasswordFile(const QUrl filename, const QString &inputPassword);
    Q_INVOKABLE bool comparePasswordQR(const QString &inputPassword);
    Q_INVOKABLE QImage saveQrCode ();
    std::string decryptFromString(const std::string &encryptedData, const uint32_t *key);
    Q_INVOKABLE void importAccountsFromQR();
    void getAccountsFromString(std::string& input);
    void fromDecryptToList(std::string decryptedText);
    void addToAccounts(std::istringstream& stream, std::string line);

public slots:
    Q_INVOKABLE void onDataReceived(QByteArray data);

signals:
    void accountsChanged();
    void accountsLoaded(const QVariantList &accounts);
    void qrChanged();
    void qrCodeEmpty();

private:
    std::vector<UserAccounts> accounts;
    uint32_t key[8];
    std::string hash;
    QByteArray qrCodeData;
    std::string encryptedQR;
};

#endif // ACCOUNTMANAGER_H
