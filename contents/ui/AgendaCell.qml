import QtQuick 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "lib/main.js" as CalendarBackend

MouseArea {
    id:agendaCell
    property var eventTitle
    property var eventColor
    property var eventBackgroudColor:'transparent'
    property var eventSourceName:''
    property var eventLink:''

    hoverEnabled: true

    width: scrollarea.width
    implicitHeight: Math.max(eventTitleLabel.height + 20, 50) // Adjust height dynamically based on content

    Rectangle {
        id: backgroundRect
        anchors.fill: agendaCell
        opacity:0.1
        radius: 2
        Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
        color: agendaCell.eventBackgroudColor
    }

    Rectangle {
        id: highlightRect
        anchors.fill: agendaCell
        opacity: agendaCell.containsMouse ? 0.4 : 0
        radius: 2
        Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
        color: PlasmaCore.Theme.highlightColor
    }
    Row{
        anchors.fill: parent
        spacing: 5

        Rectangle { //evnet color line
            id: roundRect
            width: 5
            height: agendaCell.height
            radius: 2
            opacity:0.8
            color: agendaCell.eventColor

        }

        Column {
            id: eventContent
            anchors.fill: parent
            spacing: 2

            Label {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.centerIn: parent
                id: eventTitleLabel
                text: agendaCell.eventTitle
                color: PlasmaCore.Theme.textColor
                wrapMode: Text.WordWrap // Enable text wrapping
                width: agendaCell.width - 15 // Adjust to fit within the available space
                font.pixelSize: 14
            }
            Label {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.centerIn: parent
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 5  // Optional margin to give some space from the edges
                }
                text: agendaCell.eventSourceName  // Add your desired text or model data here
                color: "grey"
                font.pixelSize: 10  // Adjust size to fit the design
                visible: agendaCell.eventSourceName !== "" 
            }
            MouseArea {
                visible: agendaCell.eventLink !== "" 
                anchors.fill: parent  // Make the entire rectangle clickable
                onClicked: {
                    Qt.openUrlExternally(agendaCell.eventLink)  // Replace with your desired URL
                }
                cursorShape: Qt.PointingHandCursor  // Change cursor on hover to indicate it's clickable
            }
        }
    }
}