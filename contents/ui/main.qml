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
        showAgenda:plasmoid.configuration.show_events 
    }
    function reset_day(date){
        date.setDate(1)
        return date
    }

    // Component.onCompleted : {
    //     console.log("===============================")
    //     console.log("===============================")
    // }
}
