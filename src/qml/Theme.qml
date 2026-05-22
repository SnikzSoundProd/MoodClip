import QtQuick

QtObject {
    id: theme

    property bool darkMode: false
    // "compact" | "default" | "cozy"
    property string density: "default"

    function colorValue(light, dark) {
        return darkMode ? dark : light;
    }

    // ── Surfaces ────────────────────────────────────────────────────────────
    readonly property color bgPrimary:   darkMode ? "#14141A" : "#F4F1EA"
    readonly property color bgSecondary: darkMode ? "#1B1B22" : "#ECE7DC"
    readonly property color bgTertiary:  darkMode ? "#23232C" : "#E2DCCE"
    readonly property color bgElevated:  darkMode ? "#1F1F27" : "#FBF9F4"
    readonly property color bgSunken:    darkMode ? "#0E0E13" : "#E8E2D2"

    // ── Text ────────────────────────────────────────────────────────────────
    readonly property color textPrimary:   darkMode ? "#ECE7DD" : "#1E1E24"
    readonly property color textSecondary: darkMode ? "#ADA597" : "#5D574E"
    readonly property color textMuted:     darkMode ? "#6E685D" : "#948C7E"
    readonly property color textInverse:   darkMode ? "#14141A" : "#F4F1EA"

    // ── Accent ──────────────────────────────────────────────────────────────
    readonly property color accent:     darkMode ? "#E0A472" : "#B6692C"
    readonly property color accentSoft: darkMode ? "#3A2A1A" : "#EFE2CF"
    readonly property color accentInk:  darkMode ? "#F4D7B5" : "#6B3812"

    // ── Sticky note palette ────────────────────────────────────────────────
    readonly property color noteYellow: darkMode ? "#564D25" : "#F5E58A"
    readonly property color notePink:   darkMode ? "#5C2E37" : "#F2B6C2"
    readonly property color noteBlue:   darkMode ? "#1F3953" : "#A8D2F2"
    readonly property color noteGreen:  darkMode ? "#2C4F2A" : "#B6E4B0"
    readonly property color noteOrange: darkMode ? "#5E3F22" : "#F3CFA0"
    readonly property color notePurple: darkMode ? "#432A57" : "#D9B6F0"

    // Tag pill colors — paired bg + ink, for scenario tags
    function tagBg(tag) {
        switch (tag) {
        case "SCENE":      return noteBlue
        case "SHOT":       return noteGreen
        case "TRANSITION": return notePurple
        case "DIALOGUE":   return noteYellow
        case "SFX":        return notePink
        case "MUSIC":      return noteOrange
        }
        return accentSoft
    }
    function tagInk(tag) {
        if (darkMode) {
            switch (tag) {
            case "SCENE":      return "#9BC8EE"
            case "SHOT":       return "#A5D8A0"
            case "TRANSITION": return "#D2B6F0"
            case "DIALOGUE":   return "#F0D880"
            case "SFX":        return "#F4B0BE"
            case "MUSIC":      return "#F0C28A"
            }
        } else {
            switch (tag) {
            case "SCENE":      return "#1F4E73"
            case "SHOT":       return "#2A5A28"
            case "TRANSITION": return "#5A2D7A"
            case "DIALOGUE":   return "#6E5A18"
            case "SFX":        return "#862E45"
            case "MUSIC":      return "#7A4012"
            }
        }
        return accentInk
    }

    // ── Lines + status ──────────────────────────────────────────────────────
    readonly property color border:      darkMode ? "#34343F" : "#CFC7B5"
    readonly property color borderLight: darkMode ? "#28282F" : "#E0D9C9"
    readonly property color shadow:      darkMode ? "#000000" : "#8A8076"

    readonly property color success: darkMode ? "#6BBF6B" : "#4E7F4A"
    readonly property color warning: darkMode ? "#D4A843" : "#C2952A"
    readonly property color danger:  darkMode ? "#D46B6B" : "#B2462E"

    // ── Type ────────────────────────────────────────────────────────────────
    readonly property string fontUI:          "Inter"
    readonly property string fontMono:        "JetBrains Mono"
    readonly property string fontDisplay:     "Inter"
    readonly property string fontHandwritten: "Caveat"

    readonly property int sizeDisplay: 22   // ws-title
    readonly property int sizeTitle:   18
    readonly property int sizeHeader:  15
    readonly property int sizeBody:    13
    readonly property int sizeSmall:   12
    readonly property int sizeCaption: 10

    // ── Radii ───────────────────────────────────────────────────────────────
    readonly property int radiusXS:     4
    readonly property int radiusSmall:  6
    readonly property int radiusMedium: 10
    readonly property int radiusLarge:  14
    readonly property int radiusXL:     20

    // ── Spacing scale (density-aware) ───────────────────────────────────────
    readonly property int pad: density === "compact" ? 14 : density === "cozy" ? 28 : 20
    readonly property int row: density === "compact" ? 30 : density === "cozy" ? 40 : 36
    readonly property int tap: density === "compact" ? 28 : density === "cozy" ? 36 : 32

    // ── Motion ──────────────────────────────────────────────────────────────
    readonly property int animFast:   140
    readonly property int animNormal: 240
    readonly property int animSlow:   400

    function noteColor(index) {
        var colors = [noteYellow, notePink, noteBlue, noteGreen, noteOrange, notePurple];
        return colors[index % colors.length];
    }
}
