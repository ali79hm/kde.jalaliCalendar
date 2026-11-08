import QtQuick 2.2
import QtQuick.Layouts 1.0

Item {
    property int configuredWidth: 720
    property int configuredHeight: 400
    property bool showAgenda: true
    property bool onboardingCompleted: true

    implicitWidth: onboardingCompleted
        ? Math.max(1, Math.floor(configuredWidth / (showAgenda ? 1 : 2)))
        : 620
    implicitHeight: onboardingCompleted ? Math.max(1, configuredHeight) : 400

    // Plasma reads the full representation's limits. Keep the configured
    // content size authoritative, including after restoring a popup size.
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight
    Layout.maximumHeight: implicitHeight
}
