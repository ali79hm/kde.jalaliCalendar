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
	id:monthView
	property int rows:7
	property int columns:7

	// property var prevMonth2 : []
	// property var currntMonth2 : []
	// property var nextMonth2 : []
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
					text:CalendarBackend.get_title(root.firstCalType, root.currntDate)
					}
				onClicked: {
					if (!stack.busy) {
						monthView.headerClicked() //FIXME not defined
					}
				}
				
			}

			PlasmaComponents3.ToolButton {
				id: previousButton
				icon.name: "go-previous"
				onClicked: root.layoutDirection=='L'? monthView.prevMonth() : monthView.nextMonth()
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
				onClicked: monthView.resetToToday()
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
				onClicked: root.layoutDirection=='L'? monthView.nextMonth() : monthView.prevMonth()
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
            columns: monthView.columns
            readonly property int cellWidth : Math.floor(monthView.width / monthView.columns - 2)
            readonly property int cellHeight :  Math.floor(monthView.height / monthView.rows - 6)

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
					holidays:CalendarBackend.get_month_holidays(root.firstCalType,root.prevMonthDate)
                    weekends : CalendarBackend.get_month_weekends(root.firstCalType,root.prevMonthDate)
					isCurrentMonth:false
					isNextMonth:false
                }
            }


			// Days cell
            Repeater {
                model: currntMonthDays
                id: daysRepeater
                DayCell{
					holidays:CalendarBackend.get_month_holidays(root.firstCalType,root.currntDate)
					weekends : CalendarBackend.get_month_weekends(root.firstCalType,root.currntDate)
				}
            }

            // after Days offset
			Repeater {
                model: nextMonthDays
                id: daysAfterRepeater
                DayCell{
					holidays:CalendarBackend.get_month_holidays(root.firstCalType,root.nextMonthDate)
					weekends : CalendarBackend.get_month_weekends(root.firstCalType,root.nextMonthDate)
					isCurrentMonth:false
					isNextMonth:true
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
		calculate_dates()
		root.nextMonthDate = root.currntDate.addMonth()
		root.prevMonthDate = root.currntDate.subtractMonth()
	}

	function daysBedoreCurrentMonth(){
        var count = CalendarBackend.daysBedoreCurrentMonth(root.startOfWeek,root.currntDate.getDay())
        var j = root.currntDate.subtractMonth().daysInMonth()
        var days_list = []
        for(let i = j-count;i<j;i++){
            days_list.push(i+1)
        }
        return days_list
        // return CalendarBackend.daysBedoreCurrentMonth(6,root.currntDate.getDay())
    }

    function daysAfterCurrentMonth(){
        var count = 42 - root.currntDate.daysInMonth() - daysBedoreCurrentMonth().length
        var days_list = []
        for(let i = 0;i<count;i++){
            days_list.push(i+1)
        }
        return days_list
        // return 42 - root.currntDate.daysInMonth().length - daysBedoreCurrentMonth() 
    }


	function calculate_dates(){

		var countDaysBefore = CalendarBackend.daysBedoreCurrentMonth(root.startOfWeek,root.currntDate.getDay())
        var countDays = root.currntDate.daysInMonth()
		var countDaysAfter = 42 - countDays - countDaysBefore

		var tmp = CalendarBackend.convert_calendars(root.currntDate,root.firstCalType,root.secondCalType)
		var currntDate1 = CalendarBackend.get_unvirsal_date(root.firstCalType,[root.currntDate.getFullYear(),root.currntDate.getMonth(),root.currntDate.getDate()])
		var currntDate2 = CalendarBackend.get_unvirsal_date(root.secondCalType,tmp)
		currntDate2 = currntDate2.subtractDate(countDaysBefore)
		currntDate1 = currntDate1.subtractDate(countDaysBefore)

		var prevMonth2 = []
		var currntMonth2 = []
		var nextMonth2 = []
		var prevMonthLastDay = root.currntDate.subtractMonth().daysInMonth()
		for(let i = prevMonthLastDay-countDaysBefore;i<prevMonthLastDay;i++){
			prevMonth2.push([[currntDate1.getDate(),currntDate1.format('MMMM'),currntDate1.getFullYear()],[currntDate2.getDate(),currntDate2.format('MMMM'),currntDate2.getFullYear()]])
			currntDate2 = currntDate2.addDate(1)
			currntDate1 = currntDate1.addDate(1)
        }

		// console.log('=======================')

		for (let i=0;i<countDays;i++){
			currntMonth2.push([[currntDate1.getDate(),currntDate1.format('MMMM'),currntDate1.getFullYear()],[currntDate2.getDate(),currntDate2.format('MMMM'),currntDate2.getFullYear()]])
			currntDate2 = currntDate2.addDate(1)
			currntDate1 = currntDate1.addDate(1)
		}

		// console.log('=======================')

		for (let i=0;i<(countDaysAfter);i++){
			nextMonth2.push([[currntDate1.getDate(),currntDate1.format('MMMM'),currntDate1.getFullYear()],[currntDate2.getDate(),currntDate2.format('MMMM'),currntDate2.getFullYear()]])
			currntDate2 = currntDate2.addDate(1)
			currntDate1 = currntDate1.addDate(1)
		}

		prevMonthDays = prevMonth2
		currntMonthDays = currntMonth2
		nextMonthDays =  nextMonth2
	}
	Component.onCompleted : {
        // console.log("===============================")
		calculate_dates()
        // console.log("===============================")
    }

}