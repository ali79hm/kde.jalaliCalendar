import QtQuick 2.2
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

// import "lib/PersianDate.js" as PersianDate
import "lib/main.js" as CalendarBackend

Item{
    id:root
    property int startOfWeek: 6 //FIXME:must come from calendar backend
    property var firstCalType : plasmoid.configuration.main_calendar
    property var secondCalType : plasmoid.configuration.second_calendar
    property bool showSecondCal : secondCalType!='NO'
    property var layoutDirection : CalendarBackend.get_layout_direction(firstCalType)
    property var weekdaysNames : CalendarBackend.get_weekdays_names(firstCalType)
    property var monthNames : CalendarBackend.get_month_names(firstCalType)
    property var today : CalendarBackend.get_unvirsal_date(firstCalType)
    property var currntDate : reset_day(CalendarBackend.get_unvirsal_date(firstCalType))
    property var nextMonthDate : root.currntDate.addMonth()
	property var prevMonthDate : root.currntDate.subtractMonth()
    
    onFirstCalTypeChanged: {
        root.currntDate = reset_day(CalendarBackend.get_unvirsal_date(firstCalType))
        root.nextMonthDate = root.currntDate.addMonth()
	    root.prevMonthDate = root.currntDate.subtractMonth()
        root.today = CalendarBackend.get_unvirsal_date(firstCalType)
    }

    onSecondCalTypeChanged: {
        console.log("SecondCalTypeChanged")
    }

    property var selectedDate : CalendarBackend.get_unvirsal_date(firstCalType)
    // Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.fullRepresentation: Calendar{
        showAgenda:plasmoid.configuration.show_events
    }

    Plasmoid.compactRepresentation: CompactRepresentation { }
    // Plasmoid.fullRepresentation: CompactRepresentation { }


    function reset_day(date){
        date.setDate(1)
        return date
    }

    Timer {
       id: dateTimer
       interval: 1000
       repeat: true
       running: true
       triggeredOnStart: true
       onTriggered: today = CalendarBackend.get_unvirsal_date(firstCalType)
   }
    // Component.onCompleted : {
    //     console.log("===============================")
    //     console.log(today.format('ddd'))
    //     console.log("===============================")
    // }
}
