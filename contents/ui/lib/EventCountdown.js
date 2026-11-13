.pragma library
.import "ReminderLogic.js" as Logic
.import "AppText.js" as Text

function text(events, now, language) {
    var next = Infinity;
    (events || []).forEach(function(event) {
        if (event.status === 'cancelled' || (event.attendees || []).some(function(a) {
            return a.self && a.responseStatus === 'declined';
        })) return;
        var start = Logic.startTime(event);
        var end = (event.end || {}).dateTime ? new Date(event.end.dateTime).getTime() : start + Logic.minute;
        if ((event.end || {}).date) {
            var parts = event.end.date.split('-');
            end = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2])).getTime();
        }
        if (start <= now && end > now) next = Math.min(next, now);
        else if (start >= now) next = Math.min(next, start);
    });
    if (!isFinite(next)) return Text.tr(language, 'No upcoming events');
    return remainingText(next, now, language);
}

// Format the event that triggered this notification, regardless of other events.
function remainingText(start, now, language) {
    var remaining = start - now;
    if (remaining < Logic.minute) return Text.tr(language, 'Now');
    var unit = remaining >= 7 * Logic.day ? 'week' : remaining >= Logic.day ? 'day'
        : remaining >= 60 * Logic.minute ? 'hour' : 'min';
    var size = unit === 'week' ? 7 * Logic.day : unit === 'day' ? Logic.day
        : unit === 'hour' ? 60 * Logic.minute : Logic.minute;
    var count = Math.floor(remaining / size);
    return Text.tr(language, '%1 ' + unit + (count > 1 && unit !== 'min' ? 's' : '') + ' to event', count);
}
