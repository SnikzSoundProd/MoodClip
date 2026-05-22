import QtQuick
import QtQuick.Controls

TextField {
    id: control
    font.family: Theme.fontUI
    font.pixelSize: Theme.sizeBody
    color: Theme.textPrimary
    placeholderTextColor: Theme.textMuted
    leftPadding: 10
    rightPadding: 10
    topPadding: 6
    bottomPadding: 6
    implicitHeight: 34

    background: Rectangle {
        color: Theme.bgPrimary
        border.color: control.activeFocus ? Theme.accent : Theme.border
        border.width: control.activeFocus ? 2 : 1
        radius: Theme.radiusSmall
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
        Behavior on color { ColorAnimation { duration: Theme.animSlow } }
    }

    cursorDelegate: Rectangle {
        width: 2
        color: Theme.accent
    }
}
