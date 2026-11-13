import "../ui/lib/AppText.js" as AppText
import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: AppText.tr(plasmoid.configuration.language, "Language")
        icon: "preferences-desktop-locale"
        source: "config/configLanguage.qml"
    }
    // ConfigCategory {
    //     name: AppText.tr(plasmoid.configuration.language, "General")
    //     icon: "configure"
    //     source: "config/configGeneral.qml"
    // }
    
    ConfigCategory {
        name: AppText.tr(plasmoid.configuration.language, "Calendar")
        icon: "view-calendar"
        source: "config/configCalendar.qml"
    }
    ConfigCategory {
        name: AppText.tr(plasmoid.configuration.language, "Popup Settings")
        icon: "window"
        source: "config/configPopup.qml"
    }
    ConfigCategory {
        name: AppText.tr(plasmoid.configuration.language, "Events")
        icon: "view-calendar-list"
        source: "config/configEvents.qml"
    }
    ConfigCategory {
		name: AppText.tr(plasmoid.configuration.language, "Google Account")
        icon: "configure"
		// icon: plasmoid.file("", "icons/Google_Calendar_2020.svg")
		source: "config/ConfigGoogleCalendar.qml"
	}
    // ConfigCategory {
    //     name: AppText.tr(plasmoid.configuration.language, "Another Tab")
    //     icon: "color-management"
    //     source: "configGeneral.qml"
    // }
}