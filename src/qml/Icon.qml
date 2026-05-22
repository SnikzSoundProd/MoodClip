import QtQuick
import QtQuick.Shapes

Item {
    id: icon
    property string name: ""
    property int size: 16
    property real stroke: 1.6
    property color color: "#1E1E24"

    property string path: {
        if (!name.length) return ""
        var d = {
            "script":     "M14 3v4a2 2 0 0 0 2 2h4 M17 21H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h7l6 6v10a2 2 0 0 1-2 2z M9 12h6 M9 16h4",
            "storyboard": "M3 5h6v14h-6z M10 5h11v6h-11z M10 13h11v6h-11z",
            "moodboard":  "M3 3h7v8h-7z M13 3h8v5h-8z M13 11h8v10h-8z M3 14h7v7h-7z",
            "assets":     "M3 7l9-4 9 4-9 4-9-4z M3 12l9 4 9-4 M3 17l9 4 9-4",
            "diamond":    "M12 2 L22 12 L12 22 L2 12 Z",
            "minus":      "M5 12h14",
            "square":     "M4 4h16v16h-16z",
            "close":      "M6 6l12 12 M18 6 L6 18",
            "sun":        "M12 8 a4 4 0 1 0 0.001 0 M12 2v2 M12 20v2 M4.93 4.93l1.41 1.41 M17.66 17.66l1.41 1.41 M2 12h2 M20 12h2 M4.93 19.07l1.41-1.41 M17.66 6.34l1.41-1.41",
            "moon":       "M21 12.79A9 9 0 1 1 11.21 3a7 7 0 0 0 9.79 9.79z",
            "chev":       "M6 9l6 6 6-6",
            "plus":       "M12 5v14 M5 12h14",
            "arrowL":     "M19 12H5 M12 5l-7 7 7 7",
            "arrowR":     "M5 12h14 M12 5l7 7-7 7",
            "search":     "M11 4 a7 7 0 1 0 0.001 0 M20 20l-3.5-3.5",
            "sparkles":   "M12 3v3 M12 18v3 M3 12h3 M18 12h3 M5.6 5.6l2.1 2.1 M16.3 16.3l2.1 2.1 M5.6 18.4l2.1-2.1 M16.3 7.7l2.1-2.1",
            "upload":     "M12 3v12 M7 8l5-5 5 5 M5 21h14",
            "download":   "M12 3v12 M7 10l5 5 5-5 M5 21h14",
            "save":       "M19 21H5 a2 2 0 0 1-2-2V5 a2 2 0 0 1 2-2h11l5 5v11 a2 2 0 0 1-2 2z M17 21v-8H7v8 M7 3v5h8",
            "folder":     "M3 7 a2 2 0 0 1 2-2h4l2 2h8 a2 2 0 0 1 2 2v8 a2 2 0 0 1-2 2H5 a2 2 0 0 1-2-2z",
            "trash":      "M3 6h18 M8 6V4 a2 2 0 0 1 2-2h4 a2 2 0 0 1 2 2v2 M19 6l-1 14 a2 2 0 0 1-2 2H8 a2 2 0 0 1-2-2L5 6",
            "copy":       "M9 9h11v11h-11z M5 15H4 a2 2 0 0 1-2-2V4 a2 2 0 0 1 2-2h9 a2 2 0 0 1 2 2v1",
            "refresh":    "M3 12 a9 9 0 0 1 15-6.7L21 8 M21 3v5h-5 M21 12 a9 9 0 0 1-15 6.7L3 16 M3 21v-5h5",
            "film":       "M3 3h18v18h-18z M7 3v18 M17 3v18 M3 8h4 M17 8h4 M3 16h4 M17 16h4 M3 12h18",
            "cursor":     "M4 4l7 16 2-6 6-2z",
            "note":       "M21 14V5 a2 2 0 0 0-2-2H5 a2 2 0 0 0-2 2v14 a2 2 0 0 0 2 2h9l7-7z M14 21v-5 a2 2 0 0 1 2-2h5",
            "image":      "M3 3h18v18h-18z M9 9 a2 2 0 1 0 4 0 a2 2 0 1 0-4 0 M21 16l-5-5L5 21",
            "text":       "M4 7V5h16v2 M9 5v14 M15 19h-6",
            "link":       "M10 14 a4 4 0 0 0 5.66 0l3-3 a4 4 0 0 0-5.66-5.66l-1 1 M14 10 a4 4 0 0 0-5.66 0l-3 3 a4 4 0 0 0 5.66 5.66l1-1",
            "zoomIn":     "M11 4 a7 7 0 1 0 0.001 0 M20 20l-3.5-3.5 M11 8v6 M8 11h6",
            "zoomOut":    "M11 4 a7 7 0 1 0 0.001 0 M20 20l-3.5-3.5 M8 11h6",
            "fit":        "M3 9V5 a2 2 0 0 1 2-2h4 M3 15v4 a2 2 0 0 0 2 2h4 M21 9V5 a2 2 0 0 0-2-2h-4 M21 15v4 a2 2 0 0 1-2 2h-4",
            "layers":     "M12 3l10 6-10 6-10-6 10-6z M2 15l10 6 10-6",
            "grid":       "M3 3h7v7h-7z M14 3h7v7h-7z M3 14h7v7h-7z M14 14h7v7h-7z",
            "list":       "M3 6h18 M3 12h18 M3 18h18"
        }
        return d[name] || ""
    }

    implicitWidth: size
    implicitHeight: size
    width: size
    height: size

    Item {
        width: 24
        height: 24
        scale: icon.size / 24
        transformOrigin: Item.TopLeft

        Shape {
            width: 24
            height: 24
            antialiasing: true

            ShapePath {
                strokeColor: icon.color
                strokeWidth: icon.stroke
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                PathSvg { path: icon.path }
            }
        }
    }

    Behavior on color {
        ColorAnimation { duration: 140 }
    }
}
