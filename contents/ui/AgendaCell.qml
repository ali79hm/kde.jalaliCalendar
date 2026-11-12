import QtQuick 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.0 as Kirigami

import "lib/main.js" as CalendarBackend
import "lib/AppText.js" as AppText

MouseArea {
    id:agendaCell
    property var eventTitle
    property var eventColor
    property var eventBackgroudColor:'transparent'
    property var eventSourceName:''
    property var eventLink:''

    property var eventDetails: null
    property bool expanded: false
    signal toggleRequested()
    readonly property string language: plasmoid.configuration.language
    readonly property bool rightToLeft: language === "fa"

    function tr(text) { return AppText.tr(language, text) }
    readonly property var detailRows: {
        var d = eventDetails;
        if (!d) return [];
        var rows = [];
        function add(label, value) {
            if (value && String(value).trim()) rows.push({label: tr(label), value: String(value)});
        }
        add('Time', d.allDay ? tr('All day') :
            (d.startTime && d.endTime ? d.startTime + ' – ' + d.endTime :
             d.startTime ? tr('Start') + ': ' + d.startTime : d.endTime ? tr('End') + ': ' + d.endTime : ''));
        add('Location', d.location);
        add('Repeat', d.recurring ? tr('Recurring event') : '');
        add('Note', CalendarBackend.plain_event_note(d.description));
        return rows;
    }

    readonly property real collapsedHeight: Math.max(eventTitleLabel.height + 20, 50)
    height: implicitHeight
    onClicked: if (eventDetails) toggleRequested()
    activeFocusOnTab: !!eventDetails
    Keys.onSpacePressed: if (eventDetails) toggleRequested()
    Keys.onReturnPressed: if (eventDetails) toggleRequested()

    hoverEnabled: true

    implicitHeight: collapsedHeight + (expanded && eventDetails ? detailsColumn.implicitHeight + 12 : 0)

    Rectangle {
        id: backgroundRect
        anchors.fill: agendaCell
        opacity:0.1
        radius: 2
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration*2 } }
        color: agendaCell.eventBackgroudColor
    }

    Rectangle {
        id: highlightRect
        anchors.fill: agendaCell
        opacity: agendaCell.containsMouse && !agendaCell.pressed ? 0.4 : 0
        radius: 2
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration*2 } }
        color: Kirigami.Theme.highlightColor
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

        Rectangle {
            width: agendaCell.width - 5 - 10  // Remaining width (parent's width minus first rectangle and spacing)
            height: agendaCell.height
            color: "transparent"  // Set a color for the remaining rectangle

            Label {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                y: (agendaCell.collapsedHeight - height) / 2
                objectName: "eventTitleLabel"
                id: eventTitleLabel
                text: agendaCell.eventTitle
                color: Kirigami.Theme.textColor
                wrapMode: Text.WordWrap // Enable text wrapping
                width: agendaCell.width - 15 // Adjust to fit within the available space
                font.pixelSize: 14
            }
            Label {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 0  // Optional margin to give some space from the edges
                }
                text: agendaCell.eventSourceName  // Add your desired text or model data here
                color: "grey"
                font.pixelSize: 10  // Adjust size to fit the design
                visible: agendaCell.eventSourceName !== "" && !agendaCell.expanded 
            }
            MouseArea {
                visible: !!agendaCell.eventDetails || agendaCell.eventLink !== "" 
                anchors.fill: parent  // Make the entire rectangle clickable
                onClicked: {
                    if (agendaCell.eventDetails) agendaCell.toggleRequested()
                    else Qt.openUrlExternally(agendaCell.eventLink)
                }
                cursorShape: Qt.PointingHandCursor  // Change cursor on hover to indicate it's clickable
            }
        Column {
            id: detailsColumn
            x: 10
            y: agendaCell.collapsedHeight
            width: parent.width - 20
            spacing: 8
            visible: agendaCell.expanded && !!agendaCell.eventDetails
            Rectangle {
                width: parent.width
                height: 1
                color: Kirigami.Theme.textColor
                opacity: 0.25
            }
            Repeater {
                model: agendaCell.detailRows
                Label {
                    width: parent.width
                    objectName: "eventDetailLabel"
                    horizontalAlignment: agendaCell.rightToLeft ? Text.AlignRight : Text.AlignLeft
                    text: modelData.label + ': ' + modelData.value
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: Kirigami.Theme.textColor
                    font.pixelSize: 12
                }
            }
            EventActionButton {
                id: meetingButton
                objectName: "meetingButton"
                readonly property string meetingUrl: agendaCell.eventDetails ? agendaCell.eventDetails.meetingLink || '' : ''
                readonly property bool isGoogleMeet: /^https:\/\/meet\.google\.com(?:[\/:?#]|$)/i.test(meetingUrl)
                visible: meetingUrl.trim().length > 0
                width: parent.width
                rightToLeft: agendaCell.rightToLeft
                text: agendaCell.tr(isGoogleMeet ? 'Join with Google Meet' : 'Join meeting')
                icon.source: isGoogleMeet ? Qt.resolvedUrl("icons/google-meet.svg") : ""
                Accessible.name: text
                onClicked: Qt.openUrlExternally(meetingUrl)
            }
            EventActionButton {
                objectName: "openEventButton"
                rightToLeft: agendaCell.rightToLeft
                width: parent.width
                visible: !!agendaCell.eventLink && String(agendaCell.eventLink).trim().length > 0
                text: agendaCell.tr('Open event')
                onClicked: Qt.openUrlExternally(agendaCell.eventLink)
            }
        }
        }
    }
}
