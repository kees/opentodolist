import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

import OpenTodoList 1.0
import OpenTodoList.UI 1.0

import "LibraryPageLogic.js" as Logic

Menu {
    id: menu

    property Library library

    signal openPage(var component, var properties)

    MenuItem {
        text: qsTr("Rename")
        onClicked: {
            renameLibraryDialog.renameLibrary(menu.library)
        }

        RenameLibraryDialog {
            id: renameLibraryDialog
        }
    }

    MenuItem {
        text: qsTr("Edit Sync Settings")
        enabled: menu.library.hasSynchronizer
        onClicked: {
            var sync = menu.library.createSynchronizer();
            if (sync !== null) {
                var key = sync.secretsKey;
                if (key !== "") {
                    sync.secret = App.secretForSynchronizer(sync);
                }
                var url = Qt.resolvedUrl(sync.type + "SettingsPage.qml");
                menu.openPage(url, {"synchronizer": sync});
            }
        }
    }
    
    MenuItem {
        text: qsTr("Sync Now")
        enabled: menu.library.hasSynchronizer
        onClicked: {
            console.debug("Manually started syncing " + menu.library.name);
            App.syncLibrary(library);
        }
    }
    
    MenuSeparator {}
    
    MenuItem {
        text: qsTr("Sync Log")
        enabled: menu.library.hasSynchronizer
        onClicked: menu.openPage(
                       Qt.resolvedUrl("LogViewPage.qml"),
                       {"log": menu.library.syncLog()})
    }
}
