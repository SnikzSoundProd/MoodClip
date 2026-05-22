// ScriptEditor.qml — refined Scenario view. Drop-in replacement.
// Changes vs original:
//   • Hero title + meta strip (words / chars / lines / est. minutes)
//   • Quick-insert tags rendered as colored TagPill buttons (was flat asterisks)
//   • Tag inserter now wraps the line, not just inserts text
//   • Editor padding/sizing follows Theme.pad / sizeBody
//
// Behavior unchanged: writes back to targetClip.script.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: scriptEditor
    color: Theme.bgPrimary
    clip: true

    property var targetClip: null
    readonly property var tags: ["SCENE", "SHOT", "TRANSITION", "DIALOGUE", "SFX", "MUSIC"]

    Behavior on color { ColorAnimation { duration: Theme.animSlow } }

    function wordCount(s) {
        if (!s) return 0
        return s.trim().split(/\s+/).filter(function(w){ return w.length > 0 }).length
    }
    function readMinutes(s) {
        return Math.max(1, Math.round(wordCount(s) / 140))
    }
    function lineCount(s) {
        if (!s) return 0
        return s.split("\n").length
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 22
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        anchors.bottomMargin: 22
        spacing: 14

        // ── Hero header ────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            ColumnLayout {
                spacing: 2
                Label {
                    text: qsTr("Scenario")
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.sizeDisplay
                    font.bold: true
                    font.letterSpacing: -0.4
                    color: Theme.textPrimary
                }
                Label {
                    text: qsTr("Narrative pass · %1 lines").arg(lineCount(textArea.text))
                    font.family: Theme.fontUI
                    font.pixelSize: 12
                    color: Theme.textMuted
                }
            }

            Item { Layout.fillWidth: true }

            AppButton { iconName: "refresh"; ghost: true; text: qsTr("Reformat") }
            AppButton { iconName: "sparkles"; text: qsTr("Expand with AI") }
            AppButton {
                iconName: "save"
                primary: true
                text: qsTr("Save")
                enabled: projectManager.hasUnsavedChanges
                onClicked: projectManager.saveProject()
            }
        }

        // ── Meta strip ─────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            Repeater {
                model: [
                    { v: wordCount(textArea.text),   k: qsTr("words") },
                    { v: textArea.text.length,        k: qsTr("chars") },
                    { v: readMinutes(textArea.text),  k: qsTr("min read") },
                    { v: lineCount(textArea.text),    k: qsTr("lines") }
                ]
                RowLayout {
                    spacing: 4
                    Label {
                        text: modelData.v
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.textSecondary
                    }
                    Label {
                        text: modelData.k
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        color: Theme.textMuted
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }

        // ── Editor ─────────────────────────────────────────────────────────
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            TextArea {
                id: textArea
                font.family: Theme.fontMono
                font.pixelSize: Theme.sizeBody
                color: Theme.textPrimary
                wrapMode: TextEdit.WordWrap
                leftPadding: 14
                rightPadding: 14
                topPadding: 12
                bottomPadding: 12
                background: Rectangle {
                    color: Theme.bgElevated
                    border.color: Theme.borderLight
                    border.width: 1
                    radius: Theme.radiusMedium
                }
                text: targetClip ? targetClip.script : ""
                onTextChanged: {
                    if (targetClip) {
                        targetClip.script = text
                        projectManager.markUnsaved()
                    }
                }
                placeholderText: qsTr("Write your video scenario here…\n\nUse the quick-insert buttons below to tag SCENE / SHOT / TRANSITION / DIALOGUE / SFX / MUSIC lines.")
                placeholderTextColor: Theme.textMuted
            }
        }

        // ── Quick-insert pill tags ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: qsTr("QUICK INSERT")
                font.family: Theme.fontMono
                font.pixelSize: 10
                font.letterSpacing: 0.5
                color: Theme.textMuted
            }

            Repeater {
                model: tags

                Rectangle {
                    implicitHeight: 24
                    implicitWidth: pillLabel.implicitWidth + 22
                    radius: 999
                    color: pillHover.containsMouse ? Theme.tagBg(modelData) : Theme.bgElevated
                    border.color: Theme.borderLight
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Label {
                        id: pillLabel
                        anchors.centerIn: parent
                        text: modelData
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 0.4
                        color: pillHover.containsMouse ? Theme.tagInk(modelData) : Theme.textSecondary
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    MouseArea {
                        id: pillHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Insert on its own line — matches the visual model
                            var tag = "[" + modelData + "] "
                            var pos = textArea.cursorPosition
                            var before = textArea.text.substring(0, pos)
                            var prefix = (before.length === 0 || before.endsWith("\n")) ? "" : "\n"
                            textArea.insert(pos, prefix + tag)
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }
    }
}
