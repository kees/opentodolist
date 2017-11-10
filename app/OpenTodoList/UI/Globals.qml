pragma Singleton

import QtQuick 2.0
import QtQuick.Controls 2.2

import OpenTodoList 1.0
import OpenTodoList.UI 1.0


Item {
    id: globals
    
    property QtObject appWindow: null
    property int fontPixelSize: typeof(defaultFontPixelSize) === "number" ? defaultFontPixelSize : 32
    property int minButtonHeight: fontPixelSize * (touchEnabled ? 2.5 : 2)
    property bool touchEnabled: enableTouchOptimizations
    property int defaultMargin: fontPixelSize
    
    readonly property int defaultAnimationTime: 500

    readonly property bool selectTextWithMouse: {
        switch (Qt.platform.os) {
            case "android":
            case "ios":
                return false;
            default:
                return true;
        }
    }
    
    function file(relativeName) {
        var result = qmlBaseDirectory + "/" + relativeName;
        result.replace("//", "/");
        return result;
    }
    
}
