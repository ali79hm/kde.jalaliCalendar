.import './Jalali.js' as Jalali

var calendar_type = {
    'Jalali': "JA",
    'gegorian': "GE",
    'ghamari': "GA"
    }

function get_unvirsal_date(calType, IN_Date){
    // IN_Date = [year,month,day] or [year,month] or [year]
    
    if (calType==calendar_type.Jalali){
        return new Jalali.Jalali(IN_Date)
    }
}
function daysBedoreCurrentMonth(startOfWeek, first_day_of_month) {
    var ans = (first_day_of_month - startOfWeek + 7) % 7;
    return ans==0 ? 7 :ans 
}

function get_title(calType, IN_Date){
    // IN_Date = date obj
    if (calType==calendar_type.Jalali){
        return IN_Date.getTitle()
    }
}

function get_weekdays_names(calType){
    if (calType==calendar_type.Jalali){
        return Jalali.week_days_name('fa',6)// better lang='fa',startOfWeek=6
    }
}

function convertToPersianNumbers(str) {
    str = str.toString()
    const persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return str.replace(/[0-9]/g, function (m) {
        return persianNumbers[parseInt(m)];
    });
}

function get_month_holidays(calType, IN_Date){
    return [28]
}
function get_month_weekends(calType, IN_Date){
    return [7,14,21,28]
}