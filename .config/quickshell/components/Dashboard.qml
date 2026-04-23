import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: dashboard
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; right: true }
    margins { top: 65; bottom: 20; right: root.dashboardVisible ? 20 : -450 }
    implicitWidth: 420
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.dashboardVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    property int cpuVal: 0
    property int ramVal: 0
    property int diskVal: 0
    property int batVal: 100
    property int volVal: 50
    property int brightVal: 100
    property string configPath: Quickshell.env("HOME") + "/.config/quickshell"

    Item {
        anchors.fill: parent
        focus: root.dashboardVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.dashboardVisible = false
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.85)
            radius: 20
            border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.3)
            border.width: 1

            // Profile picker background removed
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                z: 100

                // Music Player
                Rectangle {
                    id: mprisCard
                    Layout.fillWidth: true
                    Layout.preferredHeight: 130
                    color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.05)
                    border.color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.1)
                    border.width: 1
                    radius: 16
                    clip: true

                    property var player: {
                        var players = Mpris.players.values;
                        if (!players || players.length === 0) return null;
                        for (var i = 0; i < players.length; i++) {
                            if (players[i].isPlaying) return players[i];
                        }
                        return players[0];
                    }
                    property bool hasTrack: player !== null && (player.playbackState === MprisPlaybackState.Playing || player.playbackState === MprisPlaybackState.Paused)
                    property bool isPlaying: player !== null && player.playbackState === MprisPlaybackState.Playing

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 12
                        // Main Player Elements
                        // Details
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: mprisCard.player ? mprisCard.player.trackTitle : "Offline"
                                color: mprisCard.hasTrack ? root.walColor5 : root.walForeground
                                font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true; elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: mprisCard.player ? mprisCard.player.trackArtist : ""
                                color: root.walForeground; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"
                                opacity: 0.7; Layout.fillWidth: true; elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Controls
                        Row {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 14
                            opacity: mprisCard.hasTrack ? 1.0 : 0.4
                            Rectangle {
                                width: 30; height: 30; radius: 8; color: "transparent"
                                Text { anchors.centerIn: parent; text: "󰒮"; color: root.walForeground; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (mprisCard.player) mprisCard.player.previous() }
                            }
                            Rectangle {
                                width: 36; height: 36; radius: 18; color: root.walColor5
                                Text { anchors.centerIn: parent; text: mprisCard.isPlaying ? "󰏤" : "󰐊"; color: root.walBackground; font.pixelSize: 20; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenterOffset: mprisCard.isPlaying ? 0 : 0 }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (mprisCard.player) mprisCard.player.togglePlaying() }
                            }
                            Rectangle {
                                width: 30; height: 30; radius: 8; color: "transparent"
                                Text { anchors.centerIn: parent; text: "󰒭"; color: root.walForeground; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (mprisCard.player) mprisCard.player.next() }
                            }
                        }
                    }
                }

                // Time Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 104
                    color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.05)
                    border.color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.1)
                    border.width: 1
                    radius: 16
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            id: timeDisplay
                            Layout.alignment: Qt.AlignHCenter
                            text: "12:00 AM"
                            color: root.walColor13
                            font.pixelSize: 36
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            id: dateDisplay
                            Layout.alignment: Qt.AlignHCenter
                            text: "Fri, Jan 01"
                            color: root.walForeground
                            font.pixelSize: 13
                            opacity: 0.8
                            horizontalAlignment: Text.AlignHCenter
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                }

                // Middle Section: Sys Controls
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.05)
                    border.color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.1)
                    border.width: 1
                    radius: 16

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        // Volume
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            Text {
                                text: dashboard.volVal == 0 ? "󰝟" : dashboard.volVal < 50 ? "󰖀" : "󰕾"
                                color: root.walColor4
                                font.pixelSize: 22
                                font.family: "JetBrainsMono Nerd Font"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: volMuteProc.running = true
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: 12
                                radius: 6
                                color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.8)
                                Rectangle {
                                    width: parent.width * dashboard.volVal / 100
                                    height: parent.height
                                    radius: 6
                                    color: root.walColor4
                                    Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            var pc = Math.max(0, Math.min(100, Math.round((mouse.x / parent.width) * 100)))
                                            dashboard.volVal = pc
                                            volSetProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (pc / 100).toFixed(2)]
                                            volSetProc.running = true
                                        }
                                    }
                                }
                            }
                        }

                        // Brightness
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            Text {
                                text: dashboard.brightVal < 30 ? "󰃞" : dashboard.brightVal < 70 ? "󰃟" : "󰃠"
                                color: root.walColor13
                                font.pixelSize: 22
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: 12
                                radius: 6
                                color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.8)
                                Rectangle {
                                    width: parent.width * dashboard.brightVal / 100
                                    height: parent.height
                                    radius: 6
                                    color: root.walColor13
                                    Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            var pc = Math.max(1, Math.min(100, Math.round((mouse.x / parent.width) * 100)))
                                            dashboard.brightVal = pc
                                            brightSetProc.command = ["bash", "-c", "brightnessctl set " + pc + "%"]
                                            brightSetProc.running = true
                                        }
                                    }
                                }
                            }
                        }

                        // Battery
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            Text {
                                id: batIcon
                                text: "󰁹"
                                color: root.walColor2
                                font.pixelSize: 22
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "Battery " + dashboard.batVal + "%"
                                    color: root.walForeground
                                    font.pixelSize: 14
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                Text {
                                    id: batStatus
                                    text: "Checking..."
                                    color: root.walForeground
                                    opacity: 0.6
                                    font.pixelSize: 11
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }
                        }
                    }
                }

                // Hardware Rings Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.05)
                    border.color: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.1)
                    border.width: 1
                    radius: 16

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 20
                        Item { Layout.fillWidth: true }
                        CircularStat { label: "CPU"; barColor: root.walColor1; value: dashboard.cpuVal }
                        CircularStat { label: "RAM"; barColor: root.walColor5; value: dashboard.ramVal }
                        CircularStat { label: "DSK"; barColor: root.walColor4; value: dashboard.diskVal }
                        Item { Layout.fillWidth: true }
                    }
                }

                Item { Layout.fillHeight: true } // spacer

                // Power Buttons Footer
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.8)
                    border.color: Qt.rgba(root.walColor1.r, root.walColor1.g, root.walColor1.b, 0.4)
                    border.width: 1
                    radius: 30

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        Item { Layout.fillWidth: true }
                        PowerBtn { icon: "󰌾"; iconColor: root.walColor5; cmd: "hyprlock" }
                        PowerBtn { icon: "󰒲"; iconColor: root.walColor4; cmd: "systemctl suspend" }
                        PowerBtn { icon: "󰍃"; iconColor: root.walForeground; cmd: "hyprctl dispatch exit" }
                        PowerBtn { icon: "󰜉"; iconColor: root.walColor13; cmd: "systemctl reboot" }
                        PowerBtn { icon: "⏻"; iconColor: root.walColor1; cmd: "systemctl poweroff" }
                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onDashboardVisibleChanged() {
            if (root.dashboardVisible) {
                focusTimer.start()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }

    component CircularStat: Item {
        property string label
        property string icon
        property color barColor
        property int value
        width: 90
        height: 110
        Column {
            anchors.centerIn: parent
            spacing: 8
            Item {
                width: 70
                height: 70
                anchors.horizontalCenter: parent.horizontalCenter
                Canvas {
                    anchors.fill: parent
                    property int statValue: value
                    onStatValueChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.lineWidth = 5
                        ctx.lineCap = "round"
                        ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.3)
                        ctx.beginPath()
                        ctx.arc(35, 35, 32, 0, 2 * Math.PI)
                        ctx.stroke()
                        ctx.strokeStyle = barColor
                        ctx.beginPath()
                        ctx.arc(35, 35, 32, -Math.PI / 2, -Math.PI / 2 + (statValue / 100) * 2 * Math.PI)
                        ctx.stroke()
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: icon
                        color: barColor
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: value + "%"
                        color: root.walForeground
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                color: root.walColor8
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }

    component PowerBtn: Rectangle {
        property string icon
        property color iconColor
        property string cmd
        width: 40
        height: 40
        radius: 10
        color: powerMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
        Text {
            anchors.centerIn: parent
            text: icon
            color: iconColor
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
        }
        MouseArea {
            id: powerMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: cmdProc.running = true
        }
        Process {
            id: cmdProc
            command: ["bash", "-c", cmd]
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var hours = now.getHours()
            var minutes = now.getMinutes()
            var seconds = now.getSeconds()
            var ampm = hours >= 12 ? 'PM' : 'AM'
            hours = hours % 12
            hours = hours ? hours : 12
            var h = hours < 10 ? '0' + hours : hours
            var m = minutes < 10 ? '0' + minutes : minutes
            var s = seconds < 10 ? '0' + seconds : seconds
            timeDisplay.text = h + ':' + m + ':' + s + ' ' + ampm
            dateDisplay.text = Qt.formatDate(now, "dd.MM.yyyy, dddd")
        }
    }

    Timer {
        interval: 2000
        running: root.dashboardVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!cpuProc.running) cpuProc.running = true
            if (!ramProc.running) ramProc.running = true
            if (!diskProc.running) diskProc.running = true
            if (!batProc.running) batProc.running = true
            if (!batStatusProc.running) batStatusProc.running = true
            if (!volProc.running) volProc.running = true
            if (!brightProc.running) brightProc.running = true
            if (!uptimeProc.running) uptimeProc.running = true
        }
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}'"]
        stdout: SplitParser { onRead: data => dashboard.cpuVal = parseInt(data) || 0 }
    }
    Process {
        id: ramProc
        command: ["bash", "-c", "free | awk '/Mem:/ {printf \"%.0f\", $3/$2*100}'"]
        stdout: SplitParser { onRead: data => dashboard.ramVal = parseInt(data) || 0 }
    }
    Process {
        id: diskProc
        command: ["bash", "-c", "df / | awk 'NR==2 {gsub(/%/,\"\"); print $5}'"]
        stdout: SplitParser { onRead: data => dashboard.diskVal = parseInt(data) || 0 }
    }
    Process {
        id: batProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100"]
        stdout: SplitParser {
            onRead: data => {
                dashboard.batVal = parseInt(data) || 100
                var cap = dashboard.batVal
                if (cap >= 90) batIcon.text = "󰁹"
                else if (cap >= 80) batIcon.text = "󰂂"
                else if (cap >= 70) batIcon.text = "󰂁"
                else if (cap >= 60) batIcon.text = "󰂀"
                else if (cap >= 50) batIcon.text = "󰁿"
                else if (cap >= 40) batIcon.text = "󰁾"
                else if (cap >= 30) batIcon.text = "󰁽"
                else if (cap >= 20) batIcon.text = "󰁼"
                else if (cap >= 10) batIcon.text = "󰁻"
                else batIcon.text = "󰁺"
            }
        }
    }
    Process {
        id: batStatusProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Unknown"]
        stdout: SplitParser {
            onRead: data => {
                var status = data.trim()
                if (status === "Charging") {
                    batStatus.text = "Charging"
                    batIcon.text = "󰂄"
                } else if (status === "Full") {
                    batStatus.text = "Fully charged"
                } else {
                    batStatus.text = "Discharging"
                }
            }
        }
    }
    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f\", $2*100}'"]
        stdout: SplitParser { onRead: data => dashboard.volVal = parseInt(data) || 0 }
    }
    Process {
        id: brightProc
        command: ["bash", "-c", "brightnessctl -m | awk -F, '{gsub(/%/,\"\"); print $4}'"]
        stdout: SplitParser { onRead: data => dashboard.brightVal = parseInt(data) || 100 }
    }
    Process {
        id: uptimeProc
        command: ["bash", "-c", "uptime -p"]
        stdout: SplitParser { onRead: data => uptimeText.text = data.trim() }
    }
}