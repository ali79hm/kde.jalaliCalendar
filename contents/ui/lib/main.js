.import "./Locale.js" as Locale
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

function get_layout_direction(calType, language) { return language === 'fa' || language === 'ar' ? 'R' : 'L'; }

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

function get_title(calType, date, language) { return format_date(calType, date, 'MMMM , YYYY', language); }

function get_month_names(calType, language) { var backend = calendar_library(calType); return backend.month_names(backend.resolveLanguage(language)); }

function get_month_name(calType, index, language) { return get_month_names(calType, language)[index]; }

function get_weekdays_names(calType, language) { var backend = calendar_library(calType); return backend.week_days_names(backend.resolveLanguage(language), 6, true); }

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
    if (InCalType === OutCalType) return [IN_date.getFullYear(), IN_date.getMonth(), IN_date.getDate()]
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

function get_tool_tip(date, calType, language) { return getLocalNumber(date[0]+' '+get_month_name(calType, date[1], language)+' '+date[2], calType, language); }

function get_agenda_tool_tip(date, calType, includeDay, language) { return format_date(calType, date, includeDay ? 'ddd D MMMM YYYY' : 'D MMMM YYYY', language); }

function calendar_formated_text(date, format,firstCalType,secondCalType,firstLanguage,secondLanguage,appLanguage) {
    var second_date = secondCalType === "NO" ? [date.getFullYear(),date.getMonth(),date.getDate()] : convert_calendars_light(date,firstCalType,secondCalType)
    var second_date = get_unvirsal_date(secondCalType === "NO" ? firstCalType : secondCalType,second_date)
    var dateFormated = format_date(firstCalType, date, 'YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s', firstLanguage).split('|')
    var secondDateFormated = format_date(secondCalType, second_date, 'YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s', secondLanguage).split('|')
    var timeFormated = format_date(firstCalType, date, 'YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s', appLanguage || 'en').split('|')
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
        return secondCalType === 'NO' && match[0] === 'S' ? '' : tokens[match];
    });
    mystr = mystr.split(' ')
    // var mystr2 = mystr
    var mystr2 = ''
    for (let i = 0; i < mystr.length; i++) {
        if (mystr[i][0] == '*'){
            mystr2 +='<strong style="font-size: 16px;">&#x2068;'+mystr[i].replace(/\*/g, "")+'&#x2069; </strong>'
            // is_bold = !is_bold
            // console.log(is_bold)
        }
        else{
            mystr2 +='<span style="font-size: 14px;">&#x2068;'+mystr[i]+'&#x2069; </span>'
        }
    }
    return '<p dir="'+(appLanguage === 'fa' ? 'rtl' : 'ltr')+'">'+mystr2+'</p>'
    // return '<p dir="ltr" style="color:red;">'+mystr2+'</p>'
}

function getLocalNumber(value, calType, language) { return Locale.digits(value, resolve_language(calType, language)); }

function isFarsiNumbers(calType, language) { return resolve_language(calType, language) !== 'en'; }

function get_month_events(InCalType,IN_Date,eventSources,eventLanguage){

    const month_events = {};
    for (let i = 1; i <= 31; i++) {
        month_events[i] = [];
    }

    for (let idx = 0; idx < eventSources.length; idx++) { // loop through all event sources
        var sourceId = eventSources[idx]
        var eventSource = EventManager.get_events(sourceId)
        if (!eventSource) continue

        // must make new object from IN_Date so changes on it doesn not affect IN_Date outside of function
        var currntDate = get_unvirsal_date(InCalType,[IN_Date.getFullYear(),IN_Date.getMonth(),IN_Date.getDate()])
        currntDate.setDate(1)
        var days_in_month = currntDate.daysInMonth()
        if (calendar_type[eventSource.type] != InCalType){
            currntDate = convert_calendars_light(currntDate,InCalType,calendar_type[eventSource.type]);
            currntDate = get_unvirsal_date(calendar_type[eventSource.type],currntDate);
        }
 
        var month_number_holder = currntDate.getMonth()
        var month_number_irregular_events = {};
        for (let i = 1; i <= 31; i++) {month_number_irregular_events[i] = [];}
        if (eventSource.irregular_events){
            month_number_irregular_events = get_month_irregular_events(currntDate,eventSource.irregular_events[currntDate.getMonth()])
        }
        for (let idx = 1; idx <= days_in_month; idx++) {
            var tmpevents = eventSource.events[currntDate.getMonth()][currntDate.getDate()] || []
            for (let key in tmpevents) {
                var text = EventManager.translate(sourceId, tmpevents[key][0], eventLanguage)
                var is_holiday = tmpevents[key][1]
                var link = ''
                var event_source = EventManager.translate(sourceId, eventSource.name, eventLanguage)
                var event = {'text':text,'is_holiday':is_holiday,'event_source':event_source,'link':link}
                month_events[idx].push(event);
            }
            
            if (eventSource.irregular_events){
                if (month_number_holder != currntDate.getMonth()){
                    month_number_holder = currntDate.getMonth()
                    month_number_irregular_events = get_month_irregular_events(currntDate,eventSource.irregular_events[currntDate.getMonth()])
                }
                for (let irregular_event of month_number_irregular_events[currntDate.getDate()]){
                    var text = EventManager.translate(sourceId, irregular_event[0], eventLanguage)
                    var is_holiday = irregular_event[1]
                    var link = ''
                    var event_source = EventManager.translate(sourceId, eventSource.name, eventLanguage)
                    var event = {'text':text,'is_holiday':is_holiday,'event_source':event_source,'link':link}
                    month_events[idx].push(event);
                }
            }
            
			currntDate = currntDate.addDate(1)
        }
    }

    return month_events
}

function get_month_irregular_events(date,irregular_events){
    var days_in_month = date.daysInMonth()
    const events = {};
    for (let i = 1; i <= 31; i++) {
        events[i] = [];
    }

    for (let idx in irregular_events) {
        var text = irregular_events[idx]['name']
        var event_type = irregular_events[idx]['type']
        var is_holiday = irregular_events[idx]['holiday']
        if (event_type == 'end_of_month'){
            events[days_in_month].push([text,is_holiday]) 
        }
        else if (event_type == 'nth_weekday_of_month'){
            var weekday = irregular_events[idx]['weekday']
            var diff = date.getDay()+1-weekday
            var tmp_date_number = date.getDate()-35-diff
            var weekday_dates = []
            for (let i = tmp_date_number; i <= 35; i+=7) {
                if (i <= days_in_month && i > 0){
                    weekday_dates.push(i)
                }
            }
            var nth = irregular_events[idx]['nth']
            if (nth == -1){
                nth = weekday_dates.length-1
                events[weekday_dates[nth]].push([text,is_holiday])
            } 
            else if (nth <= weekday_dates.length){
                events[weekday_dates[nth-1]].push([text,is_holiday])
            }
        }
    }
    return events
}

// Convert note markup to plain text without rendering HTML or loading resources.
function plain_event_note(value) {
    var text = String(value || '').replace(/\r\n?/g, '\n');
    text = text.replace(/<!--[^]*?-->/g, '')
        .replace(/<(script|style)\b[^>]*>[^]*?<\/\1\s*>/gi, '')
        .replace(/<br\b[^>]*\/?\s*>/gi, '\n')
        .replace(/<\/(?:p|div|h[1-6]|li|blockquote|pre|tr|ul|ol)\s*>/gi, '\n')
        .replace(/<(?:p|div|h[1-6]|li|blockquote|pre|tr|ul|ol)\b[^>]*>/gi, function(match, offset, source) {
            return offset > 0 && source.charAt(offset - 1) !== '\n' ? '\n' : '';
        })
        .replace(/<\/?[a-z][^>]*>/gi, '');
    var entities = {amp: '&', lt: '<', gt: '>', quot: '"', apos: "'", nbsp: ' ',
        bull: '•', ndash: '–', mdash: '—', hellip: '…', copy: '©', reg: '®'};
    text = text.replace(/&(#x[0-9a-f]+|#[0-9]+|[a-z]+);/gi, function(match, entity) {
        if (entity.charAt(0) !== '#') return entities[entity] !== undefined ? entities[entity] : match;
        var number = entity.charAt(1).toLowerCase() === 'x' ? parseInt(entity.slice(2), 16) : parseInt(entity.slice(1), 10);
        return number > 0 && number <= 0x10ffff && !(number >= 0xd800 && number <= 0xdfff)
            ? String.fromCodePoint(number) : match;
    });
    return text.replace(/[ \t]+\n/g, '\n').replace(/\n{3,}/g, '\n\n').trim();
}

function google_event_details(ev) {
    var start = ev.start || {}, end = ev.end || {};
    var allDay = !!start.date && !start.dateTime;
    function parse(value, dateOnly) {
        if (!value) return null;
        var parts = value.split('-');
        var date = dateOnly ? new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2])) : new Date(value);
        return isNaN(date.getTime()) ? null : date;
    }
    function dateText(date) {
        if (!date) return '';
        var jalali = convert_calendars_light(date, 'GE', 'JA');
        return jalali[0] + '/' + (jalali[1] + 1) + '/' + jalali[2] + ' (Jalali) / '
            + date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate() + ' (Gregorian)';
    }
    function timeText(date) {
        return date ? ('0' + date.getHours()).slice(-2) + ':' + ('0' + date.getMinutes()).slice(-2) : '';
    }
    var first = parse(start.dateTime || start.date, allDay);
    var last = parse(end.dateTime || end.date, !!end.date && !end.dateTime);
    if (allDay && last) last.setDate(last.getDate() - 1);
    var date = dateText(first);
    if (last && (!first || first.toDateString() !== last.toDateString()))
        date += (date ? ' – ' : '') + dateText(last);
    var meeting = ev.hangoutLink || '';
    var entries = (ev.conferenceData || {}).entryPoints || [];
    for (var i = 0; !meeting && i < entries.length; i++) {
        if (entries[i].entryPointType === 'video') meeting = entries[i].uri || '';
    }
    return {
        date: date, allDay: allDay,
        startTime: allDay ? '' : timeText(first), endTime: allDay ? '' : timeText(last),
        location: ev.location || '', description: ev.description || '',
        recurring: !!ev.recurringEventId || !!(ev.recurrence && ev.recurrence.length),
        source: 'Google Calendar', meetingLink: meeting
    };
}

function get_month_google_events(InCalType, IN_Date, fetchMonth){
    
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

    var request = fetchMonth ? fetchMonth(start, end)
        : GoogleEventManager.fetchAllEventsFromConfig("primary", {timeMin: start, timeMax: end});
    return request.then(function(items){
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
                link: ev.htmlLink || "",
                details: google_event_details(ev)
            });
        }
        return out;
    }).catch(function(err){
        console.log("Calendar fetch error:", err.message);
        throw err; // Let the agenda display the disconnected status.
    });
}

function loadEvents2(eventSources){
    return EventManager.loadEvents2(eventSources)
}

function loadhlolidays2(eventSources){
    return EventManager.loadhlolidays2(eventSources)
}
function calendar_library(type) { return type === 'JA' ? Jalali : type === 'GA' ? Hijri : Gregorian; }
function supported_languages(type) { return calendar_library(type).supportedLanguages; }
function resolve_language(type, language) { return calendar_library(type).resolveLanguage(language); }
function format_date(type, date, pattern, language) { return calendar_library(type).localizedFormat(date, pattern, language); }
