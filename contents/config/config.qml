import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Another Tab")
        icon: "color-management"
        source: "configAnotherTab.qml"
    }
}