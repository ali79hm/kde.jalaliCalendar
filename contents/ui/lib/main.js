// .import './Jalali.js' as Jalali
.import './Jalali2.js' as Jalali
.import './gregorian.js' as Gregorian
.import "./HijriInterface.js" as Hijri
.import "./EventManager.js" as EventManager
.import "./GoogleEventManager.js" as GoogleEventManager

var calendar_type = {
    'Jalali': "JA",
    'gegorian': "GE",
    'hijri': "GA"
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
    if (calType==calendar_type.hijri){
        return new Hijri.Hijri(IN_Date)
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
    if (calType==calendar_type.hijri){
        return IN_Date.getTitle()
    }
}

function get_month_names(calType){
    // IN_Date = date obj
    if (calType==calendar_type.Jalali){
        return Jalali.month_names('fa')
    }
    if (calType==calendar_type.gegorian){
        return Gregorian.month_names('en')
    }
    if (calType==calendar_type.hijri){
        return Hijri.month_names('fa')
    }
}

function get_month_name(calType,index){
    // IN_Date = date obj
    if (calType==calendar_type.Jalali){
        return Jalali.month_names('fa')[index]
    }
    if (calType==calendar_type.gegorian){
        return Gregorian.month_names('en')[index]
    }
    if (calType==calendar_type.hijri){
        return Hijri.month_names('fa')[index]
    }
}

function get_weekdays_names(calType){
    if (calType==calendar_type.Jalali){
        return Jalali.week_days_names('fa',6)// better lang='fa',startOfWeek=6
    }
    else if (calType==calendar_type.gegorian){
        return Gregorian.week_days_names('en',6,true)// better lang='fa',startOfWeek=6
    }
    else if (calType==calendar_type.hijri){
        return Hijri.week_days_names('fa',6)// better lang='fa',startOfWeek=6
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

function convert_calendars_light(IN_date,InCalType,OutCalType){
    // console.log(IN_date.format(),InCalType,OutCalType)
    if (InCalType==calendar_type.Jalali){
        if (OutCalType==calendar_type.gegorian){
            return Jalali.JalaliToGregorian(IN_date)
        }
        if (OutCalType==calendar_type.hijri){
            var tmp = Jalali.JalaliToGregorian(IN_date)
            return Hijri.GregorianToHijri(new Date(tmp[0],tmp[1],tmp[2]))
            
        }
    }
    else if (InCalType==calendar_type.gegorian){
        if (OutCalType==calendar_type.Jalali){
            return Jalali.GregorianToJalali(IN_date)
        }
        if (OutCalType==calendar_type.hijri){
            return Hijri.GregorianToHijri(IN_date)
        }
    }
    else if (InCalType==calendar_type.hijri){
        if (OutCalType==calendar_type.Jalali){
            var tmp = Hijri.HijriToGregorian(IN_date)
            return Jalali.GregorianToJalali(new Date(tmp[0],tmp[1],tmp[2]))
        }
        if (OutCalType==calendar_type.gegorian){
            return Hijri.HijriToGregorian(IN_date)
        }
    }
}

function get_tool_tip(IN_date,InCalType){
    if (InCalType==calendar_type.Jalali || InCalType==calendar_type.hijri){
        return convertToPersianNumbers(IN_date[0].toString())+' '+IN_date[1].toString()+' '+convertToPersianNumbers(IN_date[2].toString())
    }
    else if (InCalType==calendar_type.gegorian){
        return IN_date[0].toString()+' '+IN_date[1].toString()+' '+IN_date[2].toString()
    }
}
function get_agenda_tool_tip(date,InCalType,isReturnDay=false){
    
    var myformat = ''
    if (isReturnDay){
        myformat = 'ddd D MMMM YYYY'
    }
    else{
        myformat = 'D MMMM YYYY'
    }
    if (InCalType==calendar_type.Jalali || InCalType==calendar_type.hijri){
        return convertToPersianNumbers(date.format(myformat))
    }
    else if (InCalType==calendar_type.gegorian){
        return date.format(myformat)
    } 
    // IN_date[0].toString()+' '+IN_date[1].toString()+' '+convertToPersianNumbers(IN_date[2].toString()
    
    // if (InCalType==calendar_type.Jalali){
    //     return convertToPersianNumbers(IN_date[0].toString())+' '+IN_date[1].toString()+' '+convertToPersianNumbers(IN_date[2].toString())
    // }
    // else if (InCalType==calendar_type.gegorian){
    //     return IN_date[0].toString()+' '+IN_date[1].toString()+' '+IN_date[2].toString()
    // } 
    
}

function calendar_formated_text(date, format,firstCalType,secondCalType) {
    var second_date = convert_calendars_light(date,firstCalType,secondCalType)
    var second_date = get_unvirsal_date(secondCalType,second_date)
    var dateFormated = getLocalNumber(date.format('YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s'),firstCalType).split('|')
    var secondDateFormated = getLocalNumber(second_date.format('YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s'),secondCalType).split('|')
    var timeFormated = date.format('YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s').split('|')
    const tokens = {
        'SYYYY': secondDateFormated[0],
        'YYYY': dateFormated[0],
        'SYY': secondDateFormated[1],
        'YY': dateFormated[1],
        "SMMMM": secondDateFormated[2],
        "MMMM": dateFormated[2],
        "SMMM": secondDateFormated[3],
        "MMM": dateFormated[3],
        'SMM': secondDateFormated[4],
        'MM': dateFormated[4],
        'SM': secondDateFormated[5],
        'M': dateFormated[5],
        'Sddd': secondDateFormated[6],
        'ddd': dateFormated[6],
        'Sdd': secondDateFormated[7],
        'dd': dateFormated[7],
        'Sd': secondDateFormated[8],
        'd': dateFormated[8],
        'SDD': secondDateFormated[9],
        'DD': dateFormated[9],
        'SD': secondDateFormated[10],
        'D': dateFormated[10],
        'HH':timeFormated[11],
        'H':timeFormated[12],
        'hh':timeFormated[13],
        'h':timeFormated[14],
        'mm':timeFormated[15],
        'm':timeFormated[16],
        'ss':timeFormated[17],
        's':timeFormated[18],
    };
    
    var mystr =  format.replace(/SYYYY|YYYY|SYY|YY|SMMMM|MMMM|SMMM|MMM|SMM|MM|SM|M|Sddd|ddd|Sdd|dd|Sd|d|SDD|DD|SD|D|HH|H|hh|h|mm|m|ss|s/g, function(match) {
        return tokens[match];
    });
    mystr = mystr.split(' ')
    // var mystr2 = mystr
    var mystr2 = ''
    for (let i = 0; i < mystr.length; i++) {
        if (mystr[i][0] == '*'){
            mystr2 +='<strong style="font-size: 16px;">&#x2066;'+mystr[i].replace(/\*/g, "")+'&#x2069; </strong>'
            // is_bold = !is_bold
            // console.log(is_bold)
        }
        else{
            mystr2 +='<span style="font-size: 14px;">&#x2066;'+mystr[i]+'&#x2069; </span>'
        }
    }
    return '<p dir="ltr">'+mystr2+'</p>'
    // return '<p dir="ltr" style="color:red;">'+mystr2+'</p>'
}

function getLocalNumber(instr,InCalType){
    if(InCalType==calendar_type.Jalali || InCalType==calendar_type.hijri){
        return convertToPersianNumbers(instr)
    }
    else if (InCalType==calendar_type.gegorian){
        return instr
    }
}

function isFarsiNumbers(InCalType){
    if(InCalType==calendar_type.Jalali || InCalType==calendar_type.hijri){
        return true
    }
    else{
        return false
    } 
}

function get_month_events(InCalType,IN_Date,eventSources){

    const month_events = {};
    for (let i = 1; i <= 31; i++) {
        month_events[i] = [];
    }

    for (let idx = 0; idx < eventSources.length; idx++) { // loop through all event sources
        var eventSource = EventManager.get_events(eventSources[idx])

        // must make new object from IN_Date so changes on it doesn not affect IN_Date outside of function
        var currntDate = get_unvirsal_date(InCalType,[IN_Date.getFullYear(),IN_Date.getMonth(),IN_Date.getDate()])
        currntDate.setDate(1)
        var days_in_month = currntDate.daysInMonth()
        if (calendar_type[eventSource.type] != InCalType){
            currntDate = convert_calendars_light(currntDate,InCalType,calendar_type[eventSource.type]);
            currntDate = get_unvirsal_date(calendar_type[eventSource.type],currntDate);
        }

        for (let idx = 1; idx <= days_in_month; idx++) {
            var tmpevents = eventSource.events[currntDate.getMonth()][currntDate.getDate()] || []
            for (let key in tmpevents) {
                var text = tmpevents[key][0]
                var is_holiday = tmpevents[key][1]
                var link = ''
                var event_source = eventSource.name
                var event = {'text':text,'is_holiday':is_holiday,'event_source':event_source,'link':link}
                month_events[idx].push(event);
            }
			currntDate = currntDate.addDate(1)
        }
    }

    return month_events
}

function get_month_google_events(InCalType, IN_Date){
    
    // need to convert
    var currntDate = get_unvirsal_date(InCalType,[IN_Date.getFullYear(),IN_Date.getMonth(),1])
    var IN_Date_converted = convert_calendars_light(currntDate,InCalType,calendar_type.gegorian)
    var start = new Date(IN_Date_converted[0],IN_Date_converted[1], IN_Date_converted[2]);
    currntDate = currntDate.addMonth(1)
    var IN_Date_converted = convert_calendars_light(currntDate,InCalType,calendar_type.gegorian)
    var end = new Date(IN_Date_converted[0],IN_Date_converted[1], IN_Date_converted[2]);
    var diffMs = end - start; // milliseconds
    var daysInMonth = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    var out = {}; for (var d = 1; d <= daysInMonth; d++) out[d] = [];

    return GoogleEventManager.fetchAllEventsFromConfig("primary", {
        timeMin: start,
        timeMax: end
    }).then(function(items){
        for (var i = 0; i < items.length; i++){
            var ev = items[i];
            var s  = ev._start || (ev._startISO ? new Date(ev._startISO) : null);
            if (!s) continue;

            var today_date = get_unvirsal_date(calendar_type.gegorian,[s.getFullYear(),s.getMonth(),s.getDate()])
            var IN_Date_converted = convert_calendars_light(today_date,calendar_type.gegorian,InCalType)
            var day = IN_Date_converted[2];

            if (day < 1 || day > daysInMonth) continue;
            
            out[day].push({
                text: ev.summary || "(no title)",
                is_holiday: false,
                event_source: "Google Calendar",
                link: ev.htmlLink || ""
            });
        }
        return out;
    }).catch(function(err){
        console.log("Calendar fetch error:", err.message);
        return out; // return empty map on error
    });
}

function loadEvents2(eventSources){
    return EventManager.loadEvents2(eventSources)
}

function loadhlolidays2(eventSources){
    return EventManager.loadhlolidays2(eventSources)
}