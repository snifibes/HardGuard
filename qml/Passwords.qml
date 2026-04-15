import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import QtCore
Item {
    id: passitem
    objectName: "passitem"
    property string searchText: ""
    property var filteredModel: ListModel{}
    ListModel {
        id: accountsModel
    }
    function filterAccounts() {
        filteredModel.clear();

        for (var i = 0; i < accountsModel.count; i++) {
            var item = accountsModel.get(i);
            var matchesSearch = item.platform.toLowerCase().indexOf(searchText.toLowerCase()) !== -1;

            if (matchesSearch) {
                filteredModel.append(item);
            }
        }
    }

    Component.onCompleted: {
        manager.accountsLoaded.connect(function(accounts) {
            if (accountsModel !== null){
                accountsModel.clear()
                for (var i = 0; i < accounts.length; i++) {
                    accountsModel.append(accounts[i]);
                }
                filterAccounts();
            }
        });
        manager.callLoadFromFile();
    }

    function deleteAccount(index) {
        if (index >= 0 && index < accountsModel.count) {
            accountsModel.remove(index);
        }
        if (index >= 0 && index < filteredModel.count) {
            filteredModel.remove(index);
        }
        filterAccounts();
    }

    function clearModel(){
        accountsModel.clear()
    }

    function saveAccounts(){
        manager.deleteAccounts();
        for (var i = 0; i < accountsModel.count; i++) {
            manager.addAccount(accountsModel.get(i).platform, accountsModel.get(i).login, accountsModel.get(i).password)
        }
        manager.callSaveToFile();
    }

    RowLayout {
        id: menu
        spacing: 10
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 10
        CustomButton {
            id: cancelRequest
            buttonText: "Назад"
            buttonWidth: 100
            onClickAction: function() {
                stackView.pop();
                stackView.pop();
                passitem.saveAccounts()
                passitem.clearModel()
            }
        }
        CustomButton{
            id: changePassBtn
            buttonText: "Изменить пароль для входа"
            fontSize: 10
            buttonWidth: 140
            onClickAction: function() {
                stackView.push("SetNewPassword.qml");
            }
        }
    }

    Rectangle{
        id: mainRec
        color: "transparent"
        radius: 10
        border.width: 2
        border.color: "darkgray"
        width: Math.min(parent.width - 10, 1400)
        height: Math.min(parent.height - 200, 700)
        anchors{
            top: menu.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 10
        }
        Rectangle{
            id: marginRec
            color: "transparent"
            width: mainRec.width - 10
            height: mainRec.height - 10
            anchors.centerIn: parent

            Rectangle {
                id: rightRec
                color: "transparent"
                width: marginRec.width
                height: marginRec.height
                Rectangle{
                    id: searchRec
                    width: parent.width
                    height: 35
                    color: "transparent"
                    border.width: 2
                    border.color: "darkgray"
                    radius: 5
                    TextInput {
                        activeFocusOnTab: true
                        id: inputFieldInput
                        width: parent.width - 10
                        height: parent.height - 10
                        color: Theme.textColor()
                        font.pixelSize: 18
                        anchors.centerIn: parent
                        wrapMode: TextInput.NoWrap
                        horizontalAlignment: TextInput.AlignLeft
                        clip: true
                        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                        onTextChanged: {
                            searchText = text;
                            filterAccounts();
                        }
                        onFocusChanged: {
                            if (focus) {
                                searchRec.border.color = Theme.borderColor()
                                searchRec.border.width = 3
                            }
                            else{
                                searchRec.border.color = "darkgray";
                                searchRec.border.width = 2;
                            }
                        }
                    }
                }
                ListView {
                    id: list
                    width: parent.width
                    height: parent.height - searchRec.height - 10
                    spacing: 10
                    model: searchText.length > 0 ? filteredModel : accountsModel
                    clip: true
                    anchors.top: searchRec.bottom
                    anchors.topMargin: 10
                    onContentYChanged: {
                        if(contentY < 0){
                            contentY = 0
                        }
                        if(contentY > contentHeight - height && contentHeight > height){
                            contentY = contentHeight - height
                        }
                    }
                    WheelHandler {
                        id: wheelHandler
                        target: list
                        onWheel: (event) => {
                            list.contentY -= event.angleDelta.y * 0.2
                        }
                    }
                    delegate: Rectangle {
                        width: list.width
                        height: 150
                        color: "transparent"
                        border.width: 2
                        border.color: "darkgray"
                        radius: 5
                        GridLayout{
                            id: gridLayout
                            rows: 3
                            columns: 1
                            anchors.fill: parent
                            Text{
                                text: model.platform
                                color: Theme.textColor()
                                font.pixelSize: parent.height * 0.15
                                elide: Text.ElideRight
                                Layout.row: 0
                                Layout.column: 0
                                Layout.leftMargin: 10
                                Layout.maximumWidth: parent.width - deleteBtn.width - 15
                            }
                            CustomButton {
                                id: deleteBtn
                                buttonText: "Удалить"
                                Layout.preferredWidth: parent.width / 4
                                fontSize: Math.max(12, parent.width / 40)
                                onClickAction: function() {
                                    deletePanel.open()
                                    deletePanel.accIndex = model.index
                                    deletePanel.accName = model.login
                                    deletePanel.accPlatform = model.platform
                                }
                                Layout.row: 0
                                Layout.column: 0
                                Layout.alignment: Qt.AlignRight
                                Layout.rightMargin: 10
                            }
                            Text {
                                id: loginTxt
                                text: "Логин:"
                                color: Theme.textColor()
                                font.pixelSize: parent.height * 0.15
                                elide: Text.ElideRight
                                Layout.row: 1
                                Layout.column: 0
                                Layout.leftMargin: 10
                            }
                            Text {
                                text: model.login
                                color: Theme.textColor()
                                font.pixelSize: parent.height * 0.15
                                elide: Text.ElideRight
                                Layout.leftMargin: loginTxt.width + 10
                                Layout.row: 1
                                Layout.column: 0
                                Layout.maximumWidth: parent.width - copyLogin.width - loginTxt.width - 15
                            }
                            CustomButton {
                                id: copyLogin
                                buttonText: "Копировать"
                                Layout.preferredWidth: parent.width / 4
                                fontSize: Math.max(12, parent.width / 40)
                                onClickAction: function() {
                                    clipBoard.setText(model.login)
                                }
                                Layout.row: 1
                                Layout.column: 0
                                Layout.alignment: Qt.AlignRight
                                Layout.rightMargin: 10
                            }
                            Text {
                                id: textPass
                                text: "Пароль: ***"
                                color: Theme.textColor()
                                font.pixelSize: parent.height * 0.15
                                elide: Text.ElideRight
                                Layout.row: 2
                                Layout.column: 0
                                Layout.leftMargin: 10
                                Layout.maximumWidth: parent.width - copyPassword.width - 15

                            }
                            CustomButton {
                                id: copyPassword
                                buttonText: "Копировать"
                                Layout.preferredWidth: parent.width / 4
                                fontSize: Math.max(12, parent.width / 40)
                                onClickAction: function() {
                                   clipBoard.setText(model.password)
                                }
                                Layout.row: 2
                                Layout.column: 0
                                Layout.alignment: Qt.AlignRight
                                Layout.rightMargin: 10
                            }
                        }
                    }
                }
            }
        }
    }

    CustomPopup{
        id: deletePanel
        popupWidth: Math.min(parent.width - 10, 400)
        popupHeight: Math.min(parent.height, 150)
        popupHeightAnimation: Math.min(parent.height, 150)
        popupX: (parent.width - deletePanel.popupWidth) / 2
        popupY: (parent.height - deletePanel.popupHeight) / 2
        property int accIndex: -1
        property string accName: ""
        property string accPlatform: ""
        GridLayout{
            rowSpacing: 10
            rows: 2
            columns: 2
            anchors.fill: parent
            Text{
                id: deleteText
                text: "Удалить:"
                color: Theme.textColor()
                font.pixelSize: Math.max(12, parent.width / 16)
                Layout.row: 0
                Layout.column: 0
            }
            Text{
                text: deletePanel.accName + "("+ deletePanel.accPlatform +")"+"?"
                color: Theme.textColor()
                font.pixelSize: Math.max(12, parent.width / 16)
                Layout.row: 0
                Layout.column: 1
                elide: Text.ElideRight
                Layout.maximumWidth: parent.width - deleteText.width - 15
            }
            CustomButton{
                id: confirmDeleteAccButton
                buttonText: "Да"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 1
                Layout.column: 1
                Layout.preferredWidth: 150
                Layout.fillWidth: true
                onClickAction: function(){
                    passitem.deleteAccount(deletePanel.accIndex)
                    passitem.saveAccounts()
                    deletePanel.close()
                }
            }
            CustomButton{
                id: cancelDeleteAccButton
                buttonText: "Нет"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 1
                Layout.column: 0
                Layout.preferredWidth: 150
                Layout.fillWidth: true
                onClickAction: function(){
                    deletePanel.close()
                }
            }
        }
    }

    CustomPopup{
        id: addPanel
        popupWidth: Math.min(parent.width - 10, 400)
        popupHeight: Math.min(parent.height, 250)
        popupHeightAnimation: Math.min(parent.height, 250)
        popupX: (parent.width - addPanel.popupWidth) / 2
        popupY: (parent.height - addPanel.popupHeight) / 2
        GridLayout{
            rowSpacing: 10
            rows: 5
            columns: 2
            anchors.fill: parent
            Text{
                text: "Платформа"
                color: Theme.textColor()
                font.pixelSize: Math.max(12, parent.width / 16)
                Layout.row: 0
                Layout.column: 0
                Layout.fillWidth: true
            }
            Rectangle{
                id: platformFieldRec
                Layout.preferredWidth: 200
                Layout.preferredHeight: 35
                color: "transparent"
                border.width: 2
                border.color: "darkgray"
                radius: 5
                Layout.row: 0
                Layout.column: 1
                Layout.fillWidth: true
                TextInput {
                    activeFocusOnTab: true
                    id: platformField
                    width: parent.width - 10
                    height: parent.height - 10
                    color: Theme.textColor()
                    font.pixelSize: 18
                    anchors.centerIn: parent
                    wrapMode: TextInput.NoWrap
                    horizontalAlignment: TextInput.AlignLeft
                    clip: true
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                    onFocusChanged: {
                        if (focus) {
                            platformFieldRec.border.color = Theme.borderColor()
                            platformFieldRec.border.width = 3
                        }
                        else{
                            platformFieldRec.border.color = "darkgray";
                            platformFieldRec.border.width = 2;
                        }
                    }
                }
            }
            Text{
                text: "Логин"
                color: Theme.textColor()
                font.pixelSize: Math.max(12, parent.width / 16)
                Layout.row: 1
                Layout.column: 0
            }
            InputField {
                id: loginField
                Layout.row: 1
                Layout.column: 1
                Layout.fillWidth: true
                Layout.preferredWidth: 100
                Layout.preferredHeight: 35
            }
            Text{
                text: "Пароль"
                color: Theme.textColor()
                font.pixelSize: Math.max(12, parent.width / 16)
                Layout.row: 2
                Layout.column: 0
            }
            InputField {
                id: passwordField
                mode: TextInput.Password
                Layout.row: 2
                Layout.column: 1
                Layout.fillWidth: true
                Layout.preferredWidth: 100
                Layout.preferredHeight: 35
            }
            CustomButton {
                id: addAccountButton
                buttonText: "Добавить"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 4
                Layout.column: 1
                Layout.preferredWidth: 150
                Layout.fillWidth: true
                onClickAction: function(){
                    if (platformField.text && loginField.inputText && passwordField.inputText) {
                        var newAccount = {
                            platform: platformField.text,
                            login: loginField.inputText,
                            password: passwordField.inputText
                        };
                        accountsModel.append(newAccount);
                        passitem.saveAccounts()
                        platformField.text = "";
                        loginField.inputText = "";
                        passwordField.inputText = "";
                        if (fieldsError.visible === true){
                            fieldsError.visible = false;
                        }
                    } else {
                        fieldsError.visible = true;
                    }
                }
            }
            CustomButton {
                id: cancelAddAccountButton
                buttonText: "Отмена"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 4
                Layout.column: 0
                Layout.preferredWidth: 150
                Layout.fillWidth: true
                onClickAction: function(){
                    platformField.text = ""
                    loginField.inputText = ""
                    passwordField.inputText = ""
                    fieldsError.visible = false
                    addPanel.close()
                }
            }
            Text{
                id: fieldsError
                text: "Заполните все поля"
                font.pixelSize: 14
                color: "red"
                visible: false
                Layout.row: 3
                Layout.column: 1
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
    RowLayout{
        width: mainRec.width
        anchors{
            horizontalCenter: mainRec.horizontalCenter
            top: mainRec.bottom
            topMargin: 20
        }
        CustomButton{
            id: fileButton
            buttonText: "Файл"
            buttonWidth: 80
            buttonHeight: 80
            fontSize: Math.max(12, parent.width / 40)
            buttonRadius: 10
            backgroundColor: Theme.backgroundColor()
            Layout.fillWidth: true
            onClickAction: function(){
                filePanel.open()
            }
        }
        CustomButton{
            id: qrButton
            buttonText: "QR"
            buttonWidth: 80
            buttonHeight: 80
            fontSize: Math.max(12, parent.width / 40)
            buttonRadius: 10
            backgroundColor: Theme.backgroundColor()
            Layout.fillWidth: true
            onClickAction: function(){
                qrCodePanel.open()
            }
        }
        CustomButton{
            id: addAccButton
            buttonText: "+"
            buttonWidth: 80
            buttonHeight: 80
            fontSize: 40
            buttonRadius: 10
            backgroundColor: Theme.backgroundColor()
            Layout.fillWidth: true
            onClickAction: function(){
                addPanel.open()
            }
        }
    }


    CustomPopup{
        id: qrCodePanel
        popupWidth: Math.min(parent.width - 10, 400)
        popupHeight: Math.min(parent.height, 300)
        popupHeightAnimation: Math.min(parent.height, 300)
        popupX: (parent.width - qrCodePanel.popupWidth) / 2
        popupY: (parent.height - qrCodePanel.popupHeight) / 2

        GridLayout{
            anchors.fill: parent
            rows: 4
            columns: 1
            Text{
                id: qrInfo
                text: "   Импорт/Экспорт\nс помощью QR-кода"
                font.pixelSize: Math.max(12, parent.width / 16)
                color: Theme.textColor()
                Layout.row: 0
                Layout.column: 0
                Layout.alignment: Qt.AlignHCenter
            }

            CustomButton{
                id: importFromQRButton
                buttonText: "Импортировать"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 1
                Layout.column: 0
                Layout.preferredWidth: 250
                Layout.fillWidth: true
                Layout.margins: 10
                onClickAction: function(){
                    qrCodePanel.close()
                    stackView.push("ImportFromQR.qml")
                }
            }
            CustomButton{
                id: exportFromQRButton
                buttonText: "Экспортировать"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 2
                Layout.column: 0
                Layout.preferredWidth: 250
                Layout.fillWidth: true
                Layout.margins: 10
                onClickAction: function(){
                    qrCodePanel.close()
                    passitem.saveAccounts()
                    stackView.push("ExportFromQR.qml")
                }
            }
            CustomButton {
                id: cancelQRButton
                buttonText: "Отмена"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 3
                Layout.column: 0
                Layout.preferredWidth: 150
                Layout.fillWidth: true
                Layout.margins: 10
                onClickAction: function(){
                    qrCodePanel.close()
                }
            }
        }
    }

    CustomPopup{
        id: filePanel
        popupWidth: Math.min(parent.width - 10, 400)
        popupHeight: Math.min(parent.height, 300)
        popupHeightAnimation: Math.min(parent.height, 300)
        popupX: (parent.width - filePanel.popupWidth) / 2
        popupY: (parent.height - filePanel.popupHeight) / 2

        GridLayout{
            anchors.fill: parent
            rows: 4
            columns: 1
            Text{
                id: fileInfo
                text: " Импорт/Экспорт\nс помощью файла"
                font.pixelSize: Math.max(12, parent.width / 16)
                color: Theme.textColor()
                Layout.row: 0
                Layout.column: 0
                Layout.alignment: Qt.AlignHCenter
            }

            CustomButton{
                id: importFromFileButton
                buttonText: "Импортировать"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 1
                Layout.column: 0
                Layout.preferredWidth: 250
                Layout.fillWidth: true
                Layout.margins: 10
                onClickAction: function(){
                    filePanel.close()
                    passitem.saveAccounts()
                    exportFileDialog.open()
                }
            }
            CustomButton{
                id: exportFromFileButton
                buttonText: "Экспортировать в загрузки"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 2
                Layout.column: 0
                Layout.preferredWidth: 250
                Layout.fillWidth: true
                Layout.margins: 10
                onClickAction: function(){
                    filePanel.close()
                    passitem.saveAccounts()
                    manager.callSaveToFileUrl()
                }
            }
            CustomButton {
                id: cancelFileButton
                buttonText: "Отмена"
                fontSize: Math.max(12, parent.width / 16)
                Layout.row: 3
                Layout.column: 0
                Layout.preferredWidth: 150
                Layout.fillWidth: true
                Layout.margins: 10
                onClickAction: function(){
                    filePanel.close()
                }
            }
        }
    }

    FileDialog{
        id: exportFileDialog
        currentFolder: StandardPaths.standardLocations(StandardPaths.DownloadLocation)[0]
        onAccepted: {
            stackView.push("RequestKeyFromFile.qml", {fileName:currentFile})
        }
    }
}




