import QtQuick 2.15
import org.kde.kcmutils as KCM
import "../lib/AppText.js" as AppText

KCM.SimpleKCM {
    title: AppText.tr(plasmoid.configuration.language, "Google Account")

    GoogleCalendarAccount {
        showAccountDetails: true
        width: parent.width
    }
}
