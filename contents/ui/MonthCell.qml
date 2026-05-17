import QtQuick 2.2
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "lib/main.js" as CalendarBackend

MouseArea {
    id: monthcell

    property int displayedMonth: modelData[0]
    property int selectedYear : -1
    property bool is_this_month:selectedYear==root.today.getFullYear() && modelData[0] == root.today.getMonth()+1

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
        color: Kirigami.Theme.textColor
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
        color: Kirigami.Theme.textColor
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
            color: Kirigami.Theme.textColor
            Behavior on color {
                ColorAnimation { duration: Kirigami.Units.shortDuration * 2 }
            }
        }
    }

    function getFirstCalendarFontSize(){
        return Math.min(Math.floor(monthcell.height / 3), Math.floor(monthcell.width * 0.2))
        //TODO : need change
        if (CalendarBackend.isFarsiNumbers(root.firstCalType)){
            
            return Math.max((Kirigami.Theme.defaultFont && Kirigami.Theme.defaultFont.pixelSize > 0) ? Kirigami.Theme.defaultFont.pixelSize : 12, Math.min(Math.floor(monthcell.height / 2), Math.floor(monthcell.width * 7/8)))
        }
        else{
            return Math.max((Kirigami.Theme.defaultFont && Kirigami.Theme.defaultFont.pixelSize > 0) ? Kirigami.Theme.defaultFont.pixelSize : 12, Math.min(Math.floor(monthcell.height / 32 *13), Math.floor(monthcell.width * 7/8)))
        }
    }
}