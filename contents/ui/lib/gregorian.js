function convert_month_names_to_fa(string){
    var names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var names_replce = ["ژانویه", "فوریه", "مارس", "آوریل", "مه", "ژوئن", "جولای", "اوت", "سپتامبر", "اکتبر", "نوامبر", "دسامبر"]

    for(let i=0;i<12;i++){
        string = string.replace(names[i],names_replce[i]);
    }
    return string
}

function week_days_name(lang='en',startOfWeek=6,short=false) {
    console.log(short)
    var names = []
    if (lang == 'fa'){
        names =  ['۱شنبه', '۲شنبه', '۳شنبه', '۴شنبه', '۵شنبه', 'جمعه','شنبه']
    }
    else if (!short){
        names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday"];
    }
    else{
        names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }
    return names.slice(startOfWeek).concat(names.slice(0, startOfWeek));
}

function formatDate(date, format) {
    const gregorianMonthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    const gregorianMonthNamesShort = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    const weekDaysShort = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    const weekDaysLong = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    const tokens = {
        'YYYY': date.getFullYear(),
        'YY': date.getFullYear().toString().slice(-2),
        "MMMM": gregorianMonthNames[date.getMonth()],
        "MMM": gregorianMonthNamesShort[date.getMonth()],
        'MM': ('0' + (date.getMonth() + 1)).slice(-2),
        'M': date.getMonth() + 1,
        'ddd': weekDaysLong[date.getDay()],
        'dd': weekDaysShort[date.getDay()],
        'd': date.getDay(),
        // 'DDD': Math.ceil((date - new Date(date.getFullYear(), 0, 1)) / 86400000)+1,
        'DD': ('0' + date.getDate()).slice(-2),
        'D': date.getDate(),
        // 'ww': ('0' + Math.ceil((((date - new Date(date.getFullYear(), 0, 1)) / 86400000) + new Date(date.getFullYear(), 0, 1).getDay() + 1) / 7)).slice(-2),
        // 'w': Math.ceil((((date - new Date(date.getFullYear(), 0, 1)) / 86400000) + new Date(date.getFullYear(), 0, 1).getDay() + 1) / 7),
    };
    
    return format.replace(/YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D/g, function(match) {
        return tokens[match];
    });
}

class Gregorian {
    constructor(IN_Date=null) {
        // IN_Date = [year,month,day] or [year,month] or [year]
        if (Object.is( IN_Date, null )){
            this.date = new Date();
        }
        else{
            if (IN_Date.length > 2){
                this.date = new Date(IN_Date[0],IN_Date[1],IN_Date[2]);
            }
            else if (IN_Date.length > 1){
                this.date = new Date(IN_Date[0],IN_Date[1]);
            }
            else{
                this.date = new Date(IN_Date[0]);
            }
        }
    }
    getDate() {
        return this.date.getDate()
    }
    getDay(){
        return this.date.getDay()
    }
    getFullYear(){
        return this.date.getFullYear()
    }
    getMonth(){
        return this.date.getMonth()
    }
    setDate(Number){
        this.date.setDate(Number)
    }
    setFullYear(Number){
        this.date.setFullYear(Number)
    }
    setMonth(Number){
        this.date.setMonth(Number)
    }
    daysInMonth(){
        return new Date(this.date.getFullYear(), this.date.getMonth(), 0).getDate();
    }

    getTitle(lang='en'){
        // lang = 'en' , 'fa'
        if (lang=='en'){
            return this.format('MMMM YYYY');
        }
        else{
            return convert_month_names_to_fa(this.format('MMMM YYYY'))
        }
    }
    addMonth(){
        var tmp = new Date(this.date.getFullYear(), this.date.getMonth() + 1, this.date.getDate());
        return new Gregorian([tmp.getFullYear(),tmp.getMonth(),tmp.getDate()])
    }
    subtractMonth(){
        var tmp = new Date(this.date.getFullYear(), this.date.getMonth() - 1, this.date.getDate());
        return new Gregorian([tmp.getFullYear(),tmp.getMonth(),tmp.getDate()])
    }
    addDate(){
        var tmp = new Date(this.date.getFullYear(), this.date.getMonth(), this.date.getDate()+1);
        return new Gregorian([tmp.getFullYear(),tmp.getMonth(),tmp.getDate()])
    }
    subtractDate(){
        var tmp = new Date(this.date.getFullYear(), this.date.getMonth(), this.date.getDate()-1);
        return new Gregorian([tmp.getFullYear(),tmp.getMonth(),tmp.getDate()])
    }
    format(args=''){
        if (args==''){
            return this.date.toLocaleDateString()
        }
        else{
            return formatDate(this.date,args)
        }
    }
}