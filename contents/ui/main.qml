import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "lib/persian-date.js" as PersianDate
import "lib/main.js" as CalendarBackend

Item{
    id:root
    // property int startOfWeek: Scripts.startOfWeek(screenDate)
    property int startOfWeek: 6 //FIXME:must come from calendar backend
     //FIXME:must come from calendar backend
    // day : [year,month,day,is_today,is_holyday:{0:noholyday , 1:weekends,2:holyday}]
    property var first_cal_type : plasmoid.configuration.main_calendar
    property var weekdaysNames : CalendarBackend.get_weekdays_names(root.first_cal_type)
    property var today : CalendarBackend.get_unvirsal_date(first_cal_type) // WARN:all today usage must change
    property var currntDate : reset_day(CalendarBackend.get_unvirsal_date(first_cal_type))
    property var selectedDate : CalendarBackend.get_unvirsal_date(first_cal_type)
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
        var j = currntDate.daysInMonth()
        var days_list = []
        for(let i = 0;i<count;i++){
            days_list.push(j-i)
        }
        return days_list.reverse()
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
