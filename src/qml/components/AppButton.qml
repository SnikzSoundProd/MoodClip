// AppButton.qml — refined button. Drop-in replacement for src/qml/components/AppButton.qml
// Adds optional `iconName` (Icons singleton key) and `ghost` variant.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control

    implicitHeight: 26
    leftPadding: 10
    rightPadding: 10
    topPadding: 0
    bottomPadding: 0

    property bool primary: false
    property bool ghost: false
    property bool danger: false
    /** Icons singleton key, e.g. "save". Leave empty for text-only. */
    property string iconName: ""
    property int iconSize: 13

    background: Rectangle {
        color: {
            if (!control.enabled)      return control.ghost ? "transparent" : Theme.bgTertiary
            if (control.primary) {
                if (control.pressed)   return Qt.darker(Theme.accent, 1.18)
                if (control.hovered)   return Qt.lighter(Theme.accent, 1.06)
                return Theme.accent
            }
            if (control.ghost) {
                if (control.pressed)   return Theme.bgTertiary
                if (control.hovered)   return Theme.bgSecondary
                return "transparent"
            }
            if (control.pressed)       return Theme.bgTertiary
            if (control.hovered)       return Theme.bgSecondary
            return Theme.bgElevated
        }
        border.color: control.primary ? "transparent" : (control.ghost ? "transparent" : Theme.borderLight)
        border.width: 1
        radius: Theme.radiusSmall
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    contentItem: RowLayout {
        spacing: 6
        Icon {
            visible: control.iconName.length > 0
            name: control.iconName
            size: control.iconSize
            stroke: 1.7
            color: {
                if (!control.enabled) return Theme.textMuted
                if (control.primary) return "#FFFFFF"
                if (control.danger)  return Theme.danger
                return Theme.textPrimary
            }
            Layout.alignment: Qt.AlignVCenter
        }
        Label {
            text: control.text
            visible: control.text.length > 0
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeSmall
            font.weight: control.primary ? Font.Medium : Font.Normal
            color: {
                if (!control.enabled) return Theme.textMuted
                if (control.primary) return "#FFFFFF"
                if (control.danger)  return Theme.danger
                if (control.ghost)   return Theme.textSecondary
                return Theme.textPrimary
            }
            verticalAlignment: Text.AlignVCenter
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
    }
}
