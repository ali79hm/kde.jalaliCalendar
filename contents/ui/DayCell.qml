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

MouseArea {
    id: daycell
    property bool isCurrentMonth:true
    // property var today
    hoverEnabled: true
    width: dayCell.cellWidth
    height: dayCell.cellHeight
    // onClicked: root.selectedDate = new persianDate([modelData[0], modelData[1], modelData[2]])

    

    Rectangle {
        id: todayRect
        anchors.fill: parent
        // opacity:0
        opacity: {
            if ( modelData[3]){// Today
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

    // Rectangle {
    //     id: highlightHoliday
    //     anchors.fill: todayRect
    //     opacity: modelData[4]==2 ? 0.3 : (modelData[4]==1 ? 0.05 : 0)
    //     // opacity: Scripts.isHoliday(modelData) ? 0.3 : (modelData[3] == 7 ? 0.05 : 0)
    //     // Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
    //     color: '#e81c1c'
    //     z: todayRect.z - 1
    // }

    // Show days number on screen
    Column{
        // Rectangle{
        //         radius: 0
        //         color: "purple"
        //         width: parent.width
        //         height: parent.height
        //     }
		anchors.fill: todayRect
        // Rectangle{
        //     anchors.fill: parent
        //     color: "blue"
        // }
        PlasmaComponents3.Label {
            id:secondCalendar
            anchors {
                // fill: todayRect
                horizontalCenter: parent.horizontalCenter
                // margins: PlasmaCore.Units.smallSpacing
                top:parent.top
                // bottom:firstCalendar.top
                // bottomMargin:0
                topMargin : PlasmaCore.Units.smallSpacing
                margins: PlasmaCore.Units.smallSpacing
            }
            // background: Rectangle{
            //     radius: 0
            //     color: "red"
            //     width: parent.width
            //     height: parent.height
            // }
            height:daycell.height/4
            // text:'1'
            text: modelData[2]
            opacity: isCurrentMonth ? 1.0 : 0.3
            wrapMode: Text.NoWrap

            fontSizeMode: Text.HorizontalFit
            font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(daycell.height / 2), Math.floor(daycell.width * 7/8)))/2
            font.pointSize: -1
        }
        PlasmaComponents3.Label {
            id: firstCalendar
            anchors {
                // fill: todayRect
                horizontalCenter: parent.horizontalCenter
                margins: PlasmaCore.Units.smallSpacing
                top:secondCalendar.bottom
                // topMargin:0
            }
            // background: Rectangle{
            //     radius: 0
            //     color: "blue"
            //     width: parent.width
            //     height: parent.height
            // }
            height:daycell.height/3
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Jalali.convertToPersianNumbers(modelData[2])
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
            // Component.onCompleted: {
			// 	console.log('========================')
			// 	console.log(Jalali.convertToPersianNumbers(modelData[2]))
			// 	console.log('========================')
            // }
        }

    }

    // PlasmaComponents3.Label {
    //     id: firstCalendar
    //     anchors {
    //         fill: todayRect
    //         margins: PlasmaCore.Units.smallSpacing
    //     }
    //     horizontalAlignment: Text.AlignHCenter
    //     verticalAlignment: Text.AlignVCenter
    //     text: modelData[2]
    //     opacity: isCurrentMonth ? 1.0 : 0.3
    //     wrapMode: Text.NoWrap
    //     elide: Text.ElideRight
    //     fontSizeMode: Text.HorizontalFit
    //     font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, 14)
    //     font.pointSize: -1
    //     color: modelData[3] ? PlasmaCore.Theme.backgroundColor : (modelData[4]>0 ? PlasmaCore.Theme.negativeTextColor : PlasmaCore.Theme.textColor) 
    //     Behavior on color {
    //         ColorAnimation { duration: PlasmaCore.Units.shortDuration * 2 }
    //     }
    // }
    
    
}