import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

Dialog {
    id: dialog
    title: qsTr("New Project")
    modal: true
    width: 480
    anchors.centerIn: parent

    property var selectedFolder: null

    background: Rectangle {
        color: Theme.bgElevated
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMedium
        Behavior on color { ColorAnimation { duration: Theme.animSlow } }
    }

    header: Rectangle {
        height: 48
        color: "transparent"

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: dialog.title
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeBody
            font.bold: true
            color: Theme.textPrimary
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Theme.border
        }
    }

    footer: Rectangle {
        height: 56
        color: "transparent"

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: Theme.border
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Item { Layout.fillWidth: true }

            AppButton {
                text: qsTr("Cancel")
                onClicked: dialog.reject()
            }
            AppButton {
                text: qsTr("Create Project")
                primary: true
                enabled: nameField.text.trim().length > 0 && dialog.selectedFolder !== null
                onClicked: dialog.accept()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 12

        Label {
            text: qsTr("Project Name")
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeSmall
            color: Theme.textMuted
        }

        AppTextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: qsTr("My AI Video")
        }

        Label {
            text: qsTr("Location")
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeSmall
            color: Theme.textMuted
            Layout.topMargin: 4
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            AppTextField {
                id: pathField
                Layout.fillWidth: true
                readOnly: true
                placeholderText: qsTr("Choose a folder...")
                text: dialog.selectedFolder ? dialog.selectedFolder.toString().replace("file:///", "") : ""
                font.family: Theme.fontMono
                font.pixelSize: Theme.sizeSmall
            }

            AppButton {
                text: qsTr("Browse…")
                onClicked: folderDialog.open()
            }
        }
    }

    onAccepted: {
        if (nameField.text.trim().length > 0 && selectedFolder) {
            projectManager.newProject(nameField.text.trim(), selectedFolder)
            nameField.text = ""
            selectedFolder = null
        }
    }

    onRejected: {
        nameField.text = ""
        selectedFolder = null
    }

    FolderDialog {
        id: folderDialog
        onAccepted: dialog.selectedFolder = folderDialog.selectedFolder
    }
}
