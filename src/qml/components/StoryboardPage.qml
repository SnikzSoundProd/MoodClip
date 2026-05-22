import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: page
    color: Theme.bgElevated
    border.color: isCurrent ? Theme.accent : Theme.border
    border.width: isCurrent ? 2 : 1
    radius: Theme.radiusMedium

    property int frameNumber: 1
    property string description: ""
    property string prompt: ""
    property string notes: ""
    property string imagePath: ""
    property bool isCurrent: false

    signal clicked()
    signal userDescriptionChanged(string description)
    signal userPromptChanged(string prompt)
    signal userNotesChanged(string notes)
    signal userImagePathChanged(string imagePath)

    Behavior on border.color {
        ColorAnimation { duration: Theme.animFast }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Top row: number + delete
        RowLayout {
            Layout.fillWidth: true

            Label {
                text: qsTr("#%1").arg(frameNumber)
                font.family: Theme.fontMono
                font.pixelSize: Theme.sizeSmall
                font.bold: true
                color: Theme.accent
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "transparent"
            }

            ToolButton {
                text: "🗑"
                font.pixelSize: 12
                flat: true
                onClicked: {
                    if (storyboardModel.totalFrames > 1)
                        storyboardModel.removeFrame(index)
                }
            }
        }

        // Image area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: Theme.bgTertiary
            border.color: Theme.borderLight
            border.width: 1
            radius: Theme.radiusSmall
            clip: true

            Image {
                anchors.fill: parent
                source: imagePath
                fillMode: Image.PreserveAspectCrop
                visible: imagePath.length > 0
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("Drop image here")
                visible: imagePath.length === 0
                color: Theme.textMuted
                font.family: Theme.fontUI
                font.pixelSize: Theme.sizeSmall
            }

            MouseArea {
                anchors.fill: parent
                onClicked: fileDialog.open()
            }

            FileDialog {
                id: fileDialog
                fileMode: FileDialog.OpenFile
                nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.webp)"]
                onAccepted: {
                    imagePath = selectedFile.toString()
                    page.userImagePathChanged(imagePath)
                }
            }
        }

        // Description
        TextArea {
            id: descInput
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeSmall
            color: Theme.textPrimary
            wrapMode: TextEdit.WordWrap
            placeholderText: qsTr("Frame description...")
            text: description
            background: Rectangle {
                color: Theme.bgSecondary
                radius: Theme.radiusSmall
            }
            onEditingFinished: page.userDescriptionChanged(text)
        }

        // Prompt
        TextArea {
            id: promptInput
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            font.family: Theme.fontMono
            font.pixelSize: Theme.sizeCaption
            color: Theme.textSecondary
            wrapMode: TextEdit.WordWrap
            placeholderText: qsTr("AI prompt...")
            text: prompt
            background: Rectangle {
                color: Theme.bgSecondary
                radius: Theme.radiusSmall
            }
            onEditingFinished: page.userPromptChanged(text)
        }

        // Notes
        TextArea {
            id: notesInput
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeCaption
            color: Theme.textMuted
            wrapMode: TextEdit.WordWrap
            placeholderText: qsTr("Notes...")
            text: notes
            background: Rectangle {
                color: Theme.bgSecondary
                radius: Theme.radiusSmall
            }
            onEditingFinished: page.userNotesChanged(text)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: page.clicked()
        z: -1
    }
}
