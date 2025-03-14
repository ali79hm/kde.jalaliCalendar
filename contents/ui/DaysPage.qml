import QtQuick 2.2
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.1


import org.kde.plasma.core as PlasmaCore

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

	property var prevMonthHolidays : []
	property var currntMonthHolidays : []
	property var nextMonthHolidays : []

	Item{
		anchors.fill: parent

		//header controls
		RowLayout {
			id:controls
			spacing: Kirigami.Units.smallSpacing
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
					holidays:prevMonthHolidays
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
					holidays:currntMonthHolidays
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
					holidays:nextMonthHolidays
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
		root.selectedDate = root.today

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

		var monthIndexes = []
		var yearIndexes = []
		var prevMonthTmp = []
		var currntMonthTmp = []
		var nextMonthTmp = []
		var prevMonthLastDay = root.currntDate.subtractMonth().daysInMonth()
		monthIndexes.push(currntDate1.getMonth())
		yearIndexes.push(currntDate1.getFullYear())
		for(let i = prevMonthLastDay-countDaysBefore;i<prevMonthLastDay;i++){
			prevMonthTmp.push([
								[currntDate1.getDate(),currntDate1.format('MMMM'),currntDate1.getFullYear()],
								root.showSecondCal?[currntDate2.getDate(),currntDate2.format('MMMM'),currntDate2.getFullYear()]:[0,0,0]
							])
			currntDate1 = currntDate1.addDate(1)
			if (root.showSecondCal){currntDate2 = currntDate2.addDate(1)}

        }
				
		monthIndexes.push(currntDate1.getMonth())
		yearIndexes.push(currntDate1.getFullYear())
		for (let i=0;i<countDays;i++){
			currntMonthTmp.push([
									[currntDate1.getDate(),currntDate1.format('MMMM'),currntDate1.getFullYear()],
									root.showSecondCal?[currntDate2.getDate(),currntDate2.format('MMMM'),currntDate2.getFullYear()]:[0,0,0]
								])
			currntDate1 = currntDate1.addDate(1)
			if (root.showSecondCal){currntDate2 = currntDate2.addDate(1)}
		}

		monthIndexes.push(currntDate1.getMonth())
		yearIndexes.push(currntDate1.getFullYear())
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
		
		var prevMonthHolidaysTmp = []
		var currntMonthHolidaysTmp = []
		var nextMonthHolidaysTmp = []
		root.allHolidaysFiles.forEach(eventSource => {

			var prev_year = yearIndexes[0]
			var prev_month = monthIndexes[0]
			var prev_start_day = prevMonthDays[0][0][0]
			var dateObj = CalendarBackend.get_unvirsal_date(
				root.firstCalType,
				[prev_year,prev_month,prev_start_day]
			)

			if (CalendarBackend.calendar_type[eventSource.type] != root.firstCalType){
				var tmp = CalendarBackend.convert_calendars_light(
					dateObj,
					root.firstCalType,
					CalendarBackend.calendar_type[eventSource.type]
				)
				prev_year = tmp[0]
				prev_month = tmp[1]
				prev_start_day = tmp[2]
				var dateObj = CalendarBackend.get_unvirsal_date(
					CalendarBackend.calendar_type[eventSource.type],
					[prev_year,prev_month,prev_start_day]
				)
			}

			var prev_sidx = prevMonthDays[0][0][0]
			var prev_eidx = prevMonthDays[prevMonthDays.length-1][0][0]

			for (let event_date = prev_sidx; event_date <= prev_eidx; event_date++) {
				let this_month = dateObj.getMonth(),this_day = dateObj.getDate()
				var tmpevents = eventSource.events[this_month][this_day] || []
				if (tmpevents.length > 0){
					prevMonthHolidaysTmp.push(event_date)
				}
				dateObj = dateObj.addDate(1)
			}

			
			var current_sidx = currntMonthDays[0][0][0]
			var current_eidx = currntMonthDays[currntMonthDays.length-1][0][0]
			for (let event_date = current_sidx; event_date <= current_eidx; event_date++) {
				let this_month = dateObj.getMonth(),this_day = dateObj.getDate()
				var tmpevents = eventSource.events[this_month][this_day] || []
				if (tmpevents.length > 0){
					currntMonthHolidaysTmp.push(event_date)
				}
				dateObj = dateObj.addDate(1)
			}

			var next_sidx = nextMonthDays[0][0][0]
			var next_eidx = nextMonthDays[nextMonthDays.length-1][0][0]
			for (let event_date = next_sidx; event_date <= next_eidx; event_date++) {
				let this_month = dateObj.getMonth(),this_day = dateObj.getDate()
				var tmpevents = eventSource.events[this_month][this_day] || []
				if (tmpevents.length > 0){
					nextMonthHolidaysTmp.push(event_date)
				}
				dateObj = dateObj.addDate(1)
			}
		});

		prevMonthHolidays = prevMonthHolidaysTmp
		currntMonthHolidays = currntMonthHolidaysTmp
		nextMonthHolidays = nextMonthHolidaysTmp
	}
	Component.onCompleted : {
        // console.log("===============================")
		calculate_dates()
        // console.log("===============================")
	}
}