import QtQuick 2.9
import QtQuick.Controls 2.2

import OpenTodoList.UI 1.0

Dialog {
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: Math.min(parent.width * 0.7, 800)
    parent: ApplicationWindow.window.contentItem
    padding: Globals.defaultPadding
    dim: true
}
