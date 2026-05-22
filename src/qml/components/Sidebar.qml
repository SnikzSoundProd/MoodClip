// Sidebar.qml — refined navigation. Drop-in replacement.
// Changes vs original:
//   • emoji tab icons → SVG Icon components
//   • clips list (project.clips with thumbnail + frame count)
//   • bottom project card more compact, real meta
//   • theme toggle moved here from titlebar
//
// Backward-compatible signal: activeTab property still drives StackLayout.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebar
    color: Theme.bgSecondary

    Behavior on color { ColorAnimation { duration: Theme.animSlow } }

    property int activeTab: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 14
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        spacing: 0

        // ── Section header: Workspace ──────────────────────────────────────
        Label {
            text: qsTr("WORKSPACE")
            font.family: Theme.fontUI
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 1.2
            color: Theme.textMuted
            Layout.leftMargin: 8
            Layout.bottomMargin: 8
        }

        // ── Tabs ───────────────────────────────────────────────────────────
        Repeater {
            model: [
                { iconName: "script",     label: qsTr("Scenario"),   count: 0 },
                { iconName: "storyboard", label: qsTr("Storyboard"), count: storyboardModel ? storyboardModel.totalFrames : 0 },
                { iconName: "moodboard",  label: qsTr("Moodboard"),  count: 0 },
                { iconName: "assets",     label: qsTr("Assets"),     count: assetLibrary ? (assetLibrary.count || 0) : 0 }
            ]

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                Layout.bottomMargin: 2
                color: sidebar.activeTab === index
                       ? Theme.bgElevated
                       : (tabHover.containsMouse ? Theme.bgTertiary : "transparent")
                radius: Theme.radiusSmall

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                // Active accent bar
                Rectangle {
                    visible: sidebar.activeTab === index
                    anchors.left: parent.left
                    anchors.leftMargin: -7
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: 20
                    radius: 2
                    color: Theme.accent
                }

                MouseArea {
                    id: tabHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sidebar.activeTab = index
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Icon {
                        name: modelData.iconName
                        size: 16
                        color: sidebar.activeTab === index ? Theme.accent : Theme.textMuted
                    }
                    Label {
                        text: modelData.label
                        font.family: Theme.fontUI
                        font.pixelSize: Theme.sizeBody
                        font.weight: sidebar.activeTab === index ? Font.Medium : Font.Normal
                        color: sidebar.activeTab === index ? Theme.textPrimary : Theme.textSecondary
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        visible: modelData.count > 0
                        Layout.preferredHeight: 16
                        implicitWidth: countLabel.implicitWidth + 14
                        radius: 999
                        color: sidebar.activeTab === index ? Theme.accentSoft : Theme.bgTertiary
                        Label {
                            id: countLabel
                            anchors.centerIn: parent
                            text: modelData.count
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            color: sidebar.activeTab === index ? Theme.accentInk : Theme.textMuted
                        }
                    }
                }
            }
        }

        // ── Section header: Clips ──────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 18
            Layout.leftMargin: 8
            Layout.rightMargin: 4
            Layout.bottomMargin: 8
            Label {
                text: qsTr("CLIPS · %1/10").arg(projectManager.clips.length)
                font.family: Theme.fontUI
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.2
                color: Theme.textMuted
                Layout.fillWidth: true
            }
            IconButton {
                iconName: "plus"
                iconSize: 12
                implicitWidth: 18
                implicitHeight: 18
                enabled: projectManager.clips.length < 10 && projectManager.projectName.length > 0
                onClicked: projectManager.addClip()
            }
        }

        // Clips list
        Repeater {
            model: projectManager.clips

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: index === projectManager.activeClipIndex
                       ? Theme.bgElevated
                       : (clipHover.containsMouse ? Theme.bgTertiary : "transparent")
                radius: Theme.radiusSmall

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                MouseArea {
                    id: clipHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: projectManager.activeClipIndex = index
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 10
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 18
                        radius: 3
                        color: index === projectManager.activeClipIndex
                               ? Theme.accent
                               : Theme.bgTertiary
                        border.color: Theme.borderLight
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Label {
                            anchors.centerIn: parent
                            text: (index + 1).toString().padStart(2, "0")
                            font.family: Theme.fontMono
                            font.pixelSize: 9
                            font.bold: true
                            color: index === projectManager.activeClipIndex ? "#FFFFFF" : Theme.textMuted
                        }
                    }
                    Label {
                        text: modelData.name
                        font.family: Theme.fontUI
                        font.pixelSize: 12
                        color: index === projectManager.activeClipIndex ? Theme.textPrimary : Theme.textSecondary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Spacer
        Item { Layout.fillHeight: true; Layout.fillWidth: true }

        // ── Project Card ───────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: pcContent.implicitHeight + 24
            color: Theme.bgElevated
            border.color: Theme.borderLight
            border.width: 1
            radius: Theme.radiusMedium

            ColumnLayout {
                id: pcContent
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                Label {
                    text: qsTr("PROJECT")
                    font.family: Theme.fontUI
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.2
                    color: Theme.textMuted
                }
                Label {
                    text: projectManager.projectName.length > 0 ? projectManager.projectName : qsTr("Untitled")
                    font.family: Theme.fontUI
                    font.pixelSize: Theme.sizeBody
                    font.bold: true
                    color: Theme.textPrimary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                RowLayout {
                    spacing: 10
                    Layout.topMargin: 4
                    Label {
                        text: qsTr("%1 clips").arg(projectManager.clips.length)
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        color: Theme.textMuted
                    }
                    Label {
                        text: qsTr("%1 assets").arg(assetLibrary ? (assetLibrary.count || 0) : 0)
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        color: Theme.textMuted
                    }
                }
            }
        }

        // Theme toggle
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            Layout.topMargin: 6

            Rectangle {
                anchors.fill: parent
                color: themeHover.containsMouse ? Theme.bgTertiary : "transparent"
                radius: Theme.radiusSmall
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }

            MouseArea {
                id: themeHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: projectManager.isDarkTheme = !projectManager.isDarkTheme
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 10
                Icon {
                    name: Theme.darkMode ? "sun" : "moon"
                    size: 14
                    color: Theme.textSecondary
                }
                Label {
                    text: Theme.darkMode ? qsTr("Light theme") : qsTr("Dark theme")
                    font.family: Theme.fontUI
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    Layout.fillWidth: true
                }
            }
        }
    }
}
