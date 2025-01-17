.import './yearly_events.js' as HOLYDAYS


function loadEvents2(eventSources){
    var all_event_files = []
    for (let idx = 0; idx < eventSources.length; idx++) {
        var eventSourceName = eventSources[idx];
        all_event_files.push(HOLYDAYS[eventSourceName]);
    }
    return all_event_files
}

