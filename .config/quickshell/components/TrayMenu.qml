import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: trayPanel
    visible: root.trayMenuVisible
    implicitWidth: 140
    
    implicitHeight: Math.max(50, trayContent.implicitHeight + 20)
    
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell"

    anchors {
        top: true
        right: true
    }
    margins { top: 65; right: 20 }

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.90)
        border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.5)
        border.width: 1

        Column {
            id: trayContent
            anchors.centerIn: parent
            width: parent.width - 20
            spacing: 10
            
            Text {
                text: "System Tray"
                color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.4)
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                font.pixelSize: 11
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid {
                columns: 3
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: SystemTray.items
                    delegate: Rectangle {
                        width: 32; height: 32; radius: 8
                        color: trayItemArea.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Image {
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            source: modelData.icon ? modelData.icon : ("image://icon/" + modelData.iconName)
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            id: trayItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            onClicked: function(mouse) {
                                // Map coordinates to the Window scope so menus spawn at the actual cursor location
                                var p = mapToItem(null, mouse.x, mouse.y)
                                
                                if (mouse.button === Qt.RightButton) {
                                    // Use display() to show native DBus context menu
                                    if (modelData.hasMenu) {
                                        modelData.display(trayPanel, p.x, p.y)
                                    }
                                } else if (mouse.button === Qt.MiddleButton) {
                                    modelData.secondaryActivate()
                                } else {
                                    // Left click: normally calls activate().
                                    // For apps like Discord that often ignore activate() on Wayland, fallback to showing the menu.
                                    var lowercaseId = (modelData.id || "").toLowerCase()
                                    if ((lowercaseId.indexOf("discord") !== -1 || lowercaseId.indexOf("steam") !== -1 || lowercaseId.indexOf("telegram") !== -1) && modelData.hasMenu) {
                                        modelData.display(trayPanel, p.x, p.y)
                                    } else {
                                        modelData.activate()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 20
                visible: SystemTray.items.count === 0
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "Empty"
                    color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.3)
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.italic: true
                }
            }
        }
    }
}
