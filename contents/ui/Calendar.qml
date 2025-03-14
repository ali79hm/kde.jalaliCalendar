import QtQuick 2.2
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

// main page of calendar
MouseArea{
	id: popup

	onClicked: focus = true

	
	property int padding: 0 // Assigned in main.qml
	property int spacing: 10 * Screen.devicePixelRatio

	property var showAgenda:true
	property int rowHeight: plasmoid.configuration.rowHeight * Screen.devicePixelRatio //TODO:add to config

	property int leftColumnWidth: plasmoid.configuration.leftColumnWidth * Screen.devicePixelRatio // MonthView //TODO:add to config
	property int rightColumnWidth: plasmoid.configuration.rightColumnWidth * Screen.devicePixelRatio // AgendaView //TODO:add to config

	property int withAgendaWidth : leftColumnWidth + spacing + rightColumnWidth + padding * 2
	property int noAgendaWidth : leftColumnWidth + padding * 2
	//FIXME: minimumWidth & minimumHeight must set later
	// Layout.minimumWidth: 800 * Plasmoid.units.devicePixelRatio
    // Layout.minimumHeight:  400 * Plasmoid.units.devicePixelRatio
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

	// Layout.maximumWidth: {
	// 	if(showAgenda){
	// 		return withAgendaWidth;
	// 	}
	// 	else{
	// 		return noAgendaWidth;
	// 	}
		
	// }

	// Layout.maximumHeight: {
	// 	return rowHeight + padding * 2
	// }
	// Layout.maximumWidth: {
	// 	if(showAgenda){
	// 		return 800
	// 	}
	// 	else{
	// 		return 400
	// 	}
	// }
	// Layout.maximumHeight:400
	// Layout.maximumWidth:400


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
	// Component.onCompleted : {
    //     console.log("===============================")
    //     console.log(spacing)
    //     console.log("===============================")
    // }
}
