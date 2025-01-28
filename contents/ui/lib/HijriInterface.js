.import './HijriDateBackend.js' as HijriDate

function convertToPersianNumbers(str) {
    str = str.toString()
    const persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return str.replace(/[0-9]/g, function (m) {
        return persianNumbers[parseInt(m)];
    });
}

function convert_month_names_to_en(string){
    var names_replce = ['Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Ula', 'Jumada al-Akhirah', 'Rajab', 'Shaban', 'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'];
    var names = ["محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"];
    for(let i=0;i<12;i++){
        string = string.replace(names[i],names_replce[i]);
    }
    return string
}

function month_names(lang='ar'){
    var names = []
    if (lang == 'ar' || lang == 'fa'){
        names = ["محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"];
    }
    else{
        names = ['Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Ula', 'Jumada al-Akhirah', 'Rajab', 'Shaban', 'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'];
    }
    return names
}

function week_days_names(lang='ar',startOfWeek=6) {
    var names = []
    if (lang == 'ar'){
        names = ["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة","السبت"]
    }
    else if (lang == 'fa'){
        names =  ['۱شنبه', '۲شنبه', '۳شنبه', '۴شنبه', '۵شنبه', 'جمعه','شنبه']
    }
    else{
        names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday"];
    }
    return names.slice(startOfWeek).concat(names.slice(0, startOfWeek));
}

function formatDate(date, format,day_number) {
    const MonthNames = ["محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"];
    const short_hijri_months = ["مح", "صف", "رب1", "رب2", "جم1", "جم2", "رجب", "شعب", "رمض", "شوا", "ذق", "ذح"]
    const weekDaysShort = ["أحد", "اثن", "ثلا", "أرب", "خمي", "جمع","سبت"]
    const weekDaysLong = ["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"]

    // const tmpGeDate = HijriDate.toGregorian(date['year'],date['month'],date['day'])
    // const GEdate = new Date(tmpGeDate['year'],tmpGeDate['month']-1,tmpGeDate['day']); 
    // const tmpStartGeDate = HijriDate.toGregorian(date['year'],1,1)
    // const StartGEdate = new Date(tmpStartGeDate['year'],tmpStartGeDate['month']-1,tmpStartGeDate['day']); 

    var timeDate = new Date()

    const tokens = {
        'YYYY': date['year'].toString(),
        'YY': date['year'].toString().slice(-2),
       
        "MMMM":  MonthNames[date['month']-1],
        "MMM": short_hijri_months[date['month']-1],
        'MM': ('0' + (date['month'])).slice(-2),
        'M': date['month'],
        'ddd': weekDaysLong[day_number],
        'dd': weekDaysShort[day_number],
        'd': day_number,
        'DD': ('0' + date['day']).slice(-2),
        'D': date['day'],
        // 'ww': ('0' + Math.ceil(((((GEdate - StartGEdate) / 86400000) + day_number + 1) / 7))).slice(-2),
        // 'w': Math.ceil(((((GEdate - StartGEdate) / 86400000) + day_number + 1) / 7)),
        'HH': ('0' + (timeDate.getHours())).slice(-2),
        'H': timeDate.getHours(),
        'hh':('0' + (timeDate.getHours() % 12  || 12)).slice(-2),
        'h':timeDate.getHours()% 12  || 12,
        'mm': ('0' + (timeDate.getMinutes())).slice(-2),
        'm':timeDate.getMinutes(),
        'ss':('0' + (timeDate.getSeconds())).slice(-2),
        's':timeDate.getSeconds(),
    };
    
    return format.replace(/YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s/g, function(match) {
        return tokens[match];
    });
}

class Hijri {
    constructor(IN_Date=null) {
        // IN_Date = [year,month,day] or [year,month] or [year]
        if (Object.is( IN_Date, null )){
            var tmpDate = new Date();
            this.date = HijriDate.fromGregorian(tmpDate.getFullYear(),tmpDate.getMonth()+1,tmpDate.getDate())
        }
        else{
            // var date_string = ''
            var year = 0;
            var month = 1;
            var day = 1;
            if (IN_Date.length > 2){
                year = IN_Date[0]
                month = IN_Date[1]+1
                day = IN_Date[2]
            }
            else if (IN_Date.length > 1){
                year = IN_Date[0]
                month = IN_Date[1]+1
            }
            else{
                year = IN_Date[0]
            }
            this.date = {"year":year,"month":month,"day":day}
        }
    }
    getDate() {
        return this.date['day']
    }
    getDay(){
        var tmpGeDate = HijriDate.toGregorian(this.date['year'],this.date['month'],this.date['day'])
        var GEdate = new Date(tmpGeDate['year'],tmpGeDate['month']-1,tmpGeDate['day']); 
        return GEdate.getDay()
    }
    getFullYear(){
        return this.date['year']
    }
    getMonth(){
        return this.date['month']-1
    }
    setDate(Number){
        this.date['day'] = Number
    }
    setFullYear(Number){
        this.date['year'] = Number
    }
    setMonth(Number){
        this.date['month'] = Number+1
    }
    daysInMonth(){
        return HijriDate.getDaysInMonth(this.date['year'],this.date['month'])
    }
    getTitle(lang='ar'){
        // lang = 'en' , 'fa' , 'ar'
        var text = ''
        if (lang=='fa' || lang=='ar'){
            text = convertToPersianNumbers(this.format("MMMM , YYYY")); 
        }
        else{
            text = convert_month_names_to_en(this.format("YYYY, MMMM"));
        }
        return text
    }
    addMonth(number=1){
        var month = this.date['month'];
        var year = this.date['year'];
        month = month + number
        if( month>12){
            year = year + Math.floor(month / 12)
            month = month - Math.floor(month / 12)*12
        }
        return new Hijri([year,month-1,date['day']])
        // return 
    }
    subtractMonth(number=1){
        var month = this.date['month'];
        var year = this.date['year'];
        month = month - number
        if (month <= 0) {
            year = year + Math.floor((month - 1) / 12); 
            month = 12 + (month % 12);
            if (month === 0) month = 12;
        }
        return new Hijri([year,month-1,date['day']])
    }
    addDate(number=1){
        var day = this.date['day'];
        var month = this.date['month'];
        var year = this.date['year'];
        day = day + number
        var days_in_month = HijriDate.getDaysInMonth(year,month)
        while(day>days_in_month){
            day = day-days_in_month
            if (day == 0) day = days_in_month;
            month = month +1
            if( month>12){
                year = year + Math.floor(month / 12)
                month = month - Math.floor(month / 12)*12
            }
            days_in_month = HijriDate.getDaysInMonth(year,month)
        }
        return new Hijri([year,month-1,day])

    }
    subtractDate(number=1){
        var day = this.date['day'];
        var month = this.date['month'];
        var year = this.date['year'];
        day = day - number
        while (day<1){
            month = month - 1
            var days_in_month = HijriDate.getDaysInMonth(year,month)
            day = day + days_in_month
            if (month <= 0) {
                year = year + Math.floor((month - 1) / 12); 
                month = 12 + (month % 12);
                if (month === 0) month = 12;
            }
        }
        return new Hijri([year,month-1,day])
    }
    format(args=''){
        if (args==''){
            return formatDate(this.date,'YYYY-MMMM-DD',this.getDay())
        }
        else{
            return formatDate(this.date,args,this.getDay())
        }
    }
}

function HijriToGregorian(HijriObj){
    var tmp = HijriDate.toGregorian(HijriObj.getFullYear(),HijriObj.getMonth(),HijriObj.getDate())
    return [tmp['year'],tmp['month']-1,tmp['day']]
}

function GregorianToHijri(DateObj){
    var tmp = HijriDate.fromGregorian(DateObj.getFullYear(),DateObj.getMonth()+1,DateObj.getDate())
    return [tmp['year'],tmp['month']-1,tmp['day']]
}
