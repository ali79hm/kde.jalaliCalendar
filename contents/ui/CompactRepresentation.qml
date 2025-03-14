import QtQuick 2.12
import QtQuick.Layouts 1.1
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "lib/main.js" as CalendarBackend

MouseArea {
    onClicked: root.expanded = !root.expanded
    id: compactRepresentation

    // property string compactRepresentationFormat: plasmoid.configuration.compactRepresentationFormat
    property string compactRepresentationFormat: 'dddd D MMMM'

    // property int compactRepresentationHorizontalExtraSpace: plasmoid.configuration.compactRepresentationHorizontalExtraSpace
    property int compactRepresentationHorizontalExtraSpace: 5
    
    Layout.preferredWidth: compactLabel.width + compactRepresentationHorizontalExtraSpace *2
    Layout.maximumWidth: compactLabel.width + compactRepresentationHorizontalExtraSpace *2

    PlasmaComponents.Label {
        id: compactLabel
        anchors.centerIn: parent
        wrapMode: Text.NoWrap
        smooth: true
        textFormat: Text.RichText
        font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, 16)
        // text: root.today.format('HH:mm:ss')
        // text:get_calendar_text(root.today,'YYYY MMMM D , HH:mm , SYYYY SMMMM SD')
        text:get_calendar_text(root.today,'SD SMMMM SYYYY , HH:mm , MMMM D ddd')
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
        var second_date = CalendarBackend.convert_calendars_light(date,root.firstCalType,root.secondCalType)
        var second_date = CalendarBackend.get_unvirsal_date(root.secondCalType,second_date)
        var dateFormated = CalendarBackend.getLocalNumber(date.format('YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s'),root.firstCalType).split('|')
        var secondDateFormated = CalendarBackend.getLocalNumber(second_date.format('YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s'),root.secondCalType).split('|')
        var timeFormated = date.format('YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s').split('|')
        const tokens = {
            'SYYYY': secondDateFormated[0],
            'YYYY': dateFormated[0],
            'SYY': secondDateFormated[1],
            'YY': dateFormated[1],
            "SMMMM": secondDateFormated[2],
            "MMMM": dateFormated[2],
            "SMMM": secondDateFormated[3],
            "MMM": dateFormated[3],
            'SMM': secondDateFormated[4],
            'MM': dateFormated[4],
            'SM': secondDateFormated[5],
            'M': dateFormated[5],
            'Sddd': secondDateFormated[6],
            'ddd': dateFormated[6],
            'Sdd': secondDateFormated[7],
            'dd': dateFormated[7],
            'Sd': secondDateFormated[8],
            'd': dateFormated[8],
            'SDD': secondDateFormated[9],
            'DD': dateFormated[9],
            'SD': secondDateFormated[10],
            'D': dateFormated[10],
            'HH':timeFormated[11],
            'H':timeFormated[12],
            'hh':timeFormated[13],
            'h':timeFormated[14],
            'mm':timeFormated[15],
            'm':timeFormated[16],
            'ss':timeFormated[17],
            's':timeFormated[18],
        };
        
        var mystr =  format.replace(/SYYYY|YYYY|SYY|YY|SMMMM|MMMM|SMMM|MMM|SMM|MM|SM|M|Sddd|ddd|Sdd|dd|Sd|d|SDD|DD|SD|D|HH|H|hh|h|mm|m|ss|s/g, function(match) {
            return tokens[match];
        });
        mystr = mystr.split(' ')
        var mystr2 = ''
        for (let i = 0; i < mystr.length; i++) {
            if (i ==4){
                mystr2 +='<strong style="font-size: 16px;">&#x2066;'+mystr[i]+'&#x2069; </strong>'
            }
            else{
                mystr2 +='<span style="font-size: 14px;">&#x2066;'+mystr[i]+'&#x2069; </span>'
            }
        }
        //text:get_calendar_text(root.today,'MMM YYYY MMMM d , HH:mm , SYYYY SMMMM Sd')
        return '<p dir="ltr">'+mystr2+'</p>'
        // return '<p dir="ltr" style="color:red;">'+mystr2+'</p>'
    }
}