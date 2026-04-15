#ifndef USERACCOUNTS_H
#define USERACCOUNTS_H
#include <QObject>
class UserAccounts : public QObject{
    Q_OBJECT
public:
    explicit UserAccounts(QObject *parent = nullptr);
    UserAccounts(const UserAccounts &other);  // Конструктор копирования
    UserAccounts &operator=(const UserAccounts &other);  // Оператор присваивания
    UserAccounts(const std::string &platform, const std::string &login, const std::string &password)
        : platformName(platform), userLogin(login), userPassword(password) {}
    Q_INVOKABLE void setAccounts(const std::string &platform, const std::string &login, const std::string &password);
    std::string get_string() {
        return platformName + " " + userLogin + " " + userPassword;
    }
    std::string getPlatformName() const {return platformName;}
    std::string getuserLogin() const {return userLogin;}
    std::string getuserPassword() const {return userPassword;}

private:
    std::string platformName;
    std::string userLogin;
    std::string userPassword;
};

#endif // USERACCOUNTS_H
