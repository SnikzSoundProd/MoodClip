// StoryboardFrameEditor.qml — the large editor surface for the active frame.
// New file — place at src/qml/components/StoryboardFrameEditor.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: editor
    color: "transparent"

    property int frameNumber: 1
    property string description: ""
    property string prompt: ""
    property string notes: ""
    property string imagePath: ""

    signal userDescriptionChanged(string description)
    signal userPromptChanged(string prompt)
    signal userNotesChanged(string notes)
    signal userImagePathChanged(string imagePath)

    RowLayout {
        anchors.fill: parent
        spacing: 24

        // ── Image area (left, 2.39:1 region) ───────────────────────────────
        Rectangle {
            Layout.preferredWidth: parent.width * 0.55
            Layout.fillHeight: true
            radius: Theme.radiusMedium
            color: Theme.bgSecondary
            border.color: Theme.borderLight
            border.width: 1
            clip: true

            // Diagonal placeholder stripes
            Canvas {
                anchors.fill: parent
                visible: editor.imagePath.length === 0
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.fillStyle = Theme.borderLight
                    ctx.globalAlpha = 0.5
                    for (var i = -height; i < width; i += 28) {
                        ctx.fillRect(i, 0, 14, height + height)
                    }
                }
            }

            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: editor.imagePath
                fillMode: Image.PreserveAspectCrop
                visible: editor.imagePath.length > 0
            }

            // Corner tag
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 12
                anchors.topMargin: 12
                radius: 999
                color: "#B3141420"
                implicitWidth: cornerRow.implicitWidth + 16
                implicitHeight: 22
                RowLayout {
                    id: cornerRow
                    anchors.centerIn: parent
                    spacing: 6
                    Icon { name: "film"; size: 10; color: "#FFFFFF" }
                    Label {
                        text: qsTr("FRAME #%1").arg(editor.frameNumber.toString().padStart(2, "0"))
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        color: "#FFFFFF"
                    }
                }
            }

            // Corner tools
            RowLayout {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 10
                anchors.topMargin: 10
                spacing: 4

                IconButton {
                    iconName: "sparkles"
                    iconSize: 13
                    ToolTip.text: qsTr("Generate with AI")
                    ToolTip.visible: hovered
                }
                IconButton {
                    iconName: "upload"
                    iconSize: 13
                    ToolTip.text: qsTr("Upload reference")
                    ToolTip.visible: hovered
                    onClicked: fileDialog.open()
                }
                IconButton {
                    iconName: "trash"
                    iconSize: 13
                    danger: true
                    visible: editor.imagePath.length > 0
                    onClicked: { editor.imagePath = ""; editor.userImagePathChanged("") }
                }
            }

            // Centered drop hint
            Rectangle {
                anchors.centerIn: parent
                visible: editor.imagePath.length === 0
                color: Theme.bgElevated
                border.color: Theme.borderLight
                border.width: 1
                radius: 999
                implicitWidth: dropRow.implicitWidth + 24
                implicitHeight: 32
                RowLayout {
                    id: dropRow
                    anchors.centerIn: parent
                    spacing: 6
                    Icon { name: "image"; size: 12; color: Theme.textMuted }
                    Label {
                        text: qsTr("Drop frame image · 2.39 : 1")
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        color: Theme.textMuted
                    }
                }
            }

            // Whole-area click → open file picker (only when empty)
            MouseArea {
                anchors.fill: parent
                enabled: editor.imagePath.length === 0
                cursorShape: Qt.PointingHandCursor
                onClicked: fileDialog.open()
            }

            FileDialog {
                id: fileDialog
                fileMode: FileDialog.OpenFile
                nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.webp)"]
                onAccepted: {
                    editor.imagePath = selectedFile.toString()
                    editor.userImagePathChanged(editor.imagePath)
                }
            }
        }

        // ── Fields (right) ─────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            // Description
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: qsTr("DESCRIPTION")
                        font.family: Theme.fontUI
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.2
                        color: Theme.textMuted
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: qsTr("%1 ch").arg(descArea.text.length)
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        color: Theme.textMuted
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: Theme.bgElevated
                    border.color: Theme.borderLight
                    border.width: 1
                    radius: Theme.radiusMedium

                    TextArea {
                        id: descArea
                        anchors.fill: parent
                        anchors.margins: 4
                        font.family: Theme.fontUI
                        font.pixelSize: Theme.sizeBody
                        color: Theme.textPrimary
                        wrapMode: TextEdit.WordWrap
                        placeholderText: qsTr("What happens in this frame?")
                        placeholderTextColor: Theme.textMuted
                        background: null
                        text: editor.description
                        onEditingFinished: editor.userDescriptionChanged(text)
                    }
                }
            }

            // AI Prompt
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: qsTr("AI PROMPT")
                        font.family: Theme.fontUI
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.2
                        color: Theme.textMuted
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: qsTr("For ComfyUI / Runway / Pika")
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        color: Theme.textMuted
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 110
                    color: Theme.bgElevated
                    border.color: Theme.borderLight
                    border.width: 1
                    radius: Theme.radiusMedium

                    // AI mark badge
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 10
                        width: 22; height: 22
                        radius: 6
                        color: Theme.accentSoft
                        Icon { anchors.centerIn: parent; name: "sparkles"; size: 12; color: Theme.accentInk }
                    }

                    TextArea {
                        id: promptArea
                        anchors.fill: parent
                        anchors.leftMargin: 40
                        anchors.topMargin: 8
                        anchors.rightMargin: 8
                        anchors.bottomMargin: 8
                        font.family: Theme.fontMono
                        font.pixelSize: 12
                        color: Theme.textPrimary
                        wrapMode: TextEdit.WordWrap
                        placeholderText: qsTr("A precise prompt for your AI generator…")
                        placeholderTextColor: Theme.textMuted
                        background: null
                        text: editor.prompt
                        onEditingFinished: editor.userPromptChanged(text)
                    }
                }
            }

            // Notes
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Label {
                    text: qsTr("NOTES")
                    font.family: Theme.fontUI
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.2
                    color: Theme.textMuted
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    color: Theme.bgElevated
                    border.color: Theme.borderLight
                    border.width: 1
                    radius: Theme.radiusMedium

                    TextArea {
                        id: notesArea
                        anchors.fill: parent
                        anchors.margins: 4
                        font.family: Theme.fontUI
                        font.pixelSize: 12
                        color: Theme.textSecondary
                        wrapMode: TextEdit.WordWrap
                        placeholderText: qsTr("Director's notes, references, things to fix…")
                        placeholderTextColor: Theme.textMuted
                        background: null
                        text: editor.notes
                        onEditingFinished: editor.userNotesChanged(text)
                    }
                }
            }
        }
    }
}
