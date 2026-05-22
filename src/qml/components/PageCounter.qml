import QtQuick
import QtQuick.Controls

Rectangle {
    id: counter
    width: 80
    height: 28
    color: Theme.bgSecondary
    border.color: Theme.border
    border.width: 1
    radius: Theme.radiusSmall

    property int current: 1
    property int total: 1

    Label {
        anchors.centerIn: parent
        text: qsTr("%1-%2").arg(current).arg(total)
        font.family: Theme.fontMono
        font.pixelSize: Theme.sizeSmall
        font.bold: true
        color: Theme.textPrimary
    }
}
