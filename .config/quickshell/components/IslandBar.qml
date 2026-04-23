import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: bar
    visible: true
    exclusionMode: ExclusionMode.Exclusive
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell"
    
    implicitHeight: 48
    color: "transparent"
    
    anchors {
        top: true
        left: true
        right: true
    }
    margins { top: 4 }

    // Local state variables
    property int cpuPercent: 0
    property int ramPercent: 0
    property int activeWsId: 1
    property int targetWsId: 1
    
    // Music state
    property string activeMusicString: ""
    property bool isMusicPlaying: false

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            var parts, wsId
            if (event.name === "workspace") {
                wsId = parseInt(event.data.trim())
                if (!isNaN(wsId)) {
                    bar.targetWsId = wsId
                    wsTransition.restart()
                }
            } else if (event.name === "focusedmon") {
                parts = event.data.split(",")
                if (parts.length >= 2) {
                    wsId = parseInt(parts[1])
                    if (!isNaN(wsId)) {
                        bar.targetWsId = wsId
                        wsTransition.restart()
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: wsTransition
        PropertyAnimation { target: wsHighlight; property: "highlightOpacity"; to: 0.4; duration: 50; easing.type: Easing.OutQuad }
        ScriptAction { script: bar.activeWsId = bar.targetWsId }
        ParallelAnimation {
            PropertyAnimation { target: wsHighlight; property: "highlightOpacity"; to: 1; duration: 300; easing.type: Easing.OutCubic }
            PropertyAnimation { target: wsHighlight; property: "highlightScale"; from: 0.9; to: 1.0; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
        }
    }

    Component.onCompleted: {
        if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace) {
            bar.activeWsId = Hyprland.focusedMonitor.activeWorkspace.id
            bar.targetWsId = bar.activeWsId
        }
    }

    // Poll Hardware Stats & Music
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { cpuProc.running = true; ramProc.running = true; musicProc.running = true; }
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'"]
        stdout: SplitParser {
            onRead: data => { bar.cpuPercent = parseInt(Math.round(parseFloat(data.trim()))) || 0; }
        }
    }
    
    Process {
        id: ramProc
        command: ["bash", "-c", "free | grep Mem | awk '{print $3/$2 * 100.0}'"]
        stdout: SplitParser {
            onRead: data => { bar.ramPercent = parseInt(Math.round(parseFloat(data.trim()))) || 0; }
        }
    }

    Process {
        id: musicProc
        command: ["bash", "-c", "status=$(playerctl --player=%any status 2>/dev/null); artist=$(playerctl --player=%any metadata artist 2>/dev/null); title=$(playerctl --player=%any metadata title 2>/dev/null); if [ \"$status\" = \"Playing\" ] || [ \"$status\" = \"Paused\" ]; then if [ -n \"$title\" ]; then text=\"$title\"; [ -n \"$artist\" ] && text=\"$artist - $title\"; if [ ${#text} -gt 45 ]; then text=\"${text:0:42}...\"; fi; echo \"$status|$text\"; else echo 'stopped|'; fi; else echo 'stopped|'; fi"]
        stdout: SplitParser {
            onRead: data => { 
                var parts = data.trim().split("|");
                if (parts[0] === "Playing" || parts[0] === "Paused") {
                    bar.isMusicPlaying = true;
                    bar.activeMusicString = parts[1];
                } else {
                    bar.isMusicPlaying = false;
                    bar.activeMusicString = "";
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        // ===================================
        // LEFT PILL (Launcher & Workspaces)
        // ===================================
        Rectangle {
            anchors.left: parent.left
            height: 44
            width: leftRow.implicitWidth + 30
            radius: height / 2
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.70)
            border.color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.1)
            border.width: 1

            Row {
                id: leftRow
                anchors.centerIn: parent
                spacing: 12
                
                // App Launcher / Dashboard Toggle
                Rectangle {
                    width: 30; height: 30; radius: 15
                    color: launcherArea.containsMouse ? root.walColor5 : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰣇"
                        color: launcherArea.containsMouse ? root.walBackground : root.walForeground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    MouseArea {
                        id: launcherArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton) {
                                root.toggleDashboard()
                            } else {
                                root.toggleLauncher()
                            }
                        }
                        onEntered: parent.scale = 1.10
                        onExited: parent.scale = 1.0
                    }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                }

                // Workspace pill container
                Rectangle {
                    width: wsRow.width + 12
                    height: 26
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 13
                    color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.08)

                    Item {
                        id: wsContainer
                        anchors.centerIn: parent
                        width: wsRow.width
                        height: 20

                        Rectangle {
                            id: wsHighlight
                            height: 20
                            radius: 10
                            
                            property real targetX: 0
                            property real targetWidth: 26
                            property real highlightOpacity: 1.0
                            property real highlightScale: 1.0

                            x: targetX
                            width: targetWidth
                            opacity: highlightOpacity
                            scale: highlightScale
                            transformOrigin: Item.Center
                            
                            color: root.walColor5
                            antialiasing: true

                            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }

                        Row {
                            id: wsRow
                            anchors.centerIn: parent
                            spacing: 4

                            Repeater {
                                id: wsRepeater
                                model: Hyprland.workspaces

                                delegate: Item {
                                    required property var modelData
                                    property bool isActive: bar.activeWsId === modelData.id
                                    property bool isHovered: wsMA.containsMouse

                                    visible: modelData.id > 0
                                    width: Math.max(wsText.implicitWidth + 12, 24)
                                    height: 20

                                    onIsActiveChanged: updateHighlight()
                                    onXChanged: if (isActive) updateHighlight()
                                    onWidthChanged: if (isActive) updateHighlight()
                                    Component.onCompleted: if (isActive) updateHighlight()

                                    function updateHighlight() {
                                        if (isActive) {
                                            wsHighlight.targetX = x
                                            wsHighlight.targetWidth = width
                                        }
                                    }

                                    Text {
                                        id: wsText
                                        anchors.centerIn: parent
                                        text: modelData.name || modelData.id.toString()
                                        color: isActive ? root.walBackground : (isHovered ? root.walForeground : Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.5))
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: "JetBrainsMono Nerd Font"

                                        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                    }

                                    MouseArea {
                                        id: wsMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Hyprland.dispatch("workspace " + modelData.id)
                                    }
                                }
                            }
                        }

                        Connections {
                            target: bar
                            function onActiveWsIdChanged() {
                                for (var i = 0; i < wsRepeater.count; i++) {
                                    var item = wsRepeater.itemAt(i)
                                    if (item && item.isActive) {
                                        item.updateHighlight()
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ===================================
        // CENTER PILL (Dynamic Media Tracker)
        // ===================================
        Rectangle {
            anchors.centerIn: parent
            height: 44
            visible: bar.isMusicPlaying
            opacity: bar.isMusicPlaying ? 1.0 : 0.0
            width: centerRow.implicitWidth + 30
            radius: height / 2
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.70)
            border.color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.1)
            border.width: 1
            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

            Row {
                id: centerRow
                anchors.centerIn: parent
                spacing: 10
                Text {
                    visible: bar.isMusicPlaying
                    text: bar.activeMusicString
                    color: musicTextArea.containsMouse ? root.walColor5 : root.walForeground
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        id: musicTextArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleMusic()
                    }
                }
            }
        }

        // ===================================
        // RIGHT PILL (HW, Slim Clock, Tray, Toggles)
        // ===================================
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 44
            width: rightRow.implicitWidth + 30
            radius: height / 2
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.70)
            border.color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.1)
            border.width: 1

            Row {
                id: rightRow
                anchors.centerIn: parent
                spacing: 18
                
                // Hardware Specs
                Row {
                    spacing: 12
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        text: " " + bar.ramPercent + "%"
                        color: root.walColor5
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Text {
                        text: " " + bar.cpuPercent + "%"
                        color: root.walForeground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                // Minimal Clock
                Rectangle {
                    width: clockText.implicitWidth + 24
                    height: 30
                    radius: 15
                    color: clockArea.containsMouse || root.calendarVisible ? root.walColor5 : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        id: clockText
                        anchors.centerIn: parent
                        color: (clockArea.containsMouse || root.calendarVisible) ? root.walBackground : root.walForeground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true

                        Timer {
                            interval: 1000; running: true; repeat: true
                            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "MMM d • hh:mm AP")
                        }
                        
                        Component.onCompleted: clockText.text = Qt.formatDateTime(new Date(), "MMM d • hh:mm AP")
                    }
                    MouseArea {
                        id: clockArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleCalendar()
                        
                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                    }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                }

                // Interactive Buttons
                Row {
                    spacing: 6
                    anchors.verticalCenter: parent.verticalCenter

                    // Dashboard Toggle
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: dashboardArea.containsMouse || root.dashboardVisible ? root.walColor5 : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰕮"
                            color: (dashboardArea.containsMouse || root.dashboardVisible) ? root.walBackground : root.walForeground
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        MouseArea {
                            id: dashboardArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleDashboard()
                            
                            onEntered: parent.scale = 1.10
                            onExited: parent.scale = 1.0
                        }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    }

                    // Tray Dropdown Toggle
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: trayMenuArea.containsMouse || root.trayMenuVisible ? root.walColor5 : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰅂"
                            color: (trayMenuArea.containsMouse || root.trayMenuVisible) ? root.walBackground : root.walForeground
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            rotation: root.trayMenuVisible ? 180 : 0
                            Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        MouseArea {
                            id: trayMenuArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleTrayMenu()
                            
                            onEntered: parent.scale = 1.10
                            onExited: parent.scale = 1.0
                        }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    }

                    // Toggles wrapper
                    Rectangle {
                        width: 1; height: 20
                        color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.15)
                    }

                    // Bluetooth Toggle
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: btArea.containsMouse || root.btVisible ? root.walColor5 : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: root.btEnabled ? "󰂯" : "󰂲"
                            color: (btArea.containsMouse || root.btVisible) ? root.walBackground : root.walForeground
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        MouseArea {
                            id: btArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleBluetooth()
                            
                            onEntered: parent.scale = 1.10
                            onExited: parent.scale = 1.0
                        }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    }

                    // Audio Toggle
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: volArea.containsMouse || root.audioVisible ? root.walColor5 : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰕾"
                            color: (volArea.containsMouse || root.audioVisible) ? root.walBackground : root.walForeground
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        MouseArea {
                            id: volArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleAudio()
                            
                            onEntered: parent.scale = 1.10
                            onExited: parent.scale = 1.0
                        }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    }

                    // WiFi Toggle
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: wifiArea.containsMouse || root.wifiVisible ? root.walColor5 : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: root.wifiEnabled ? "󰤨" : "󰤭"
                            color: (wifiArea.containsMouse || root.wifiVisible) ? root.walBackground : root.walForeground
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        MouseArea {
                            id: wifiArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleWifi()
                            
                            onEntered: parent.scale = 1.10
                            onExited: parent.scale = 1.0
                        }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    }
                }
            }
        }
    }
}
