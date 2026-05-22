import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import "components"
import "dialogs"

Window {
    id: root
    visible: true
    width: 1400
    height: 900
    minimumWidth: 900
    minimumHeight: 600
    // Remove OS title bar — AppWindow draws its own
    flags: Qt.FramelessWindowHint | Qt.Window
    title: projectManager.projectName.length > 0
           ? (projectManager.hasUnsavedChanges ? "• " : "") + projectManager.projectName + " — MoodClip"
           : "MoodClip"

    color: "transparent"

    // ── Font registration ──────────────────────────────────────────────
    FontLoader { source: Qt.resolvedUrl("../../resources/fonts/InterVariable.ttf") }
    FontLoader { source: Qt.resolvedUrl("../../resources/fonts/InterVariable-Italic.ttf") }
    FontLoader { source: Qt.resolvedUrl("../../resources/fonts/JetBrainsMono-Regular.ttf") }
    FontLoader { source: Qt.resolvedUrl("../../resources/fonts/JetBrainsMono-Medium.ttf") }
    FontLoader { source: Qt.resolvedUrl("../../resources/fonts/Caveat-Medium.ttf") }
    FontLoader { source: Qt.resolvedUrl("../../resources/fonts/Caveat-SemiBold.ttf") }

    AppWindow {
        anchors.fill: parent
        appWindow: root
    }

    Binding {
        target: Theme
        property: "darkMode"
        value: projectManager.isDarkTheme
    }

    // Global shortcuts
    Shortcut {
        sequences: [StandardKey.Save]
        onActivated: projectManager.saveProject()
    }
}
