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
	id:daysPage
    
    signal headerClicked
	property var firstCalType: root.firstCalType
	property var secondCalType : root.secondCalType
	property int rows:7
	property int columns:7
	property var prevMonthDays : []
	property var currntMonthDays : []
	property var nextMonthDays : []

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
					text:CalendarBackend.get_title(firstCalType, root.currntDate)
					}
				onClicked: {
					if (!stack.busy) {
						daysPage.headerClicked() //FIXME not defined
					}
				}
				
			}

			PlasmaComponents3.ToolButton {
				id: previousButton
				icon.name: "go-previous"
				onClicked: root.layoutDirection=='L'? daysPage.prevMonth() : daysPage.nextMonth()
				property string tooltip: root.layoutDirection=='L'? i18nd("libplasma5", "Previous Month"):i18nd("libplasma5", "Next Month")
				QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
				QQC2.ToolTip.text: tooltip
				QQC2.ToolTip.visible: hovered
				Accessible.name: tooltip
				//SEE QTBUG-58307
				Layout.preferredHeight: implicitHeight + implicitHeight%2 //TODO:what is this
			}

			PlasmaComponents3.ToolButton {
				icon.name: "go-jump-today"
				onClicked: daysPage.resetToToday()
				property string tooltip: i18ndc("libplasma5", "Reset calendar to today", "Today")
				QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
				QQC2.ToolTip.text: tooltip
				QQC2.ToolTip.visible: hovered
				Accessible.name: tooltip
				Accessible.description: i18nd("libplasma5", "Reset calendar to today")
				//SEE QTBUG-58307
				Layout.preferredHeight: implicitHeight + implicitHeight%2 //TODO:what is this
			}

			PlasmaComponents3.ToolButton {
				id: nextButton
				icon.name: "go-next"
				onClicked: root.layoutDirection=='L'? daysPage.nextMonth() : daysPage.prevMonth()
				property string tooltip: root.layoutDirection=='L'?i18nd("libplasma5", "Next Month"):i18nd("libplasma5", "Previous Month")
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
            columns: daysPage.columns
            readonly property int cellWidth : Math.floor(daysPage.width / daysPage.columns - 2)
            readonly property int cellHeight :  Math.floor(daysPage.height / daysPage.rows - 6)

			anchors {
				horizontalCenter: parent.horizontalCenter
                bottomMargin: cellHeight/3
				bottom: parent.bottom
			}

            // day names
            Repeater {
				model : root.weekdaysNames
                PlasmaComponents3.Label {
                    width: monthGrid.cellWidth
                    height: monthGrid.cellHeight*2/3
                    text: modelData
                    font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, monthGrid.cellHeight / 3)
                    opacity: 0.4
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    fontSizeMode: Text.HorizontalFit
                }

            }

			// before Days offset
            Repeater {
                model: prevMonthDays
                id: daysBeforeRepeater
                DayCell{
					holidays:CalendarBackend.get_month_holidays(firstCalType,root.prevMonthDate)
                    weekends : CalendarBackend.get_month_weekends(firstCalType,root.prevMonthDate)
					isCurrentMonth:false
					isNextMonth:false
					showSecondCal:root.showSecondCal
                }
            }


			// Days cell
            Repeater {
                model: currntMonthDays
                id: daysRepeater
                DayCell{
					holidays:CalendarBackend.get_month_holidays(firstCalType,root.currntDate)
					weekends : CalendarBackend.get_month_weekends(firstCalType,root.currntDate)
					isCurrentMonth:true
					isNextMonth:false
					showSecondCal:root.showSecondCal
				}
            }

            // after Days offset
			Repeater {
                model: nextMonthDays
                id: daysAfterRepeater
                DayCell{
					holidays:CalendarBackend.get_month_holidays(firstCalType,root.nextMonthDate)
					weekends : CalendarBackend.get_month_weekends(firstCalType,root.nextMonthDate)
					isCurrentMonth:false
					isNextMonth:true
					showSecondCal:root.showSecondCal
				}
            }
        
		}

	}
	function nextMonth() {
		root.currntDate = root.nextMonthDate
		root.nextMonthDate = root.currntDate.addMonth()
		root.prevMonthDate = root.currntDate.subtractMonth()
		calculate_dates()
	}
	function prevMonth() {
		root.currntDate = root.prevMonthDate
		root.nextMonthDate = root.currntDate.addMonth()
		root.prevMonthDate = root.currntDate.subtractMonth()
		calculate_dates()
	}
	function resetToToday(){
		// calculateSecondCalendar()
		root.currntDate = root.reset_day(CalendarBackend.get_unvirsal_date(firstCalType))
		root.nextMonthDate = root.currntDate.addMonth()
		root.prevMonthDate = root.currntDate.subtractMonth()
		calculate_dates()
	}
	function goToMonth(index){
		var tmp_date = root.currntDate
		tmp_date.setMonth(index)
		root.currntDate = tmp_date
		root.nextMonthDate = root.currntDate.addMonth()
		root.prevMonthDate = root.currntDate.subtractMonth()
		calculate_dates()
	}

	onFirstCalTypeChanged: {
		resetToToday()
    }
	onSecondCalTypeChanged: {
		resetToToday()
    }
	
	function calculate_dates(){
		var countDaysBefore = CalendarBackend.daysBedoreCurrentMonth(root.startOfWeek,root.currntDate.getDay())
        var countDays = root.currntDate.daysInMonth()
		// console.log('@@',root.currntDate.daysInMonth(),root.currntDate.format('YYYY,MMMM,DD'))
		var countDaysAfter = 42 - countDays - countDaysBefore
		var currntDate1 = CalendarBackend.get_unvirsal_date(firstCalType,[root.currntDate.getFullYear(),root.currntDate.getMonth(),root.currntDate.getDate()])
		var tmp = CalendarBackend.convert_calendars_light(root.currntDate,firstCalType,secondCalType)
		var currntDate2 = undefined
		if (root.showSecondCal)
		{
			var currntDate2 = CalendarBackend.get_unvirsal_date(secondCalType,tmp)
			currntDate2 = currntDate2.subtractDate(countDaysBefore)
		}
		currntDate1 = currntDate1.subtractDate(countDaysBefore)

		// console.log('=======================')
		// console.log('firstCalType',firstCalType,'secondCalType',secondCalType)
		// console.log('countDaysBefore',countDaysBefore,'countDays',countDays,'countDaysAfter',countDaysAfter)
		// console.log('currntDate',root.currntDate.format('YYYY,MMMM,DD'))
		// console.log('currntDate1',currntDate1.format('YYYY,MMMM,DD'))
		// console.log(root.startOfWeek,root.currntDate.getDay(),countDaysBefore)
		// console.log(CalendarBackend.get_unvirsal_date(secondCalType,tmp).getDay())
		// console.log('=======================')

		var prevMonthTmp = []
		var currntMonthTmp = []
		var nextMonthTmp = []
		var prevMonthLastDay = root.currntDate.subtractMonth().daysInMonth()
		for(let i = prevMonthLastDay-countDaysBefore;i<prevMonthLastDay;i++){
			prevMonthTmp.push([
								[currntDate1.getDate(),currntDate1.format('MMMM'),currntDate1.getFullYear()],
								root.showSecondCal?[currntDate2.getDate(),currntDate2.format('MMMM'),currntDate2.getFullYear()]:[0,0,0]
							])
			currntDate1 = currntDate1.addDate(1)
			if (root.showSecondCal){currntDate2 = currntDate2.addDate(1)}

        }

		for (let i=0;i<countDays;i++){
			currntMonthTmp.push([
									[currntDate1.getDate(),currntDate1.format('MMMM'),currntDate1.getFullYear()],
									root.showSecondCal?[currntDate2.getDate(),currntDate2.format('MMMM'),currntDate2.getFullYear()]:[0,0,0]
								])
			currntDate1 = currntDate1.addDate(1)
			if (root.showSecondCal){currntDate2 = currntDate2.addDate(1)}
		}

		// console.log('=======================')

		for (let i=0;i<(countDaysAfter);i++){
			nextMonthTmp.push([
								[currntDate1.getDate(),currntDate1.format('MMMM'),currntDate1.getFullYear()],
								showSecondCal?[currntDate2.getDate(),currntDate2.format('MMMM'),currntDate2.getFullYear()]:[0,0,0]
							])
			currntDate1 = currntDate1.addDate(1)
			if (showSecondCal){currntDate2 = currntDate2.addDate(1)}
		}

		prevMonthDays = prevMonthTmp
		currntMonthDays = currntMonthTmp
		nextMonthDays =  nextMonthTmp
		// console.log('=======================')
		// console.log('prevMonthDays',prevMonthDays)
		// console.log('currntMonthDays',currntMonthDays)
		// console.log('nextMonthDays',nextMonthDays)
		// console.log('=======================')

	}
	Component.onCompleted : {
        // console.log("===============================")
		calculate_dates()
        // console.log("===============================")
	}
}