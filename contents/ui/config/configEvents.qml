import "../lib/EventManager.js" as EventManager
import "../lib/AppText.js" as AppText
import QtQuick 2.2
import QtQuick.Layouts 1.15
import QtQuick.Dialogs as Dialogs
import org.kde.plasma.plasma5support 2.0 as Plasma5Support
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.plasmoid 2.0

import "../lib/yearly_events.js" as EventsModule

Kirigami.FormLayout {
    id: page
    property string cfg_googleReminderSound: plasmoid.configuration.googleReminderSound || "message-new-instant"
    property alias cfg_googleRemindersEnabled: remindersEnabled.checked
    property string cfg_eventLanguage: plasmoid.configuration.eventLanguage
    LayoutMirroring.enabled: plasmoid.configuration.language === "fa"
    LayoutMirroring.childrenInherit: true
    Kirigami.Heading {
        objectName: 'eventSelectionHeading'
        Kirigami.FormData.isSection: true
        level: 2
        text: AppText.tr(plasmoid.configuration.language, 'Event selection')
    }
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
        objectName: 'holidaySelection'
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

    Kirigami.Heading {
        objectName: 'notificationHeading'
        Kirigami.FormData.isSection: true
        level: 2
        text: AppText.tr(plasmoid.configuration.language, 'Notifications')
    }
    QQC2.CheckBox {
        id: remindersEnabled
        objectName: 'remindersEnabled'
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Google reminders")
        text: AppText.tr(plasmoid.configuration.language, "Enable Google event reminders")
        checked: plasmoid.configuration.googleRemindersEnabled
    }
    // Theme sound names let KDE use the active system sound theme.
    readonly property var systemSounds: [
        {name: 'Instant message (default)', sound: 'message-new-instant'},
        {name: 'Bell', sound: 'bell'},
        {name: 'Alarm', sound: 'alarm-clock-elapsed'},
        {name: 'Message', sound: 'message'},
        {name: 'Warning', sound: 'dialog-warning'},
        {name: 'Task complete', sound: 'complete'},
        {name: 'Incoming call', sound: 'phone-incoming-call'}
    ]
    property string previewCommand: ""
    property string previewError: ""
    function previewSound() {
        if (previewCommand) return
        function quote(value) { return "'" + value.replace(/'/g, "'\\''") + "'" }
        var helper = decodeURIComponent(Qt.resolvedUrl('../lib/preview_sound.py').toString().replace(/^file:\/\//, ''))
        previewError = ''
        previewCommand = 'python3 ' + quote(helper) + ' ' + quote(cfg_googleReminderSound || 'message-new-instant')
        previewPlayer.connectSource(previewCommand)
    }
    Plasma5Support.DataSource {
        id: previewPlayer
        engine: 'executable'
        onNewData: function(source, data) {
            if (data['exit code'] === undefined) return
            previewPlayer.disconnectSource(source)
            page.previewCommand = ''
            if (data['exit code'] !== 0)
                page.previewError = AppText.tr(plasmoid.configuration.language, 'Unable to play sound')
        }
    }
    RowLayout {
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Reminder sound")
        QQC2.ComboBox {
            id: systemSoundPicker
            objectName: 'systemSoundPicker'
            Layout.minimumWidth: 220
            Layout.preferredWidth: 220
            Layout.maximumWidth: 220
            model: page.systemSounds
            textRole: 'name'
            displayText: currentIndex >= 0
                ? AppText.tr(plasmoid.configuration.language, page.systemSounds[currentIndex].name)
                : AppText.tr(plasmoid.configuration.language, 'Custom sound')
            delegate: QQC2.ItemDelegate {
                required property var modelData
                text: AppText.tr(plasmoid.configuration.language, modelData.name)
            }
            currentIndex: {
                var selected = page.cfg_googleReminderSound || 'message-new-instant'
                for (var i = 0; i < page.systemSounds.length; ++i)
                    if (page.systemSounds[i].sound === selected) return i
                return -1
            }
            onActivated: page.cfg_googleReminderSound = page.systemSounds[currentIndex].sound
        }
        QQC2.Button {
            objectName: 'previewSoundButton'
            text: AppText.tr(plasmoid.configuration.language, 'Play')
            icon.name: 'media-playback-start'
            enabled: !page.previewCommand
            onClicked: page.previewSound()
        }
    }
    QQC2.Label {
        visible: page.previewError.length > 0
        text: page.previewError
        color: Kirigami.Theme.negativeTextColor
    }
    RowLayout {
        Kirigami.FormData.label: AppText.tr(plasmoid.configuration.language, "Custom sound")
        QQC2.Label {
            Layout.minimumWidth: 200
            Layout.preferredWidth: 200
            Layout.maximumWidth: 200
            elide: Text.ElideMiddle
            text: !page.cfg_googleReminderSound || page.cfg_googleReminderSound === 'message-new-instant'
                ? AppText.tr(plasmoid.configuration.language, "Instant message (default)")
                : page.cfg_googleReminderSound.split('/').pop()
        }
        QQC2.Button {
            text: AppText.tr(plasmoid.configuration.language, "Choose sound…")
            onClicked: soundPicker.open()
        }
        QQC2.Button {
            text: AppText.tr(plasmoid.configuration.language, "Reset to default")
            onClicked: page.cfg_googleReminderSound = 'message-new-instant'
        }
    }
    Dialogs.FileDialog {
        id: soundPicker
        title: AppText.tr(plasmoid.configuration.language, "Choose reminder sound")
        nameFilters: [AppText.tr(plasmoid.configuration.language, "Audio files (*.ogg *.oga *.wav *.mp3 *.flac)"),
            AppText.tr(plasmoid.configuration.language, "All files (*)")]
        onAccepted: page.cfg_googleReminderSound = decodeURIComponent(selectedFile.toString().replace(/^file:\/\//, ''))
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