// Presentation only: calendar arithmetic always uses ordinary numbers.
function digits(value, language) {
    var ascii = String(value).replace(/[۰-۹]/g, c => String(c.charCodeAt(0)-1776)).replace(/[٠-٩]/g, c => String(c.charCodeAt(0)-1632));
    var alphabet = language === 'fa' ? '۰۱۲۳۴۵۶۷۸۹' : language === 'ar' ? '٠١٢٣٤٥٦٧٨٩' : '0123456789';
    return ascii.replace(/[0-9]/g, c => alphabet[Number(c)]);
}
function format(date, pattern, language, months, weekdays) {
    var now = new Date();
    var pad = n => ('0'+n).slice(-2);
    var values = {
        YYYY: date.getFullYear(), YY: String(date.getFullYear()).slice(-2),
        MMMM: months[date.getMonth()], MMM: months[date.getMonth()].slice(0,3),
        MM: pad(date.getMonth()+1), M: date.getMonth()+1,
        ddd: weekdays[date.getDay()], dd: weekdays[date.getDay()].slice(0,3), d: date.getDay(),
        DD: pad(date.getDate()), D: date.getDate(),
        HH: pad(now.getHours()), H: now.getHours(), hh: pad(now.getHours()%12 || 12), h: now.getHours()%12 || 12,
        mm: pad(now.getMinutes()), m: now.getMinutes(), ss: pad(now.getSeconds()), s: now.getSeconds()
    };
    return pattern.replace(/YYYY|YY|MMMM|MMM|MM|M|ddd|dd|d|DD|D|HH|H|hh|h|mm|m|ss|s/g, token => digits(values[token], language));
}
