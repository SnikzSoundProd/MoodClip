import QtQuick
import QtQuick.Controls

Rectangle {
    id: imgFrame
    width: 240
    height: 180
    color: Theme.bgElevated
    border.color: Theme.border
    border.width: 1
    radius: Theme.radiusSmall

    property string source: ""
    property string caption: ""
    property string itemType: "image"

    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: parent.width
            height: parent.height - 28
            color: Theme.bgTertiary
            clip: true

            Image {
                anchors.fill: parent
                source: imgFrame.source
                fillMode: Image.PreserveAspectFit
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("No image")
                visible: imgFrame.source.length === 0
                color: Theme.textMuted
            }
        }

        Rectangle {
            width: parent.width
            height: 28
            color: Theme.bgSecondary

            TextInput {
                anchors.fill: parent
                anchors.margins: 4
                font.family: Theme.fontUI
                font.pixelSize: Theme.sizeSmall
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: caption
                onEditingFinished: caption = text
            }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: parent
        drag.smoothed: true
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
            onMouseXChanged: imgFrame.width = Math.max(80, imgFrame.width + mouseX)
            onMouseYChanged: imgFrame.height = Math.max(60, imgFrame.height + mouseY)
        }
    }
}
