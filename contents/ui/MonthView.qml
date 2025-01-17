import QtQuick 2.2
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.1


import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "lib/main.js" as CalendarBackend

Item{
	id:monthView
	

	ListModel {
		id: monthModel
		Component.onCompleted: {
			for (var i = 0; i < 12; ++i) {
				append({
					label: CalendarBackend.get_month_name(root.firstCalType,i),
					monthNumber: i + 1,
					isCurrent: true,
				})
			}
			// print_list()
			// updateYearOverview()
		}
	}
	
	QQC2.StackView {
		id: stack
		anchors.fill: parent

		pushEnter: Transition {
			NumberAnimation {
				duration: units.shortDuration
				property: "opacity"
				from: 0
				to: 1
			}
			ScaleAnimator {
				duration: units.longDuration
				from: 1.5
				to: 1
			}
		}
		pushExit: Transition {
			NumberAnimation {
				duration: units.shortDuration
				property: "opacity"
				from: 1
				to: 0
			}
		}

		popEnter: Transition {
			NumberAnimation {
				duration: units.shortDuration
				property: "opacity"
				from: 0
				to: 1
			}
		}
		popExit: Transition {
			id: popExit
			NumberAnimation {
				duration: units.shortDuration
				property: "opacity"
				from: 0.5
				to: 0
			}
			ScaleAnimator {
				duration: units.longDuration
				from : 1
				// so no matter how much you scaled, it would still fly towards you
				to: 1.5
			}
		}

		initialItem: DaysPage {
			id: daysPage
			firstCalType : root.firstCalType
			onHeaderClicked: {
				// console.log('clicekd!!!!!!')
				stack.push(monthPage)
			}
		}
	}

	Component {
		id: monthPage
		MonthPage{
			onHeaderClicked: {
				console.log('clicekd on year!!!!!!')
				// stack.push(yearOverview)
			}
			onActivated: {
				// console.log(date)
				selectMonth(index,date)
				// calendarBackend.goToMonth(date.monthNumber+3)
				stack.pop()
			}
			onResetToToday:{
				daysPage.resetToToday()
				stack.pop()
			}
		}
	}

	Component.onCompleted : {
        // console.log("===============================")
		// console.log('')
        // console.log("===============================")
	}

	function selectMonth(index,model){
		// root.currntDate.getDay()
		
		var selectedMonth = model[index]
		// console.log('=========')
		// console.log(model[index])
		// console.log('=========')
		daysPage.goToMonth(index)
	}

	// function print_list(){
	// 	console.log("===============================")
	// 	console.log(JSON.stringify(monthModel.get(11)))
	// 	console.log(monthModel.count)
    //     console.log("===============================")
	// }
}