// TagPill.qml — colored monospace pill for scenario tags.
// Usage: TagPill { tag: "SCENE" }

import QtQuick
import QtQuick.Controls

Rectangle {
    id: pill
    property string tag: "SCENE"

    implicitHeight: 20
    implicitWidth: tagLabel.implicitWidth + 16
    radius: 999
    color: Theme.tagBg(tag)

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Label {
        id: tagLabel
        anchors.centerIn: parent
        text: pill.tag
        font.family: Theme.fontMono
        font.pixelSize: 10
        font.bold: true
        font.letterSpacing: 0.4
        color: Theme.tagInk(pill.tag)
    }
}
