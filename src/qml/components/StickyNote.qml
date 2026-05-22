import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: note
    width: 200
    height: 140
    color: Theme.noteColor(colorIndex)
    radius: Theme.radiusSmall
    border.color: Qt.darker(color, 1.2)
    border.width: 1

    property int colorIndex: 0
    property string itemType: "note"
    property alias text: noteText.text

    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // Header with color picker
        RowLayout {
            Layout.fillWidth: true

            Repeater {
                model: 6
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: Theme.noteColor(index)
                    border.color: note.colorIndex === index ? Theme.textPrimary : "transparent"
                    border.width: 2
                    MouseArea {
                        anchors.fill: parent
                        onClicked: note.colorIndex = index
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "transparent"
            }

            ToolButton {
                text: "×"
                font.pixelSize: 14
                flat: true
                onClicked: note.destroy()
            }
        }

        TextArea {
            id: noteText
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.family: Theme.fontHandwritten
            font.pixelSize: 15
            color: Theme.textPrimary
            wrapMode: TextEdit.WordWrap
            background: Rectangle { color: "transparent" }
            text: qsTr("Note")
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: parent
        drag.smoothed: true
        onPressed: {
            note.z = 100
        }
        onReleased: {
            note.z = 1
        }
    }

    // Resize handle
    Rectangle {
        width: 12
        height: 12
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            drag.target: null
            onMouseXChanged: {
                if (drag.active) {
                    note.width = Math.max(100, note.width + mouseX)
                }
            }
            onMouseYChanged: {
                if (drag.active) {
                    note.height = Math.max(60, note.height + mouseY)
                }
            }
        }
    }
}
