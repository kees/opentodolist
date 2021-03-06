import QtQuick 2.9
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

import OpenTodoList 1.0

import "../Components"
import "../Fonts"

Page {
    id: page

    property alias errors: view.model

    ListView {
        id: view

        anchors.fill: parent
        ScrollBar.vertical: ScrollBar {}

        delegate: RowLayout {
            width: view.width
            spacing: 2
            ToolButton {
                symbol: Icons.faWarning
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: modelData
            }
        }
    }
}
