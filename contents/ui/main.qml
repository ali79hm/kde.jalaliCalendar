import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "lib/persian-date.js" as PersianDate
import "lib/main.js" as CalendarBackend

Item{
    id:root
    property int startOfWeek: 6 //FIXME:must come from calendar backend
    property var firstCalType : plasmoid.configuration.main_calendar
    property var secondCalType : plasmoid.configuration.second_calendar
    property var layoutDirection : CalendarBackend.get_layout_direction(firstCalType)
    property var weekdaysNames : CalendarBackend.get_weekdays_names(firstCalType)
    property var today : CalendarBackend.get_unvirsal_date(firstCalType)
    property var currntDate : reset_day(CalendarBackend.get_unvirsal_date(firstCalType))
    property var nextMonthDate : root.currntDate.addMonth()
	property var prevMonthDate : root.currntDate.subtractMonth()
    
    onFirstCalTypeChanged: {
        root.currntDate = reset_day(CalendarBackend.get_unvirsal_date(firstCalType))
        root.nextMonthDate = root.currntDate.addMonth()
	    root.prevMonthDate = root.currntDate.subtractMonth()
    }

    property var selectedDate : CalendarBackend.get_unvirsal_date(firstCalType)
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.fullRepresentation: Calendar{
        showAgenda:true
    }
    function reset_day(date){
        date.setDate(1)
        return date
    }
    function daysBedoreCurrentMonth(){
        var count = CalendarBackend.daysBedoreCurrentMonth(root.startOfWeek,root.currntDate.getDay())
        var j = currntDate.subtractMonth().daysInMonth()
        var days_list = []
        for(let i = j-count;i<j;i++){
            days_list.push(i+1)
        }
        return days_list
        // return CalendarBackend.daysBedoreCurrentMonth(6,root.currntDate.getDay())
    }
    function daysAfterCurrentMonth(){
        var count = 42 - root.currntDate.daysInMonth() - daysBedoreCurrentMonth().length
        var days_list = []
        for(let i = 0;i<count;i++){
            days_list.push(i+1)
        }
        return days_list
        // return 42 - root.currntDate.daysInMonth().length - daysBedoreCurrentMonth() 
    }

    // Component.onCompleted : {
    //     console.log("===============================")
    //     console.log("===============================")
    // }
}
