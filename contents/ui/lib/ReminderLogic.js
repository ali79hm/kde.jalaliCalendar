.pragma library

var minute = 60000;
var day = 86400000;
var grace = 15 * minute;
var horizon = 30 * day;
// Google permits alerts up to four weeks before an event. Fetch that far
// beyond the reminder window, so an early alert cannot fall outside it.
var maxLead = 28 * day;

function eventKey(event) { return String(event.id); }

function startTime(event) {
    if (typeof event._reminderStart === 'number') return event._reminderStart;
    var start = event.start || {};
    if (start.dateTime) return new Date(start.dateTime).getTime();
    // Date-only values are calendar dates, not UTC timestamps.
    if (start.date) {
        var parts = start.date.split('-');
        return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2])).getTime();
    }
    return NaN;
}

function meetingLink(event) {
    if (event.hangoutLink) return event.hangoutLink;
    var entries = (event.conferenceData || {}).entryPoints || [];
    for (var i = 0; i < entries.length; ++i)
        if (entries[i].entryPointType === 'video') return entries[i].uri || '';
    return '';
}

function alerts(events, defaults, calendarId, now, delivered) {
    var result = [], seen = {};
    for (var i = 0; i < events.length; ++i) {
        var event = events[i];
        if (!event.id || event.status === 'cancelled') continue;
        var declined = (event.attendees || []).some(function(a) {
            return a.self && a.responseStatus === 'declined';
        });
        if (declined) continue;
        var start = startTime(event);
        if (!isFinite(start)) continue;
        var reminders = event.reminders || {};
        var rules = reminders.useDefault ? defaults : (reminders.overrides || []);
        for (var j = 0; j < rules.length; ++j) {
            var rule = rules[j], minutes = Number(rule.minutes);
            if (rule.method !== 'popup' || !isFinite(minutes) || minutes < 0 || minutes > 40320) continue;
            var due = start - minutes * minute;
            var key = JSON.stringify([calendarId, event.id, start, minutes]);
            if (due < now - grace || due > now + horizon || delivered[key] || seen[key]) continue;
            seen[key] = true;
            result.push({key: key, due: due, start: start,
                end: (event.end || {}).dateTime ? new Date(event.end.dateTime).getTime() : null,
                title: event.summary || '(no title)', link: event.htmlLink || '',
                meeting: meetingLink(event), allDay: !!(event.start || {}).date});
        }
    }
    result.sort(function(a, b) { return a.due - b.due; });
    return result;
}

function pruneDelivered(delivered, now) {
    var clean = {};
    Object.keys(delivered).forEach(function(key) {
        if (typeof delivered[key] === 'number' && delivered[key] >= now - 7 * day
                && delivered[key] <= now + 7 * day) clean[key] = delivered[key];
    });
    return clean;
}

// Event objects are interned once; month caches and the background window
// retain only IDs. Rebuilding the live set drops objects nobody needs.
function createStore() { return {events: {}, months: [], upcoming: []}; }
function ingest(store, events) {
    var ids = [];
    events.forEach(function(event) {
        if (!event.id || event.status === 'cancelled') return;
        var key = eventKey(event);
        store.events[key] = event;
        ids.push(key);
    });
    return ids;
}
function collect(store) {
    var keep = {}, live = store.upcoming.slice();
    store.months.forEach(function(month) { live = live.concat(month.ids); });
    live.forEach(function(id) { if (store.events[id]) keep[id] = store.events[id]; });
    store.events = keep;
}
function putMonth(store, key, events, now) {
    store.months = store.months.filter(function(month) { return month.key !== key; });
    store.months.push({key: key, ids: ingest(store, events), fetched: now});
    while (store.months.length > 3) store.months.shift();
    collect(store);
}
function getMonth(store, key, now) {
    var index = store.months.findIndex(function(month) { return month.key === key; });
    if (index < 0 || now - store.months[index].fetched >= 15 * minute) return null;
    var month = store.months.splice(index, 1)[0];
    store.months.push(month);
    return month.ids.map(function(id) { return store.events[id]; });
}
function setUpcoming(store, events) {
    store.upcoming = ingest(store, events);
    // Other ranges may contain changed/deleted events: revalidate on next use.
    store.months.forEach(function(month) { month.fetched = 0; });
    collect(store);
}
function pruneUpcoming(store, now) {
    store.upcoming = store.upcoming.filter(function(id) {
        var start = startTime(store.events[id]);
        return start >= now - grace && start <= now + horizon + maxLead;
    });
    collect(store);
}
