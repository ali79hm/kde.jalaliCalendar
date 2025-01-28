import QtQuick 2.2
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.1
// import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
// import org.kde.plasma.extras 2.0 as PlasmaExtras

import "lib/main.js" as CalendarBackend

MouseArea {
    id: daycell
    property bool isCurrentMonth:false
    property bool isNextMonth:false
    property bool showSecondCal:false
    property var holidays:[]
    property var weekends:[]
    property var is_today:isCurrentMonth&&root.currntDate.getFullYear()==root.today.getFullYear() && root.currntDate.getMonth()==root.today.getMonth() && modelData[0][0]==root.today.getDate()
    
    property var is_selected:isSelected()
    
    hoverEnabled: true
    width: monthGrid.cellWidth
    height: monthGrid.cellHeight
    onClicked : onClick()

    PlasmaCore.ToolTipArea {
		anchors.fill: parent
		active: true
		visible: true
		mainText: daycell.containsMouse ? getToolTip1() : ""
		subText: showSecondCal?(daycell.containsMouse ? getToolTip2() : ""):""
	}

    function getToolTip1(){
        return CalendarBackend.get_tool_tip(modelData[0],root.firstCalType)
    }
    function getToolTip2(){
        return CalendarBackend.get_tool_tip(modelData[1],root.secondCalType)
    }
    function isSelected(){
        if (root.selectedDate == null){
            return false
        }
        else if (isCurrentMonth){
            return root.selectedDate.getFullYear()==root.currntDate.getFullYear() && root.selectedDate.getMonth()==root.currntDate.getMonth() && modelData[0][0]==root.selectedDate.getDate()
        }
        else if(isNextMonth){
            return root.selectedDate.getFullYear()==root.nextMonthDate.getFullYear() && root.selectedDate.getMonth()==root.nextMonthDate.getMonth() && modelData[0][0]==root.selectedDate.getDate()
        }
        else{
            return root.selectedDate.getFullYear()==root.prevMonthDate.getFullYear() && root.selectedDate.getMonth()==root.prevMonthDate.getMonth() && modelData[0][0]==root.selectedDate.getDate()
        }
    }
    function onClick(){
        if (isCurrentMonth){
            root.selectedDate = CalendarBackend.get_unvirsal_date(firstCalType,[root.currntDate.getFullYear(),root.currntDate.getMonth(),modelData[0][0]])
        }
        else if(isNextMonth){
            root.selectedDate = CalendarBackend.get_unvirsal_date(firstCalType,[root.nextMonthDate.getFullYear(),root.nextMonthDate.getMonth(),modelData[0][0]])
        }
        else{
            root.selectedDate = CalendarBackend.get_unvirsal_date(firstCalType,[root.prevMonthDate.getFullYear(),root.prevMonthDate.getMonth(),modelData[0][0]])
        }
        
    }

    Rectangle {
        id: todayRect
        anchors.fill: parent
        // opacity:0
        opacity: {
            if (is_today && is_selected){// Selected and Today
                0.6
            } else if (is_today){// Today  
                0.6
            } else {
                0
            } 
        }
        radius: 2
        Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
        color: PlasmaCore.Theme.textColor
    }

    Rectangle {
        id: highlightDate
        anchors.fill: todayRect
        opacity: {
            if (is_selected){
                0.6
            } else if (daycell.containsMouse){
                0.4
            } else {
                0
            }
        }
        radius: 2
        // border.color: PlasmaCore.Theme.highlightColor
        // border.width: 2
        Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
        color: PlasmaCore.Theme.highlightColor
        z: todayRect.z - 1
    }


    Item {
        anchors.fill: todayRect

        // show second calendar date
        PlasmaComponents3.Label {
            id: secondCalendar
            visible: daycell.showSecondCal
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: PlasmaCore.Units.smallSpacing
                margins: PlasmaCore.Units.smallSpacing
            }
            height: daycell.height / 4
            text: daycell.showSecondCal?CalendarBackend.getLocalNumber(modelData[1][0], root.secondCalType):''
            opacity: isCurrentMonth ? 1.0 : 0.3
            wrapMode: Text.NoWrap
            fontSizeMode: Text.HorizontalFit
            font.pixelSize: getSecondCalendarFontSize()
            font.pointSize: -1
            color: holidays.includes(modelData[0][0]) ? PlasmaCore.Theme.negativeTextColor : (is_today ? PlasmaCore.Theme.backgroundColor : PlasmaCore.Theme.textColor)
        }

        PlasmaComponents3.Label {
            id: firstCalendar
            anchors {
                horizontalCenter: parent.horizontalCenter
                margins: secondCalendar.visible ? PlasmaCore.Units.smallSpacing : 0
                top: secondCalendar.visible ? secondCalendar.bottom : parent.top
            }
            height: daycell.showSecondCal ? daycell.height / 3 : daycell.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: CalendarBackend.getLocalNumber(modelData[0][0], root.firstCalType)
            opacity: isCurrentMonth ? 1.0 : 0.3
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            fontSizeMode: Text.HorizontalFit
            font.pixelSize: getFirstCalendarFontSize()
            font.pointSize: -1
            color: holidays.includes(modelData[0][0]) ? PlasmaCore.Theme.negativeTextColor : (is_today ? PlasmaCore.Theme.backgroundColor : PlasmaCore.Theme.textColor)
            Behavior on color {
                ColorAnimation { duration: PlasmaCore.Units.shortDuration * 2 }
            }
        }
    }

    function getFirstCalendarFontSize(){
        if (CalendarBackend.isFarsiNumbers(root.firstCalType)){
            
            return Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(daycell.height / 2), Math.floor(daycell.width * 7/8)))
        }
        else{
            return Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(daycell.height / 32 *13), Math.floor(daycell.width * 7/8)))
        }
    }
    function getSecondCalendarFontSize(){
        if (CalendarBackend.isFarsiNumbers(root.secondCalType)){
            
            return Math.floor(Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(daycell.height / 2), Math.floor(daycell.width * 7/8)))/8*5)
        }
        else{
            return Math.floor( Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(daycell.height / 8 *3), Math.floor(daycell.width * 7/8)))/2)
        }
    }
}