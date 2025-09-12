import QtQuick 2.2
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0

import "../lib/yearly_events.js" as EventsModule
import "../lib/main.js" as MainJS

Kirigami.FormLayout {
    id: page

    property var firstCalendarDropdownValue : plasmoid.configuration.main_calendar
    property var secondCalendarDropdownValue : plasmoid.configuration.second_calendar
    property alias cfg_main_calendar: page.firstCalendarDropdownValue
    property alias cfg_second_calendar: page.secondCalendarDropdownValue
    property alias cfg_show_events: showEvents.checked

    property alias cfg_compactRepresentationFormat: _formatField.text

    property var calendar_type_list_old : ["gregorian", "Jalali(shamsi)",'hijri(islamic)']
    
    property var calendar_type_list : ListModel {
        ListElement { key: "GE"; value: 'gegorian' ; enabled1: true }
        ListElement { key: "JA"; value: 'Jalali(shamsi)' ; enabled1: true }
        ListElement { key: "GA"; value: 'hijri(islamic)' ; enabled1: true}
    }
    property var calendar_type_list2 : ListModel{}

    QQC2.ComboBox {
        id: firstCalendarDropdown
        Kirigami.FormData.label: i18n("main calendar:")
        textRole: "value"
        model: calendar_type_list
        property int lastchoosenIndex : 0
        currentIndex : page.getfirstCalendarDropdownValue()
        delegate: QQC2.ItemDelegate {
                width: firstCalendarDropdown.width
                text: value
                font.weight: firstCalendarDropdown.currentIndex === index ? Font.DemiBold : Font.Normal
                highlighted: ListView.isCurrentItem
                enabled: enabled1
        }
        onCurrentIndexChanged: {
            updateSecondDropdownModel()
            cfg_main_calendar = firstCalendarDropdown.model.get(currentIndex).key
        }
    }
    QQC2.ComboBox {
        id: secondCalendarDropdown
        Kirigami.FormData.label: i18n("Second calendar:")
        property int lastchoosenIndex : 1
        
        currentIndex : page.getsecondCalendarDropdownValue()
        model : calendar_type_list2
        textRole: "value"
        delegate: QQC2.ItemDelegate {
                width: secondCalendarDropdown.width
                text: value
                font.weight: secondCalendarDropdown.currentIndex === index ? Font.DemiBold : Font.Normal
                highlighted: ListView.isCurrentItem
                enabled: enabled1
        }
        onCurrentIndexChanged: {
            lastchoosenIndex = currentIndex
            cfg_second_calendar = secondCalendarDropdown.model.get(currentIndex).key
        }
    }
    QQC2.CheckBox {
        id: showEvents
        text: i18n("Show event pane")
    }

    Kirigami.Separator { Kirigami.FormData.isSection: true }

    // QQC2.Label {
    //     Kirigami.FormData.label: i18n("Clock & Date Format")
    //     text: i18n("Pattern used in the calendar (Qt format)")
    //     wrapMode: Text.WordWrap
    // }

    // 2) The format input
    QQC2.TextField {
        id: _formatField
        Kirigami.FormData.label: i18n("Clock & Date Format:")
        placeholderText: "'SD SMMMM SYYYY , *HH:mm* , MMMM D ddd'"
        selectByMouse: true
        // clearButtonEnabled: true
        onTextChanged: previewTimer.restart()
    }

    Loader {
        id: previewHelper
        source: Qt.resolvedUrl("../CompactRepresentation.qml")
        active: true
        visible: false
        asynchronous: true
        onLoaded: previewTimer.restart()
    }


    QQC2.Label {
        id: previewLabel
        text: i18n(previewText())
        opacity: 0.85
        wrapMode: Text.NoWrap
        textFormat: Text.RichText
        // smooth: true

        function previewText() {
            try {
                if (previewHelper.status === Loader.Ready &&
                    previewHelper.item &&
                    typeof previewHelper.item.get_calendar_text === "function") {

                    var today = MainJS.get_unvirsal_date(
                        plasmoid.configuration.main_calendar
                    )
                    return MainJS.calendar_formated_text(today, _formatField.text, plasmoid.configuration.main_calendar, plasmoid.configuration.second_calendar)
                }
            } catch (e) {
                console.log("Preview error:", e)
            }

            return ""
        }
    }

    // Avoid hammering the helper while typing
    Timer {
        id: previewTimer
        interval: 150
        repeat: false
        // onTriggered: previewLabel.text = i18n("Preview: %1", previewLabel.previewText())
        onTriggered: previewLabel.text = i18n(previewLabel.previewText())
    }

    QQC2.Label {
        Kirigami.FormData.isSection: true
        text: i18n("Common presets:")
    }
    RowLayout{
        
    }

    GridLayout {
        id: presetGrid
        columns: 3
        rowSpacing: Kirigami.Units.smallSpacing
        columnSpacing: Kirigami.Units.smallSpacing

        Repeater {
            model: [
                "YYYY-MM-DD",
                "MMMM D ddd",
                "D",
                "HH:mm",
                "*HH:mm*",
                "MMM D",
                "HH:mm:ss"
            ]
            delegate: QQC2.Button {
                text: modelData
                Layout.fillWidth: true
                onClicked: _formatField.text = modelData
            }
        }

        QQC2.Button {
            text: i18n("Reset to default")
            Layout.columnSpan: 3
            onClicked: _formatField.text = "SD SMMMM SYYYY , *HH:mm* , MMMM D ddd"
        }
    }

    // QQC2.Label { //TODO:fix it 
    //     text: i18n("Tokens: yyyy=year, MM=month, dd=day, hh/HH=hour(12/24), mm=minute, ss=second, EEE=weekday.")
    //     wrapMode: Text.WordWrap
    //     opacity: 0.7
    // }

    function calendar_type_list2Init(){
        calendar_type_list2.insert(0, { 'key': "NO", 'value': '--' , 'enabled1': true })
        for (let i = 0; i < calendar_type_list.count; i++){
            calendar_type_list2.insert(i, calendar_type_list.get(i))
        }
        calendar_type_list2.setProperty(firstCalendarDropdown.currentIndex, "enabled1", false)
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
    function updateSecondDropdownModel() {
        var firstCalendarDropdownKey = firstCalendarDropdown.model.get(firstCalendarDropdown.currentIndex)
        if (firstCalendarDropdown.lastchoosenIndex != -1){
            calendar_type_list2.setProperty(firstCalendarDropdown.lastchoosenIndex, "enabled1", true)
        }
        calendar_type_list2.setProperty(firstCalendarDropdown.currentIndex, "enabled1", false)
        secondCalendarDropdown.model = calendar_type_list2
        if (secondCalendarDropdown.lastchoosenIndex == firstCalendarDropdown.currentIndex)
        {
            secondCalendarDropdown.currentIndex = 1 ? firstCalendarDropdown.currentIndex==0 : 0
        }
        firstCalendarDropdown.lastchoosenIndex = firstCalendarDropdown.currentIndex
    }

    function getfirstCalendarDropdownValue() {
        for(var i = 0; i < firstCalendarDropdown.model.count; ++i) {
            if (firstCalendarDropdown.model.get(i).key == plasmoid.configuration.main_calendar ) return i;
        }   
        return 0;
    }

    function getsecondCalendarDropdownValue() {
        for(var i = 0; i < secondCalendarDropdown.model.count; ++i) {
            if (secondCalendarDropdown.model.get(i).key == plasmoid.configuration.second_calendar ) return i;
        }   
        return 0;
    }

    Component.onCompleted : {
        calendar_type_list2Init()
    }
}