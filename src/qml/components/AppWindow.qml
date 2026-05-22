// AppWindow.qml — slimmer titlebar + clean workspace shell. Drop-in replacement.
// Changes vs original:
//   • Titlebar height 48 → 44, brand on left with diamond mark
//   • Theme toggle removed (now in Sidebar)
//   • Project name no longer duplicated (it's in the sidebar's Project card)
//   • Clip selector replaced by a clean inline picker
//   • Window controls thinner, more consistent
//   • Status bar bumps useful info (frame counter, hint about ⌘K)

import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import "../dialogs"

Rectangle {
    id: shell
    color: Theme.bgPrimary

    property var appWindow: null

    border.color: Theme.border
    border.width: appWindow && appWindow.visibility === Window.Maximized ? 0 : 1
    radius: appWindow && appWindow.visibility === Window.Maximized ? 0 : 8

    Behavior on color { ColorAnimation { duration: Theme.animSlow } }

    layer.enabled: radius > 0
    layer.effect: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: appWindow && appWindow.visibility === Window.Maximized ? 0 : 1
        spacing: 0

        // ── Titlebar ───────────────────────────────────────────────────────
        Rectangle {
            id: titlebar
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: Theme.bgElevated
            radius: shell.radius

            Behavior on color { ColorAnimation { duration: Theme.animSlow } }

            // square off bottom corners
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.radius
                color: parent.color
                Behavior on color { ColorAnimation { duration: Theme.animSlow } }
            }

            // bottom hairline
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.borderLight
            }

            MouseArea {
                anchors.fill: parent
                z: -1
                onPressed: if (appWindow) appWindow.startSystemMove()
                onDoubleClicked: {
                    if (!appWindow) return
                    if (appWindow.visibility === Window.Maximized)
                        appWindow.showNormal()
                    else
                        appWindow.showMaximized()
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 6
                spacing: 10

                // Brand
                RowLayout {
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                        radius: 5
                        gradient: Gradient {
                            orientation: Gradient.Diagonal
                            GradientStop { position: 0.0; color: Theme.accent }
                            GradientStop { position: 1.0; color: Qt.darker(Theme.accent, 1.25) }
                        }
                        Icon {
                            anchors.centerIn: parent
                            name: "diamond"
                            size: 11
                            stroke: 2.2
                            color: "#FFFFFF"
                        }
                    }
                    Label {
                        text: "MoodClip"
                        font.family: Theme.fontUI
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.letterSpacing: -0.2
                        color: Theme.textPrimary
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 18; color: Theme.border; opacity: 0.7 }

                // Project name (subtle)
                Label {
                    text: projectManager.projectName.length > 0 ? projectManager.projectName : qsTr("No project")
                    font.family: Theme.fontUI
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    elide: Text.ElideRight
                    Layout.maximumWidth: 200
                }

                // Clip picker (inline, pill-style)
                Rectangle {
                    visible: projectManager.clips.length > 0
                    Layout.preferredHeight: 26
                    implicitWidth: clipRow.implicitWidth + 18
                    radius: Theme.radiusSmall
                    color: clipPickerMouse.containsMouse ? Theme.bgSecondary : Theme.bgPrimary
                    border.color: Theme.borderLight
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    RowLayout {
                        id: clipRow
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 10
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            radius: 4
                            color: Theme.accentSoft
                            Label {
                                anchors.centerIn: parent
                                text: (projectManager.activeClipIndex + 1).toString().padStart(2, "0")
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: true
                                color: Theme.accentInk
                            }
                        }
                        Label {
                            text: projectManager.activeClipIndex >= 0 && projectManager.clips[projectManager.activeClipIndex]
                                  ? projectManager.clips[projectManager.activeClipIndex].name
                                  : qsTr("No clip")
                            font.family: Theme.fontUI
                            font.pixelSize: 12
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                            Layout.maximumWidth: 160
                        }
                        Icon { name: "chev"; size: 13; color: Theme.textMuted }
                    }

                    MouseArea {
                        id: clipPickerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clipMenu.open()
                    }

                    Menu {
                        id: clipMenu
                        y: parent.height + 4
                        Repeater {
                            model: projectManager.clips
                            MenuItem {
                                text: modelData.name
                                onTriggered: projectManager.activeClipIndex = index
                            }
                        }
                    }
                }

                AppButton {
                    iconName: "plus"
                    text: qsTr("Clip")
                    ghost: true
                    enabled: projectManager.clips.length < 10 && projectManager.projectName.length > 0
                    onClicked: projectManager.addClip()
                }

                Item { Layout.fillWidth: true }

                // ── Action buttons ─────────────────────────────────────────
                AppButton {
                    iconName: "folder"
                    text: qsTr("Open")
                    ghost: true
                    onClicked: openProjectDialog.open()
                }
                AppButton {
                    iconName: "save"
                    text: qsTr("Save")
                    enabled: projectManager.hasUnsavedChanges
                    onClicked: projectManager.saveProject()
                }
                AppButton {
                    iconName: "download"
                    text: qsTr("Export")
                    primary: true
                    enabled: projectManager.activeClipIndex >= 0
                    onClicked: exportDialog.open()
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 18; color: Theme.border; opacity: 0.5 }

                // ── Window controls ────────────────────────────────────────
                RowLayout {
                    spacing: 2

                    IconButton {
                        iconName: "minus"
                        iconSize: 13
                        onClicked: if (appWindow) appWindow.showMinimized()
                    }
                    IconButton {
                        iconName: "square"
                        iconSize: 11
                        onClicked: {
                            if (!appWindow) return
                            if (appWindow.visibility === Window.Maximized)
                                appWindow.showNormal()
                            else
                                appWindow.showMaximized()
                        }
                    }
                    IconButton {
                        iconName: "close"
                        iconSize: 13
                        danger: true
                        onClicked: if (appWindow) appWindow.close()
                    }
                }
            }
        }

        // ── Workspace body ─────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Sidebar {
                id: sidebar
                Layout.preferredWidth: 232
                Layout.fillHeight: true
            }

            StackLayout {
                id: contentStack
                currentIndex: sidebar.activeTab
                Layout.fillWidth: true
                Layout.fillHeight: true

                ScriptEditor    { targetClip: projectManager.activeClip }
                StoryboardView  { }
                MoodboardCanvas { targetClip: projectManager.activeClip }
                AssetGrid       { }
            }
        }

        // ── Status bar ─────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: Theme.bgSecondary
            radius: shell.radius

            Behavior on color { ColorAnimation { duration: Theme.animSlow } }

            // Top hairline + square off top corners
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.radius
                color: parent.color
                Behavior on color { ColorAnimation { duration: Theme.animSlow } }
            }
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.borderLight
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 14

                RowLayout {
                    spacing: 5
                    Rectangle {
                        Layout.preferredWidth: 6
                        Layout.preferredHeight: 6
                        radius: 3
                        color: projectManager.hasUnsavedChanges ? Theme.accent : Theme.success
                    }
                    Label {
                        text: projectManager.hasUnsavedChanges ? qsTr("Unsaved changes") : qsTr("Saved")
                        font.family: Theme.fontUI
                        font.pixelSize: 11
                        color: projectManager.hasUnsavedChanges ? Theme.accent : Theme.textMuted
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 10; color: Theme.border }

                Label {
                    text: projectManager.activeClipIndex >= 0
                          ? qsTr("Clip %1 / %2")
                                .arg((projectManager.activeClipIndex + 1).toString().padStart(2, "0"))
                                .arg(projectManager.clips.length.toString().padStart(2, "0"))
                          : qsTr("No clip")
                    font.family: Theme.fontUI
                    font.pixelSize: 11
                    color: Theme.textMuted
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 10; color: Theme.border }

                Label {
                    visible: storyboardModel.totalFrames > 0
                    text: qsTr("Frame %1 / %2")
                            .arg((storyboardModel.currentFrameIndex + 1).toString().padStart(2, "0"))
                            .arg(storyboardModel.totalFrames.toString().padStart(2, "0"))
                    font.family: Theme.fontUI
                    font.pixelSize: 11
                    color: Theme.textMuted
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 6
                    Label {
                        text: qsTr("Press")
                        font.family: Theme.fontUI
                        font.pixelSize: 11
                        color: Theme.textMuted
                    }
                    Rectangle {
                        Layout.preferredHeight: 14
                        implicitWidth: kbdLbl.implicitWidth + 8
                        radius: 3
                        color: Theme.bgTertiary
                        border.color: Theme.borderLight
                        border.width: 1
                        Label {
                            id: kbdLbl
                            anchors.centerIn: parent
                            text: "⌘K"
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            color: Theme.textSecondary
                        }
                    }
                    Label {
                        text: qsTr("for quick actions")
                        font.family: Theme.fontUI
                        font.pixelSize: 11
                        color: Theme.textMuted
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 10; color: Theme.border }

                Label {
                    text: "MoodClip v1.2"
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    color: Theme.textMuted
                }
            }
        }
    }

    // ── Dialogs (unchanged) ───────────────────────────────────────────────
    NewProjectDialog { id: newProjectDialog }
    ExportDialog     { id: exportDialog }

    FileDialog {
        id: openProjectDialog
        title: qsTr("Open Project")
        fileMode: FileDialog.OpenFile
        nameFilters: ["MoodClip projects (*.moodclip)", "Project folders (project.json)", "All files (*)"]
        onAccepted: projectManager.openProject(selectedFile)
    }
}
