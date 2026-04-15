#include "h/AccountsManager.h"
#include "qdir.h"
#include <QFile>
#include <QTextStream>
#include <QCoreApplication>
#include <iostream>
#include <fstream>
#include <sstream>
#include "QZXing.h"
#include "qstandardpaths.h"
#include "qurl.h"
#include <QDateTime>
const int BLOCK_SIZE = 8;
const int NUM_ROUNDS = 32;

void generateKeyFromString(const std::string& input, uint32_t* key) {
    for (int i = 0; i < 8; ++i) {
        key[i] = 0;
    }
    for (int j = 0; j < static_cast<int>(input.size()); ++j) {
        key[j % 8] = (key[j % 8] << 1) ^ (key[j % 8] >> 31) ^ uint32_t(input[j]);
    }
}

void generateHashFromString(const std::string& input, std::string& hash) {
    uint32_t temp = 5381;

    for (unsigned char c : input) {
        temp = ((temp << 5) + temp) + c;
    }

    std::stringstream ss;
    ss << std::hex << std::setfill('0') << std::setw(8) << temp;
    hash = ss.str();
}

std::string hashForInput(std::string s){
    std::string hashS;
    generateHashFromString(s, hashS);
    return hashS;
}

std::string getStringFromAccounts(std::vector<UserAccounts>& accounts, std::string password) {
    std::string result = password + "\n";
    for (int i = 0; i < static_cast<int>(accounts.size()); i++) {
        result += accounts[i].get_string() + "\n";
    }
    return result;
}

void AccountManager::addToAccounts(std::istringstream &stream, std::string line){
    std::getline(stream, line);

    while (std::getline(stream, line)) {
        std::istringstream lineStream(line);
        std::string site, login, password;
        if (lineStream >> site >> login >> password) {
            UserAccounts temp = {site, login, password};
            bool flag = true;
            for(int i = 0; i < accounts.size(); i++){
                if(accounts[i].getuserLogin() == temp.getuserLogin()
                    and accounts[i].getuserPassword() == temp.getuserPassword()
                    and accounts[i].getPlatformName() == temp.getPlatformName()){
                    flag = false;
                }
            }
            if(flag) accounts.emplace_back(temp);
        }
    }
}

void AccountManager::getAccountsFromString(std::string& input) {
    std::istringstream stream(input);
    std::string line;
    addToAccounts(stream, line);
}

uint8_t SBox[8][16] = {
    { 12, 4, 6, 2, 10, 5, 11, 9, 14, 8, 13, 15, 3, 7, 0, 1 },
    { 6, 8, 2, 3, 9, 10, 5, 12, 1, 14, 4, 7, 11, 13, 0, 15 },
    { 11, 3, 5, 8, 2, 15, 10, 13, 14, 1, 7, 4, 12, 9, 6, 0 },
    { 12, 8, 2, 1, 13, 4, 10, 7, 3, 15, 5, 6, 9, 0, 11, 14 },
    { 10, 5, 15, 6, 12, 11, 3, 14, 7, 13, 8, 0, 9, 4, 1, 2 },
    { 9, 7, 12, 8, 5, 14, 3, 0, 6, 2, 10, 1, 11, 13, 4, 15 },
    { 4, 10, 7, 12, 0, 15, 2, 8, 14, 1, 6, 5, 13, 11, 9, 3 },
    { 7, 13, 10, 1, 0, 8, 9, 15, 14, 4, 6, 12, 11, 2, 5, 3 }
}; // Таблица подстановок (Прямо из госта 34.12—2018 Криптографическая защита информации - блочные шифры)

uint32_t rol(uint32_t value, uint8_t bits) {
    return (value << bits) | (value >> (32 - bits));
}

uint32_t g(uint32_t x, uint32_t k) {
    uint32_t temp = (x + k) % 0x100000000;

    uint8_t bytes[4];
    for (int i = 0; i < 4; ++i) {
        bytes[i] = (temp >> (8 * i)) & 0xFF;
        bytes[i] = SBox[i * 2][bytes[i] >> 4] << 4 | SBox[i * 2 + 1][bytes[i] & 0x0F];
    }

    temp = (bytes[3] << 24) | (bytes[2] << 16) | (bytes[1] << 8) | bytes[0];

    return (temp << 11) | (temp >> (32 - 11));
}
void encryptBlock(uint8_t* block, const uint32_t* key) {
    uint32_t n1 = *(uint32_t*)(block);
    uint32_t n2 = *(uint32_t*)(block + 4);

    for (int i = 0; i < NUM_ROUNDS; ++i) {
        uint32_t temp = n1;
        n1 = n2 ^ g(n1, key[i % 8]);
        n2 = temp;
    }

    *(uint32_t*)(block) = n2;
    *(uint32_t*)(block + 4) = n1;
}

void decryptBlock(uint8_t* block, const uint32_t* key) {
    uint32_t n1 = *(uint32_t*)(block);
    uint32_t n2 = *(uint32_t*)(block + 4);

    for (int i = 0; i < NUM_ROUNDS; ++i) {
        uint32_t temp = n1;
        n1 = n2 ^ g(n1, key[7 - (i % 8)]);
        n2 = temp;
    }

    *(uint32_t*)(block) = n2;
    *(uint32_t*)(block + 4) = n1;
}

void AccountManager::deleteAccounts(){
    accounts.clear();
}

void AccountManager::addAccount(const QString &platform, const QString &login, const QString &password) {
    std::string platformStr = platform.toStdString();
    std::string loginStr = login.toStdString();
    std::string passwordStr = password.toStdString();
    UserAccounts account(platformStr, loginStr, passwordStr);
    accounts.push_back(account);
    emit accountsChanged();
}

void AccountManager::saveToFile(const std::string& filename, const std::string& plaintext, const uint32_t* key) {
    std::ofstream outfile(filename, std::ios::binary);

    size_t length = plaintext.size();
    outfile.write(reinterpret_cast<const char*>(&length), sizeof(size_t));
    std::vector<uint8_t> buffer(BLOCK_SIZE, 0);
    for (size_t i = 0; i < length; i += BLOCK_SIZE) {
        memset(buffer.data(), 0, BLOCK_SIZE);
        size_t blockSize = std::min(BLOCK_SIZE, int(length - i));
        memcpy(buffer.data(), plaintext.data() + i, blockSize);
        encryptBlock(buffer.data(), key);
        outfile.write(reinterpret_cast<const char*>(buffer.data()), BLOCK_SIZE);
    }

    outfile.close();
}


std::string AccountManager::loadFromFile(const std::string& filename, const uint32_t* key) {
    std::ifstream infile(filename, std::ios::binary);
    size_t length;

    infile.read(reinterpret_cast<char*>(&length), sizeof(size_t));
    std::string result;
    result.resize(length);
    std::vector<uint8_t> buffer(BLOCK_SIZE, 0);
    for (size_t i = 0; i < length; i += BLOCK_SIZE) {
        infile.read(reinterpret_cast<char*>(buffer.data()), BLOCK_SIZE);

        decryptBlock(buffer.data(), key);
        size_t blockSize = std::min(BLOCK_SIZE, int(length - i));
        memcpy(&result[i], buffer.data(), blockSize);
    }

    infile.close();
    return result;
}

void AccountManager::callSaveToFile() {
    saveToFile("data", getStringFromAccounts(accounts, hash), key);
}

void AccountManager::callSaveToFileUrl() {
#ifdef Q_OS_ANDROID
    QString downloadsPath = "/storage/emulated/0/Download";
#else
    QString downloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
#endif
    QString currentDateTime = QDateTime::currentDateTime().toString("yyyy_MM_dd_HH_mm");
    QString filePath = downloadsPath + "/" + "data_" + currentDateTime ;
    saveToFile(filePath.toStdString(), getStringFromAccounts(accounts, hash), key);
}

void AccountManager::fromDecryptToList(std::string decryptedText){
    size_t pos = decryptedText.find('\n');
    std::string firstLine = decryptedText.substr(0, pos);
    if (firstLine == hash) {
        getAccountsFromString(decryptedText);
        std::vector<UserAccounts> temp = accounts;
        QVariantList accountList;
        for (const auto& account : temp) {
            QVariantMap accountMap;
            accountMap["platform"] = QString::fromStdString(account.getPlatformName());
            accountMap["login"] = QString::fromStdString(account.getuserLogin());
            accountMap["password"] = QString::fromStdString(account.getuserPassword());
            accountList.append(accountMap);
        }
        emit accountsLoaded(accountList);
    }
}


void AccountManager::callLoadFromFile() {
    accounts.clear();
    std::string decryptedText = loadFromFile("data", key);
    fromDecryptToList(decryptedText);
}

std::vector<UserAccounts> AccountManager::getAccounts() const {
    return accounts;
}

void AccountManager::setPassword(const QString newPassword) {
    std::string password = newPassword.toStdString();
    hash.clear();
    generateHashFromString(password, hash);
    generateKeyFromString(password, key);
    saveToFile("data", getStringFromAccounts(accounts, hash), key);
}

bool AccountManager::findDataFile() {
    namespace fs = std::filesystem;
    std::string baseDirectory = "data";
    fs::path path_obj(baseDirectory);
    if (fs::exists(path_obj)) {
        return true;
    }
    return false;
}

bool AccountManager::comparePassword(const QString &inputPassword){
    std::string inputHash;
    uint32_t localkey[8];
    std::string inPass = inputPassword.toStdString();
    generateHashFromString(inPass, inputHash);
    generateKeyFromString(inPass, localkey);

    std::string decryptedText = loadFromFile("data", localkey);
    size_t pos = decryptedText.find('\n');
    std::string firstLine = decryptedText.substr(0, pos);
    if (firstLine == inputHash){
        hash = inputHash;
        for(int i = 0; i < 8; i++){
            key[i] = localkey[i];
        }
        return true;
    }
    else{
        return false;
    }
}


std::string getFixedPath(const QUrl url){
#ifdef Q_OS_ANDROID
    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/tempFile.dat";
    if(QFile::exists(tempPath)){
        QFile::remove(tempPath);
    }

    QFile::copy(url.toString(), tempPath);
    return tempPath.toStdString();
#else
    return url.toLocalFile().toStdString();
#endif
}


void AccountManager::callLoadFromFileUrl(const QUrl &url) {
    std::string decryptedText = loadFromFile(getFixedPath(url), key);
    fromDecryptToList(decryptedText);
}

bool AccountManager::comparePasswordFile(const QUrl filename, const QString &inputPassword){
    std::string inputHash;
    uint32_t localkey[8];
    std::string fixedPath = getFixedPath(filename);
    std::string inPass = inputPassword.toStdString();
    generateHashFromString(inPass, inputHash);
    generateKeyFromString(inPass, localkey);

    std::string decryptedText = loadFromFile(fixedPath, localkey);
    size_t pos = decryptedText.find('\n');
    std::string firstLine = decryptedText.substr(0, pos);
    if (firstLine == inputHash){
        return true;
    }
    else{
        return false;
    }
}

void AccountManager::importAccountsFromQR(){
    std::istringstream stream(encryptedQR);
    std::string line;
    addToAccounts(stream, line);
    callSaveToFile();
}

bool AccountManager::comparePasswordQR(const QString &inputPassword) {
    std::string inputHash;
    uint32_t localkey[8];
    std::string inPass = inputPassword.toStdString();
    generateHashFromString(inPass, inputHash);
    generateKeyFromString(inPass, localkey);
    std::string decryptedText = decryptFromString(qrCodeData.toStdString(), localkey);
    size_t pos = decryptedText.find('\n');
    std::string firstLine = decryptedText.substr(0, pos);
    if (firstLine == inputHash) {
        return true;
    }
    return false;
}

std::string AccountManager::decryptFromString(const std::string &encryptedData, const uint32_t *key) {
    std::istringstream stream(encryptedData, std::ios::binary);

    size_t length;
    stream.read(reinterpret_cast<char*>(&length), sizeof(size_t));

    std::string result;
    result.resize(length);
    std::vector<uint8_t> buffer(BLOCK_SIZE, 0);

    for (size_t i = 0; i < length; i += BLOCK_SIZE) {
        stream.read(reinterpret_cast<char*>(buffer.data()), BLOCK_SIZE);

        decryptBlock(buffer.data(), key);

        size_t blockSize = std::min(BLOCK_SIZE, int(length - i));

        memcpy(&result[i], buffer.data(), blockSize);
    }

    encryptedQR = result;
    return result;
}


void AccountManager::onDataReceived(QByteArray data){
    qrCodeData = data;
}

QImage AccountManager::saveQrCode() {
    std::ifstream infile("data", std::ios::binary);
    if (!infile) {
        return QImage();
    }

    infile.seekg(0, std::ios::end);
    std::streamsize fileSize = infile.tellg();
    infile.seekg(0, std::ios::beg);

    QByteArray rawData;
    rawData.resize(static_cast<int>(fileSize));
    infile.read(rawData.data(), fileSize);
    infile.close();

    if (rawData.isEmpty()) {
        emit qrCodeEmpty();
        return QImage();
    }

    QImage img = QZXing::encodeData(rawData.toBase64(), QZXing::EncoderFormat_QR_CODE);
    if (img.isNull()) {
        emit qrCodeEmpty();
        return QImage();
    }

    emit qrChanged();
    return img;
}

