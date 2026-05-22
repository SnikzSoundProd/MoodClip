// StoryboardView.qml — "shot strip + focused editor" redesign.
// Drop-in replacement for src/qml/components/StoryboardView.qml.
//
// Layout:
//   ┌──────────────────────────────────────────────────────────────┐
//   │  Storyboard          [meta]      [< 03/12 >]  [Dup] [+ Frame]│
//   ├──────────────────────────────────────────────────────────────┤
//   │  [shot 1][shot 2][shot 3]...                ← horizontal strip│
//   ├──────────────────────────────────────────────────────────────┤
//   │  ┌─────────────────────┐  Description                         │
//   │  │   FRAME #03 image   │  AI Prompt (monospace, ai-mark)      │
//   │  │   2.39:1            │  Shot type | Tone                    │
//   │  └─────────────────────┘  Notes                               │
//   └──────────────────────────────────────────────────────────────┘

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Rectangle {
    id: storyboardView
    color: Theme.bgPrimary
    clip: true

    Behavior on color { ColorAnimation { duration: Theme.animSlow } }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 22
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        anchors.bottomMargin: 22
        spacing: 14

        // ── Header ────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            ColumnLayout {
                spacing: 2
                Label {
                    text: qsTr("Storyboard")
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.sizeDisplay
                    font.bold: true
                    font.letterSpacing: -0.4
                    color: Theme.textPrimary
                }
                Label {
                    text: qsTr("%1 frames · 2.39:1 aspect").arg(storyboardModel.totalFrames)
                    font.family: Theme.fontUI
                    font.pixelSize: 12
                    color: Theme.textMuted
                }
            }

            Item { Layout.fillWidth: true }

            // Frame nav
            RowLayout {
                spacing: 6
                IconButton {
                    iconName: "arrowL"
                    enabled: storyboardModel.currentFrameIndex > 0
                    onClicked: storyboardModel.previousFrame()
                }
                Rectangle {
                    implicitWidth: counterLabel.implicitWidth + 22
                    implicitHeight: 26
                    radius: Theme.radiusSmall
                    color: Theme.bgElevated
                    border.color: Theme.borderLight
                    border.width: 1
                    Label {
                        id: counterLabel
                        anchors.centerIn: parent
                        text: storyboardModel.totalFrames > 0
                              ? qsTr("<b>%1</b> / %2")
                                    .arg((storyboardModel.currentFrameIndex + 1).toString().padStart(2, "0"))
                                    .arg(storyboardModel.totalFrames.toString().padStart(2, "0"))
                              : qsTr("0 / 0")
                        textFormat: Text.RichText
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        color: Theme.textSecondary
                    }
                }
                IconButton {
                    iconName: "arrowR"
                    enabled: storyboardModel.currentFrameIndex < storyboardModel.totalFrames - 1
                    onClicked: storyboardModel.nextFrame()
                }
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 18; color: Theme.border; opacity: 0.6 }

            AppButton {
                iconName: "copy"
                text: qsTr("Duplicate")
                enabled: storyboardModel.totalFrames > 0
                onClicked: storyboardModel.duplicateFrame(storyboardModel.currentFrameIndex)
            }
            AppButton {
                iconName: "plus"
                text: qsTr("Add frame")
                primary: true
                onClicked: storyboardModel.addFrame()
            }
        }

        // ── Shot strip (horizontal ListView) ───────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 124
            color: "transparent"

            ListView {
                id: stripView
                anchors.fill: parent
                orientation: ListView.Horizontal
                spacing: 10
                clip: true
                model: storyboardModel

                delegate: StoryboardShotCard {
                    width: 142
                    height: 110
                    frameNumber: model.frameNumber
                    description: model.description
                    imagePath: model.imagePath
                    isActive: storyboardModel.currentFrameIndex === index
                    onClicked: storyboardModel.goToFrame(index)
                }

                ScrollBar.horizontal: ScrollBar {}

                footer: Rectangle {
                    width: 142
                    height: 110
                    color: "transparent"
                    radius: Theme.radiusMedium
                    border.color: addHover.containsMouse ? Theme.accent : Theme.border
                    border.width: 1

                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Icon {
                            name: "plus"
                            size: 18
                            color: addHover.containsMouse ? Theme.accent : Theme.textMuted
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: qsTr("New frame")
                            font.family: Theme.fontUI
                            font.pixelSize: 10
                            color: addHover.containsMouse ? Theme.accent : Theme.textMuted
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                    }

                    MouseArea {
                        id: addHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: storyboardModel.addFrame()
                    }
                }
            }
        }

        // ── Focused editor (Loader-on-active-index pattern) ────────────────
        // Uses Repeater + Loader{active:} to render exactly one delegate —
        // the one matching currentFrameIndex. This is the cleanest way to
        // get role data out of a QAbstractListModel without a custom proxy.
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                anchors.centerIn: parent
                visible: storyboardModel.totalFrames === 0
                text: qsTr("No frames yet — add one above to start storyboarding.")
                font.family: Theme.fontUI
                font.pixelSize: Theme.sizeBody
                color: Theme.textMuted
            }

            Repeater {
                model: storyboardModel
                delegate: Loader {
                    anchors.fill: parent
                    active: index === storyboardModel.currentFrameIndex
                    visible: active

                    sourceComponent: StoryboardFrameEditor {
                        frameNumber: model.frameNumber
                        description: model.description
                        prompt: model.prompt
                        imagePath: model.imagePath
                        notes: model.notes
                        onUserDescriptionChanged: storyboardModel.updateFrame(index, description, prompt, notes, imagePath)
                        onUserPromptChanged:      storyboardModel.updateFrame(index, description, prompt, notes, imagePath)
                        onUserNotesChanged:       storyboardModel.updateFrame(index, description, prompt, notes, imagePath)
                        onUserImagePathChanged:   storyboardModel.updateFrame(index, description, prompt, notes, imagePath)
                    }
                }
            }
        }
    }
}
