import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: audioPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: root.audioVisible ? 65 : -200; right: 10 }
    implicitWidth: 320
    implicitHeight: 120
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.audioVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.top { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    property int volume: 0
    property bool muted: false

    Item {
        anchors.fill: parent
        focus: root.audioVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.audioVisible = false
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.85)
            radius: 15
            border.color: Qt.rgba(1,1,1,0.1)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2)
                        
                        Text {
                            anchors.centerIn: parent
                            text: audioPanel.muted ? "󰝟" : (audioPanel.volume > 50 ? "" : "")
                            color: root.walColor5
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: volToggleProc.running = true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: "Output Volume"
                            color: root.walForeground
                            font.pixelSize: 14
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: audioPanel.muted ? "Muted" : (audioPanel.volume + "%")
                            color: root.walColor8
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                            Layout.fillWidth: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 12
                    radius: 6
                    color: Qt.rgba(0,0,0,0.3)

                    Rectangle {
                        width: parent.width * (audioPanel.volume / 100)
                        height: parent.height
                        radius: 6
                        color: audioPanel.muted ? root.walColor8 : root.walColor5
                        Behavior on width { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: function(mouse) {
                            if (pressed) {
                                var v = Math.round((mouse.x / width) * 100)
                                if (v < 0) v = 0
                                if (v > 100) v = 100
                                audioPanel.volume = v
                                volSetProc.targetVol = v
                                volSetProc.running = true
                                if (audioPanel.muted) volToggleProc.running = true
                            }
                        }
                        onClicked: function(mouse) {
                            var v = Math.round((mouse.x / width) * 100)
                            if (v < 0) v = 0
                            if (v > 100) v = 100
                            audioPanel.volume = v
                            volSetProc.targetVol = v
                            volSetProc.running = true
                            if (audioPanel.muted) volToggleProc.running = true
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 500
        running: root.audioVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: volGetProc.running = true
    }

    Process {
        id: volGetProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                var isMuted = line.includes("MUTED")
                var volMatch = line.match(/Volume: ([\d.]+)/)
                if (volMatch) {
                    audioPanel.volume = Math.round(parseFloat(volMatch[1]) * 100)
                }
                audioPanel.muted = isMuted
            }
        }
    }

    Process {
        id: volSetProc
        property int targetVol: 0
        command: ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + targetVol + "%"]
    }

    Process {
        id: volToggleProc
        command: ["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]
        onExited: volGetProc.running = true
    }

    Connections {
        target: root
        function onAudioVisibleChanged() {
            if (root.audioVisible) {
                focusTimer.start()
                volGetProc.running = true
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            audioPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: audioPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
    }
}
