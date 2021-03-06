import QtQuick 2.5
import QtQuick.Controls 2.12

import OpenTodoList 1.0 as OTL

import "../Components"
import "../Fonts"
import "../Windows"
import "../Widgets"
import "../Utils"

ItemPage {
    id: page

    property OTL.Todo item: OTL.Todo {}
    property OTL.Library library: null
    property OTL.TodoList todoList: null
    property Item parentDrawer: null

    signal closePage()
    signal openPage(var component, var properties)

    readonly property alias editingNotes: d.editingNotes

    function finishEditingNotes() {
        itemNotesEditor.finishEditing();
    }

    function deleteItem() {
        confirmDeleteDialog.deleteItem(item);
    }

    function renameItem() {
        renameItemDialog.renameItem(item);
    }

    function setDueDate() {
        dueDateSelectionDialog.selectedDate = item.dueTo;
        dueDateSelectionDialog.open();
    }

    function find() {
        filterBar.edit.forceActiveFocus();
        d.reopenDrawer();
    }

    function attach() {
        d.attach();
    }

    title: Markdown.markdownToPlainText(item.title)
    topLevelItem: todoList

    QtObject {
        id: d

        property bool editingNotes: false

        signal attach()

        function reopenDrawer() {
            if (page.parentDrawer) {
                page.parentDrawer.open();
            }
        }
    }

    DeleteItemDialog {
        id: confirmDeleteDialog
        onAccepted: {
            page.closePage();
        }
        onClosed: d.reopenDrawer()
    }

    DateSelectionDialog {
        id: dueDateSelectionDialog
        onAccepted: page.item.dueTo = selectedDate
        onClosed: d.reopenDrawer()
    }

    RenameItemDialog {
        id: renameItemDialog
        onClosed: d.reopenDrawer()
    }

    OTL.ItemsSortFilterModel {
        id: tasks
        sourceModel: OTL.ItemsModel {
            cache: OTL.Application.cache
            parentItem: page.item.uid
            searchString: filterBar.text
        }
    }

    TextInputBar {
        id: filterBar
        placeholderText: qsTr("Search term 1, search term 2, ...")
        symbol: Icons.faTimes
        showWhenNonEmpty: true
        closeOnButtonClick: true
    }

    ItemScrollView {
        id: scrollView
        anchors {
            left: parent.left
            right: parent.right
            top: filterBar.bottom
            bottom: parent.bottom
        }
        item: page.todoList

        TodosWidget {
            id: todosWidget

            width: parent.width
            model: tasks
            title: qsTr("Tasks")
            headerItemVisible: false
            allowCreatingNewItems: true
            newItemPlaceholderText: qsTr("Add new task...")
            onCreateNewItem: {
                var properties = {
                    "title": title
                };
                var task = OTL.Application.addTask(
                            page.library,
                            page.item,
                            properties);
            }
            headerComponent: Column {
                id: column
                width: parent.width

                ItemPageHeader {
                    item: page.item
                }

                ItemProgressEditor {
                    item: page.item
                    width: parent.width
                }

                ItemDueDateEditor {
                    id: itemDueDateEditor
                    item: page.item
                    width: parent.width
                }

                ItemNotesEditor {
                    id: itemNotesEditor
                    item: page.item
                    width: parent.width

                    Binding {
                        target: d
                        property: "editingNotes"
                        value: itemNotesEditor.editing
                    }
                }

            }

            footerComponent: Attachments {
                id: attachments
                item: page.item
                width: parent.width

                Connections {
                    target: d
                    onAttach: attach()
                }

                Connections {
                    target: openFileDialog
                    onClosed: d.reopenDrawer()
                }
            }
        }
    }

    PullToRefreshOverlay {
        anchors.fill: scrollView
        refreshEnabled: page.library.hasSynchronizer
        flickable: todosWidget
        onRefresh: OTL.Application.syncLibrary(page.library)
    }

    AutoScrollOverlay {
        anchors.fill: parent
        flickable: todosWidget
    }
}

