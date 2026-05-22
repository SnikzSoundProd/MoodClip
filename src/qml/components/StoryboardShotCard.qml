// StoryboardShotCard.qml — compact thumbnail card for the shot strip.
// New file — place at src/qml/components/StoryboardShotCard.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: card

    property int frameNumber: 1
    property string description: ""
    property string imagePath: ""
    property bool isActive: false

    signal clicked()

    color: Theme.bgElevated
    border.color: isActive ? Theme.accent : Theme.borderLight
    border.width: isActive ? 2 : 1
    radius: Theme.radiusMedium

    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // Frame # + shot label
        Label {
            text: qsTr("#%1").arg(card.frameNumber.toString().padStart(2, "0"))
            font.family: Theme.fontMono
            font.pixelSize: 10
            font.bold: true
            color: card.isActive ? Theme.accent : Theme.textSecondary
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }

        // Thumb
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radiusXS
            color: Theme.bgTertiary
            clip: true

            Image {
                anchors.fill: parent
                source: card.imagePath
                fillMode: Image.PreserveAspectCrop
                visible: card.imagePath.length > 0
            }

            Label {
                anchors.centerIn: parent
                visible: card.imagePath.length === 0
                text: qsTr("image")
                font.family: Theme.fontMono
                font.pixelSize: 9
                color: Theme.textMuted
            }
        }

        // Description (one line, elided)
        Label {
            Layout.fillWidth: true
            text: card.description.length > 0 ? card.description : qsTr("Untitled frame")
            font.family: Theme.fontUI
            font.pixelSize: 10
            color: Theme.textMuted
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: card.clicked()
        onEntered: if (!card.isActive) card.border.color = Theme.border
        onExited:  if (!card.isActive) card.border.color = Theme.borderLight
    }
}
