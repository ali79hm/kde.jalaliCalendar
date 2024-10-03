import QtQuick 2.2
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.1
// import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
// import org.kde.plasma.extras 2.0 as PlasmaExtras

import "lib/main.js" as CalendarBackend

MouseArea {
    id: monthcell
    // property bool isCurrentMonth:true
    property var is_this_month:root.currntDate.getFullYear()==root.today.getFullYear() && modelData[0] == root.today.getMonth()+1


    hoverEnabled: true
    width: monthGrid.cellWidth
    height: monthGrid.cellHeight
    onClicked : onClick()
    
    // PlasmaCore.ToolTipArea {
	// 	anchors.fill: parent
	// 	active: true
	// 	visible: true
	// 	mainText: monthcell.containsMouse ? getToolTip1() : ""
	// 	subText: showSecondCal?(monthcell.containsMouse ? getToolTip2() : ""):""
	// }

    // function getToolTip1(){
    //     return CalendarBackend.get_tool_tip(modelData[0],root.firstCalType)
    // }
    // function getToolTip2(){
    //     return CalendarBackend.get_tool_tip(modelData[1],root.secondCalType)
    // }

    function onClick(){
        //will set from outside
        // console.log(modelData)
        return
        // if (isCurrentMonth){
        //     root.selectedDate = CalendarBackend.get_unvirsal_date(firstCalType,[root.currntDate.getFullYear(),root.currntDate.getMonth(),modelData[0][0]])
        // }
        // else if(isNextMonth){
        //     root.selectedDate = CalendarBackend.get_unvirsal_date(firstCalType,[root.nextMonthDate.getFullYear(),root.nextMonthDate.getMonth(),modelData[0][0]])
        // }
        // else{
        //     root.selectedDate = CalendarBackend.get_unvirsal_date(firstCalType,[root.prevMonthDate.getFullYear(),root.prevMonthDate.getMonth(),modelData[0][0]])
        // }
        
    }

    Rectangle {
        id: todayRect
        anchors.fill: parent
        opacity: {
            if (is_this_month){
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
            if (monthcell.containsMouse){
                0.6
            } else {
                0
            }
        }
        radius: 2
        // border.color: PlasmaCore.Theme.highlightColor
        // border.width: 2
        Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
        color: PlasmaCore.Theme.textColor
        z: todayRect.z - 1
    }

    Item {
        anchors.fill: todayRect

        // show second calendar date
        // PlasmaComponents3.Label {
        //     id: secondCalendar
        //     visible: monthcell.showSecondCal
        //     anchors {
        //         horizontalCenter: parent.horizontalCenter
        //         top: parent.top
        //         topMargin: PlasmaCore.Units.smallSpacing
        //         margins: PlasmaCore.Units.smallSpacing
        //     }
        //     height: monthcell.height / 4
        //     text: monthcell.showSecondCal?CalendarBackend.getLocalNumber(modelData[1][0], root.secondCalType):''
        //     opacity: isCurrentMonth ? 1.0 : 0.3
        //     wrapMode: Text.NoWrap
        //     fontSizeMode: Text.HorizontalFit
        //     font.pixelSize: getSecondCalendarFontSize()
        //     font.pointSize: -1
        //     color: is_this_month ? PlasmaCore.Theme.backgroundColor : (weekends.includes(modelData[0][0]) ? PlasmaCore.Theme.negativeTextColor : PlasmaCore.Theme.textColor)
        // }

        PlasmaComponents3.Label {
            id: firstCalendar
            anchors {
                horizontalCenter: parent.horizontalCenter
                // margins: PlasmaCore.Units.smallSpacing
                top: parent.top
            }
            height: monthcell.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: modelData[1]
            opacity: 1.0
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            fontSizeMode: Text.HorizontalFit
            font.pixelSize: getFirstCalendarFontSize()
            font.pointSize: -1
            color: PlasmaCore.Theme.textColor
            Behavior on color {
                ColorAnimation { duration: PlasmaCore.Units.shortDuration * 2 }
            }
        }
    }

    function getFirstCalendarFontSize(){
        return Math.min(Math.floor(monthcell.height / 3), Math.floor(monthcell.width * 0.2))
        //TODO : need change
        if (CalendarBackend.isFarsiNumbers(root.firstCalType)){
            
            return Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(monthcell.height / 2), Math.floor(monthcell.width * 7/8)))
        }
        else{
            return Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(monthcell.height / 32 *13), Math.floor(monthcell.width * 7/8)))
        }
    }
    // function getSecondCalendarFontSize(){
    //     if (CalendarBackend.isFarsiNumbers(root.secondCalType)){
            
    //         return Math.floor(Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(monthcell.height / 2), Math.floor(monthcell.width * 7/8)))/8*5)
    //     }
    //     else{
    //         return Math.floor( Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(monthcell.height / 8 *3), Math.floor(monthcell.width * 7/8)))/2)
    //     }
    // }
}