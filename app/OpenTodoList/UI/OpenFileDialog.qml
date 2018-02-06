import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.2

import OpenTodoList 1.0
import OpenTodoList.UI 1.0

CenteredDialog {
    id: dialog

    property url fileUrl: ""
    property alias nameFilters: files.nameFilters

    title: qsTr("Select a File")
    modal: true
    standardButtons: fileUrl != "" ? (Dialog.Ok | Dialog.Cancel) : Dialog.Cancel

    header: RowLayout {
        Symbol {
            symbol: Fonts.symbols.faArrowUp
            onClicked: files.folder = App.cleanPath(files.folder + "/..")
        }
    }

    ListView {
        implicitWidth: 300
        implicitHeight: 400
        header: Label {
            text: qsTr("Selected file: ") + "<strong>" +
                  App.urlToLocalFile(dialog.fileUrl) + "</strong>"
            width: parent.width
            clip: true
            wrapMode: Text.WordWrap
        }
        clip: true


        model: FolderListModel {
            id: files
            showFiles: true
            showDirs: true
            showOnlyReadable: true
            showDotAndDotDot: false

            onFolderChanged: {
                var f = folder.toString();
                f = App.urlToLocalFile(f);
                if (f.endsWith("/..")) {
                    f = f.substring(0, f.length - 3);
                    if (f === "") {
                        f = "/";
                    }
                    folder = App.localFileToUrl(f);
                }
            }
        }
        delegate: MouseArea {
            width: parent.width
            height: childrenRect.height + Globals.defaultMargin
            onClicked: {
                if (fileIsDir) {
                    files.folder = App.cleanPath(files.folder +
                                                 "/" + fileName);
                } else {
                    dialog.fileUrl = fileURL;
                }
            }

            Rectangle {
                anchors.fill: row
                visible: dialog.fileUrl === fileURL
                color: Colors.highlight
            }

            RowLayout {
                id: row

                y: Globals.defaultMargin / 2
                x: Globals.defaultMargin / 2
                width: parent.width - Globals.defaultMargin

                Symbol {
                    symbol: fileIsDir ? Fonts.symbols.faFolderOpenO : Fonts.symbols.faFileO
                }
                Label {
                    Layout.fillWidth: true
                    text: fileName
                    wrapMode: Text.WordWrap
                    color: dialog.fileUrl == fileURL ? Colors.highlightedText : Colors.windowText
                }
            }
        }
    }
}
