import "../lib/AppText.js" as AppText
import QtQuick 2.2
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0

import "../lib/yearly_events.js" as EventsModule
import "../lib/main.js" as MainJS

Kirigami.FormLayout {
    id: page

    property string cfg_firstCalendarLanguage: plasmoid.configuration.firstCalendarLanguage
    property string cfg_secondCalendarLanguage: plasmoid.configuration.secondCalendarLanguage
    LayoutMirroring.enabled: plasmoid.configuration.language === "fa"
    LayoutMirroring.childrenInherit: true

    property var firstCalendarDropdownValue : plasmoid.configuration.main_calendar
    property var secondCalendarDropdownValue : plasmoid.configuration.second_calendar
    property var is_event_pane_visible : plasmoid.configuration.show_events
    property var compactRepresentationFormat : plasmoid.configuration.compactRepresentationFormat

    property alias cfg_main_calendar: page.firstCalendarDropdownValue
    property alias cfg_second_calendar: page.secondCalendarDropdownValue
    property alias cfg_show_events: showEvents.checked

    property alias cfg_compactRepresentationFormat: _formatField.text

    function calendarChoices(includeNone) {
        var values = [{key:"GE", value: AppText.tr(plasmoid.configuration.language,"Gregorian")},
                      {key:"JA", value: AppText.tr(plasmoid.configuration.language,"Jalali")},
                      {key:"GA", value: AppText.tr(plasmoid.configuration.language,"Hijri")}]
        if (includeNone) values.push({key:"NO", value:AppText.tr(plasmoid.configuration.language,"None")})
        return values
    }
    function calendarIndex(model, key) {
        for (var i=0; i<model.length; i++) if (model[i].key === key) return i
        return 0
    }
    QQC2.ComboBox {
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "main calendar:")
        model: page.calendarChoices(false)
        textRole: "value"
        currentIndex: page.calendarIndex(model, page.cfg_main_calendar)
        onActivated: page.cfg_main_calendar = model[currentIndex].key
    }
    QQC2.ComboBox {
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Second calendar:")
        model: page.calendarChoices(true)
        textRole: "value"
        currentIndex: page.calendarIndex(model, page.cfg_second_calendar)
        onActivated: page.cfg_second_calendar = model[currentIndex].key
    }
    QQC2.ComboBox {
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Calendar 1 language")
        model: MainJS.supported_languages(page.cfg_main_calendar)
        displayText: AppText.languageName(currentText)
        delegate: QQC2.ItemDelegate { required property string modelData; text: AppText.languageName(modelData) }
        currentIndex: model.indexOf(MainJS.resolve_language(page.cfg_main_calendar, page.cfg_firstCalendarLanguage))
        onActivated: page.cfg_firstCalendarLanguage = model[currentIndex]
    }
    QQC2.ComboBox {
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Calendar 2 language")
        enabled: page.cfg_second_calendar !== "NO"
        model: MainJS.supported_languages(page.cfg_second_calendar)
        displayText: AppText.languageName(currentText)
        delegate: QQC2.ItemDelegate { required property string modelData; text: AppText.languageName(modelData) }
        currentIndex: model.indexOf(MainJS.resolve_language(page.cfg_second_calendar, page.cfg_secondCalendarLanguage))
        onActivated: page.cfg_secondCalendarLanguage = model[currentIndex]
    }
    QQC2.CheckBox {
        id: showEvents
        checked: page.is_event_pane_visible
        text: AppText.tr(plasmoid.configuration.language, "Show event pane")
    }

    Kirigami.Separator { Kirigami.FormData.isSection: true }

    // QQC2.Label {
    //     Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Clock & Date Format")
    //     text: AppText.tr(plasmoid.configuration.language, "Pattern used in the calendar (Qt format)")
    //     wrapMode: Text.WordWrap
    // }

    // 2) The format input
    QQC2.TextField {
        id: _formatField
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Clock & Date Format:")
        placeholderText: "'SD SMMMM SYYYY , *HH:mm* , MMMM D ddd'"
        selectByMouse: true
        // clearButtonEnabled: true
        text: page.compactRepresentationFormat

    }

    QQC2.Label {
        id: previewLabel
        text: previewText()
        opacity: 0.85
        wrapMode: Text.NoWrap
        textFormat: Text.RichText
        // smooth: true

        function previewText() {
            var today = MainJS.get_unvirsal_date(page.cfg_main_calendar)
            return MainJS.calendar_formated_text(today, _formatField.text, page.cfg_main_calendar, page.cfg_second_calendar,
                page.cfg_firstCalendarLanguage, page.cfg_secondCalendarLanguage, plasmoid.configuration.language)
        }
    }

    QQC2.Label {
        Kirigami.FormData.isSection: true
        text: AppText.tr(plasmoid.configuration.language, "Common presets:")
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
            text: AppText.tr(plasmoid.configuration.language, "Reset to default")
            Layout.columnSpan: 3
            onClicked: _formatField.text = "SD SMMMM SYYYY , *HH:mm* , MMMM D ddd"
        }
    }

    // QQC2.Label { //TODO:fix it
    //     text: AppText.tr(plasmoid.configuration.language, "Tokens: yyyy=year, MM=month, dd=day, hh/HH=hour(12/24), mm=minute, ss=second, EEE=weekday.")
    //     wrapMode: Text.WordWrap
    //     opacity: 0.7
    // }

}
