import QtQuick 2.2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.0 as Kirigami

// main page of calendar
MouseArea{
	id: popup

	onClicked: focus = true

	
	property int padding: 0 // Assigned in main.qml
	property int spacing: 10 * Kirigami.Units.devicePixelRatio

	property var showAgenda:true


	GridLayout {
		id: widgetGrid
		anchors.fill: parent
		anchors.margins: popup.padding
		columnSpacing: popup.spacing
		rowSpacing: popup.spacing
		
		MonthView {
			id: monthView
			// showWeekNumbers: plasmoid.configuration.monthShowWeekNumbers //TODO : must add later
			Layout.preferredWidth: 200 //TODO : must add to config
			Layout.preferredHeight: 200 //TODO : must add to config
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
		AgendaView {
			id: agendaview
			visible: showAgenda
			Layout.preferredWidth: 200 //TODO : must add to config
			Layout.preferredHeight: 200 //TODO : must add to config
			Layout.fillWidth: true
			Layout.fillHeight: true
		} 

	}
}
