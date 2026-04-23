import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: mangaNotifications
    visible: notifModel.count > 0
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    color: "transparent"

    anchors {
        bottom: true
        right: true
    }

    margins {
        bottom: 70
        right: 20
    }

    implicitWidth: 520
    implicitHeight: 850
    WlrLayershell.layer: WlrLayer.Overlay

    NotificationServer {
        id: server
        keepOnReload: true

        // When a notification arrives, append it to our internal model
        onNotification: (notif) => {
            notifModel.append({
                "nId":     notif.id,
                "summary": notif.appName + (notif.summary ? ": " + notif.summary : ""),
                "body":    notif.body || ""
            })

            // Auto-expire after 8 seconds
            var idx = notifModel.count - 1
            expireTimer.createObject(mangaNotifications, { targetIndex: idx })
        }
    }

    ListModel {
        id: notifModel
    }

    // Dynamic timer factory for per-notification expire
    Component {
        id: expireTimer
        Timer {
            property int targetIndex: 0
            interval: 8000
            running: true
            repeat: false
            onTriggered: {
                if (targetIndex < notifModel.count)
                    notifModel.remove(targetIndex)
                destroy()
            }
        }
    }

    ListView {
        id: notifList
        anchors.fill: parent
        model: notifModel
        spacing: 20
        verticalLayoutDirection: ListView.BottomToTop
        interactive: false
        clip: false

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutBack }
                NumberAnimation { property: "scale";   from: 0.8; to: 1; duration: 350; easing.type: Easing.OutBack }
            }
        }

        remove: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        }

        delegate: Item {
            id: notifItem
            width: notifList.width
            height: 230

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // Speech bubble (now on the LEFT, Madoka on the RIGHT)
                Item {
                    id: bubble
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    height: 160

                    // Tail shadow (black diamond, on the RIGHT side)
                    Rectangle {
                        width: 28; height: 28
                        color: "black"
                        rotation: 45
                        x: bubble.width - 14
                        y: bubble.height / 2 - 14
                        z: 1
                    }

                    // Main white bubble
                    Rectangle {
                        anchors.fill: parent
                        color: "white"
                        border.color: "black"
                        border.width: 5
                        radius: 22
                        z: 2

                        // Click to dismiss
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notifModel.remove(index)
                        }
                    }

                    // White tail inner (cuts through border on RIGHT)
                    Rectangle {
                        width: 20; height: 20
                        color: "white"
                        rotation: 45
                        x: bubble.width - 8
                        y: bubble.height / 2 - 10
                        z: 3
                    }

                    // Text content
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        z: 4
                        spacing: 10

                        Text {
                            text: model.summary || "Notification"
                            color: "black"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            font.bold: true
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.body || ""
                            color: "#333333"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            visible: text !== ""
                        }
                    }
                }

                // Madoka character (now on the RIGHT)
                Image {
                    source: "file:///home/neverchosen/Belgeler/madoka.png"
                    Layout.alignment: Qt.AlignBottom
                    fillMode: Image.PreserveAspectFit
                    sourceSize.height: 220
                    Layout.preferredHeight: 220
                    Layout.preferredWidth: 160
                }
            }
        }
    }
}
