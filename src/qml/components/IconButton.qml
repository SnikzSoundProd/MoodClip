// IconButton.qml — square icon-only button. Companion to AppButton.qml.
// Usage:
//   IconButton { iconName: "trash"; danger: true; onClicked: ... }

import QtQuick
import QtQuick.Controls

Button {
    id: control

    property string iconName: ""
    property int iconSize: 14
    property bool danger: false
    property bool active: false   // toggled state

    implicitWidth: 26
    implicitHeight: 26

    background: Rectangle {
        color: {
            if (control.danger && control.hovered) return Theme.danger
            if (control.active)  return Theme.accentSoft
            if (control.pressed) return Theme.bgTertiary
            if (control.hovered) return Theme.bgSecondary
            return "transparent"
        }
        border.color: "transparent"
        radius: Theme.radiusSmall
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    contentItem: Icon {
        name: control.iconName
        size: control.iconSize
        color: {
            if (control.danger && control.hovered) return "#FFFFFF"
            if (control.active)  return Theme.accentInk
            if (control.hovered) return Theme.textPrimary
            return Theme.textSecondary
        }
    }
}
