import QtQuick 2.15
import org.kde.plasma.plasma5support 2.0 as Plasma5Support

Item {
    id: resolver
    property var requests: ({})
    function quote(value) { return "'" + value.replace(/'/g, "'\\''") + "'" }
    function resolve(events, zone) {
        var dates = []
        events.forEach(function(event) {
            var date = (event.start || {}).date
            if (date && dates.indexOf(date) < 0) dates.push(date)
        })
        if (!dates.length) return Promise.resolve(events)
        if (!zone) return Promise.reject(new Error('Google Calendar timezone is missing'))
        var path = decodeURIComponent(Qt.resolvedUrl('lib/reminder_timezones.py').toString().replace(/^file:\/\//, ''))
        var command = 'python3 ' + quote(path) + ' ' + quote(Qt.btoa(JSON.stringify({zone: zone, dates: dates})))
        var pending = requests[command]
        if (!pending) {
            var promise = new Promise(function(accept, reject) {
                requests[command] = {accept: accept, reject: reject}
            })
            requests[command].promise = promise
            pending = requests[command]
            executable.connectSource(command)
        }
        return pending.promise.then(function(starts) {
            events.forEach(function(event) {
                var date = (event.start || {}).date
                if (date) event._reminderStart = starts[date]
            })
            return events
        })
    }
    Plasma5Support.DataSource {
        id: executable
        engine: 'executable'
        onNewData: function(source, data) {
            if (data['exit code'] === undefined) return
            var request = resolver.requests[source]
            executable.disconnectSource(source)
            delete resolver.requests[source]
            if (!request) return
            try {
                if (data['exit code'] !== 0) throw new Error('Unable to resolve calendar timezone')
                request.accept(JSON.parse(data.stdout))
            } catch (error) { request.reject(error) }
        }
    }
}
