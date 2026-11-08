.import "./translations/events/AncientIran_event.en.js" as Map0
.import "./translations/events/AncientIran_event.fa.js" as Map1
.import "./translations/events/Gregorian_Calendar_events.en.js" as Map2
.import "./translations/events/Gregorian_Calendar_events.fa.js" as Map3
.import "./translations/events/Islamic_events.en.js" as Map4
.import "./translations/events/Islamic_events.fa.js" as Map5
.import "./translations/events/persian_event.en.js" as Map6
.import "./translations/events/persian_event.fa.js" as Map7
.import './yearly_events.js' as HOLYDAYS

function get_events(eventSourceName){
    return HOLYDAYS[eventSourceName]
}

function loadEvents2(eventSources){
    var all_event_files = []
    for (let idx = 0; idx < eventSources.length; idx++) {
        var eventSourceName = eventSources[idx];
        all_event_files.push(HOLYDAYS[eventSourceName]);
    }
    return all_event_files
}


function loadhlolidays2(eventSources) {
    var all_event_files = [];
    for (let idx = 0; idx < eventSources.length; idx++) {
        var eventSourceName = eventSources[idx];
        var sourceEvents = HOLYDAYS[eventSourceName];

        var holidayEvents = {};
        for (var month in sourceEvents.events) {
            holidayEvents[month] = {};
            for (var day in sourceEvents.events[month]) {
                var filteredEvents = sourceEvents.events[month][day].filter(event => event[1]); // Check if is_holiday is true
                if (filteredEvents.length > 0) {
                    holidayEvents[month][day] = filteredEvents;
                }
            }
        }

        all_event_files.push({
            name: sourceEvents.name,
            type: sourceEvents.type,
            events: holidayEvents,
        });
    }
    return all_event_files;
}


// Static QML imports avoid local-file XHR permissions and make maps available immediately.
var translationMaps = {
    "AncientIran_event": {"en": Map0.translations, "fa": Map1.translations},
    "Gregorian_Calendar_events": {"en": Map2.translations, "fa": Map3.translations},
    "Islamic_events": {"en": Map4.translations, "fa": Map5.translations},
    "persian_event": {"en": Map6.translations, "fa": Map7.translations}
};
function translationMap(sourceId, language) {
    var sourceMaps = translationMaps[sourceId];
    return sourceMaps && sourceMaps[language] ? sourceMaps[language] : {};
}
function translate(sourceId, title, language) {
    var map = translationMap(sourceId, language);
    return map[title] !== undefined ? map[title] : title;
}
function supported_languages(sourceIds) {
    if (!sourceIds.length) sourceIds = Object.keys(HOLYDAYS.all_events);
    var languages = [];
    sourceIds.forEach(function(id) {
        var source = get_events(id);
        if (!source) return;
        var codes = [source.sourceLanguage || 'fa'].concat(Object.keys(source.translationFiles || {}));
        codes.forEach(function(code) { if (languages.indexOf(code) < 0) languages.push(code); });
    });
    return languages.length ? languages : ['fa'];
}
