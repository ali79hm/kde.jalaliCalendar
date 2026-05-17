import QtQuick 2.2
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0

Kirigami.FormLayout {
    id: page

    property int defaultPopupWidth: 720
    property int defaultPopupHeight: 400
    property int popupWidthValue: Math.min(Math.max(plasmoid.configuration.popupWidth, 600), 900)
    property int popupHeightValue: Math.min(Math.max(plasmoid.configuration.popupHeight, 250), 500)

    property alias cfg_popupWidth: page.popupWidthValue
    property alias cfg_popupHeight: page.popupHeightValue

    onPopupWidthValueChanged: {
        if (!popupWidthField.activeFocus) {
            popupWidthField.text = popupWidthValue.toString()
        }
    }

    onPopupHeightValueChanged: {
        if (!popupHeightField.activeFocus) {
            popupHeightField.text = popupHeightValue.toString()
        }
    }

    QQC2.Label {
        Kirigami.FormData.label: i18n("Popup width:")
        text: i18n("Popup width:")
    }

    RowLayout {
        Layout.fillWidth: true

        QQC2.TextField {
            id: popupWidthField
            Layout.preferredWidth: 90
            text: page.popupWidthValue.toString()
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 600; top: 900 }
            onEditingFinished: {
                var parsedValue = parseInt(text)
                if (!isNaN(parsedValue)) {
                    page.popupWidthValue = Math.min(Math.max(parsedValue, 600), 900)
                }
            }
        }

        QQC2.Slider {
            id: popupWidthSlider
            Layout.fillWidth: true
            from: 600
            to: 900
            stepSize: 1
            value: page.popupWidthValue
            onValueChanged: {
                if (page.popupWidthValue !== value) {
                    page.popupWidthValue = value
                }
            }
        }
    }

    QQC2.Label {
        Layout.fillWidth: true
        text: i18n("Allowed range: 600 to 900")
        opacity: 0.7
        wrapMode: Text.WordWrap
    }

    QQC2.Label {
        text: i18n("Popup height:")
    }

    RowLayout {
        Layout.fillWidth: true

        QQC2.TextField {
            id: popupHeightField
            Layout.preferredWidth: 90
            text: page.popupHeightValue.toString()
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 250; top: 500 }
            onEditingFinished: {
                var parsedValue = parseInt(text)
                if (!isNaN(parsedValue)) {
                    page.popupHeightValue = Math.min(Math.max(parsedValue, 250), 500)
                }
            }
        }

        QQC2.Slider {
            id: popupHeightSlider
            Layout.fillWidth: true
            from: 250
            to: 500
            stepSize: 1
            value: page.popupHeightValue
            onValueChanged: {
                if (page.popupHeightValue !== value) {
                    page.popupHeightValue = value
                }
            }
        }
    }

    QQC2.Label {
        Layout.fillWidth: true
        text: i18n("Allowed range: 250 to 500")
        opacity: 0.7
        wrapMode: Text.WordWrap
    }

    QQC2.Button {
        Layout.fillWidth: true
        text: i18n("Reset to default")
        onClicked: {
            page.popupWidthValue = defaultPopupWidth
            page.popupHeightValue = defaultPopupHeight
        }
    }
}
