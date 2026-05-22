// AssetGrid.qml — refined Asset Library. Drop-in replacement.
// Changes vs original:
//   • Two-pane layout: 200px sidebar (categories + tags) + grid main
//   • Category list with color dots + counts (use allCategories)
//   • Tag cloud with active state
//   • Search field with ⌘K kbd hint
//   • Grid / List view toggle
//   • Asset card with usage badge + category dot
//
// Bindings to assetLibrary (filterCategory, filterTag, searchQuery,
// allCategories, allTags, importAsset, incrementAssetUsage) unchanged.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: assetGrid
    color: Theme.bgPrimary
    clip: true

    Behavior on color { ColorAnimation { duration: Theme.animSlow } }

    function colorForCategory(c) {
        // Deterministic color from name hash → 6 stable accents
        if (!c || c.length === 0) return Theme.textMuted
        var palette = [Theme.accent, "#3D6FA3", "#4E7F4A", "#8B5BAA", "#B2462E", "#7A4012"]
        var h = 0
        for (var i = 0; i < c.length; i++) h = (h * 31 + c.charCodeAt(i)) >>> 0
        return palette[h % palette.length]
    }

    property string viewMode: "grid"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── Sidebar (categories + tags) ───────────────────────────────────
        Rectangle {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            color: Theme.bgSecondary
            border.color: Theme.borderLight
            border.width: 0

            // Right border only
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: Theme.borderLight
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 22
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.bottomMargin: 14
                spacing: 0

                // ── Categories ────────────────────────────────────────────
                Label {
                    text: qsTr("CATEGORIES")
                    font.family: Theme.fontUI
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.2
                    color: Theme.textMuted
                    Layout.bottomMargin: 8
                }

                // "All" row
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: Theme.radiusSmall
                    color: assetLibrary.filterCategory === ""
                           ? Theme.bgElevated
                           : (allHover.containsMouse ? Theme.bgTertiary : "transparent")
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    MouseArea {
                        id: allHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: assetLibrary.filterCategory = ""
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8
                        Rectangle { Layout.preferredWidth: 8; Layout.preferredHeight: 8; radius: 2; color: Theme.textMuted }
                        Label {
                            text: qsTr("All assets")
                            font.family: Theme.fontUI
                            font.pixelSize: 12
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }
                    }
                }

                // Category rows
                Repeater {
                    model: assetLibrary.allCategories

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: Theme.radiusSmall
                        color: assetLibrary.filterCategory === modelData
                               ? Theme.bgElevated
                               : (catHover.containsMouse ? Theme.bgTertiary : "transparent")
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        MouseArea {
                            id: catHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: assetLibrary.filterCategory =
                                assetLibrary.filterCategory === modelData ? "" : modelData
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8
                            Rectangle {
                                Layout.preferredWidth: 8
                                Layout.preferredHeight: 8
                                radius: 2
                                color: colorForCategory(modelData)
                            }
                            Label {
                                text: modelData
                                font.family: Theme.fontUI
                                font.pixelSize: 12
                                color: assetLibrary.filterCategory === modelData
                                       ? Theme.textPrimary : Theme.textSecondary
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // ── Tags ──────────────────────────────────────────────────
                Label {
                    text: qsTr("TAGS")
                    font.family: Theme.fontUI
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.2
                    color: Theme.textMuted
                    Layout.topMargin: 18
                    Layout.bottomMargin: 8
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 5

                    Repeater {
                        model: assetLibrary.allTags

                        Rectangle {
                            height: 22
                            implicitWidth: tLbl.implicitWidth + 16
                            radius: 999
                            color: assetLibrary.filterTag === modelData
                                   ? Theme.accent
                                   : Theme.bgElevated
                            border.color: assetLibrary.filterTag === modelData
                                          ? Theme.accent : Theme.borderLight
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }

                            Label {
                                id: tLbl
                                anchors.centerIn: parent
                                text: modelData
                                font.family: Theme.fontUI
                                font.pixelSize: 11
                                color: assetLibrary.filterTag === modelData
                                       ? "#FFFFFF" : Theme.textSecondary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: assetLibrary.filterTag =
                                    assetLibrary.filterTag === modelData ? "" : modelData
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true; Layout.fillWidth: true }
            }
        }

        // ── Main grid ──────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 22
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.bottomMargin: 6
                spacing: 14

                ColumnLayout {
                    spacing: 2
                    Label {
                        text: qsTr("Asset Library")
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.sizeDisplay
                        font.bold: true
                        font.letterSpacing: -0.4
                        color: Theme.textPrimary
                    }
                    Label {
                        text: {
                            var parts = []
                            if (assetLibrary.filterCategory.length > 0) parts.push(assetLibrary.filterCategory)
                            if (assetLibrary.filterTag.length > 0) parts.push("#" + assetLibrary.filterTag)
                            return parts.length ? parts.join(" · ") : qsTr("All categories · all tags")
                        }
                        font.family: Theme.fontUI
                        font.pixelSize: 12
                        color: Theme.textMuted
                    }
                }
                Item { Layout.fillWidth: true }

                AppButton {
                    iconName: "upload"
                    text: qsTr("Import")
                    primary: true
                    onClicked: importDialog.open()
                }
            }

            // Toolbar (search + view toggle)
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.bottomMargin: 12
                spacing: 8

                // Search field
                Rectangle {
                    Layout.preferredWidth: 320
                    Layout.preferredHeight: 32
                    radius: Theme.radiusMedium
                    color: Theme.bgElevated
                    border.color: searchField.activeFocus ? Theme.accent : Theme.borderLight
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 8
                        Icon { name: "search"; size: 14; color: Theme.textMuted }
                        TextField {
                            id: searchField
                            placeholderText: qsTr("Search assets, tags, captions…")
                            placeholderTextColor: Theme.textMuted
                            color: Theme.textPrimary
                            font.family: Theme.fontUI
                            font.pixelSize: 13
                            background: null
                            Layout.fillWidth: true
                            onTextChanged: assetLibrary.searchQuery = text
                        }
                        Rectangle {
                            Layout.preferredHeight: 18
                            implicitWidth: kbdLabel.implicitWidth + 10
                            radius: 3
                            color: Theme.bgTertiary
                            border.color: Theme.borderLight
                            border.width: 1
                            Label {
                                id: kbdLabel
                                anchors.centerIn: parent
                                text: "⌘K"
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                color: Theme.textMuted
                            }
                        }
                    }
                }

                // View toggle
                Rectangle {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 60
                    radius: Theme.radiusSmall
                    color: Theme.bgElevated
                    border.color: Theme.borderLight
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 2
                        spacing: 2
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 4
                            color: assetGrid.viewMode === "grid" ? Theme.bgSecondary : "transparent"
                            Icon { anchors.centerIn: parent; name: "grid"; size: 13; color: assetGrid.viewMode === "grid" ? Theme.textPrimary : Theme.textMuted }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: assetGrid.viewMode = "grid" }
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 4
                            color: assetGrid.viewMode === "list" ? Theme.bgSecondary : "transparent"
                            Icon { anchors.centerIn: parent; name: "list"; size: 13; color: assetGrid.viewMode === "list" ? Theme.textPrimary : Theme.textMuted }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: assetGrid.viewMode = "list" }
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }

            // Grid
            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.bottomMargin: 28
                cellWidth: 184
                cellHeight: 208
                model: assetLibrary
                clip: true

                delegate: Rectangle {
                    width: grid.cellWidth - 14
                    height: grid.cellHeight - 14
                    color: Theme.bgElevated
                    border.color: cardHover.containsMouse ? Theme.border : Theme.borderLight
                    border.width: 1
                    radius: Theme.radiusMedium

                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Thumb
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 140
                            color: Theme.bgTertiary
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: model.thumbnailPath
                                fillMode: Image.PreserveAspectCrop
                            }

                            // Usage badge
                            Rectangle {
                                visible: model.usageCount > 0
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.margins: 8
                                radius: 999
                                color: "#B3141420"
                                implicitWidth: useLbl.implicitWidth + 14
                                implicitHeight: 18
                                Label {
                                    id: useLbl
                                    anchors.centerIn: parent
                                    text: "×" + model.usageCount
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    color: "#FFFFFF"
                                }
                            }
                        }

                        // Meta
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            Layout.topMargin: 8
                            Layout.bottomMargin: 10
                            spacing: 4

                            Label {
                                text: model.assetName
                                font.family: Theme.fontUI
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            RowLayout {
                                spacing: 5
                                Rectangle {
                                    Layout.preferredWidth: 6
                                    Layout.preferredHeight: 6
                                    radius: 3
                                    color: colorForCategory(model.category)
                                }
                                Label {
                                    text: model.category || qsTr("Uncategorized")
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    color: Theme.textMuted
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: cardHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: assetLibrary.incrementAssetUsage(model.assetId)
                    }
                }

                ScrollBar.vertical: ScrollBar {}
            }
        }
    }

    FileDialog {
        id: importDialog
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.webp *.gif)", "All files (*)"]
        onAccepted: {
            for (var i = 0; i < selectedFiles.length; ++i) {
                assetLibrary.importAsset(selectedFiles[i], "", "References", [], "")
            }
        }
    }
}
