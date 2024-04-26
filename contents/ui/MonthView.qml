import QtQuick 2.2
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.1

// import "./calendars/Jalali.js" as Jalali

import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "./lib/Jalali.js" as Jalali

Item{
	id:monthView
	
	property int rows:7
	property int columns:7
	ColumnLayout{
		anchors.fill: parent
        // Rectangle{
        //     anchors.fill: parent
        //     color: "blue"
        // }
		RowLayout {
			id:controls
			// layoutDirection :Qt.RightToLeft
			anchors {
				top: parent.top
				// left: parent.left
				// right: parent.right
			}
			// Rectangle{
			//     anchors.fill: parent
			//     color: "blue"
			// }
			// Rectangle{
			// 	Layout.minimumHeight: 150
            //     color: "blue"
            //     width: parent.width
            //     // height: parent.height
            // }
			spacing: units.smallSpacing

			PlasmaComponents3.ToolButton {
				Layout.fillWidth:true
				// icon.name: "view-refresh-symbolic"
				PlasmaComponents3.Label{
					// Layout.fillWidth: true
					// Layout.leftMargin:20
					// layout.right:parent.right
					// Layout.fillHeight: true
					anchors {
						left: parent.left
						leftMargin:20
						margins:0
					}
					// background: Rectangle{
					// 	    radius: 0
					// 	    color: "red"
					// 	    width: parent.width
					// 	    height: parent.height
					// 	}
					// fontSizeMode: Text.HorizontalFit
                    font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, parent.height)
					y: -font.pixelSize*0.6
					horizontalAlignment: Text.AlignLeft
					text:Jalali.Jget_title(root.today[0],root.today[1],'fa')
					}
				// hoverEnabled: false
				onClicked: {
					if (!stack.busy) {
						monthView.headerClicked()
					}
				}
				
			}

			// PlasmaComponents3.Label{
			// 	Layout.fillWidth: true
			// 	// Layout.leftMargin:20
			// 	// layout.right:parent.right
			// 	// Layout.fillHeight: true
			// 	// anchors {
			// 	// 	left: parent.left
			// 	// 	// leftMargin:20
			// 	// }
			// 	horizontalAlignment: Text.AlignLeft
			// 	background: Rectangle{
			// 	    radius: 0
			// 	    color: "blue"
			// 	    width: parent.width
			// 	    height: parent.height
			// 	}
			// 	text:Jalali.Jget_title(root.today[0],root.today[1],'fa')
			// 	MouseArea {
			// 		id: monthMouse
			// 		property int previousPixelDelta

			// 		anchors.fill: parent
			// 		onClicked: {
			// 			if (!stack.busy) {
			// 				monthView.headerClicked()
			// 			}
			// 		}
			// 		onExited: previousPixelDelta = 0
			// 		onWheel: {
			// 			var delta = wheel.angleDelta.y || wheel.angleDelta.x
			// 			var pixelDelta = wheel.pixelDelta.y || wheel.pixelDelta.x

			// 			// For high-precision touchpad scrolling, we get a wheel event for basically every slightest
			// 			// finger movement. To prevent the view from suddenly ending up in the next century, we
			// 			// cumulate all the pixel deltas until they're larger than the label and then only change
			// 			// the month. Standard mouse wheel scrolling is unaffected since it's fine.
			// 			if (pixelDelta) {
			// 				if (Math.abs(previousPixelDelta) < monthMouse.height) {
			// 					previousPixelDelta += pixelDelta
			// 					return
			// 				}
			// 			}

			// 			if (delta >= 15) {
			// 				monthView.previous()
			// 			} else if (delta <= -15) {
			// 				monthView.next()
			// 			}
			// 			previousPixelDelta = 0
			// 		}
					
			// 	}
			// }

			
			// PlasmaExtras.Heading {
			// 	text:Jalali.Jget_title(root.today[0],root.today[1],'fa')
			// 	id: heading
			// 	// text:   Jalali.Jget_title(root.today[0],root.today[1],'fa')
			// 	Layout.fillWidth: true

			// 	// level: root.headingFontLevel
			// 	wrapMode: Text.NoWrap
			// 	elide: Text.ElideRight
			// 	font.capitalization: Font.Capitalize
			// 	//SEE QTBUG-58307
			// 	//try to make all heights an even number, otherwise the layout engine gets confused
			// 	Layout.preferredHeight: implicitHeight + implicitHeight%2

			// 	MouseArea {
			// 		id: monthMouse
			// 		property int previousPixelDelta

			// 		anchors.fill: parent
			// 		onClicked: {
			// 			if (!stack.busy) {
			// 				monthView.headerClicked()
			// 			}
			// 		}
			// 		onExited: previousPixelDelta = 0
			// 		onWheel: {
			// 			var delta = wheel.angleDelta.y || wheel.angleDelta.x
			// 			var pixelDelta = wheel.pixelDelta.y || wheel.pixelDelta.x

			// 			// For high-precision touchpad scrolling, we get a wheel event for basically every slightest
			// 			// finger movement. To prevent the view from suddenly ending up in the next century, we
			// 			// cumulate all the pixel deltas until they're larger than the label and then only change
			// 			// the month. Standard mouse wheel scrolling is unaffected since it's fine.
			// 			if (pixelDelta) {
			// 				if (Math.abs(previousPixelDelta) < monthMouse.height) {
			// 					previousPixelDelta += pixelDelta
			// 					return
			// 				}
			// 			}

			// 			if (delta >= 15) {
			// 				monthView.previous()
			// 			} else if (delta <= -15) {
			// 				monthView.next()
			// 			}
			// 			previousPixelDelta = 0
			// 		}
					
			// 	}
				
			// }

			PlasmaComponents3.ToolButton {
				id: previousButton
				icon.name: "go-previous"
				onClicked: monthView.previous()
				property string tooltip: i18nd("libplasma5", "Previous Month")
				QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
				QQC2.ToolTip.text: tooltip
				QQC2.ToolTip.visible: hovered
				Accessible.name: tooltip
				//SEE QTBUG-58307
				Layout.preferredHeight: implicitHeight + implicitHeight%2 //TODO:what is this
			}

			PlasmaComponents3.ToolButton {
				icon.name: "go-jump-today"
				onClicked: root.resetToToday()
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
				onClicked: monthView.next()
				property string tooltip: i18nd("libplasma5", "Next Month")
				QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
				QQC2.ToolTip.text: tooltip
				QQC2.ToolTip.visible: hovered
				Accessible.name: tooltip
				//SEE QTBUG-58307
				Layout.preferredHeight: implicitHeight + implicitHeight%2 //TODO:what is this
			}
		}
		Grid {
            id: dayCell
            columns: monthView.columns
            readonly property int cellWidth : Math.floor(monthView.width / monthView.columns - 2)
            readonly property int cellHeight :  Math.floor(monthView.height / monthView.rows - 6)

			anchors {
				horizontalCenter: parent.horizontalCenter
                bottomMargin: cellHeight/3
                // top:controls.bottom
				bottom: parent.bottom
			}
            // rows: Math.floor((days + (startOfWeek - 1)) / 7)
            layoutDirection: Qt.RightToLeft
            spacing: 1

            
            // days name
            Repeater {
                // model: root.week
				model: Jalali.Jweek_days()
                PlasmaComponents3.Label {
                    width: dayCell.cellWidth
                    height: dayCell.cellHeight*2/3
                    text: modelData
                    font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, dayCell.cellHeight / 3)
                    opacity: 0.4
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    fontSizeMode: Text.HorizontalFit
                }
				// Component.onCompleted: {
				// console.log('========================')
				// console.log(Jalali.Jweek_days())
				// console.log('========================')
            // }
            }
			// before Days offset
            // Repeater {
            //     model: root.startOfWeek - 1
            //     Rectangle {
            //         width: dayCell.cellWidth
            //         height: dayCell.cellHeight
            //         opacity: 0
            //     }
            // }
            Repeater {
                model: root.days_before
                id: daysBeforeRepeater
                DayCell{
                    isCurrentMonth:false
                }
            }

			// Days cell
            Repeater {
                model: root.days
                id: daysRepeater
                DayCell{}
            }
            // after Days offset
            // Repeater {
            //     // model: 5
            //     model: (monthView.rows-1)*monthView.columns - (root.startOfWeek - 1) - daysRepeater.count
            //     Rectangle {
            //         width: dayCell.cellWidth
            //         height: dayCell.cellHeight
            //         opacity: 0
            //     }

            // }
			Repeater {
                model: root.days_after
                id: daysAfterRepeater
                DayCell{
					isCurrentMonth:false
				}
            }
        

		}

	}
}
// PinchArea {
// 	id: root

//     property int borderWidth: 1
//     property real borderOpacity: 0.4

//     QQC2.StackView {
// 		id: stack
//         anchors.fill: parent
// 		Rectangle{
// 			anchors.fill: parent
// 			color: "blue"
// 		}
//         initialItem: DaysCalendar {
// 			id: mainDaysCalendar
            
//             columns: 7 // number of days => of corse its 7 you idiot
// 			rows: 6 // number of weeks in month
// 			// columns: calendarBackend.days // number of days => of corse its 7 you idiot
// 			// rows: calendarBackend.weeks // number of weeks in month

// 			// gridModel: daysModel //gives the days info 

// 			// dateMatchingPrecision: Calendar.MatchYearMonthAndDay // what the fuck is this ?????????

// 			// onPrevious: calendarBackend.previousMonth()
// 			// onNext: calendarBackend.nextMonth()
		
// 			// onActivated: { //TODO need this 
// 			// 	var rowNumber = Math.floor(index / columns)
// 			// 	week = 1 + calendarBackend.weeksModel[rowNumber]
// 			// 	root.date = date
// 			// 	var dt = new Date(date.yearNumber, date.monthNumber - 1, date.dayNumber)
// 			// 	root.setSelectedDate(dt)
// 			// 	root.dateClicked(dt)
// 			// }
// 			// onDoubleClicked: {
// 			// 	root.dayDoubleClicked(date)
// 			// }
// 		}
//     }
// }