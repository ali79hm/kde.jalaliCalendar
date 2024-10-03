import QtQuick 2.2
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.1


import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "lib/main.js" as CalendarBackend

Item{
	id:monthPage
    
	signal resetToToday
    signal headerClicked
	signal activated(int index,var date)

	property var firstCalType: root.firstCalType
	// property var secondCalType : root.secondCalType

	property int rows:4
	property int columns:3
	property var monthNameList : []

	property var currentYear : get_current_year()
	
	function get_current_year(){
		return CalendarBackend.getLocalNumber(String(root.currntDate.getFullYear()),firstCalType)
	}
		
	Item{
		anchors.fill: parent

		//header controls
		RowLayout {
			id:controls
			spacing: PlasmaCore.Units.smallSpacing
			// layoutDirection :Qt.RightToLeft
			anchors {
				top: parent.top
				left: parent.left
				right: parent.right
			}

			//month selector
			PlasmaComponents3.ToolButton { 
				Layout.fillWidth:true
				hoverEnabled: false
				PlasmaComponents3.Label{
					anchors {
						left: parent.left
						leftMargin:20
						margins:0
					}

					// fontSizeMode: Text.HorizontalFit
                    font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, parent.height)
					y: layoutDirection=='R'?-font.pixelSize*0.6:-font.pixelSize*0.2
					horizontalAlignment: Text.AlignLeft
					// text:CalendarBackend.get_title(firstCalType, root.currntDate)
					text:currentYear
					}
				onClicked: {
					if (!stack.busy) {
						monthPage.headerClicked() //FIXME not defined
					}
				}
				
			}

			PlasmaComponents3.ToolButton {
				id: previousButton
				icon.name: "go-previous"
				onClicked: root.layoutDirection=='L'? monthPage.prevYear() : monthPage.nextYear()
				property string tooltip: root.layoutDirection=='L'? i18nd("libplasma5", "Previous Year"):i18nd("libplasma5", "Next Year")
				QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
				QQC2.ToolTip.text: tooltip
				QQC2.ToolTip.visible: hovered
				Accessible.name: tooltip
				//SEE QTBUG-58307
				Layout.preferredHeight: implicitHeight + implicitHeight%2 //TODO:what is this
			}

			PlasmaComponents3.ToolButton {
				icon.name: "go-jump-today"
				onClicked: monthPage.resetToCurrentYear()
				property string tooltip: i18ndc("libplasma5", "Reset calendar to this year", "This year")
				QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
				QQC2.ToolTip.text: tooltip
				QQC2.ToolTip.visible: hovered
				Accessible.name: tooltip
				Accessible.description: i18nd("libplasma5", "Reset calendar this year")
				//SEE QTBUG-58307
				Layout.preferredHeight: implicitHeight + implicitHeight%2 //TODO:what is this
			}

			PlasmaComponents3.ToolButton {
				id: nextButton
				icon.name: "go-next"
				onClicked: root.layoutDirection=='L'? monthPage.nextYear() : monthPage.prevYear()
				property string tooltip: root.layoutDirection=='L'?i18nd("libplasma5", "Next Year"):i18nd("libplasma5", "Previous Year")
				QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
				QQC2.ToolTip.text: tooltip
				QQC2.ToolTip.visible: hovered
				Accessible.name: tooltip
				//SEE QTBUG-58307
				Layout.preferredHeight: implicitHeight + implicitHeight%2 //TODO:what is this
			}
		}
		Grid {
            id: monthGrid
			layoutDirection: root.layoutDirection=='R'? Qt.RightToLeft :Qt.LeftToRight  
            spacing: 1
            columns: monthPage.columns
            readonly property int cellWidth : Math.floor(monthPage.width / monthPage.columns - 6)
            readonly property int cellHeight :  Math.floor(monthPage.height / monthPage.rows - 9)

			anchors {
				horizontalCenter: parent.horizontalCenter
                topMargin: cellHeight/3
				top: parent.top
			}

			// Month cell
            Repeater {
                model: monthPage.monthNameList
                id: daysRepeater
                MonthCell{
					onClicked: monthPage.activated(index,daysRepeater.model)
				}
            }
		}

	}

	// function selectMonth(index,model){
	// 	var selectedMonth = model[index]
	// 	console.log('=========')
	// 	console.log(model[index])
	// 	console.log('=========')
	// 	// calculateSecondCalendar()
	// 	root.currntDate = root.reset_day(CalendarBackend.get_unvirsal_date(firstCalType,[root.currntDate.getFullYear(),selectedMonth]))
	// 	calculate_dates()
	// 	root.nextMonthDate = root.currntDate.addMonth()
	// 	root.prevMonthDate = root.currntDate.subtractMonth()
	// 	monthPage.activated(index,model)
	// }

	function nextYear() {
		root.currntDate.setFullYear(parseInt(root.currntDate.getFullYear())+1)
		refresh_current_year()
	}
	function prevYear() {
		root.currntDate.setFullYear(Math.min(parseInt(root.currntDate.getFullYear())-1),1)
		refresh_current_year()
	}
	function refresh_current_year(){
		currentYear = get_current_year()
	}
	function resetToCurrentYear(){
		monthPage.resetToToday()
		monthPage.refresh_current_year()
	}
	// function resetToToday(){
	// 	// calculateSecondCalendar()
	// 	root.currntDate = root.reset_day(CalendarBackend.get_unvirsal_date(firstCalType))
	// 	calculate_dates()
	// 	root.nextMonthDate = root.currntDate.addMonth()
	// 	root.prevMonthDate = root.currntDate.subtractMonth()
	// }

	function make_month_list(){

		var month_list = []
		for(let i = 1;i<root.monthNames.length+1;i++){
			month_list.push([
								i,root.monthNames[i-1]
							])
        }
		monthNameList = month_list
	}

	onFirstCalTypeChanged: {
		make_month_list()
    }
	// onSecondCalTypeChanged: {
	// 	resetToToday()
    // }

	Component.onCompleted : {
        // console.log("===============================")
		make_month_list()
		// console.log()
        // console.log("===============================")
	}
}