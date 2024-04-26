import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item{
    id:root
    // property int startOfWeek: Scripts.startOfWeek(screenDate)
    property int startOfWeek: 7

    property var week: ['شنبه', '1شنبه', '2شنبه', '3شنبه', '4شنبه', '5شنبه', 'جمعه']
    //WARN:must change
    // day : [year,month,day,is_today,is_holyday:{0:noholyday , 1:weekends,2:holyday}]
    property var days_before: [[1403, 3, 26, 0, 0], [1403, 3, 27, 0, 0], [1403, 3, 28, 0, 2], [1403, 3, 29, 0, 0], [1403, 3, 30, 0, 0], [1403, 3, 31, 0, 0]]
    property var days: [[1403, 4, 1, 0, 1], [1403, 4, 2, 0, 0], [1403, 4, 3, 0, 0], [1403, 4, 4, 0, 0], [1403, 4, 5, 0, 2], [1403, 4, 6, 0, 0], [1403, 4, 7, 0, 0], [1403, 4, 8, 0, 1], [1403, 4, 9, 0, 0], [1403, 4, 10, 1, 0], [1403, 4, 11, 0, 0], [1403, 4, 12, 0, 0], [1403, 4, 13, 0, 0], [1403, 4, 14, 0, 0], [1403, 4, 15, 0, 1], [1403, 4, 16, 0, 0], [1403, 4, 17, 0, 0], [1403, 4, 18, 0, 0], [1403, 4, 19, 0, 0], [1403, 4, 20, 0, 0], [1403, 4, 21, 0, 0], [1403, 4, 22, 0, 1], [1403, 4, 23, 0, 0], [1403, 4, 24, 0, 0], [1403, 4, 25, 0, 2], [1403, 4, 26, 0, 2], [1403, 4, 27, 0, 0], [1403, 4, 28, 0, 0], [1403, 4, 29, 0, 1], [1403, 4, 30, 0, 0], [1403, 4, 31, 0, 0]]
    property var days_after :[[1403, 5, 1, 0, 0], [1403, 5, 2, 0, 0], [1403, 5, 3, 0, 0], [1403, 5, 4, 0, 0], [1403, 5, 5, 0, 1]]
    property var today : [1403, 4, 10, 1, 0]
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    
    Plasmoid.fullRepresentation: Calendar{
        showAgenda:true
    }

}
