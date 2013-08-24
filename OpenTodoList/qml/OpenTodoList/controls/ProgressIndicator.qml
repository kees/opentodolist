/*
 *  OpenTodoListDesktopQml - Desktop QML frontend for OpenTodoList
 *  Copyright (C) 2013  Martin Höher <martin@rpdev.net>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0

Item {
    id: indicator

    property int percentage: 25
    property int indicatorBorder: 10
    property bool readOnly: false
    property color innerColor: colors.button
    property color outerColor: colors.complementaryColorDarker2

    signal decreasePressed()
    signal increasePressed()

    function stepUp() {
        return Math.max( 0, Math.min( 100, percentage + 10 ) );
    }

    function stepDown() {
        return Math.max( 0, Math.min( 100, percentage - 10 ) );
    }

    Behavior on percentage { SmoothedAnimation { velocity: 120 } }
    width: 150
    height: 150

    Image {
        source: "image://primitives/pie/fill=" +
                indicator.outerColor +
                ",percentage=" + indicator.percentage
        width: indicator.width
        height: indicator.height
        sourceSize.width: width
        sourceSize.height: height
    }

    Image {
        source: "image://primitives/pie/fill=" +
                indicator.innerColor + ",percentage=100"
        width: indicator.width - indicator.indicatorBorder * 2
        height: indicator.height - indicator.indicatorBorder * 2
        x: indicator.indicatorBorder
        y: indicator.indicatorBorder
        sourceSize.width: width
        sourceSize.height: height
    }

    SymbolButton {
        id: decreaseButton
        text: "\uf068"
        font.pointSize: fonts.p
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: indicator.indicatorBorder * 2
        color: colors.fontColorFor( indicator.innerColor )

        onClicked: indicator.decreasePressed()
    }

    Text {
        anchors.centerIn: parent
        text: indicator.percentage + "%"
        font.pointSize: fonts.p
        color: colors.fontColorFor( indicator.innerColor )
    }

    SymbolButton {
        id: increaseButton
        text: "\uf067"
        font.pointSize: fonts.p
        color: colors.fontColorFor( indicator.innerColor )
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: indicator.indicatorBorder * 2
        }

        onClicked: indicator.increasePressed()
    }
}
