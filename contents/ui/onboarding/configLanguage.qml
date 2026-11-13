import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import "../lib/AppText.js" as AppText
import "../lib/main.js" as Backend
import "../lib/EventManager.js" as EventManager

Kirigami.FormLayout {
    id: page
    property bool live: false
    property bool appOnly: false
    property string cfg_language: plasmoid.configuration.language
    property string cfg_firstCalendarLanguage: plasmoid.configuration.firstCalendarLanguage
    property string cfg_secondCalendarLanguage: plasmoid.configuration.secondCalendarLanguage
    property string cfg_eventLanguage: plasmoid.configuration.eventLanguage
    LayoutMirroring.enabled: cfg_language === "fa"
    LayoutMirroring.childrenInherit: true

    function choices(codes) { return codes.map(code => ({code: code, label: AppText.languageName(code)})) }
    function selected(model, code) { for (var i=0; i<model.length; i++) if (model[i].code === code) return i; return 0 }

    QQC2.ComboBox {
        Kirigami.FormData.label: AppText.tr(page.cfg_language, "App language")
        model: page.choices(["fa", "en"])
        textRole: "label"
        currentIndex: page.selected(model, page.cfg_language)
        onActivated: {
            page.cfg_language = model[currentIndex].code
            if (page.live) plasmoid.configuration.language = page.cfg_language
        }
    }
    QQC2.ComboBox {
        visible: !page.appOnly
        Kirigami.FormData.label: AppText.tr(page.cfg_language, "Calendar 1 language")
        model: page.choices(Backend.supported_languages(plasmoid.configuration.main_calendar))
        textRole: "label"
        currentIndex: page.selected(model, Backend.resolve_language(plasmoid.configuration.main_calendar, page.cfg_firstCalendarLanguage))
        onActivated: {
            page.cfg_firstCalendarLanguage = model[currentIndex].code
            if (page.live) plasmoid.configuration.firstCalendarLanguage = page.cfg_firstCalendarLanguage
        }
    }
    QQC2.ComboBox {
        visible: !page.appOnly
        Kirigami.FormData.label: AppText.tr(page.cfg_language, "Calendar 2 language")
        enabled: plasmoid.configuration.second_calendar !== "NO"
        model: page.choices(Backend.supported_languages(plasmoid.configuration.second_calendar))
        textRole: "label"
        currentIndex: page.selected(model, Backend.resolve_language(plasmoid.configuration.second_calendar, page.cfg_secondCalendarLanguage))
        onActivated: {
            page.cfg_secondCalendarLanguage = model[currentIndex].code
            if (page.live) plasmoid.configuration.secondCalendarLanguage = page.cfg_secondCalendarLanguage
        }
    }
    QQC2.ComboBox {
        visible: !page.appOnly
        Kirigami.FormData.label: AppText.tr(page.cfg_language, "Event language")
        model: page.choices(EventManager.supported_languages(plasmoid.configuration.events_json_files.split(",").filter(code => code !== "")))
        textRole: "label"
        currentIndex: page.selected(model, page.cfg_eventLanguage)
        onActivated: {
            page.cfg_eventLanguage = model[currentIndex].code
            if (page.live) plasmoid.configuration.eventLanguage = page.cfg_eventLanguage
        }
    }
}
