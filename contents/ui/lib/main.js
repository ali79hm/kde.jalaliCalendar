// .import './Jalali.js' as Jalali
.import './Jalali2.js' as Jalali
.import './gregorian.js' as Gregorian

var calendar_type = {
    'Jalali': "JA",
    'gegorian': "GE",
    'ghamari': "GA"
    }

function get_layout_direction(calType){
    if (calType==calendar_type.Jalali){
        return "R"
    }
    else{
        return "L"
    }
}
function get_unvirsal_date(calType, IN_Date){
    // IN_Date = [year,month,day] or [year,month] or [year]
    
    if (calType==calendar_type.Jalali){
        return new Jalali.Jalali(IN_Date)
    }
    if (calType==calendar_type.gegorian){
        return new Gregorian.Gregorian(IN_Date)
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
    if (calType==calendar_type.gegorian){
        return IN_Date.getTitle()
    }
}

function get_weekdays_names(calType){
    if (calType==calendar_type.Jalali){
        return Jalali.week_days_name('fa',6)// better lang='fa',startOfWeek=6
    }
    else if (calType==calendar_type.gegorian){
        return Gregorian.week_days_name('en',6,true)// better lang='fa',startOfWeek=6
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
    return []
}
function get_month_weekends(calType, IN_Date){
    return []
}

function convert_calendars(IN_date,InCalType,OutCalType){
    // console.log(IN_date.format(),InCalType,OutCalType)
    if (InCalType==calendar_type.Jalali){
        if (OutCalType==calendar_type.gegorian){
            return Jalali.JalaliToGregorian(IN_date)
        }
    }
    else if (InCalType==calendar_type.gegorian){
        if (OutCalType==calendar_type.Jalali){
            return Jalali.GregorianToJalali(IN_date)
        }
    } 
}

function get_tool_tip(IN_date,InCalType){
    if (InCalType==calendar_type.Jalali){
        return convertToPersianNumbers(IN_date[0].toString())+' '+IN_date[1].toString()+' '+convertToPersianNumbers(IN_date[2].toString())
    }
    else if (InCalType==calendar_type.gegorian){
        return IN_date[0].toString()+' '+IN_date[1].toString()+' '+IN_date[2].toString()
    } 
}

function getLocalNumber(instr,InCalType){
    if(InCalType==calendar_type.Jalali){
        return convertToPersianNumbers(instr)
    }
    else if (InCalType==calendar_type.gegorian){
        return instr
    }
}

function isFarsiNumbers(InCalType){
    if(InCalType==calendar_type.Jalali){
        return true
    }
    else{
        return false
    } 
}