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
    id: daycell
    property bool isCurrentMonth:true
    property bool isNextMonth:false
    property var holidays:[]
    property var weekends:[]
    property var is_today:root.currntDate.getFullYear()==root.today.getFullYear() && root.currntDate.getMonth()==root.today.getMonth() && modelData==root.today.getDate()
    property var is_selected:isCurrentMonth && root.selectedDate.getFullYear()==root.currntDate.getFullYear() && root.selectedDate.getMonth()==root.currntDate.getMonth() && modelData==root.selectedDate.getDate()
    hoverEnabled: true
    width: monthGrid.cellWidth
    height: monthGrid.cellHeight
    onClicked : onClick()

    function onClick(){
        if (isCurrentMonth){
            root.selectedDate = CalendarBackend.get_unvirsal_date(first_cal_type,[root.currntDate.getFullYear(),root.currntDate.getMonth(),modelData])
        }
        else if(isNextMonth){
            root.selectedDate = CalendarBackend.get_unvirsal_date(first_cal_type,[monthView.nextMonthDate.getFullYear(),monthView.nextMonthDate.getMonth(),modelData])
            monthView.nextMonth()
        }
        else{
            root.selectedDate = CalendarBackend.get_unvirsal_date(first_cal_type,[monthView.prevMonthDate.getFullYear(),monthView.prevMonthDate.getMonth(),modelData])
            monthView.prevMonth()
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
                0.4
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
        Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
        color: PlasmaCore.Theme.textColor
        z: todayRect.z - 1
    }

    // Show days number on screen
    Item{
		anchors.fill: todayRect

        // show second calendar date
        PlasmaComponents3.Label {
            id:secondCalendar
            anchors {
                horizontalCenter: parent.horizontalCenter
                top:parent.top
                topMargin : PlasmaCore.Units.smallSpacing
                margins: PlasmaCore.Units.smallSpacing
            }
            height:daycell.height/4
            text: modelData
            opacity: isCurrentMonth ? 1.0 : 0.3
            wrapMode: Text.NoWrap
            fontSizeMode: Text.HorizontalFit
            font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(daycell.height / 2), Math.floor(daycell.width * 7/8)))/2
            font.pointSize: -1
            color: is_today ? PlasmaCore.Theme.backgroundColor : (weekends.includes(modelData) ? PlasmaCore.Theme.negativeTextColor : PlasmaCore.Theme.textColor) 
        }

        PlasmaComponents3.Label {
            id: firstCalendar
            anchors {
                horizontalCenter: parent.horizontalCenter
                margins: PlasmaCore.Units.smallSpacing
                top:secondCalendar.bottom
            }
            height:daycell.height/3
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: CalendarBackend.convertToPersianNumbers(modelData) //FIXME : fix for calendar
            opacity: isCurrentMonth ? 1.0 : 0.3
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            fontSizeMode: Text.HorizontalFit
            font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(daycell.height / 2), Math.floor(daycell.width * 7/8)))
            font.pointSize: -1
            color: is_today ? PlasmaCore.Theme.backgroundColor : (weekends.includes(modelData) ? PlasmaCore.Theme.negativeTextColor : PlasmaCore.Theme.textColor) 
            Behavior on color {
                ColorAnimation { duration: PlasmaCore.Units.shortDuration * 2 }
            }
        }
    }
}