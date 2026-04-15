#include "h/userAccounts.h"
#include <QDebug>

UserAccounts::UserAccounts(QObject *parent) : QObject(parent) {}

UserAccounts::UserAccounts(const UserAccounts &other)
    : QObject(other.parent()),
    platformName(other.platformName),
    userLogin(other.userLogin),
    userPassword(other.userPassword) {}

UserAccounts &UserAccounts::operator=(const UserAccounts &other) {
    if (this != &other) {
        platformName = other.platformName;
        userLogin = other.userLogin;
        userPassword = other.userPassword;
    }
    return *this;
}

void UserAccounts::setAccounts(const std::string &platform, const std::string &login, const std::string &password) {
    platformName = platform;
    userLogin = login;
    userPassword = password;
}
