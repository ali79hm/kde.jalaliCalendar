import QtQuick 2.12
import QtQuick.Layouts 1.1
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.0 as Kirigami
import "lib/main.js" as CalendarBackend

MouseArea {
    id: compactRepresentation

    acceptedButtons: Qt.LeftButton

    property string compactRepresentationFormat: plasmoid.configuration.compactRepresentationFormat
    // property string compactRepresentationFormat: 'dddd D MMMM'

    // property int compactRepresentationHorizontalExtraSpace: plasmoid.configuration.compactRepresentationHorizontalExtraSpace
    property int compactRepresentationHorizontalExtraSpace: 5
    
    property bool wasExpanded: false

    implicitWidth: compactLabel.implicitWidth + compactRepresentationHorizontalExtraSpace * 2
    implicitHeight: compactLabel.implicitHeight + compactRepresentationHorizontalExtraSpace * 2
    width: implicitWidth
    height: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.maximumWidth: implicitWidth
    Layout.maximumHeight: implicitHeight

    onPressed: wasExpanded = root.expanded
    onClicked: root.expanded = !wasExpanded

    PlasmaComponents.Label {
        id: compactLabel
        anchors.centerIn: parent
        wrapMode: Text.NoWrap
        smooth: true
        textFormat: Text.RichText
        font.pixelSize: Math.max((Kirigami.Theme.defaultFont && Kirigami.Theme.defaultFont.pixelSize > 0) ? Kirigami.Theme.defaultFont.pixelSize : 12, 16)
        // text: root.today.format('HH:mm:ss')
        text:CalendarBackend.calendar_formated_text(root.today,compactRepresentationFormat,root.firstCalType,root.secondCalType,root.firstCalendarLanguage,root.secondCalendarLanguage,root.appLanguage)
        // text:get_calendar_text(root.today,compactRepresentationFormat)
        // text:get_calendar_text(root.today,'SD SMMMM SYYYY , HH:mm , MMMM D ddd')
    }
    
// if date = 2024,september,5 12:05:06 PM
// YYYY = full year : 2024
// YY = year : 24
// MMMM = month name : September
// MMM = short month name : Sep
// MM = month number 2 digit : 09
// M : month number : 9
// ddd : day of week name : Thursday
// dd : day of week short name : Thu
// d : day of week number : 4
// DD : day date 2 digit : 05
// D : day date : 5
// HH : hour 24 format 2 digit : 00
// H : hour 24 format : 0
// hh : hour 12 format 2 digit : 12
// h : hour 12 format : 12
// mm : minute 2 digit : 05
// m : minute  : 5
// ss : second 2 digit : 06
// s : second :6

    function get_calendar_text(date, format) {
        return CalendarBackend.calendar_formated_text(date, format, root.firstCalType, root.secondCalType,
            root.firstCalendarLanguage, root.secondCalendarLanguage, root.appLanguage)
    }
}
