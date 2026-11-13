import "lib/AppText.js" as AppText
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Page {
    id: onboardingPage
    LayoutMirroring.enabled: plasmoid.configuration.language === "fa"
    LayoutMirroring.childrenInherit: true

    signal finished()

    property var currentConfigLoader: null
    property var eventsConfigLoaderRef: null

    title: AppText.tr(plasmoid.configuration.language, "Jalali Calendar Setup")

    QQC2.StackView {
        id: setupStack
        anchors.fill: parent
        initialItem: welcomePageComponent
    }

    function pushPage(component) {
        setupStack.push(component)
    }

    function popPage() {
        if (setupStack.depth > 1) {
            setupStack.pop()
        }
    }

    footer: QQC2.ToolBar {
        // Navigation stays in the same physical positions in both languages.
        LayoutMirroring.enabled: false
        LayoutMirroring.childrenInherit: true
        RowLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            QQC2.Button {
                text: AppText.tr(plasmoid.configuration.language, "Back")
                enabled: setupStack.depth > 1
                onClicked: onboardingPage.popPage()
            }

            Item {
                Layout.fillWidth: true
            }

            QQC2.Label {
                text: AppText.tr(plasmoid.configuration.language, "Step %1 of 5", setupStack.depth)
                opacity: 0.7
            }

            QQC2.Button {
                text: setupStack.depth === 5 ? AppText.tr(plasmoid.configuration.language, "Start using app") : AppText.tr(plasmoid.configuration.language, "Next")
                icon.name: setupStack.depth === 5 ? "dialog-ok-apply" : "go-next"

                onClicked: {
                    if (setupStack.depth === 1) {
                        onboardingPage.pushPage(calendarPageComponent)

                    } else if (setupStack.depth === 2) {
                        if (onboardingPage.currentConfigLoader
                                && onboardingPage.currentConfigLoader.item) {
                            plasmoid.configuration.main_calendar =
                                onboardingPage.currentConfigLoader.item.cfg_main_calendar

                            plasmoid.configuration.second_calendar =
                                onboardingPage.currentConfigLoader.item.cfg_second_calendar

                            plasmoid.configuration.firstCalendarLanguage = onboardingPage.currentConfigLoader.item.cfg_firstCalendarLanguage
                            plasmoid.configuration.secondCalendarLanguage = onboardingPage.currentConfigLoader.item.cfg_secondCalendarLanguage

                            plasmoid.configuration.show_events =
                                onboardingPage.currentConfigLoader.item.cfg_show_events

                            plasmoid.configuration.compactRepresentationFormat =
                                onboardingPage.currentConfigLoader.item.cfg_compactRepresentationFormat
                        }

                        onboardingPage.pushPage(eventsPageComponent)

                    } else if (setupStack.depth === 3) {
                        if (onboardingPage.eventsConfigLoaderRef
                                && onboardingPage.eventsConfigLoaderRef.item) {
                            plasmoid.configuration.events_json_files =
                                onboardingPage.eventsConfigLoaderRef.item.cfg_events_json_files

                            plasmoid.configuration.eventLanguage = onboardingPage.eventsConfigLoaderRef.item.cfg_eventLanguage

                            plasmoid.configuration.holiday_json_files =
                                onboardingPage.eventsConfigLoaderRef.item.cfg_holiday_json_files
                        }

                        onboardingPage.pushPage(googlePageComponent)

                    } else if (setupStack.depth === 4) {
                        onboardingPage.pushPage(completePageComponent)

                    } else {
                        onboardingPage.finished()
                    }
                }
            }
        }
    }

    Component {
        id: welcomePageComponent

        Kirigami.Page {
            ColumnLayout {
                anchors.centerIn: parent
                width: Math.min(parent.width - Kirigami.Units.gridUnit * 2, Kirigami.Units.gridUnit * 24)
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    text: AppText.tr(plasmoid.configuration.language, "Welcome to Jalali Calendar")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: AppText.tr(plasmoid.configuration.language, "Let’s finish the basic setup before you start using the widget.")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Loader {
                    Layout.fillWidth: true
                    source: "onboarding/configLanguage.qml"
                    onLoaded: { item.live = true; item.appOnly = true }
                }
            }
        }
    }

    Component {
        id: calendarPageComponent

        Kirigami.Page {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    text: AppText.tr(plasmoid.configuration.language, "Calendar Settings")
                    level: 1
                    Layout.fillWidth: true
                }

                QQC2.ScrollView {
                    id: calendarSettingsScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    LayoutMirroring.enabled: false
                    LayoutMirroring.childrenInherit: true
                    contentWidth: availableWidth

                    Loader {
                        id: calendarConfigLoader
                        // Size the form to its contents and align the whole form,
                        // independently of its own right-to-left field layout.
                        width: Math.min(calendarSettingsScroll.availableWidth, Math.max(implicitWidth, Kirigami.Units.gridUnit * 24))
                        x: plasmoid.configuration.language === "fa" ? calendarSettingsScroll.availableWidth - width : 0
                        source: Qt.resolvedUrl("onboarding/configCalendar.qml")

                        Component.onCompleted: {
                            onboardingPage.currentConfigLoader = calendarConfigLoader
                        }
                    }
                }
            }
        }
    }

    Component {
        id: eventsPageComponent

        Kirigami.Page {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    text: AppText.tr(plasmoid.configuration.language, "Events Settings")
                    level: 1
                    Layout.fillWidth: true
                }

                QQC2.ScrollView {
                    id: eventsSettingsScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    LayoutMirroring.enabled: false
                    LayoutMirroring.childrenInherit: true
                    contentWidth: availableWidth

                    Loader {
                        id: eventsConfigLoader
                        // Size the form to its contents and align the whole form,
                        // independently of its own right-to-left field layout.
                        width: Math.min(eventsSettingsScroll.availableWidth, Math.max(implicitWidth, Kirigami.Units.gridUnit * 24))
                        x: plasmoid.configuration.language === "fa" ? eventsSettingsScroll.availableWidth - width : 0
                        source: Qt.resolvedUrl("onboarding/configEvents.qml")

                        Component.onCompleted: {
                            onboardingPage.eventsConfigLoaderRef = eventsConfigLoader
                        }
                    }
                }
            }
        }
    }

    Component {
        id: googlePageComponent

        Kirigami.Page {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    text: AppText.tr(plasmoid.configuration.language, "Google Calendar")
                    level: 1
                    Layout.fillWidth: true
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: AppText.tr(plasmoid.configuration.language, "Configure Google Calendar now, or continue and do it later from settings.")
                    wrapMode: Text.WordWrap
                }

                QQC2.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Loader {
                        width: parent.width
                        source: Qt.resolvedUrl("onboarding/ConfigGoogleCalendar.qml")
                    }
                }
            }
        }
    }

    Component {
        id: completePageComponent

        Kirigami.Page {
            ColumnLayout {
                anchors.centerIn: parent
                width: Math.min(parent.width - Kirigami.Units.gridUnit * 2, Kirigami.Units.gridUnit * 24)
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    text: AppText.tr(plasmoid.configuration.language, "Setup complete")
                    horizontalAlignment: Text.AlignHCenter
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: AppText.tr(plasmoid.configuration.language, "Jalali Calendar is ready to use.")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}