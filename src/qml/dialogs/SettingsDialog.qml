import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Dialog {
    id: dialog
    title: qsTr("Settings")
    modal: true
    width: 420
    anchors.centerIn: parent

    background: Rectangle {
        color: Theme.bgElevated
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMedium
        Behavior on color { ColorAnimation { duration: Theme.animSlow } }
    }

    header: Rectangle {
        height: 48
        color: "transparent"

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: dialog.title
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeBody
            font.bold: true
            color: Theme.textPrimary
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Theme.border
        }
    }

    footer: Rectangle {
        height: 56
        color: "transparent"

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: Theme.border
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12

            Item { Layout.fillWidth: true }

            AppButton {
                text: qsTr("Done")
                primary: true
                onClicked: dialog.accept()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 20

        // Appearance section
        Label {
            text: qsTr("Appearance")
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeBody
            font.bold: true
            color: Theme.textPrimary
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: qsTr("Theme")
                font.family: Theme.fontUI
                font.pixelSize: Theme.sizeBody
                color: Theme.textSecondary
                Layout.preferredWidth: 80
            }

            ComboBox {
                model: [qsTr("Light"), qsTr("Dark")]
                currentIndex: projectManager.isDarkTheme ? 1 : 0
                onCurrentIndexChanged: projectManager.isDarkTheme = (currentIndex === 1)
                Layout.fillWidth: true

                background: Rectangle {
                    color: parent.pressed ? Theme.bgTertiary : (parent.hovered ? Theme.bgSecondary : Theme.bgPrimary)
                    border.color: Theme.border
                    border.width: 1
                    radius: Theme.radiusSmall
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
                contentItem: Label {
                    leftPadding: 10
                    text: parent.displayText
                    font.family: Theme.fontUI
                    font.pixelSize: Theme.sizeBody
                    color: Theme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                }
                indicator: Label {
                    x: parent.width - width - 8
                    y: (parent.height - height) / 2
                    text: "⌄"
                    font.pixelSize: Theme.sizeSmall
                    color: Theme.textSecondary
                }
                popup: Popup {
                    y: parent.height + 2
                    width: parent.width
                    padding: 4
                    background: Rectangle {
                        color: Theme.bgElevated
                        border.color: Theme.border
                        border.width: 1
                        radius: Theme.radiusSmall
                    }
                    contentItem: ListView {
                        implicitHeight: contentHeight
                        model: parent.parent.popup.visible ? parent.parent.delegateModel : null
                        clip: true
                    }
                }
                delegate: ItemDelegate {
                    width: parent ? parent.width - 8 : 0
                    contentItem: Label {
                        text: modelData
                        font.family: Theme.fontUI
                        font.pixelSize: Theme.sizeBody
                        color: Theme.textPrimary
                    }
                    background: Rectangle {
                        color: parent.highlighted ? Theme.accentSoft : "transparent"
                        radius: Theme.radiusSmall - 2
                    }
                    highlighted: parent ? parent.highlightedIndex === index : false
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: qsTr("Font size")
                font.family: Theme.fontUI
                font.pixelSize: Theme.sizeBody
                color: Theme.textSecondary
                Layout.preferredWidth: 80
            }

            Slider {
                id: fontSlider
                from: 10
                to: 20
                value: 14
                stepSize: 1
                Layout.fillWidth: true

                background: Rectangle {
                    x: fontSlider.leftPadding
                    y: fontSlider.topPadding + fontSlider.availableHeight / 2 - height / 2
                    width: fontSlider.availableWidth
                    height: 4
                    radius: 2
                    color: Theme.bgTertiary

                    Rectangle {
                        width: fontSlider.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: Theme.accent
                    }
                }

                handle: Rectangle {
                    x: fontSlider.leftPadding + fontSlider.visualPosition * (fontSlider.availableWidth - width)
                    y: fontSlider.topPadding + fontSlider.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: fontSlider.pressed ? Qt.darker(Theme.accent, 1.1) : Theme.accent
                    border.color: Theme.bgElevated
                    border.width: 2
                }
            }

            Label {
                text: fontSlider.value + "px"
                font.family: Theme.fontMono
                font.pixelSize: Theme.sizeSmall
                color: Theme.textMuted
                Layout.preferredWidth: 32
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderLight }

        // Project section
        Label {
            text: qsTr("Project")
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeBody
            font.bold: true
            color: Theme.textPrimary
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: qsTr("Auto-save")
                font.family: Theme.fontUI
                font.pixelSize: Theme.sizeBody
                color: Theme.textSecondary
                Layout.preferredWidth: 80
            }

            Switch {
                id: autoSaveSwitch
                checked: false

                indicator: Rectangle {
                    implicitWidth: 40
                    implicitHeight: 22
                    radius: 11
                    color: autoSaveSwitch.checked ? Theme.accent : Theme.bgTertiary
                    border.color: autoSaveSwitch.checked ? Theme.accent : Theme.border
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Rectangle {
                        x: autoSaveSwitch.checked ? parent.width - width - 3 : 3
                        y: (parent.height - height) / 2
                        width: 16
                        height: 16
                        radius: 8
                        color: Theme.bgElevated
                        Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                    }
                }

                contentItem: Label {
                    leftPadding: autoSaveSwitch.indicator.width + 8
                    text: autoSaveSwitch.checked ? qsTr("Enabled") : qsTr("Coming soon")
                    font.family: Theme.fontUI
                    font.pixelSize: Theme.sizeBody
                    color: autoSaveSwitch.checked ? Theme.textPrimary : Theme.textMuted
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
