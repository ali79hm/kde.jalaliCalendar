.import './yearly_events.js' as HOLYDAYS


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

