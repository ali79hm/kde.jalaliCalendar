.import './PersianDate.js' as PersianDate

function convertToPersianNumbers(str) {
    str = str.toString()
    const persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return str.replace(/[0-9]/g, function (m) {
        return persianNumbers[parseInt(m)];
    });
}

function convert_month_names_to_en(string){
    var names_replce = ['Farvardin', 'Ordibehesht', 'Khordād', 'Tir', 'Mordād', 'Shahrivar', 'Mehr', 'Abān', 'Azar', 'Dey', 'Bahman', 'Esfand']
    var names = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند']
    for(let i=0;i<12;i++){
        string = string.replace(names[i],names_replce[i]);
    }
    return string
}

function week_days_name(lang='fa',startOfWeek=6) {
    var names = []
    if (lang == 'fa'){
        names =  ['۱شنبه', '۲شنبه', '۳شنبه', '۴شنبه', '۵شنبه', 'جمعه','شنبه']
    }
    else{
        names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday"];
    }
    return names.slice(startOfWeek).concat(names.slice(0, startOfWeek));
}

function formatDate(date, format) {

    const tokens = {
        'YYYY': date.year(),
        'YY': date.year().toString().slice(-2),
        "MMMM": date.month('jMMMM'),
        "MMM": date.month('jMMMM').slice(0,3),
        'MM': ('0' + (date.month())).slice(-2),
        'M': date.month(),
        'ddd': date.date('jdddd'),
        'dd': date.date('jdd'),
        'd': date.date('jd'),
        // 'DDD': Math.ceil((date - new Date(date.getFullYear(), 0, 1)) / 86400000)+1,
        'DD': ('0' + date.date()).slice(-2),
        'D': date.date(),
        // 'ww': ('0' + Math.ceil((((date - new Date(date.getFullYear(), 0, 1)) / 86400000) + new Date(date.getFullYear(), 0, 1).getDay() + 1) / 7)).slice(-2),
        // 'w': Math.ceil((((date - new Date(date.getFullYear(), 0, 1)) / 86400000) + new Date(date.getFullYear(), 0, 1).getDay() + 1) / 7),
        'HH':date.hour('HH'),
        'H':date.hour('H'),
        'hh':date.hour('hh'),
        'h':date.hour('h'),
        'mm':date.minute('mm'),
        'm':date.minute('m'),
        'ss':date.second('ss'),
        's':date.second('s'),

    };
    
    return format.replace(/YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s/g, function(match) {
        return tokens[match];
    });
}

class Jalali {
    constructor(IN_Date=null) {
        // IN_Date = [year,month,day] or [year,month] or [year]
        if (Object.is( IN_Date, null )){
            this.date = new PersianDate.PersianDate()
        }
        else{
            var date_string = ''
            if (IN_Date.length > 2){
                date_string = IN_Date[0].toString()+'-'+(IN_Date[1]+1).toString()+'-'+IN_Date[2].toString();
            }
            else if (IN_Date.length > 1){
                date_string = IN_Date[0].toString()+'-'+(IN_Date[1]+1).toString();
            }
            else{
                date_string = IN_Date[0].toString();
            }
            this.date = new PersianDate.PersianDate(date_string,"jalali")

        }
    }
    getDate() {
        return this.date.date()
    }
    getDay(){
        return this.date.date('jd')
    }
    getFullYear(){
        return this.date.year()
    }
    getMonth(){
        return this.date.month()-1
    }
    setDate(Number){
        this.date =  this.date.date(Number)
    }
    setFullYear(Number){
        this.date = this.date.year(Number)
    }
    setMonth(Number){
        this.date = this.date.month(Number+1)
    }
    daysInMonth(){
        return this.date.getDaysInMonth();
    }
    getTitle(lang='fa'){
        // lang = 'en' , 'fa'
        var text = ''
        if (lang=='fa'){
            text = convertToPersianNumbers(this.format("MMMM , YYYY")); 
        }
        else{
            text = convert_month_names_to_en(this.format("YYYY, MMMM"));
        }
        return text
    }
    addMonth(number=1){

        var tmp = this.date.addMonth(number)
        var tmp2 = [tmp.year(),tmp.month()-1,tmp.date()]
        this.date.subMonth(number)
        return new Jalali(tmp2)
        // return 
    }
    subtractMonth(number=1){
        var tmp = this.date.subMonth(number)
        var tmp2 = [tmp.year(),tmp.month()-1,tmp.date()]
        this.date.addMonth(number)
        return new Jalali(tmp2)
    }
    addDate(number=1){
        var tmp = this.date.addDay(number)
        var tmp2 = [tmp.year(),tmp.month()-1,tmp.date()]
        this.date.subDay(number)
        return new Jalali(tmp2)
        // return 
    }
    subtractDate(number=1){
        var tmp = this.date.subDay(number)
        var tmp2 = [tmp.year(),tmp.month()-1,tmp.date()]
        this.date.addDay(number)
        return new Jalali(tmp2)
    }
    format(args=''){
        if (args==''){
            return this.date.toString()
        }
        else{
            return formatDate(this.date,args)
        }
    }
}

function JalaliToGregorian(JalaliObj){
    var cal2 = JalaliObj.date.toDate()
    var tmp = [cal2.getFullYear(),cal2.getMonth(),cal2.getDate()]
    return tmp
}

function GregorianToJalali(DateObj){
    var cal2 = new PersianDate.PersianDate(DateObj.date)
    return [cal2.year(),cal2.month()-1,cal2.date()]
}