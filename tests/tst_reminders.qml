import QtQuick 2.15
import QtTest 1.3
import "../contents/ui" as UI
import "../contents/ui/lib/ReminderLogic.js" as Logic
import "../contents/ui/lib/GoogleEventManager.js" as Google

TestCase {
    id: test
    name: "GoogleReminders"
    property var events: []
    property var defaults: []
    property int fetchCount: 0
    property bool offline: false
    property QtObject config: QtObject {
        property bool googleRemindersEnabled: false
        property string googleReminderState: ''
        property string accessToken: 'test'
        property string refreshToken: ''
    }
    UI.GoogleCalendarService {
        id: service
        configuration: test.config
        fetchEvents: function(options) {
            ++test.fetchCount
            if (test.offline) return Promise.reject(new Error('Offline test'))
            return Promise.resolve(test.events)
        }
        fetchSettings: function() { return Promise.resolve({id: 'calendar', defaultReminders: test.defaults}) }
    }
    UI.ReminderTimeZones { id: zones }
    SignalSpy { id: due; target: service; signalName: 'reminderDue' }
    SignalSpy { id: refreshed; target: service; signalName: 'eventsRefreshed' }
    Component { id: notification; UI.EventNotification {} }

    function test_forcedMonthRefresh() {
        var start = new Date(2026, 0, 1), end = new Date(2026, 1, 1)
        var completed = 0
        service.monthEvents(start, end).then(function() { ++completed })
        tryCompare(test, "fetchCount", 1)
        tryVerify(function() { return completed === 1 })
        service.monthEvents(start, end).then(function() { ++completed })
        tryVerify(function() { return completed === 2 })
        compare(fetchCount, 1)
        service.monthEvents(start, end, true).then(function() { ++completed })
        service.monthEvents(start, end, true).then(function() { ++completed })
        tryVerify(function() { return completed === 4 })
        compare(fetchCount, 2)
    }

    function event(id, start, reminders) {
        return {id: id, summary: 'Title', start: {dateTime: new Date(start).toISOString()},
            end: {dateTime: new Date(start + 60 * Logic.minute).toISOString()},
            reminders: reminders, htmlLink: 'https://calendar.google.com/event',
            hangoutLink: 'https://meet.google.com/test'}
    }
    function init() {
        config.googleRemindersEnabled = false
        service.reset()
        test.events = []
        test.defaults = []
        test.fetchCount = 0
        test.offline = false
        due.clear()
        refreshed.clear()
    }
    function enable() {
        config.googleRemindersEnabled = true
        tryCompare(refreshed, 'count', 1)
    }
    function test_defaultsOverridesAndMultipleAlerts() {
        var now = Date.now(), start = now + 60 * Logic.minute
        var rules = [{method: 'popup', minutes: 10}, {method: 'email', minutes: 5}]
        var items = [event('default', start, {useDefault: true}),
            event('none', start, {useDefault: false}),
            event('custom', start, {useDefault: false, overrides: [
                {method: 'popup', minutes: 30}, {method: 'popup', minutes: 5},
                {method: 'popup', minutes: 5}]})]
        var alerts = Logic.alerts(items, rules, 'calendar', now, {})
        compare(alerts.length, 3)
        compare(alerts[0].due, start - 30 * Logic.minute)
        compare(alerts[1].due, start - 10 * Logic.minute)
        compare(alerts[2].due, start - 5 * Logic.minute)
        compare(alerts[0].meeting, 'https://meet.google.com/test')
    }
    function test_cancelledDeclinedAndRecurringInstances() {
        var now = Date.now(), rules = {useDefault: true}
        var cancelled = event('cancelled', now, rules); cancelled.status = 'cancelled'
        var declined = event('declined', now, rules); declined.attendees = [{self: true, responseStatus: 'declined'}]
        var first = event('series_1', now, rules), second = event('series_2', now + 1000, rules)
        var alerts = Logic.alerts([cancelled, declined, first, second], [{method: 'popup', minutes: 0}], 'cal', now, {})
        compare(alerts.length, 2)
        verify(alerts[0].key !== alerts[1].key)
    }
    function test_earlyAlertsAndMissedGrace() {
        var now = Date.now()
        var early = event('early', now + 40 * Logic.day, {overrides: [{method: 'popup', minutes: 28 * 1440}]})
        var recent = event('recent', now - 10 * Logic.minute, {overrides: [{method: 'popup', minutes: 0}]})
        var old = event('old', now - 16 * Logic.minute, {overrides: [{method: 'popup', minutes: 0}]})
        var alerts = Logic.alerts([early, recent, old], [], 'cal', now, {})
        compare(alerts.length, 2)
        compare(alerts[0].due, recent.start ? Logic.startTime(recent) : 0)
    }
    function test_allDayLocalMidnightAndOffset() {
        compare(Logic.startTime({start: {date: '2026-11-13'}}), new Date(2026, 10, 13).getTime())
        compare(Logic.startTime({start: {dateTime: '2026-11-13T14:00:00+03:30'}}), Date.UTC(2026, 10, 13, 10, 30))
        var date = new Date(2026, 10, 1)
        compare(Google._iso8601(date), date.toISOString())
    }
    function test_cacheLruSharedObjectsAndPruning() {
        var store = Logic.createStore(), now = Date.now()
        for (var i = 1; i <= 3; ++i)
            Logic.putMonth(store, 'month' + i, [event('event' + i, now, {})], now)
        Logic.getMonth(store, 'month1', now)
        Logic.putMonth(store, 'month4', [event('event4', now, {})], now)
        compare(store.months.length, 3)
        verify(!store.events.event2)
        var shared = event('event1', now, {})
        Logic.setUpcoming(store, [shared])
        compare(store.events.event1, shared)
        Logic.getMonth(store, 'month1', now) // Invalidated after background changes.
        compare(Logic.getMonth(store, 'month1', now), null)
        Logic.pruneUpcoming(store, now + 2 * Logic.day)
        compare(store.upcoming.length, 0)
        // Still referenced by a retained month until its eviction.
        verify(!!store.events.event1)
        for (i = 5; i <= 7; ++i) Logic.putMonth(store, 'month' + i, [], now)
        compare(Object.keys(store.events).length, 0)
    }
    function test_deliveredRetention() {
        var now = Date.now(), clean = Logic.pruneDelivered({recent: now - 1000,
            old: now - 8 * Logic.day, future: now + 8 * Logic.day}, now)
        compare(Object.keys(clean).length, 1)
        verify(!!clean.recent)
        // A small backwards clock correction must not erase delivery history.
        verify(Logic.pruneDelivered({delivered: now}, now - Logic.minute).delivered === now)
    }
    function test_serviceDeliveryPersistenceAndNoRepeat() {
        test.events = [event('now', Date.now() - 1000, {overrides: [{method: 'popup', minutes: 0}]})]
        enable()
        compare(due.count, 1)
        verify(JSON.parse(config.googleReminderState).delivered[due.signalArguments[0][0].key] > 0)
        service.refresh()
        tryCompare(refreshed, 'count', 2)
        compare(due.count, 1)
        service.restore()
        service.processDue()
        compare(due.count, 1)
    }
    function test_serviceCancellationAndNewTime() {
        var now = Date.now()
        test.events = [event('future', now + Logic.minute, {overrides: [{method: 'popup', minutes: 0}]})]
        enable()
        compare(service.queue.length, 1)
        test.events = []
        service.refresh()
        tryCompare(refreshed, 'count', 2)
        compare(service.queue.length, 0)
        compare(service.store.upcoming.length, 0)
        test.events = [event('future', now - 1000, {overrides: [{method: 'popup', minutes: 0}]})]
        service.refresh()
        tryCompare(refreshed, 'count', 3)
        compare(due.count, 1)
    }
    function test_serviceOfflineRestoreAndDisable() {
        enable()
        var now = Date.now()
        config.googleReminderState = JSON.stringify({version: 1, account: 'calendar', delivered: {},
            queue: [{key: 'offline', due: now - 1000, start: now, title: 'Cached', link: '', meeting: ''}]})
        service.restore()
        test.offline = true
        service.refresh()
        tryCompare(due, 'count', 1)
        service.processDue()
        compare(due.count, 1)
        config.googleRemindersEnabled = false
        compare(service.queue.length, 0)
    }
    function test_serviceMonthDedupAndLimit() {
        var completed = 0
        function done() { ++completed }
        var start = new Date(2026, 0, 1), end = new Date(2026, 1, 1)
        service.monthEvents(start, end).then(done)
        service.monthEvents(start, end).then(done)
        tryVerify(function() { return completed === 2 })
        compare(test.fetchCount, 1)
        service.monthEvents(start, end).then(done)
        tryVerify(function() { return completed === 3 })
        compare(test.fetchCount, 1)
        for (var i = 1; i <= 4; ++i)
            service.monthEvents(new Date(2026, i, 1), new Date(2026, i + 1, 1)).then(done)
        tryVerify(function() { return completed === 7 })
        compare(service.store.months.length, 3)
    }
    function test_timezoneResolver() {
        var result = null, error = ''
        zones.resolve([{start: {date: '2026-11-13'}}], 'Asia/Tehran').then(function(events) {
            result = events
        }, function(e) { error = String(e) })
        tryVerify(function() { return result !== null || error !== '' })
        compare(error, '')
        compare(result[0]._reminderStart, Date.UTC(2026, 10, 12, 20, 30))
        compare(Logic.startTime(result[0]), Date.UTC(2026, 10, 12, 20, 30))
    }
    function test_wakeRefresh() {
        enable()
        var count = test.fetchCount
        service.lastClock = Date.now() - 2 * Logic.day
        service.lastAttempt = Date.now() - 2 * Logic.day
        service.clockTick(Date.now())
        tryCompare(refreshed, 'count', 2)
        compare(test.fetchCount, count + 1)
    }
    Component { id: serviceComponent; UI.GoogleCalendarService {} }
    function test_startupOfflineRecovery() {
        var now = Date.now()
        config.googleReminderState = JSON.stringify({version: 1, account: 'calendar', delivered: {},
            queue: [{key: 'startup', due: now - 1000, start: now, title: 'Cached', link: '', meeting: ''}]})
        // Give the new service an already-enabled configuration at creation.
        var configuration = Qt.createQmlObject('import QtQml; QtObject { property bool googleRemindersEnabled: true; property string accessToken: "test"; property string refreshToken: ""; property string googleReminderState: "" }', test)
        configuration.googleReminderState = config.googleReminderState
        var instance = createTemporaryObject(serviceComponent, test, {
            configuration: configuration,
            fetchEvents: function(options) { return Promise.reject(new Error('Offline startup test')) },
            fetchSettings: function() { return Promise.resolve({id: 'calendar'}) }
        })
        verify(instance !== null)
        tryVerify(function() { return !!JSON.parse(configuration.googleReminderState).delivered.startup })
        compare(instance.queue.length, 0)
        instance.destroy()
        configuration.destroy()
    }
    function test_noStaleMonthAfterDisconnect() {
        var accept = null, rejected = false
        var previous = service.fetchEvents
        service.fetchEvents = function(options) { return new Promise(function(resolve) { accept = resolve }) }
        service.monthEvents(new Date(2026, 0, 1), new Date(2026, 1, 1)).catch(function() { rejected = true })
        service.reset()
        accept([event('stale', Date.now(), {})])
        tryVerify(function() { return rejected })
        compare(service.store.months.length, 0)
        service.fetchEvents = previous
    }
    function test_realDelayedTimerAndActions() {
        test.events = [event('soon', Date.now() + 200, {overrides: [{method: 'popup', minutes: 0}]})]
        enable()
        tryCompare(due, 'count', 1)
        var alert = due.signalArguments[0][0]
        var instance = createTemporaryObject(notification, test, {reminder: alert})
        verify(instance !== null)
        compare(instance.componentName, 'kde.jalaliCalendar')
        compare(instance.eventId, 'eventReminder')
        compare(instance.actions.length, 2)
        compare(alert.end, alert.start + 60 * Logic.minute)
        compare(instance.title, 'Title')
        compare(instance.text, Qt.formatTime(new Date(alert.start), 'HH:mm')
            + ' - ' + Qt.formatTime(new Date(alert.end), 'HH:mm') + '\nNow')
        alert = {title: 'No Meet', start: Date.now(), meeting: '', link: 'https://calendar.google.com'}
        instance = createTemporaryObject(notification, test, {reminder: alert})
        compare(instance.actions.length, 1)
        compare(instance.actions[0].label, 'Open event')
        var futureStart = Date.now() + 5 * Logic.minute + 1000
        instance = createTemporaryObject(notification, test, {reminder: {
            title: 'Future', start: futureStart, meeting: '', link: ''}})
        compare(instance.text, Qt.formatTime(new Date(futureStart), 'HH:mm') + '\n5 min to event')
    }
}
