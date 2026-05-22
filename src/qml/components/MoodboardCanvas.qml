// MoodboardCanvas.qml — refined infinite canvas. Drop-in replacement.
// Changes vs original:
//   • 48px top ToolBar → floating glass pill at bottom-center
//   • Compact header (title + meta) at top
//   • Dot-grid renders dot pattern via CSS-like positioning (Canvas)
//   • Zoom pill shows current scale percent
//   • Mini-map placeholder in bottom-right
//
// Functionality unchanged: addNote(), addImage(), toggleConnectMode(),
// collectItems(), restoreItems(), clearCanvas() — same signatures.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: moodboardCanvas
    color: Theme.bgPrimary
    clip: true

    property var targetClip: null
    property var previousClip: null
    /** Active tool: "cursor", "note", "image", "text", "link" */
    property string activeTool: "cursor"

    Behavior on color { ColorAnimation { duration: Theme.animSlow } }

    onTargetClipChanged: {
        if (previousClip !== null)
            previousClip.moodboardItems = canvas.collectItems()
        canvas.clearCanvas()
        if (targetClip !== null && targetClip.moodboardItems.length > 0)
            canvas.restoreItems(targetClip.moodboardItems)
        previousClip = targetClip
    }

    Connections {
        target: projectManager
        function onAboutToSave() {
            if (targetClip !== null)
                targetClip.moodboardItems = canvas.collectItems()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Compact header ────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 22
            Layout.leftMargin: 28
            Layout.rightMargin: 28
            Layout.bottomMargin: 12
            spacing: 14

            ColumnLayout {
                spacing: 2
                Label {
                    text: qsTr("Moodboard")
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.sizeDisplay
                    font.bold: true
                    font.letterSpacing: -0.4
                    color: Theme.textPrimary
                }
                Label {
                    text: qsTr("∞ canvas · zoom %1%").arg(Math.round(canvas.scale * 100))
                    font.family: Theme.fontUI
                    font.pixelSize: 12
                    color: Theme.textMuted
                }
            }
            Item { Layout.fillWidth: true }

            AppButton { iconName: "layers"; ghost: true; text: qsTr("Layers") }
            AppButton { iconName: "download"; text: qsTr("Export board") }
        }

        // ── Canvas + floating toolbar ─────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                id: canvas
                anchors.fill: parent
                contentWidth: 4000
                contentHeight: 4000
                clip: true

                property real scale: 1.0
                property bool connectMode: false
                property var selectedItem: null

                function addNote(x, y) {
                    var comp = Qt.createComponent("StickyNote.qml")
                    if (comp.status === Component.Ready) {
                        comp.createObject(canvasContent, {
                            x: x || 200 + Math.random() * 200,
                            y: y || 200 + Math.random() * 200
                        })
                        projectManager.markUnsaved()
                    }
                }
                function addImage() {
                    var comp = Qt.createComponent("ImageFrame.qml")
                    if (comp.status === Component.Ready) {
                        comp.createObject(canvasContent, {
                            x: 300 + Math.random() * 200,
                            y: 300 + Math.random() * 200
                        })
                        projectManager.markUnsaved()
                    }
                }
                function toggleConnectMode() {
                    connectMode = !connectMode
                    moodboardCanvas.activeTool = connectMode ? "link" : "cursor"
                }
                function collectItems() {
                    var result = []
                    var ch = canvasContent.children
                    for (var i = 0; i < ch.length; i++) {
                        var item = ch[i]
                        if (!item.hasOwnProperty("itemType")) continue
                        var entry = { type: item.itemType, x: item.x, y: item.y,
                                      width: item.width, height: item.height }
                        if (item.itemType === "note") {
                            entry.colorIndex = item.colorIndex
                            entry.text = item.text
                        } else {
                            entry.source = item.source
                            entry.caption = item.caption
                        }
                        result.push(entry)
                    }
                    return result
                }
                function clearCanvas() {
                    var toDestroy = []
                    for (var i = 0; i < canvasContent.children.length; i++) {
                        if (canvasContent.children[i].hasOwnProperty("itemType"))
                            toDestroy.push(canvasContent.children[i])
                    }
                    for (var j = 0; j < toDestroy.length; j++)
                        toDestroy[j].destroy()
                }
                function restoreItems(items) {
                    for (var i = 0; i < items.length; i++) {
                        var d = items[i]
                        var comp = Qt.createComponent(d.type === "note" ? "StickyNote.qml" : "ImageFrame.qml")
                        if (comp.status !== Component.Ready) continue
                        var props = { x: d.x, y: d.y, width: d.width, height: d.height }
                        if (d.type === "note") {
                            props.colorIndex = d.colorIndex
                            props.text = d.text
                        } else {
                            props.source = d.source
                            props.caption = d.caption
                        }
                        comp.createObject(canvasContent, props)
                    }
                }

                transform: Scale {
                    origin.x: canvas.contentX + canvas.width / 2
                    origin.y: canvas.contentY + canvas.height / 2
                    xScale: canvas.scale
                    yScale: canvas.scale
                }

                Rectangle {
                    id: canvasContent
                    width: parent.contentWidth
                    height: parent.contentHeight
                    color: Theme.bgPrimary

                    // Dot grid
                    Canvas {
                        anchors.fill: parent
                        property color dotColor: Theme.border
                        onDotColorChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.fillStyle = dotColor.toString()
                            for (var x = 0; x <= width; x += 24) {
                                for (var y = 0; y <= height; y += 24) {
                                    ctx.beginPath()
                                    ctx.arc(x, y, 1, 0, Math.PI * 2)
                                    ctx.fill()
                                }
                            }
                        }
                    }
                }

                PinchArea {
                    anchors.fill: parent
                    onPinchUpdated: {
                        canvas.scale = Math.max(0.1, Math.min(5.0, canvas.scale * pinch.scale))
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: parent
                    onWheel: {
                        if (wheel.modifiers & Qt.ControlModifier) {
                            var ns = canvas.scale + (wheel.angleDelta.y > 0 ? 0.1 : -0.1)
                            canvas.scale = Math.max(0.1, Math.min(5.0, ns))
                        } else {
                            wheel.accepted = false
                        }
                    }
                }
            }

            // ── Floating glass toolbar (bottom-center) ────────────────────
            Rectangle {
                id: floatingToolbar
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 18
                radius: 999
                color: Theme.darkMode ? "#D11F1F27" : "#D1FBF9F4"
                border.color: Theme.borderLight
                border.width: 1
                implicitHeight: 42
                implicitWidth: tbRow.implicitWidth + 12
                z: 10

                RowLayout {
                    id: tbRow
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    spacing: 2

                    Repeater {
                        model: [
                            { tool: "cursor", iconName: "cursor", tip: qsTr("Select") },
                            { tool: "note",   iconName: "note",   tip: qsTr("Sticky note"), action: "note" },
                            { tool: "image",  iconName: "image",  tip: qsTr("Image"),       action: "image" },
                            { tool: "text",   iconName: "text",   tip: qsTr("Text label") },
                            { tool: "link",   iconName: "link",   tip: qsTr("Connection"),  action: "link" }
                        ]
                        IconButton {
                            iconName: modelData.iconName
                            iconSize: 15
                            implicitWidth: 32
                            implicitHeight: 32
                            active: moodboardCanvas.activeTool === modelData.tool
                            ToolTip.text: modelData.tip
                            ToolTip.visible: hovered
                            background: Rectangle {
                                radius: 999
                                color: active ? Theme.accentSoft : (parent.hovered ? Theme.bgSecondary : "transparent")
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            }
                            onClicked: {
                                moodboardCanvas.activeTool = modelData.tool
                                if (modelData.action === "note") canvas.addNote()
                                else if (modelData.action === "image") canvas.addImage()
                                else if (modelData.action === "link") canvas.toggleConnectMode()
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 18
                        Layout.leftMargin: 4
                        Layout.rightMargin: 4
                        color: Theme.border
                    }

                    IconButton {
                        iconName: "zoomOut"
                        iconSize: 15
                        implicitWidth: 32; implicitHeight: 32
                        background: Rectangle { radius: 999; color: parent.hovered ? Theme.bgSecondary : "transparent"; Behavior on color { ColorAnimation { duration: Theme.animFast } } }
                        onClicked: canvas.scale = Math.max(0.1, canvas.scale / 1.2)
                    }
                    Rectangle {
                        Layout.preferredWidth: zoomLbl.implicitWidth + 16
                        Layout.preferredHeight: 26
                        radius: 999
                        color: Theme.bgSecondary
                        Label {
                            id: zoomLbl
                            anchors.centerIn: parent
                            text: Math.round(canvas.scale * 100) + "%"
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            color: Theme.textSecondary
                        }
                    }
                    IconButton {
                        iconName: "zoomIn"
                        iconSize: 15
                        implicitWidth: 32; implicitHeight: 32
                        background: Rectangle { radius: 999; color: parent.hovered ? Theme.bgSecondary : "transparent"; Behavior on color { ColorAnimation { duration: Theme.animFast } } }
                        onClicked: canvas.scale = Math.min(5.0, canvas.scale * 1.2)
                    }
                    IconButton {
                        iconName: "fit"
                        iconSize: 15
                        implicitWidth: 32; implicitHeight: 32
                        background: Rectangle { radius: 999; color: parent.hovered ? Theme.bgSecondary : "transparent"; Behavior on color { ColorAnimation { duration: Theme.animFast } } }
                        onClicked: {
                            canvas.scale = 1.0
                            canvas.contentX = 0
                            canvas.contentY = 0
                        }
                    }
                }
            }

            // ── Mini-map (bottom-right) ───────────────────────────────────
            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 18
                anchors.bottomMargin: 18
                width: 160
                height: 100
                radius: Theme.radiusMedium
                color: Theme.darkMode ? "#CC1F1F27" : "#CCFBF9F4"
                border.color: Theme.borderLight
                border.width: 1
                z: 9

                // Dot grid
                Canvas {
                    anchors.fill: parent
                    anchors.margins: 8
                    property color dotColor: Theme.borderLight
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.fillStyle = dotColor.toString()
                        for (var x = 0; x <= width; x += 8) {
                            for (var y = 0; y <= height; y += 8) {
                                ctx.beginPath()
                                ctx.arc(x, y, 0.6, 0, Math.PI * 2)
                                ctx.fill()
                            }
                        }
                    }
                }

                // Viewport rect
                Rectangle {
                    x: 44
                    y: 22
                    width: 70; height: 50
                    color: "transparent"
                    border.color: Theme.accent
                    border.width: 1.5
                    radius: 3

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.accent
                        opacity: 0.12
                        radius: 3
                    }
                }
            }
        }
    }
}
