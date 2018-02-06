import QtQuick 2.5
import QtQuick.Controls 2.2


import OpenTodoList 1.0
import OpenTodoList.UI 1.0

Page {
    id: page

    property ImageTopLevelItem item: ImageTopLevelItem {}
    property var library: null

    signal openPage(var component, var properties)
    signal closePage()

    function deleteItem() {
        confirmDeleteDialog.open();
    }

    CenteredDialog {
        id: confirmDeleteDialog

        title: qsTr("Delete Image?")

        Label {
            text: qsTr("Are you sure you want to delete the image <strong>%1</strong>? This action " +
                       "cannot be undone.").arg(item.displayTitle)
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Globals.defaultMargin
            }
            wrapMode: Text.WordWrap
        }

        standardButtons: Dialog.Ok | Dialog.Cancel
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        onAccepted: {
            item.deleteItem();
            page.closePage();
        }
    }

    Rectangle {
        color: Colors.lightItemColor(item.color)
        opacity: 0.3
        anchors.fill: parent
    }

    ScrollView {
        id: scrollView

        anchors.fill: parent

        Column {
            width: scrollView.width
            spacing: Globals.defaultMargin

            ItemTitle {
                item: page.item
                width: parent.width
            }

            Image {
                id: image
                visible: item.validImage
                source: item.imageUrl
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Globals.defaultMargin * 2
                }
                asynchronous: true
                fillMode: Image.PreserveAspectFit
            }

            StickyNote {
                id: note
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Globals.defaultMargin
                }
                title: qsTr("Notes")
                text: Globals.markdownToHtml(item.notes)
                onClicked: page.openPage(notesEditor, {item: page.item})
            }

            ItemDueDateEditor {
                item: page.item
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Globals.defaultMargin * 2
                }
            }

            Attachments {
                item: page.item
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Globals.defaultMargin * 2
                }
            }

            TagsEditor {
                item: page.item
                library: page.library
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Globals.defaultMargin * 2
                }
            }

            Item {
                height: Globals.defaultMargin
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Globals.defaultMargin * 2
                }
            }

            Component {
                id: notesEditor
                RichTextEditor {
                    backgroundColor: Colors.lightItemColor(page.item.color)
                }
            }
        }
    }
}




