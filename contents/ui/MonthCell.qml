import QtQuick 2.2
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.1
import org.kde.plasma.core as PlasmaCore
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
    

    function onClick(){
        //will set from outside
        return
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
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration*2 } }
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
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration*2 } }
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
                ColorAnimation { duration: Kirigami.Units.shortDuration * 2 }
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
}