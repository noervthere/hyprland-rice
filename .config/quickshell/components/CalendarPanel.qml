import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: calPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: root.calendarVisible ? 65 : -400; right: 10 }
    implicitWidth: 320
    implicitHeight: 360
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.calendarVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.top { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    property var currentDate: new Date()
    property var displayDate: new Date()

    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function generateDays() {
        var days = [];
        var firstDayIndex = new Date(displayDate.getFullYear(), displayDate.getMonth(), 1).getDay(); // 0 is Sunday
        var daysInMonth = getDaysInMonth(displayDate.getFullYear(), displayDate.getMonth());
        var daysInPrevMonth = getDaysInMonth(displayDate.getFullYear(), displayDate.getMonth() - 1);

        // Fill empty days from previous month
        for(var i = firstDayIndex - 1; i >= 0; i--) {
            days.push({ day: daysInPrevMonth - i, isCurrent: false, isToday: false });
        }
        
        // Fill current month
        for(var i = 1; i <= daysInMonth; i++) {
            days.push({ day: i, isCurrent: true, isToday: (i === currentDate.getDate() && displayDate.getMonth() === currentDate.getMonth() && displayDate.getFullYear() === currentDate.getFullYear()) });
        }
        
        // Fill empty days for next month to complete the 42 slots grid
        var remaining = 42 - days.length;
        for(var i = 1; i <= remaining; i++) {
            days.push({ day: i, isCurrent: false, isToday: false });
        }
        
        return days;
    }

    Item {
        anchors.fill: parent
        focus: root.calendarVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.calendarVisible = false
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
                anchors.margins: 15
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    
                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: prevMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        Text { anchors.centerIn: parent; text: ""; color: root.walColor5; font.family: "JetBrainsMono Nerd Font" }
                        MouseArea { 
                            id: prevMa; anchors.fill: parent; hoverEnabled:true; cursorShape: Qt.PointingHandCursor 
                            onClicked: { displayDate = new Date(displayDate.getFullYear(), displayDate.getMonth() - 1, 1); daysModel.clear(); var d = generateDays(); for(var i=0;i<d.length;i++) daysModel.append(d[i]); }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: displayDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                        color: root.walForeground
                        font.bold: true
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: nextMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        Text { anchors.centerIn: parent; text: ""; color: root.walColor5; font.family: "JetBrainsMono Nerd Font" }
                        MouseArea { 
                            id: nextMa; anchors.fill: parent; hoverEnabled:true; cursorShape: Qt.PointingHandCursor 
                            onClicked: { displayDate = new Date(displayDate.getFullYear(), displayDate.getMonth() + 1, 1); daysModel.clear(); var d = generateDays(); for(var i=0;i<d.length;i++) daysModel.append(d[i]); }
                        }
                    }
                }

                // Days of week
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            color: root.walColor8
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                }

                // Calendar Grid
                GridLayout {
                    id: grid
                    columns: 7
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    Repeater {
                        model: ListModel { id: daysModel }
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 30
                            color: model.isToday ? root.walColor5 : "transparent"
                            radius: 8

                            Text {
                                anchors.centerIn: parent
                                text: model.day
                                color: model.isToday ? root.walBackground : (model.isCurrent ? root.walForeground : root.walColor8)
                                font.pixelSize: 12
                                font.bold: model.isToday
                                font.family: "JetBrainsMono Nerd Font"
                                opacity: model.isCurrent ? 1.0 : 0.4
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        var d = generateDays();
        for(var i=0;i<d.length;i++) daysModel.append(d[i]);
    }

    Connections {
        target: root
        function onCalendarVisibleChanged() {
            if (root.calendarVisible) {
                currentDate = new Date(); // Update on load
                displayDate = new Date();
                daysModel.clear();
                var d = generateDays();
                for(var i=0;i<d.length;i++) daysModel.append(d[i]);
                focusTimer.start()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            calPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: calPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
    }
}
