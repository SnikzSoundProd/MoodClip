import QtQuick
import QtQuick.Shapes

Shape {
    id: connection

    property real x1: 0
    property real y1: 0
    property real x2: 100
    property real y2: 100
    property color strokeColor: Theme.accent
    property real strokeWidth: 2
    property bool dashed: false

    ShapePath {
        strokeColor: connection.strokeColor
        strokeWidth: connection.strokeWidth
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        dashPattern: connection.dashed ? [6, 4] : []

        PathLine {
            x: connection.x1
            y: connection.y1
        }
        PathLine {
            x: connection.x2
            y: connection.y2
        }
    }

    // Arrow head
    Rectangle {
        x: connection.x2 - 4
        y: connection.y2 - 4
        width: 8
        height: 8
        rotation: 45
        color: connection.strokeColor
        visible: !connection.dashed
    }
}
