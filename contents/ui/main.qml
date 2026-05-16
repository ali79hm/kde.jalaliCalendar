import QtQuick 2.2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

// import "lib/PersianDate.js" as PersianDate
import "lib/main.js" as CalendarBackend

PlasmoidItem{
    id:root

    // Layout.minimumWidth: 200
    // Layout.minimumHeight: 200

    // Layout.preferredWidth: 200
    // Layout.preferredHeight: 200

    // implicitWidth: 800
    // implicitHeight: 400


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
    property var eventsTypes : plasmoid.configuration.events_json_files.split(",").filter(item => item !== "")
    property var holidayTypes : plasmoid.configuration.holiday_json_files.split(",").filter(item => item !== "")

    onFirstCalTypeChanged: {
        root.currntDate = reset_day(CalendarBackend.get_unvirsal_date(firstCalType))
        root.nextMonthDate = root.currntDate.addMonth()
	    root.prevMonthDate = root.currntDate.subtractMonth()
        root.today = CalendarBackend.get_unvirsal_date(firstCalType)
    }


    property var selectedDate : CalendarBackend.get_unvirsal_date(firstCalType)
    preferredRepresentation: compactRepresentation
    fullRepresentation: Item {
        id: fullRoot

        // implicitWidth: 720
        // implicitHeight: 420

        // implicitWidth: plasmoid.configuration.onboarding_completed ? calendarView.implicitWidth : Kirigami.Units.gridUnit * 34
        // implicitHeight: plasmoid.configuration.onboarding_completed ? calendarView.implicitHeight : Kirigami.Units.gridUnit * 30

        Calendar {
            id: calendarView
            anchors.fill: parent
            showAgenda: plasmoid.configuration.show_events
            visible: plasmoid.configuration.onboarding_completed
        }

        OnboardingFlow {
            anchors.fill: parent
            visible: !plasmoid.configuration.onboarding_completed
            onFinished: plasmoid.configuration.onboarding_completed = true
        }
    }

    compactRepresentation: CompactRepresentation { }
    // fullRepresentation: CompactRepresentation { }


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
    //     console.log(JSON.stringify(allHolidaysFiles[1]))
    //     console.log("===============================")
    // }
}
