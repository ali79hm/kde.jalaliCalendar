.import './persian-date.js' as PersianDate

function get_day_of_week_number(Jnumber){
    //map jalali day of week number to system day of week number
    // weekday = [  "Sunday"  , "Monday"   ,  "Tuesday" ,   "Wednesday"  ,  "Thursday" , "Friday","Saturday"];
    //           [       0    ,       1    ,      2     ,        3       ,      4      ,    5    ,    6     ];
    // weekday = ["Yekshanbeh", "Doshanbeh", "Seshanbeh", "Chaharshanbeh", "Panjshanbeh", "Jomeh", "Shanbeh"];
    //           [     2      ,     3             4             5                 6           7         1   ];
    const translator = {1:6,2:0,3:1,4:2,5:3,6:4,7:5}
    return translator[Jnumber]
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

class Jalali {
    constructor(IN_Date=null) {
        // IN_Date = [year,month,day] or [year,month] or [year]
        if (Object.is( IN_Date, null )){
            this.date = new persianDate(new Date())
        }
        else{
            IN_Date[1] = IN_Date[1]+1
            this.date = new persianDate(IN_Date)
        }
    }
    getDate() {
        return this.date.date()
    }
    getDay(){
        return get_day_of_week_number(this.date.days())
    }
    getFullYear(){
        return this.date.year()
    }
    getMonth(){
        return this.date.month()-1
    }
    setDate(Number){
        this.date =  this.date.dates(Number)
    }
    setFullYear(Number){
        this.date = this.date.year(Number)
    }
    setMonth(Number){
        this.date = this.date.month(Number+1)
    }
    daysInMonth(){
        return this.date.daysInMonth();
    }
    getTitle(lang='fa'){
        // lang = 'en' , 'fa'
        var text = ''
        if (lang=='fa'){
            text = this.date.format("MMMM , YYYY"); 
        }
        else{
            text = convert_month_names_to_en(this.date.format("YYYY, MMMM"));
        }
        return text
    }
    addMonth(){
        var tmp = this.date.add('months', 1)
        return new Jalali([tmp.year(),tmp.month()-1,tmp.date()])
        // return 
    }
    subtractMonth(){
        var tmp = this.date.subtract('months', 1)
        return new Jalali([tmp.year(),tmp.month()-1,tmp.date()])
    }
    format(args=''){
        if (args==''){
            return this.date.format()
        }
        else{
            return this.date.format(args)
        }
    }
}