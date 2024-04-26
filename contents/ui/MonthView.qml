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

		//header controls
		RowLayout {
			id:controls
			spacing: units.smallSpacing
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
					y: -font.pixelSize*0.6
					horizontalAlignment: Text.AlignLeft
					text:Jalali.Jget_title(root.today[0],root.today[1],'fa')
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
				onClicked: monthView.previous() //FIXME not defined
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
				onClicked: root.resetToToday() //FIXME not defined
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
				onClicked: monthView.next() //FIXME not defined
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
            id: monthGrid
			layoutDirection: Qt.RightToLeft
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
				model: Jalali.Jweek_days() //TODO:add to config
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