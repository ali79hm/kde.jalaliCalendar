import "../lib/EventManager.js" as EventManager
import "../lib/AppText.js" as AppText
import QtQuick 2.2
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.plasmoid 2.0

import "../lib/yearly_events.js" as EventsModule

Kirigami.FormLayout {
    id: page
    property string cfg_eventLanguage: plasmoid.configuration.eventLanguage
    LayoutMirroring.enabled: plasmoid.configuration.language === "fa"
    LayoutMirroring.childrenInherit: true
    QQC2.ComboBox {
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Event language")
        model: EventManager.supported_languages(page.eventsJsonFiles)
        displayText: AppText.languageName(currentText)
        delegate: QQC2.ItemDelegate { required property string modelData; text: AppText.languageName(modelData) }
        currentIndex: Math.max(0, model.indexOf(page.cfg_eventLanguage))
        onActivated: page.cfg_eventLanguage = model[currentIndex]
    }


    property var holidayJsonFilesStr: plasmoid.configuration.holiday_json_files
    property var holidayJsonFiles: holidayJsonFilesStr.split(",").filter(item => item !== "") // Deserialize as array
    property alias cfg_holiday_json_files: page.holidayJsonFilesStr

    property var eventsJsonFilesStr: plasmoid.configuration.events_json_files
    property var eventsJsonFiles: eventsJsonFilesStr.split(",").filter(item => item !== "") // Deserialize as array
    property alias cfg_events_json_files: page.eventsJsonFilesStr
    
    ListModel {
        id: eventList2
    }

    ListModel {
        id: holidayList2
    }

    QQC2.GroupBox {
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Visible Events:")
        width: parent.width
        QQC2.ScrollView {
            width: parent.width
            height: 150

            Column {
                id: eventCheckboxContainer
                spacing: 8
                width: parent.width

                Repeater {
                    model: eventList2
                    delegate: QQC2.CheckBox {
                        text: EventManager.translate(key, EventsModule[key].name, page.cfg_eventLanguage)
                        checked: eventsJsonFiles.includes(key) // Restore state from string
                        onCheckedChanged: {
                            if (checked) {
                                // Add to the list if not already present
                                if (!eventsJsonFiles.includes(key)) {
                                    eventsJsonFiles.push(key);
                                }
                            } else {
                                // Remove from the list if present
                                const index = eventsJsonFiles.indexOf(key);
                                if (index !== -1) {
                                    eventsJsonFiles.splice(index, 1);
                                }
                            }
                            // Save the updated list as a comma-separated string
                            cfg_events_json_files = eventsJsonFiles.join(",");
                        }
                    }
                }
            }
        }
    }

    QQC2.GroupBox {
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "holidays:")
        width: parent.width
        QQC2.ScrollView {
            width: parent.width
            height: 150

            Column {
                id: holidaysCheckboxContainer
                spacing: 8
                width: parent.width

                Repeater {
                    model: holidayList2
                    delegate: QQC2.CheckBox {
                        text: EventManager.translate(key, EventsModule[key].name, page.cfg_eventLanguage)
                        checked: holidayJsonFiles.includes(key) // Restore state from string
                        onCheckedChanged: {
                            if (checked) {
                                // Add to the list if not already present
                                if (!holidayJsonFiles.includes(key)) {
                                    holidayJsonFiles.push(key);
                                }
                            } else {
                                // Remove from the list if present
                                const index = holidayJsonFiles.indexOf(key);
                                if (index !== -1) {
                                    holidayJsonFiles.splice(index, 1);
                                }
                            }
                            // Save the updated list as a comma-separated string
                            cfg_holiday_json_files = holidayJsonFiles.join(",");
                        }
                    }
                }
            }
        }
    }

    function set_event_list(){
        for (let key in EventsModule.all_events) {
            eventList2.append({
                key: key,
                value: EventsModule.all_events[key],
                enabled1: true
            });
        }
    }

    function set_holiday_list(){
        for (let key in EventsModule.all_holidays) {
            holidayList2.append({
                key: key,
                value: EventsModule.all_holidays[key],
                enabled1: true
            });
        }
    }

    Component.onCompleted : {
        set_event_list()
        set_holiday_list()
    }
}