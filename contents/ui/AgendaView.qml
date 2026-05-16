import QtQuick 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.kirigami 2.0 as Kirigami


import "lib/main.js" as CalendarBackend
import "lib/GoogleEventManager.js" as GoogleEventManager

PinchArea {
    id: agendaView

    property var selectedDate: root.selectedDate
    property var firstCalType: root.firstCalType
    property var secondCalType: root.secondCalType

    property var myagendaList: []
    // property var myagendaList:[['اربعین حسینی','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,1])] ]

    property var firstTitle: ""
    property var secondTitle: ""

    property var month_events_cache: []
    property int month_events_cache_index: -1

    property var month_google_events_cache: ({})

    Component.onCompleted: {
        setTitles()
    }

    ColumnLayout {
        id: information
        spacing: Kirigami.Units.smallSpacing
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        PlasmaComponents3.Label {
            Layout.alignment: Qt.AlignCenter
            text: agendaView.firstTitle
            font.pixelSize: 20
        }
        PlasmaComponents3.Label {
            Layout.alignment: Qt.AlignCenter
            text: agendaView.secondTitle
            font.pixelSize: 15
        }
    }

    onSelectedDateChanged:{
        // console.log('=========================')
        setTitles()
        getEvents()
        // console.log('=========================')

    }

    Connections {
        target: root
        function onEventsTypesChanged() {
            updateEvents(agendaView.selectedDate)
            getEvents()
            updateGoogleEvents(agendaView.selectedDate)
        }
    }

    function setTitles() {
        agendaView.firstTitle = getFirstTitle()
        agendaView.secondTitle = getSecondTitle()
    }

    function translate_event(event, colors=['gray','red']) {
        var text = event['text']
        var is_holiday = event['is_holiday']
        var color = is_holiday ? colors[1] : colors[0]
        var link = event['link']
        var sub_text = event['event_source']
        return [text, sub_text, color, link]
    }

    function updateGoogleEvents(Date) {
        console.log("updateGoogleEvents")

        CalendarBackend.get_month_google_events(
            root.firstCalType, Date
        ).then(function(googleEvents) {

            month_google_events_cache = {}
            for (let i = 1; i <= 31; i++) {
                month_google_events_cache[i] = []
            }
            for (let key in googleEvents) {
                for (let idx = 0; idx < googleEvents[key].length; idx++) {
                    var event = translate_event(googleEvents[key][idx], ['#004d39', '#004d39'])
                    month_google_events_cache[Number(key)].push(event)
                }
            }

            getEvents() // This time includes Google events
        }).catch(function(err) {
            console.log("Google event fetch failed:", err)
        })
    }

    function updateEvents(Date) {
        console.log("updateEvents")
        var month_events = CalendarBackend.get_month_events(
            root.firstCalType,
            Date,
            root.eventsTypes
        )

        month_events_cache = {}
        for (let i = 1; i <= 31; i++) {
            month_events_cache[i] = []
        }

        for (let key in month_events) {
            for (let idx = 0; idx < month_events[key].length; idx++) {
                var event = translate_event(month_events[key][idx])
                month_events_cache[Number(key)].push(event)
            }
        }
        month_events_cache_index = Date.getFullYear() * 100 + Date.getMonth()
    }

    function getEvents() {
        var is_update_google_events = false
        if (month_events_cache_index != agendaView.selectedDate.getFullYear() * 100 + agendaView.selectedDate.getMonth()) {
            updateEvents(agendaView.selectedDate)
            is_update_google_events = true
            month_google_events_cache = []
        }
        agendaView.myagendaList = month_events_cache[agendaView.selectedDate.getDate()]
        if (is_update_google_events) {
            updateGoogleEvents(agendaView.selectedDate)
        }
        if ("1" in month_google_events_cache)
            agendaView.myagendaList = month_google_events_cache[agendaView.selectedDate.getDate()].concat(agendaView.myagendaList)
    }

    function getFirstTitle() {
        return CalendarBackend.get_agenda_tool_tip(agendaView.selectedDate, firstCalType, true)
    }

    function getSecondTitle() {
        var tmp = CalendarBackend.convert_calendars_light(selectedDate, firstCalType, secondCalType)
        return CalendarBackend.get_agenda_tool_tip(CalendarBackend.get_unvirsal_date(secondCalType, tmp), secondCalType)
    }

    // end info
    Rectangle {
        id: seperatorLine
        width: parent.width
        height: 1
        opacity: 0.4
        color: "grey"
        anchors {
            left: parent.left
            right: parent.right
            top: information.bottom
            topMargin: 10
        }
    }

    Item {
        id: agendaArea
        anchors {
            left: parent.left
            right: parent.right
            top: seperatorLine.bottom
            bottom: parent.bottom
            margins: 5
            bottomMargin : 10
        }

        // how tall the "fade/shadow overlay" is
        property int bottomOverlayHeight: 28

        Flickable {
            id: flick
            anchors.fill: parent
            clip: true

            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.DragAndOvershootBounds
            interactive: contentHeight > height

            contentWidth: width
            contentHeight: contentColumn.height

            ScrollBar.vertical: ScrollBar {
                id: agendaScrollBar
                parent: flick
                anchors.top: flick.top
                anchors.bottom: flick.bottom
                anchors.right: flick.right
                anchors.rightMargin: 0
                width: 8
                policy: ScrollBar.AsNeeded
                z: 1000
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                hoverEnabled: true

                onWheel: {
                    var dy = wheel.angleDelta ? wheel.angleDelta.y : wheel.delta
                    var newY = flick.contentY - dy
                    var maxY = Math.max(0, flick.contentHeight - flick.height)
                    flick.contentY = Math.max(0, Math.min(maxY, newY))
                    wheel.accepted = true
                }
            }

            Column {
                id: contentColumn
                width: flick.width
                spacing: 5
                height: implicitHeight   // ensure height follows children

                Repeater {
                    model: agendaView.myagendaList
                    AgendaCell {
                        width: contentColumn.width
                        eventTitle: modelData[0]
                        eventColor: modelData[2]
                        eventBackgroudColor: modelData[2]
                        eventSourceName: modelData[1]
                        eventLink: modelData[3]
                    }
                }
            }
        }

        // Bottom overlay shadow (items go "under" this)
        Rectangle {
            id: bottomOverlay
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: agendaArea.bottomOverlayHeight
            color: "black"
            opacity: 1.0
            antialiasing: true
            z: 999
            visible: flick.contentHeight > flick.height &&
                flick.contentY < (flick.contentHeight - flick.height - 1)

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 1.0; color: "#80000000" }
            }
        }
    }

    // Show this message if the list is empty
    PlasmaComponents3.Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: "today has no events :)"
        color: "grey"
        font.pixelSize: 15
        visible: myagendaList.length === 0
    }
}