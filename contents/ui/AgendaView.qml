import QtQuick 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.15

import "lib/main.js" as CalendarBackend

PinchArea {
	id: agendaView
    
    property var selectedDate: root.selectedDate
    property var firstCalType: root.firstCalType
	property var secondCalType : root.secondCalType

    property var myagendaList: []
    // property var myagendaList:[['اربعین حسینی','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,1])] ]
    
    property var firstTitle:""
    property var secondTitle:""

    property var month_events_cache : []
    property int month_events_cache_index : -1

    Component.onCompleted : {
       setTitles()
	}

    ColumnLayout {
			id:information
			spacing: PlasmaCore.Units.smallSpacing
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
                text:agendaView.secondTitle
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
            getEvents();
        }
    }
    
    function setTitles(){
        agendaView.firstTitle = getFirstTitle()
        agendaView.secondTitle = getSecondTitle()
    }
    function updateEvents(Date){
        var month_events =  CalendarBackend.get_month_events(
            root.firstCalType,
            Date,
            root.eventsTypes
        )

        month_events_cache = {};
        for (let i = 1; i <= 31; i++) {
            month_events_cache[i] = [];
        }

		for (let key in month_events) {
			for (let idx = 0; idx < month_events[key].length; idx++) {
                var text = month_events[key][idx]['text']
                var is_holiday = month_events[key][idx]['is_holiday']
                var color = is_holiday ? 'red' : 'gray';
                var link = month_events[key][idx]['link']
                var sub_text = month_events[key][idx]['event_source']
                var event = [text,sub_text,color,link];
                month_events_cache[Number(key)].push(event);
			}
		}
        month_events_cache_index = Date.getMonth()
    }

    function getEvents(){
        if (month_events_cache_index != agendaView.selectedDate.getMonth()){
            updateEvents(agendaView.selectedDate)
            // console.log('events updated')
        }
        agendaView.myagendaList = month_events_cache[agendaView.selectedDate.getDate()]
    }
    function getFirstTitle(){
        return CalendarBackend.get_agenda_tool_tip(agendaView.selectedDate,firstCalType,true)
    }
    function getSecondTitle(){
        var tmp = CalendarBackend.convert_calendars_light(selectedDate,firstCalType,secondCalType)
		
        return CalendarBackend.get_agenda_tool_tip(CalendarBackend.get_unvirsal_date(secondCalType,tmp),secondCalType)
    }

    //end info
    // Add a gray line as a separator
    Rectangle {
        id : seperatorLine
        width: parent.width
        height: 1
        opacity:0.4
        color: "grey"
        anchors {
            left: parent.left
            right: parent.right
            top: information.bottom
            topMargin: 10
        }
    }
    //scroll
    ScrollView{
        anchors.margins: 5
        id:scrollarea
        // contentWidth: -1
        ScrollBar.vertical.visible: contentHeight > height

        height:parent.height-information.height
        width:parent.width
        // anchors.fill: parent
        anchors {
				horizontalCenter: parent.horizontalCenter
                // topMargin: 2
				top: seperatorLine.bottom
			}
        Column{
            width: scrollarea.width
            spacing: 5 
            Repeater {
                model: agendaView.myagendaList
                AgendaCell{
                    eventTitle:modelData[0]
                    eventColor:modelData[2]
                    eventBackgroudColor:modelData[2]
                    eventSourceName:modelData[1]
                    eventLink:modelData[3]

                }
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
        visible: myagendaList.length === 0  // Visible only if the list is empty
    }
}