import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    // ConfigCategory {
    //     name: i18n("General")
    //     icon: "configure"
    //     source: "config/configGeneral.qml"
    // }
    
    ConfigCategory {
        name: i18n("Calendar")
        icon: "view-calendar"
        source: "config/configCalendar.qml"
    }
    ConfigCategory {
        name: i18n("Events")
        icon: "view-calendar-list"
        source: "config/configEvents.qml"
    }
    // ConfigCategory {
    //     name: i18n("Another Tab")
    //     icon: "color-management"
    //     source: "configGeneral.qml"
    // }
}