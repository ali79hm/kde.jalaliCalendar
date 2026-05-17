import QtQuick 2.2
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "lib/main.js" as CalendarBackend

Item{
	id:yearsPage
    
	signal resetToToday
    signal headerClicked
	signal activated(int index,var yearList)

	property var firstCalType: root.firstCalType
	// property var secondCalType : root.secondCalType

	property int rows:5
	property int columns:2
	// property var monthNameList : []
	property var yearsList : []
	// property var currentYear : get_current_year()
	property var currentDecadeStart : get_decade_first_year()
	property var currentDecade : get_decade(currentDecadeStart)

	function get_decade_first_year(){
		return Math.floor(root.currntDate.getFullYear() / 10) * 10
	}
	function get_decade(year){
		var result = Math.floor(year / 10) * 10
		return CalendarBackend.getLocalNumber(String(result)+'-'+String(result+9),firstCalType)
	}

	// function get_current_year(){
	// 	return CalendarBackend.getLocalNumber(String(root.currntDate.getFullYear()),firstCalType)
	// }
		
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
				down: false
				PlasmaComponents3.Label{
					anchors {
						left: parent.left
						leftMargin:20
						margins:0
					}

					// fontSizeMode: Text.HorizontalFit
					font.pixelSize: Math.max((Kirigami.Theme.defaultFont && Kirigami.Theme.defaultFont.pixelSize > 0) ? Kirigami.Theme.defaultFont.pixelSize : 12, parent.height)
					y: layoutDirection=='R'?-font.pixelSize*0.3:-font.pixelSize*0.3
					horizontalAlignment: Text.AlignLeft
					text:currentDecade
					}
				onClicked: {
					if (!stack.busy) {
						yearsPage.headerClicked() //FIXME not defined
					}
				}
				
			}

			PlasmaComponents3.ToolButton {
				id: previousButton
				icon.name: "go-previous"
				onClicked: root.layoutDirection=='L'? yearsPage.prevDecade() : yearsPage.nextDecade()
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
				onClicked: yearsPage.resetToCurrentYear()
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
				onClicked: root.layoutDirection=='L'? yearsPage.nextDecade() : yearsPage.prevDecade()
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
            id: yearsGrid
			layoutDirection: root.layoutDirection=='R'? Qt.RightToLeft :Qt.LeftToRight  
            spacing: 1
            columns: yearsPage.columns
            readonly property int cellWidth : Math.floor(yearsPage.width / yearsPage.columns - 6)
            readonly property int cellHeight :  Math.floor(yearsPage.height / yearsPage.rows - 9)

			anchors {
				horizontalCenter: parent.horizontalCenter
                topMargin: cellHeight/2
				top: parent.top
			}

			// Month cell
            Repeater {
                model: yearsPage.yearsList
                id: daysRepeater
                YearCell{
					onClicked: yearsPage.activated(index,daysRepeater.model)
				}
            }
		}

	}

	function nextDecade(){
		yearsPage.currentDecadeStart = yearsPage.currentDecadeStart+10
		yearsPage.currentDecade = get_decade(yearsPage.currentDecadeStart)
		make_years_list()
	}
	function prevDecade(){
		yearsPage.currentDecadeStart = Math.max(yearsPage.currentDecadeStart-10,1)
		yearsPage.currentDecade = get_decade(yearsPage.currentDecadeStart)
		make_years_list()
	}

	// function nextYear() {
	// 	root.currntDate.setFullYear(parseInt(root.currntDate.getFullYear())+1)
	// 	refresh_current_year()
	// }
	// function prevYear() {
	// 	root.currntDate.setFullYear(Math.min(parseInt(root.currntDate.getFullYear())-1),1)
	// 	refresh_current_year()
	// }
	// function refresh_current_year(){
	// 	currentYear = get_current_year()
	// }
	function resetToCurrentYear(){
		yearsPage.resetToToday()
		// monthPage.refresh_current_year()
	}

	function make_years_list(){
		var years = []
		for (var i = 0; i < 10; i++) {
			years.push([
							i,yearsPage.currentDecadeStart + i
						])
		}
		yearsPage.yearsList = years
	}

	// function make_month_list(){

	// 	var month_list = []
	// 	for(let i = 1;i<root.monthNames.length+1;i++){
	// 		month_list.push([
	// 							i,root.monthNames[i-1]
	// 						])
    //     }
	// 	monthNameList = month_list
	// }

	onFirstCalTypeChanged: {
		make_years_list()
		// make_month_list()
    }

	Component.onCompleted : {
        // console.log("===============================")
		make_years_list()
		// make_month_list()
        // console.log("===============================")
	}
}