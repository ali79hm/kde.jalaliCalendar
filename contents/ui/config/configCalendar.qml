import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0


Kirigami.FormLayout {
    id: page

    property var firstCalendarDropdownValue : plasmoid.configuration.main_calendar
    property var secondCalendarDropdownValue : plasmoid.configuration.second_calendar
    property alias cfg_main_calendar: page.firstCalendarDropdownValue
    property alias cfg_second_calendar: page.secondCalendarDropdownValue
    property alias cfg_show_events: showEvents.checked

    property var calendar_type_list_old : ["gregorian", "Jalali(shamsi)",'ghamari']
    
    property var calendar_type_list : ListModel {
        ListElement { key: "GE"; value: 'gegorian' ; enabled1: true }
        ListElement { key: "JA"; value: 'Jalali(shamsi)' ; enabled1: true }
        ListElement { key: "GA"; value: 'ghamari' ; enabled1: true}
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
    function calendar_type_list2Init(){
        calendar_type_list2.insert(0, { 'key': "NO", 'value': '--' , 'enabled1': true })
        for (let i = 0; i < calendar_type_list.count; i++){
            calendar_type_list2.insert(i, calendar_type_list.get(i))
        }
        calendar_type_list2.setProperty(firstCalendarDropdown.currentIndex, "enabled1", false)
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