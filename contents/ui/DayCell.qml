import QtQuick 2.2
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.1
// import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
// import org.kde.plasma.extras 2.0 as PlasmaExtras

import "./lib/Jalali.js" as Jalali

MouseArea {
    id: daycell
    property bool isCurrentMonth:true
    // property var today
    hoverEnabled: true
    width: monthGrid.cellWidth
    height: monthGrid.cellHeight
    // onClicked: root.selectedDate = new persianDate([modelData[0], modelData[1], modelData[2]]) //FIXME:must fix to work

    Rectangle {
        id: todayRect
        anchors.fill: parent
        // opacity:0
        opacity: {
            if (modelData[3]){// Today
                0.4
            } else {
                0
            } //else if (
                // // Selected and Today
            //        todayDate.year()  == selectedDate.year() 
            //     && todayDate.month() == selectedDate.month()
            //     && todayDate.date()  == selectedDate.date()
            //     && todayDate.year()  == modelData[0]
            //     && todayDate.month() == modelData[1]
            //     && todayDate.date()  == modelData[2]
            // ){
            //     0.6
            // } 
        }
        // Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
        color: PlasmaCore.Theme.textColor
    }

    Rectangle {
        id: highlightDate
        anchors.fill: todayRect
        opacity:0
        // opacity: {
        //     if (
        //         // Selected
        //            selectedDate.year()  == modelData[0]
        //         && selectedDate.month() == modelData[1]
        //         && selectedDate.date()  == modelData[2]
        //     ){
        //         0.6
        //     } else if (daycell.containsMouse){
        //         0.4
        //     } else {
        //         0
        //     }
        // }
        
        // Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
        color: PlasmaCore.Theme.highlightColor
        z: todayRect.z - 1
    }

    // Show days number on screen
    Column{
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
            text: modelData[2] //FIXME : fix for calendar
            opacity: isCurrentMonth ? 1.0 : 0.3
            wrapMode: Text.NoWrap
            fontSizeMode: Text.HorizontalFit
            font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(daycell.height / 2), Math.floor(daycell.width * 7/8)))/2
            font.pointSize: -1
            color: modelData[3] ? PlasmaCore.Theme.backgroundColor : (modelData[4]>0 ? PlasmaCore.Theme.negativeTextColor : PlasmaCore.Theme.textColor) 
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
            text: Jalali.convertToPersianNumbers(modelData[2]) //FIXME : fix for calendar
            opacity: isCurrentMonth ? 1.0 : 0.3
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            fontSizeMode: Text.HorizontalFit
            font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(daycell.height / 2), Math.floor(daycell.width * 7/8)))
            font.pointSize: -1
            color: modelData[3] ? PlasmaCore.Theme.backgroundColor : (modelData[4]>0 ? PlasmaCore.Theme.negativeTextColor : PlasmaCore.Theme.textColor) 
            Behavior on color {
                ColorAnimation { duration: PlasmaCore.Units.shortDuration * 2 }
            }
        }
    }
}