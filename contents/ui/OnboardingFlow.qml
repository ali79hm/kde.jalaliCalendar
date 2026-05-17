import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Page {
    id: onboardingPage

    signal finished()

    property var currentConfigLoader: null
    property var eventsConfigLoaderRef: null
    property var languageDropdownRef: null

    title: i18n("Jalali Calendar Setup")

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
        RowLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            QQC2.Button {
                text: i18n("Back")
                enabled: setupStack.depth > 1
                onClicked: onboardingPage.popPage()
            }

            Item {
                Layout.fillWidth: true
            }

            QQC2.Label {
                text: i18n("Step %1 of 5", setupStack.depth)
                opacity: 0.7
            }

            QQC2.Button {
                text: setupStack.depth === 5 ? i18n("Start using app") : i18n("Next")
                icon.name: setupStack.depth === 5 ? "dialog-ok-apply" : "go-next"

                onClicked: {
                    if (setupStack.depth === 1) {
                        if (onboardingPage.languageDropdownRef) {
                            plasmoid.configuration.language =
                                onboardingPage.languageDropdownRef.model.get(
                                    onboardingPage.languageDropdownRef.currentIndex
                                ).key
                        }

                        onboardingPage.pushPage(calendarPageComponent)

                    } else if (setupStack.depth === 2) {
                        if (onboardingPage.currentConfigLoader
                                && onboardingPage.currentConfigLoader.item) {
                            plasmoid.configuration.main_calendar =
                                onboardingPage.currentConfigLoader.item.cfg_main_calendar

                            plasmoid.configuration.second_calendar =
                                onboardingPage.currentConfigLoader.item.cfg_second_calendar

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
                    text: i18n("Welcome to Jalali Calendar")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: i18n("Let’s finish the basic setup before you start using the widget.")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                QQC2.ComboBox {
                    id: languageDropdown
                    Layout.fillWidth: true
                    textRole: "label"

                    model: ListModel {
                        ListElement { key: "en"; label: "English" }
                        // ListElement { key: "fa"; label: "فارسی" }
                    }

                    currentIndex: {
                        var lang = plasmoid.configuration.language || "en"
                        for (var i = 0; i < model.count; ++i) {
                            if (model.get(i).key === lang) {
                                return i
                            }
                        }
                        return 0
                    }
                    Component.onCompleted: {
                        onboardingPage.languageDropdownRef = languageDropdown
                    }
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
                    text: i18n("Calendar Settings")
                    level: 1
                    Layout.fillWidth: true
                }

                QQC2.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Loader {
                        id: calendarConfigLoader
                        width: parent.width
                        source: Qt.resolvedUrl("config/configCalendar.qml")

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
                    text: i18n("Events Settings")
                    level: 1
                    Layout.fillWidth: true
                }

                QQC2.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Loader {
                        id: eventsConfigLoader
                        width: parent.width
                        source: Qt.resolvedUrl("config/configEvents.qml")

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
                    text: i18n("Google Calendar")
                    level: 1
                    Layout.fillWidth: true
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: i18n("Configure Google Calendar now, or continue and do it later from settings.")
                    wrapMode: Text.WordWrap
                }

                QQC2.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Loader {
                        width: parent.width
                        source: Qt.resolvedUrl("config/ConfigGoogleCalendar.qml")
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
                    text: i18n("Setup complete")
                    horizontalAlignment: Text.AlignHCenter
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: i18n("Jalali Calendar is ready to use.")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}