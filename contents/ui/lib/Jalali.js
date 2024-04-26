var breaks = [-61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210
    , 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178
]

function Jweek_days() {
    var names =  ['شنبه', '۱شنبه', '۲شنبه', '۳شنبه', '۴شنبه', '۵شنبه', 'جمعه']
    return names
}

function Jmonth_name(jm) {
    var names = ['','فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند']
    return names[jm]
}
function Jmonth_name_en(jm) {
    var names = ['', 'Farvardin', 'Ordibehesht', 'Khordād', 'Tir', 'Mordād', 'Shahrivar', 'Mehr', 'Abān', 'Azar', 'Dey', 'Bahman', 'Esfand']
    return names[jm]
}
function convertToPersianNumbers(str) {
    str = str.toString()
    const persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return str.replace(/[0-9]/g, function (m) {
        return persianNumbers[parseInt(m)];
    });
}

function Jget_title(jy=-1,jm=0,lang='en'){
    var text = ''
    if (lang=='fa'){
        text += Jmonth_name(jm)
        if (jy!=-1){
            text = convertToPersianNumbers(jy.toString())+' '+text //+'     ' 
        }   
    }
    else{
        text += Jmonth_name_en(jm)
        if (jy!=-1){
            text = ' ' + jy.toString()
        }
    }
    return text
}