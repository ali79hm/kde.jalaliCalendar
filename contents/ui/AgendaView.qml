import QtQuick 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "lib/main.js" as CalendarBackend

PinchArea {
	id: agendaview
    // anchors.fill: parent
    // anchors.margins: 5

    // property var myagendaList: []
    property var myagendaList:[['اربعین حسینی','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,1])],
        ['اربعین حسینی','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,1])],
        ['arbaeen hossseini','google-calendar','red','https://www.google.com',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,2])],
        ['dayly scram','google-calendar','blue','https://www.google.com',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,3])],
        ['mother day','','green','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,4])],
        ['روز مادر','','green','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,5])],
        ['عید نوروز','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,6])],
        ['عید نوروز','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,7])],
        ['عید نوروز','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,8])],
        ['عید نوروز','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,9])],
        ['عید نوروز','','red','',CalendarBackend.get_unvirsal_date('Jalali',[1403,2,10])],
    ]
    property var stringsList: ["text 1 : test test test", "text2: test test tes", "text3 : test test test", "text4 : test test test","text 1 : test test test", "text2: test test tes", "text3 : test test test", "text4 : test test test","text 1 : test test test", "text2: test test tes", "text3 : test test test", "text4 : test test test"]
    
    ColumnLayout {
			id:information
			spacing: PlasmaCore.Units.smallSpacing
			anchors {
				top: parent.top
				left: parent.left
				right: parent.right
			}

            PlasmaComponents3.Label {
                // id: firstCalendar
                anchors.horizontalCenter: parent.horizontalCenter
                // horizontalAlignment: Text.AlignHCenter
                // verticalAlignment: Text.AlignVCenter
                text:'جمعه ۱۳ مهر ۱۴۰۳'
                // wrapMode: Text.NoWrap
                // elide: Text.ElideRight
                // fontSizeMode: Text.HorizontalFit
                font.pixelSize: 20
                // font.pointSize: -1
            }
            PlasmaComponents3.Label {
                // id: firstCalendar
                anchors.horizontalCenter: parent.horizontalCenter
                // horizontalAlignment: Text.AlignHCenter
                // verticalAlignment: Text.AlignVCenter
                text:'4 october 2024'
                // wrapMode: Text.NoWrap
                // elide: Text.ElideRight
                // fontSizeMode: Text.HorizontalFit
                font.pixelSize: 15
                // font.pointSize: -1
            }
	}
    //end info
    // Add a gray line as a separator
    Rectangle {
        id : seperatorLine
        width: parent.width
        height: 1
        opacity:0.4
        color: "grey"
        anchors {
            left: parent.left
            right: parent.right
            top: information.bottom
            topMargin: 10
        }
    }
    //scroll
    ScrollView{
        anchors.margins: 5
        id:scrollarea
        // contentWidth: -1

        height:parent.height-information.height
        width:parent.width
        // anchors.fill: parent
        anchors {
				horizontalCenter: parent.horizontalCenter
                // topMargin: 2
				top: seperatorLine.bottom
			}
        Column{
            width: scrollarea.width
            Repeater {
                model: agendaview.myagendaList
                
                Column{
                    Rectangle {
                        width: scrollarea.width
                        height: 50
                        radius: 10
                        // border.color: "black"
                        color : 'transparent'
                        // color: modelData[2]
                        Label {
                            anchors.centerIn: parent
                            text: modelData[0]
                            // text: 'test'
                            color: "white"
                        }
                        // Bottom-right gray text
                        Label {
                            anchors {
                                right: parent.right
                                bottom: parent.bottom
                                margins: 5  // Optional margin to give some space from the edges
                            }
                            text: modelData[1]  // Add your desired text or model data here
                            color: "grey"
                            font.pixelSize: 10  // Adjust size to fit the design
                            visible: modelData[1] !== "" 
                        }
                        MouseArea {
                            visible: modelData[3] !== "" 
                            anchors.fill: parent  // Make the entire rectangle clickable
                            onClicked: {
                                Qt.openUrlExternally(modelData[3])  // Replace with your desired URL
                            }
                            cursorShape: Qt.PointingHandCursor  // Change cursor on hover to indicate it's clickable
                        }
                    }
                    Rectangle {
                        id : seperatorLine
                        width: parent.width
                        height: 1
                        opacity:0.4
                        color: "grey"
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: information.bottom
                            topMargin: 10
                        }
                    }
                }
            }
        }
            
        
    }
    // Show this message if the list is empty
    PlasmaComponents3.Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: "no event found"
        color: "grey"
        font.pixelSize: 15
        visible: myagendaList.length === 0  // Visible only if the list is empty
    }
}