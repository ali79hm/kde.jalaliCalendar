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

	property int padding: 0 // Assigned in main.qml
	property int spacing: 10 * units.devicePixelRatio

	property bool showAgenda:true
	property int topRowHeight: plasmoid.configuration.topRowHeight * units.devicePixelRatio
	property int bottomRowHeight: plasmoid.configuration.bottomRowHeight * units.devicePixelRatio
	// property int singleColumnMonthViewHeight: plasmoid.configuration.monthHeightSingleColumn * units.devicePixelRatio

	// // DigitalClock LeftColumn minWidth: units.gridUnit * 22
	// // DigitalClock RightColumn minWidth: units.gridUnit * 14
	// // 14/(22+14) * 400 = 156
	// // rightColumnWidth=156 looks nice but is very thin for listing events + date + weather.
	property int leftColumnWidth: plasmoid.configuration.leftColumnWidth * units.devicePixelRatio // Meteogram + MonthView
	property int rightColumnWidth: plasmoid.configuration.rightColumnWidth * units.devicePixelRatio // TimerView + AgendaView

	// property bool singleColumn: !showAgenda || !showCalendar
	// property bool singleColumnFullHeight: !plasmoid.configuration.twoColumns && showAgenda && showCalendar
	// property bool twoColumns: plasmoid.configuration.twoColumns && showAgenda && showCalendar

	// Layout.minimumWidth: 800 * PlasmaCore.Units.devicePixelRatio
    // Layout.minimumHeight:  400 * PlasmaCore.Units.devicePixelRatio
    // width: 800 * PlasmaCore.Units.devicePixelRatio
    // height: 400 * PlasmaCore.Units.devicePixelRatio

	Layout.minimumWidth: {
		if(showAgenda){
			return units.gridUnit * 40
		}
		else{
			return units.gridUnit * 20
		}
		
	}
	Layout.preferredWidth: {
		return (leftColumnWidth + spacing + rightColumnWidth) + padding * 2
	}

	Layout.minimumHeight: units.gridUnit * 20
	Layout.preferredHeight: {
		return bottomRowHeight + padding * 2
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
			// visible: showCalendar
			// borderOpacity: plasmoid.configuration.monthShowBorder ? 0.25 : 0
			// showWeekNumbers: plasmoid.configuration.monthShowWeekNumbers
			// highlightCurrentDayWeek: plasmoid.configuration.monthHighlightCurrentDayWeek

			Layout.preferredWidth: 200
			Layout.preferredHeight: 200
			Layout.fillWidth: true
			Layout.fillHeight: true
			// Layout.bottomPadding:20
		}
		AgendaView {
			id: agendaview
			visible: showAgenda
			// borderOpacity: plasmoid.configuration.monthShowBorder ? 0.25 : 0
			// showWeekNumbers: plasmoid.configuration.monthShowWeekNumbers
			// highlightCurrentDayWeek: plasmoid.configuration.monthHighlightCurrentDayWeek

			Layout.preferredWidth: 200
			Layout.preferredHeight: 200
			Layout.fillWidth: true
			Layout.fillHeight: true
		} 

	}
}


// Item{
//     id:calendar

//     property int rows:6
// 	property int columns:7
//     property int cellWidth:30
// 	property int cellHeight:30
//     property var weekDays: ['شنبه', '1شنبه', '2شنبه', '3شنبه', '4شنبه', '5شنبه', 'جمعه']

//     Layout.minimumWidth: 900 * PlasmaCore.Units.devicePixelRatio
//     Layout.minimumHeight:  480 * PlasmaCore.Units.devicePixelRatio
//     width: 1000 * PlasmaCore.Units.devicePixelRatio
//     height: 600 * PlasmaCore.Units.devicePixelRatio

//     // Rectangle
//     // {
//     //     id: background
//     //     anchors.fill: parent
//     //     color: "blue"
//     // }

//     // PlasmaComponents.Label {
//     //     text: "Hello World!2"
//     // }

//     Grid {
// 		id: calendarGrid
// 		// anchors {
// 		// 	right: parent.right
// 		// 	rightMargin: root.borderWidth
// 		// 	bottom: parent.bottom
// 		// 	bottomMargin: root.borderWidth
// 		// }

// 		columns: calendar.columns
// 		rows: calendar.rows

// 		property Item selectedItem
// 		property bool containsEventItems: false // FIXME
// 		property bool containsTodoItems: false // FIXME

//     // --------------- Week days name ---------------
// 		Repeater {
// 			id: days
//             model: 7
// 			PlasmaComponents.Label {
// 				width: calendar.cellWidth
// 				height: calendar.cellHeight
// 				font.pointSize: -1 // Ignore pixelSize warning
// 				font.pixelSize: Math.max(theme.smallestFont.pixelSize, Math.min(calendar.cellHeight / 3, calendar.cellWidth * 5/8))
// 				horizontalAlignment: Text.AlignHCenter
// 				verticalAlignment: Text.AlignVCenter
// 				elide: Text.ElideRight
// 				fontSizeMode: Text.HorizontalFit
// 				readonly property int currentDayIndex: (0+ index) % 7
// 				readonly property bool isCurrentDay: false
// 				readonly property bool showHighlight: false
// 				color: showHighlight ? PlasmaCore.ColorScope.highlightColor : PlasmaCore.ColorScope.textColor
// 				opacity: showHighlight ? 0.75 : 0.4
// 				text: weekDays[currentDayIndex]
// 			}
// 		}
//         // --------------- calendar days ---------------
// 		// Repeater {
// 		// 	id: repeater
// 		// 	model: 30
// 		// 	DayDelegate {
// 		// 		id: delegate
// 		// 		width: daysCalendar.cellWidth
// 		// 		height: daysCalendar.cellHeight
				
// 		// 		onClicked: daysCalendar.activated(index, model, delegate)
// 		// 		onDoubleClicked: daysCalendar.doubleClicked(index, model, delegate)

// 		// 		eventBadgeType: {
// 		// 			switch (daysCalendar.eventBadgeType) {
// 		// 				case 'bottomBar':
// 		// 				case 'dots':
// 		// 					return daysCalendar.eventBadgeType

// 		// 				case 'theme':
// 		// 				default:
// 		// 					if (calendarSvg.hasElement('event')) {
// 		// 						return daysCalendar.eventBadgeType
// 		// 					} else {
// 		// 						return 'bottomBar'
// 		// 					}
// 		// 			}
// 		// 		}

// 		// 		todayStyle: {
// 		// 			switch (daysCalendar.todayStyle) {
// 		// 				case 'bigNumber':
// 		// 					return daysCalendar.todayStyle

// 		// 				case 'theme':
// 		// 				default:
// 		// 					return 'theme'
// 		// 			}
// 		// 		}

// 		// 		Connections {
// 		// 			target: daysCalendar
// 		// 			function onActivateHighlightedItem() {
// 		// 				if (delegate.containsMouse) {
// 		// 					delegate.clicked(null)
// 		// 				}
// 		// 			}
// 		// 		}
// 		// 	}
// 		// }
//     }
// 		// --------------- Week days name end ---------------
//     // PlasmaCalendar.MonthView {
//     //     Layout.minimumWidth: PlasmaCore.Units.gridUnit * 20
//     //     Layout.minimumHeight: PlasmaCore.Units.gridUnit * 20

//     //     today: currentDateTime
//     // }
    
// }