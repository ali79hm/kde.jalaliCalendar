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
	property int rowHeight: plasmoid.configuration.rowHeight * Kirigami.Units.devicePixelRatio //TODO:add to config

	property int leftColumnWidth: plasmoid.configuration.leftColumnWidth * Kirigami.Units.devicePixelRatio // MonthView //TODO:add to config
	property int rightColumnWidth: plasmoid.configuration.rightColumnWidth * Kirigami.Units.devicePixelRatio // AgendaView //TODO:add to config


	//FIXME: minimumWidth & minimumHeight must set later
	// Layout.minimumWidth: 800 * Kirigami.Units.devicePixelRatio
    // Layout.minimumHeight:  400 * Kirigami.Units.devicePixelRatio
    // width: 800 * Kirigami.Units.devicePixelRatio
    // height: 400 * Kirigami.Units.devicePixelRatio
	Layout.minimumWidth: {
		if(showAgenda){
			return Kirigami.Units.gridUnit * 40
		}
		else{
			return Kirigami.Units.gridUnit * 20
		}
	}
	Layout.preferredWidth: {
		if(showAgenda){
			return (leftColumnWidth + spacing + rightColumnWidth) + (padding * 2)
		}
		else{
			return leftColumnWidth + (padding * 2)
		}
	}
	Layout.minimumHeight: Kirigami.Units.gridUnit * 20
	Layout.preferredHeight: {
		return rowHeight + padding * 2
	}


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
