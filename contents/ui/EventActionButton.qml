import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.0 as Kirigami

T.Button {
    id: control
    property bool rightToLeft: false
    implicitHeight: Math.max(32, contentItem.implicitHeight + topPadding + bottomPadding)

    topPadding: 4
    bottomPadding: 4
    leftPadding: 10
    rightPadding: 10
    hoverEnabled: true
    Accessible.name: text
    background: Rectangle {
        radius: 4
        color: Kirigami.Theme.highlightColor
        opacity: control.down ? 0.35 : control.hovered || control.activeFocus ? 0.22 : 0.1
        border.width: 1
        border.color: Kirigami.Theme.textColor
    }
    contentItem: RowLayout {
        spacing: 10
        layoutDirection: control.rightToLeft ? Qt.RightToLeft : Qt.LeftToRight
        Image {
            visible: String(control.icon.source).length > 0
            source: control.icon.source
            sourceSize.width: 24
            sourceSize.height: 24
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
        }
        Label {
            objectName: "buttonLabel"
            text: control.text
            textFormat: Text.PlainText
            color: Kirigami.Theme.textColor
            font.pixelSize: 12
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }
}
