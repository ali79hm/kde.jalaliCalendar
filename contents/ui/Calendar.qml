import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar

// main page of calendar
MouseArea{
	id: popup

	onClicked: focus = true

	// Component.onCompleted : {
    //     console.log("===============================")
    //     console.log("===============================")
    // }
	
	property int padding: 0 // Assigned in main.qml
	property int spacing: 10 * PlasmaCore.Units.devicePixelRatio

	property bool showAgenda:true //TODO : add to config
	property int rowHeight: plasmoid.configuration.rowHeight * PlasmaCore.Units.devicePixelRatio //TODO:add to config

	property int leftColumnWidth: plasmoid.configuration.leftColumnWidth * PlasmaCore.Units.devicePixelRatio // MonthView //TODO:add to config
	property int rightColumnWidth: plasmoid.configuration.rightColumnWidth * PlasmaCore.Units.devicePixelRatio // AgendaView //TODO:add to config


	//FIXME: minimumWidth & minimumHeight must set later
	// Layout.minimumWidth: 800 * PlasmaCore.Units.devicePixelRatio
    // Layout.minimumHeight:  400 * PlasmaCore.Units.devicePixelRatio
    // width: 800 * PlasmaCore.Units.devicePixelRatio
    // height: 400 * PlasmaCore.Units.devicePixelRatio
	Layout.minimumWidth: {
		if(showAgenda){
			return PlasmaCore.Units.gridUnit * 40
		}
		else{
			return PlasmaCore.Units.gridUnit * 20
		}
	}
	Layout.preferredWidth: {
		return (leftColumnWidth + spacing + rightColumnWidth) + padding * 2
	}
	Layout.minimumHeight: PlasmaCore.Units.gridUnit * 20
	Layout.preferredHeight: {
		return rowHeight + padding * 2
	}

	// property alias today: monthView.today
	// property alias selectedDate: monthView.currentDate
	// property alias monthViewDate: monthView.displayedDate

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
