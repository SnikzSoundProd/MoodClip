import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

Dialog {
    id: dialog
    title: qsTr("Export")
    modal: true
    width: 460
    anchors.centerIn: parent

    property var exportFolder: null

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
            spacing: 8

            Item { Layout.fillWidth: true }

            AppButton {
                text: qsTr("Close")
                onClicked: dialog.reject()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 16

        Label {
            text: qsTr("Export folder")
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeSmall
            color: Theme.textMuted
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            AppTextField {
                id: pathField
                Layout.fillWidth: true
                readOnly: true
                placeholderText: qsTr("Choose a folder…")
                text: dialog.exportFolder ? dialog.exportFolder.toString().replace("file:///", "") : ""
                font.family: Theme.fontMono
                font.pixelSize: Theme.sizeSmall
            }

            AppButton {
                text: qsTr("Browse…")
                onClicked: folderDialog.open()
            }
        }

        // Styled CheckBox
        CheckBox {
            id: includeImagesCheck
            checked: true

            indicator: Rectangle {
                implicitWidth: 18
                implicitHeight: 18
                radius: Theme.radiusSmall - 1
                border.color: includeImagesCheck.checked ? Theme.accent : Theme.border
                border.width: 1
                color: includeImagesCheck.checked ? Theme.accent : Theme.bgPrimary
                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Label {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.textInverse
                    visible: includeImagesCheck.checked
                }
            }

            contentItem: Label {
                leftPadding: includeImagesCheck.indicator.width + 8
                text: qsTr("Include images in markdown")
                font.family: Theme.fontUI
                font.pixelSize: Theme.sizeBody
                color: Theme.textPrimary
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.borderLight
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Export Markdown")
                enabled: dialog.exportFolder !== null
                onClicked: {
                    exportManager.exportMarkdown(projectManager.activeClip, storyboardModel, dialog.exportFolder, includeImagesCheck.checked)
                    dialog.close()
                }
            }

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Export JSON")
                primary: true
                enabled: dialog.exportFolder !== null
                onClicked: {
                    exportManager.exportJson(projectManager.activeClip, storyboardModel, dialog.exportFolder)
                    dialog.close()
                }
            }
        }
    }

    FolderDialog {
        id: folderDialog
        onAccepted: dialog.exportFolder = selectedFolder
    }
}
