import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: wifiPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: root.wifiVisible ? 58 : -500; right: 10 }
    implicitHeight: 440
    implicitWidth: 340
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.wifiVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.top { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Item {
        anchors.fill: parent
        focus: root.wifiVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (root.wifiPasswordSSID !== "") {
                    root.wifiPasswordSSID = ""
                    wifiPassInput.text = ""
                } else {
                    root.wifiVisible = false
                }
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.85)
            radius: 18
            border.color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.1)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        width: 36; height: 36; radius: 12
                        color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.15)
                        Text {
                            anchors.centerIn: parent
                            text: "󰤨"
                            color: root.walColor5
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            text: "Wi-Fi"
                            color: root.walForeground
                            font.pixelSize: 15
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            text: root.wifiEnabled ? (root.wifiCurrentSSID !== "" ? "Connected" : "Enabled") : "Disabled"
                            color: root.walColor8
                            font.pixelSize: 10
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 48
                        height: 26
                        radius: 13
                        color: root.wifiEnabled ? root.walColor5 : Qt.rgba(0.3, 0.3, 0.3, 0.5)
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Rectangle {
                            width: 22
                            height: 22
                            radius: 11
                            y: 2
                            x: root.wifiEnabled ? 24 : 2
                            color: root.walBackground
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wifiToggleProc.running = true
                        }
                    }
                }

                // Current Connection Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: 14
                    color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.08)
                    border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2)
                    border.width: 1
                    visible: root.wifiCurrentSSID !== ""

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Rectangle {
                            width: 32; height: 32; radius: 10
                            color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.15)
                            Text {
                                anchors.centerIn: parent
                                text: root.wifiSignal > 66 ? "󰤨" : root.wifiSignal > 33 ? "󰤥" : "󰤟"
                                color: root.walColor5
                                font.pixelSize: 16
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: root.wifiCurrentSSID
                                color: root.walForeground
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "Connected · " + root.wifiSignal + "%"
                                color: root.walColor8
                                font.pixelSize: 10
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        Rectangle {
                            width: 28; height: 28; radius: 8
                            color: wifiDiscMa.containsMouse ? Qt.rgba(root.walColor1.r, root.walColor1.g, root.walColor1.b, 0.15) : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: wifiDiscMa.containsMouse ? root.walColor1 : root.walColor8
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            MouseArea {
                                id: wifiDiscMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: wifiDisconnectProc.running = true
                            }
                        }
                    }
                }

                // Password Input
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 12
                    color: Qt.rgba(0, 0, 0, 0.25)
                    border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.3)
                    border.width: 1
                    visible: root.wifiPasswordSSID !== ""
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 10
                        spacing: 10
                        Text {
                            text: "󰌾"
                            color: root.walColor5
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        TextInput {
                            id: wifiPassInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: root.walForeground
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            clip: true
                            Text {
                                text: "Password for " + root.wifiPasswordSSID
                                color: root.walColor8
                                visible: !parent.text
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                font: parent.font
                            }
                            Keys.onReturnPressed: {
                                if (wifiPassInput.text.length > 0) {
                                    root.wifiConnecting = true
                                    wifiConnectProc.ssid = root.wifiPasswordSSID
                                    wifiConnectProc.password = wifiPassInput.text
                                    wifiConnectProc.running = true
                                    wifiPassInput.text = ""
                                }
                            }
                            Keys.onEscapePressed: {
                                root.wifiPasswordSSID = ""
                                wifiPassInput.text = ""
                            }
                        }
                        Rectangle {
                            width: 28; height: 28; radius: 8
                            color: root.walColor5
                            Text {
                                anchors.centerIn: parent
                                text: "→"
                                color: root.walBackground
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (wifiPassInput.text.length > 0) {
                                        root.wifiConnecting = true
                                        wifiConnectProc.ssid = root.wifiPasswordSSID
                                        wifiConnectProc.password = wifiPassInput.text
                                        wifiConnectProc.running = true
                                        wifiPassInput.text = ""
                                    }
                                }
                            }
                        }
                    }
                }

                // Available Networks Header
                RowLayout {
                    Layout.fillWidth: true
                    visible: root.wifiEnabled
                    Text {
                        text: "Available Networks"
                        color: root.walColor8
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 28; height: 28; radius: 8
                        color: wifiRefreshMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.15) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: root.wifiScanning ? "󰑓" : "󰑐"
                            color: wifiRefreshMa.containsMouse ? root.walColor5 : root.walColor8
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        MouseArea {
                            id: wifiRefreshMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!root.wifiScanning) root.refreshWifi()
                            }
                        }
                    }
                }

                // Network List
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(0, 0, 0, 0.2)
                    radius: 14
                    clip: true

                    ListView {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        model: root.wifiNetworks
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 48
                            radius: 12
                            color: wifiNetMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.1) : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                Rectangle {
                                    width: 28; height: 28; radius: 8
                                    color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.1)
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.signal > 66 ? "󰤨" : modelData.signal > 33 ? "󰤥" : "󰤟"
                                        color: root.walColor5
                                        font.pixelSize: 14
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        text: modelData.ssid
                                        color: root.walForeground
                                        font.pixelSize: 12
                                        font.family: "JetBrainsMono Nerd Font"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: (modelData.security !== "" && modelData.security !== "--" ? "󰌾 " + modelData.security : "Open") + " · " + modelData.signal + "%"
                                        color: root.walColor8
                                        font.pixelSize: 9
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }

                                Text {
                                    visible: modelData.security !== "" && modelData.security !== "--"
                                    text: "󰌾"
                                    color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.3)
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }
                            MouseArea {
                                id: wifiNetMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.security !== "" && modelData.security !== "--") {
                                        root.wifiPasswordSSID = modelData.ssid
                                        wifiPassInput.forceActiveFocus()
                                    } else {
                                        root.wifiConnecting = true
                                        wifiConnectProc.ssid = modelData.ssid
                                        wifiConnectProc.password = ""
                                        wifiConnectProc.running = true
                                    }
                                }
                            }
                        }
                        ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: root.wifiNetworks.length === 0 && !root.wifiScanning
                        text: root.wifiEnabled ? "No networks found" : "Wi-Fi is off"
                        color: root.walColor8
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: root.wifiScanning
                        text: "Scanning..."
                        color: root.walColor8
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onWifiVisibleChanged() {
            if (root.wifiVisible) {
                focusTimer.start()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            wifiPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            wifiPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }
}