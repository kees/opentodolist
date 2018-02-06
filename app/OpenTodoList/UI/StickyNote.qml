import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import OpenTodoList 1.0
import OpenTodoList.UI 1.0

MouseArea {
    id: note
    
    property string title: qsTr("Sticky Note Title")
    property string text: qsTr("Note Content")
    property color backgroundColor: Colors.light
    property color titleBackgroundColor: Colors.midlight
    property color borderColor: Colors.mid
    property var checkBoxList: undefined
    property bool showCheckBoxList: false
    
    property int __shadowOffset: hoverEnabled && containsMouse ? Globals.defaultMargin : 0
    
    implicitWidth: 200
    implicitHeight: titleLabel.height + contentLabel.height +
                    checkBockListView.height + Globals.defaultMargin * 6
    
    Behavior on __shadowOffset { SmoothedAnimation { duration: 500 } }
    
    Component {
        id: checkBoxListItemDelegate
        
        Item {
            width: parent.width
            height: itemRow.height + Globals.minButtonHeight / 2
            
            Rectangle {
                width: parent.width
                height: 1
                color: Colors.midlight
                visible: index > 0
            }

            RowLayout {
                id: itemRow
                visible: object !== undefined // TODO: Check why this is required at all!
                width: parent.width
                y: Globals.minButtonHeight / 4
                Label {
                    font.family: Fonts.symbols.name
                    text: object.done ? Fonts.symbols.faCheckSquareO : Fonts.symbols.faSquareO
                }
                Label {
                    text: object.displayTitle
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }
    
    Rectangle {
        id: shadow
        anchors {
            fill: parent
            leftMargin: Globals.defaultMargin * 2 + __shadowOffset
            topMargin: Globals.defaultMargin * 2 + __shadowOffset
            rightMargin: Globals.defaultMargin * 0.5 - __shadowOffset
            bottomMargin: Globals.defaultMargin * 0.5 - __shadowOffset
        }
        color: Colors.shadow
        opacity: note.hoverEnabled & note.containsMouse ? 0.5 : 0.1
        Behavior on opacity { SmoothedAnimation { duration: 500 } }
    }
    
    Rectangle {
        id: notesItemBackground
        anchors {
            fill: parent
            margins: Globals.defaultMargin - __shadowOffset * 0.5
        }
        color: note.backgroundColor
        border {
            width: 1
            color: note.borderColor
        }
    }
    
    Item {
        id: notesItem
        
        anchors {
            fill: notesItemBackground
            margins: 0
            bottomMargin: 1
        }
        clip: true
        
        Rectangle {
            id: titleLabelBackground
            
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: notesItemBackground.border.width
            }
            height: titleLabel.height + Globals.defaultMargin * 2
            color: note.titleBackgroundColor
        }

        Label {
            id: titleLabel
            
            text: title
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Globals.defaultMargin
            }
            font.bold: true
            elide: Text.ElideRight
        }
        
        Column {
            
            anchors {
                left: parent.left
                right: parent.right
                top: titleLabelBackground.bottom
                margins: Globals.defaultMargin
            }
            spacing: Globals.defaultMargin
            
            Column {
                id: checkBockListView
                
                anchors {
                    left: parent.left
                    right: parent.right
                }
                
                Repeater {
                    id: checkBoxListRepeater
                    visible: note.showCheckBoxList
                    delegate: checkBoxListItemDelegate
                    model: checkBoxList
                }
            }
            
            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                wrapMode: Text.WordWrap
                text: qsTr("All Todos Done :)")
                opacity: 0.5
                font.italic: true
                visible: showCheckBoxList && (checkBoxList.count === 0)
            }
            
            Label {
                id: contentLabel
                
                text: note.text
                anchors {
                    left: parent.left
                    right: parent.right
                }
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}
