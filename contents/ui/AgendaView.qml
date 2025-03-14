import QtQuick 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.core as PlasmaCore

import "lib/main.js" as CalendarBackend

PinchArea {
	id: agendaView
    
    property var selectedDate: root.selectedDate
    property var firstCalType: root.firstCalType
	property var secondCalType : root.secondCalType

    property var eventFiles : root.allEventFiles

    property var myagendaList: []
    // property var myagendaList:[['اربعین حسینی','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,1])] ]
    
    property var firstTitle:""
    property var secondTitle:""

    Component.onCompleted : {
       setTitles()
	}

    ColumnLayout {
			id:information
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
    
    function setTitles(){
        agendaView.firstTitle = getFirstTitle()
        agendaView.secondTitle = getSecondTitle()
    }
    function getEvents(){
        var tmpAgendaList = [];
        agendaView.eventFiles.forEach(eventSource => {
            if (CalendarBackend.calendar_type[eventSource.type] == root.firstCalType){
                var event_month = agendaView.selectedDate.getMonth()
                var event_date = agendaView.selectedDate.getDate()
            }
            else{
                var converted_date = CalendarBackend.convert_calendars_light(agendaView.selectedDate,root.firstCalType,CalendarBackend.calendar_type[eventSource.type])
                var event_month = converted_date[1]
                var event_date = converted_date[2]
            }
            var tmpevents = eventSource.events[event_month][event_date]
            for (let key in tmpevents) {
                    var text = tmpevents[key][0]
                    var is_holiday = tmpevents[key][1]
                    var color = is_holiday ? 'red' : 'gray';
                    var link = ''
                    var sub_text = eventSource.name
                    var event = [text,sub_text,color,link];
                    tmpAgendaList.push(event);
                }
        });
        agendaView.myagendaList = tmpAgendaList
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