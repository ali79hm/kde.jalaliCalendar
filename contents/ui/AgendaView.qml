import QtQuick 2.2
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.1


import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PinchArea {
	id: agendaview
    property string r_color: "red"
	Rectangle
    {
        id: background
        anchors.fill: parent
        color: r_color
    }
}