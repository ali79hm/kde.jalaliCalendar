// import QtQuick 2.2
// import QtQuick.Controls 2.5
// import org.kde.kirigami 2.4 as Kirigami
// import org.kde.plasma.extras 2.0 as PlasmaExtras

// import org.kde.plasma.core 2.0 as PlasmaCore
// import org.kde.plasma.plasmoid 2.0
// import QtQuick.Layouts 1.0


// import "widgets" as Widget


// Item {
// 	property var calendar_type_list : ListModel {
//         ListElement { key: "T"; value: 'Time' ; enabled1: true }
// 		ListElement { key: "D"; value: 'Date' ; enabled1: true }
//         ListElement { key: "d"; value: 'Date2' ; enabled1: true }

//         ListElement { key: "TD"; value: 'Time+Date' ; enabled1: true }
//         ListElement { key: "Td"; value: 'Time+Date2' ; enabled1: true }
// 		ListElement { key: "DT"; value: 'Date+Time' ; enabled1: true }
//         ListElement { key: "Dd"; value: 'Date+Date2' ; enabled1: true }
//         ListElement { key: "dT"; value: 'Date2+Time' ; enabled1: true }
//         ListElement { key: "dD"; value: 'Date2+Date' ; enabled1: true }

//         ListElement { key: "TDd"; value: 'Time+Date+Date2' ; enabled1: true }
//         ListElement { key: "TdD"; value: 'Time+Date2+Date' ; enabled1: true }
//         ListElement { key: "DTd"; value: 'Date+Time+Date2' ; enabled1: true }
//         ListElement { key: "DdT"; value: 'Date+Date2+Time' ; enabled1: true }
//         ListElement { key: "dTD"; value: 'Date2+Time+Date' ; enabled1: true }
//         ListElement { key: "dDt"; value: 'Date2+Date+Time' ; enabled1: true }
//     }
	
// 	width: parent.width
// 	ColumnLayout{
// 		width: parent.width
// 		PlasmaExtras.Heading {
// 			id: heading
// 			text: "Widget Format"
// 			level: 2
// 			color: Kirigami.Theme.textColor
// 			Layout.fillWidth: true
// 			property bool showUnderline: level <= 2
// 			width: parent.width
// 			Rectangle {
// 				visible: heading.showUnderline
// 				anchors.bottom: heading.bottom
// 				width: heading.width
// 				height: 1
// 				color: heading.color
// 			}
// 		}
// 		RowLayout{
// 			Rectangle {
// 				width: 200
// 				height: 40
// 				border.color: "gray"
// 				radius: 5
// 				color: Kirigami.Theme.buttonBackgroundColor

// 				Text {
// 					anchors.centerIn: parent
// 					text: "Text with Border"
// 					font.pixelSize: 16
// 				}
//         	}
// 			Button {
//             text: "Open Window"
//             onClicked: dialog.open()
//         }
			
// 		}
		
// 		ComboBox {
//             id: comboBox
//             model: calendar_type_list
//             currentIndex: 0 // Optional: sets the default value
//             textRole: "value" // Use the 'value' property for display
//             width: 200

//             onActivated: {
//                 // Print the 'key' of the selected item
//                 console.log("Selected key:", calendar_type_list.get(currentIndex).key)
//             }
//         }
// 		TextField {
// 			id: clockTimeFormat
// 			width: 1000
// 			// configKey: 'clockTimeFormat1'
// 			placeholderText: 'DD:' //TODO
// 		}
// 		Button {
//             text: "Open Window"
//             onClicked: dialog.open()
//         }
// 		Text {
//             width: parent.width
//             textFormat: Text.RichText
//             text: "<p style='color:red;'>test</p>"
//         }
// 	}
// 	Dialog {
//         id: dialog
//         title: "Small Window"
//         modal: true
//         standardButtons: Dialog.Ok | Dialog.Cancel
//         onAccepted: {
//             // Handle OK pressed
//             console.log("Text input:", dialogTextField.text)
//         }
//         onRejected: {
//             // Handle Cancel pressed
//         }

//         ColumnLayout {
//             TextField {
//                 id: dialogTextField
//                 placeholderText: "Enter text here"
//             }
//         }
// 	}
// }

import QtQuick 2.2
import QtQuick.Controls 2.5
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0

import "widgets" as Widget


Item {
    id: root
    width: parent.width
    height: parent.height

    property var boxOrder: ['Box 1', 'Box 2', 'Box 3'] // Initial box order

    // Rectangle{
    //     width:parent.width
    //     height: parent.height
    //     color:'red'
    // }
    ColumnLayout {
        width: parent.width

        PlasmaExtras.Heading {
            id: heading
            text: "Configure Box Order"
            level: 2
            color: Kirigami.Theme.textColor
            Layout.fillWidth: true
            property bool showUnderline: level <= 2
            width: parent.width
            Rectangle {
                visible: heading.showUnderline
                anchors.bottom: heading.bottom
                width: heading.width
                height: 1
                color: heading.color
            }
        }
        
        RowLayout {
            id: rowLayout
            width: parent.width
            height: 100
            Layout.fillWidth: true


            Repeater {
                id: repeater
                model: root.boxOrder
                Widget.DraggableBox {
                    id: draggableBox
                    width: 100
                    height: 100
                    color: modelData === "Box 1" ? "red" : (modelData === "Box 2" ? "green" : "blue")
                    label: modelData
                    onPositionChanged: reorderBoxes()
                }
            }
        }
        Button {
            text: "Save Order"
            Layout.fillWidth: true
            onClicked: {
                console.log("Current box order:", root.boxOrder.join(", "))
            }
        }
    }

    //Reorder function to update the box order when dragging
    function reorderBoxes() {
        console.log('!!!!')
        let order = [];
        for (let i = 0; i < rowLayout.children.length; i++) {
            order.push(rowLayout.children[i].label);
        }
        root.boxOrder = order;
        console.log("Updated order: " + root.boxOrder.join(", "));
    }

}



// Item {
//     id: root
//     width: parent.width
//     height: parent.height

//     property var boxOrder: ['Box 1', 'Box 2', 'Box 3'] // Initial box order

//     ColumnLayout {
//         width: parent.width

//         PlasmaExtras.Heading {
//             id: heading
//             text: "Configure Box Order"
//             level: 2
//             color: Kirigami.Theme.textColor
//             Layout.fillWidth: true
//             property bool showUnderline: level <= 2
//             width: parent.width
//             Rectangle {
//                 visible: heading.showUnderline
//                 anchors.bottom: heading.bottom
//                 width: heading.width
//                 height: 1
//                 color: heading.color
//             }
//         }

//         RowLayout {
//             id: rowLayout
//             width: parent.width
//             height: 150

//             Repeater {
//                 id: repeater
//                 model: root.boxOrder
//                 DraggableBox {
//                     id: draggableBox
//                     width: 100
//                     height: 100
//                     color: modelData === "Box 1" ? "red" : (modelData === "Box 2" ? "green" : "blue")
//                     label: modelData
//                     onPositionChanged: reorderBoxes()
//                 }
//             }
//         }

//         Button {
//             text: "Save Order"
//             onClicked: {
//                 console.log("Current box order:", root.boxOrder.join(", "))
//             }
//         }
//     }

//     // Reorder function to update the box order when dragging
//     function reorderBoxes() {
//         let order = [];
//         for (let i = 0; i < rowLayout.children.length; i++) {
//             order.push(rowLayout.children[i].label);
//         }
//         root.boxOrder = order;
//         console.log("Updated order: " + root.boxOrder.join(", "));
//     }
// }

// // Custom DraggableBox component
// Rectangle {
//     id: draggableBox
//     property alias label: textItem.text
//     signal positionChanged

//     width: 100
//     height: 100
//     color: "gray"
//     radius: 10

//     Text {
//         id: textItem
//         anchors.centerIn: parent
//         font.pixelSize: 16
//         text: ""
//     }

//     MouseArea {
//         id: mouseArea
//         anchors.fill: parent
//         drag.target: parent

//         onReleased: {
//             positionChanged();
//         }
//     }
// }
