import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    // ConfigCategory {
    //     name: i18n("General")
    //     icon: "configure"
    //     source: "config/configGeneral.qml"
    // }
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "config/configAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Calendar")
        icon: "office-calendar"
        source: "config/configCalendar.qml"
    }
    // ConfigCategory {
    //     name: i18n("Another Tab")
    //     icon: "color-management"
    //     source: "configGeneral.qml"
    // }
}