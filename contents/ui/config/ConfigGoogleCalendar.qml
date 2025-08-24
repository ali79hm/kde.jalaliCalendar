import QtQuick 2.2
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Kirigami.FormLayout {
    id: page

    GoogleLoginManager {
		id: googleLoginManager
    }
    QQC2.Button {
        text: i18n("Authorize")
        onClicked: {
            googleLoginManager.fetchAccessToken()
        }
    }
}