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
    id: yearcell
    // property bool isCurrentMonth:true
    property var is_this_year : modelData[1] == root.today.getFullYear()

    // property var is_this_year:root.currntDate.getFullYear()==root.today.getFullYear()


    hoverEnabled: true
    width: yearsGrid.cellWidth
    height: yearsGrid.cellHeight
    onClicked : onClick()
    

    function onClick(){
        //will set from outside
        return
    }

    Rectangle {
        id: todayRect
        anchors.fill: parent
        opacity: {
            if (is_this_year){
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
            if (yearcell.containsMouse){
                0.6
            } else {
                0
            }
        }
        radius: 2
        Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration*2 } }
        color: PlasmaCore.Theme.textColor
        z: todayRect.z - 1
    }

    Item {
        anchors.fill: todayRect

        PlasmaComponents3.Label {
            id: firstCalendar
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            height: yearcell.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: CalendarBackend.getLocalNumber(modelData[1],firstCalType)
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
        return Math.min(Math.floor(yearcell.height / 3), Math.floor(yearcell.width * 0.2))
        //TODO : need change
        if (CalendarBackend.isFarsiNumbers(root.firstCalType)){
            
            return Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(yearcell.height / 2), Math.floor(yearcell.width * 7/8)))
        }
        else{
            return Math.max(PlasmaCore.Theme.smallestFont.pixelSize, Math.min(Math.floor(yearcell.height / 32 *13), Math.floor(yearcell.width * 7/8)))
        }
    }
}