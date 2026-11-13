import QtQuick 2.15
import "lib/GoogleEventManager.js" as Google
import "lib/ReminderLogic.js" as Logic

Item {
    id: service
    required property var configuration
    readonly property bool authorized: !!(configuration.refreshToken || configuration.accessToken)
    readonly property bool enabled: configuration.googleRemindersEnabled && authorized
    property bool initialized: false
    readonly property string refreshCredential: configuration.refreshToken || ""
    property var store: Logic.createStore()
    property var pendingMonths: ({})
    property var queue: []
    property var delivered: ({})
    property string account: ""
    property bool refreshing: false
    property int generation: 0
    property double lastRefresh: 0
    property double lastClock: Date.now()
    property string lastError: ""
    // Injectable transports keep scheduling/cache tests independent of Google.
    property var fetchEvents: function(options) { return Google.fetchAllEvents("primary", options) }
    property var fetchSettings: function() { return Google.fetchCalendarSettings("primary") }
    property var resolveTimeZones: function(events, zone) { return timeZones.resolve(events, zone) }
    ReminderTimeZones { id: timeZones }
    signal reminderDue(var reminder)
    signal eventsRefreshed()
    signal refreshRequested()
    property double lastAgendaAttempt: 0
    property double retryDelay: Logic.minute

    function refreshAll() {
        if (!authorized) return
        lastAgendaAttempt = Date.now()
        refreshRequested()
        refresh()
    }

    function save() {
        delivered = Logic.pruneDelivered(delivered, Date.now())
        configuration.googleReminderState = JSON.stringify({version: 1, account: account,
            delivered: delivered, queue: queue})
    }

    function restore() {
        try {
            var state = JSON.parse(configuration.googleReminderState || '{}')
            if (state.version !== 1) return
            account = state.account || ''
            delivered = Logic.pruneDelivered(state.delivered || {}, Date.now())
            queue = (state.queue || []).filter(function(alert) {
                return typeof alert.key === 'string' && typeof alert.due === 'number'
                    && alert.due >= Date.now() - Logic.grace && alert.due <= Date.now() + Logic.horizon
                    && !delivered[alert.key]
            }).sort(function(a, b) { return a.due - b.due })
        } catch (error) { queue = []; delivered = ({}) }
    }

    function reset() {
        ++generation
        alarm.stop()
        refreshing = false
        store = Logic.createStore()
        pendingMonths = ({})
        queue = []
        delivered = ({})
        account = ''
        lastRefresh = 0
        save()
    }

    function monthEvents(start, end, force) {
        if (!authorized) return Promise.reject(new Error('Google Calendar is not connected'))
        var key = start.toISOString() + '/' + end.toISOString()
        var cached = Logic.getMonth(store, key, Date.now())
        if (!force && cached !== null) return Promise.resolve(cached)
        if (pendingMonths[key]) return pendingMonths[key]
        var requestGeneration = generation
        var pending = fetchEvents({timeMin: start, timeMax: end}).then(function(events) {
            if (requestGeneration !== generation) throw new Error('Google connection changed')
            Logic.putMonth(store, key, events, Date.now())
            lastError = ""
            retryDelay = Logic.minute
            delete pendingMonths[key]
            return events
        }, function(error) {
            if (requestGeneration === generation) {
                delete pendingMonths[key]
                lastError = String(error.message || error)
                retryDelay = Math.min(10 * Logic.minute, retryDelay * 2)
            }
            throw error
        })
        pendingMonths[key] = pending
        return pending
    }

    function refresh() {
        if (!enabled || refreshing) return
        refreshing = true
        lastAttempt = Date.now()
        var requestGeneration = generation
        var now = Date.now()
        Promise.all([fetchSettings(), fetchEvents({
            timeMin: new Date(now - Logic.grace),
            timeMax: new Date(now + Logic.horizon + Logic.maxLead)
        })]).then(function(results) {
            if (requestGeneration !== generation || !enabled) return null
            return resolveTimeZones(results[1], results[0].timeZone).then(function(events) {
                return [results[0], events]
            })
        }).then(function(results) {
            if (!results) return
            if (requestGeneration !== generation || !enabled) return
            var settings = results[0], events = results[1]
            if (account && account !== settings.id) {
                store = Logic.createStore()
                delivered = ({})
            }
            account = settings.id
            Logic.setUpcoming(store, events)
            queue = Logic.alerts(events, settings.defaultReminders || [], account, Date.now(), delivered)
            lastRefresh = Date.now()
            lastError = ''
            refreshing = false
            save()
            processDue()
            eventsRefreshed()
        }).catch(function(error) {
            if (requestGeneration !== generation) return
            refreshing = false
            lastError = String(error.message || error)
            console.warn('Google reminder refresh failed:', lastError)
            // Cached alerts remain useful while offline.
            processDue()
        })
    }

    function processDue() {
        alarm.stop()
        if (!enabled || refreshing) return
        var now = Date.now()
        delivered = Logic.pruneDelivered(delivered, now)
        var changed = false
        while (queue.length && queue[0].due <= now) {
            var alert = queue.shift()
            changed = true
            if (alert.due >= now - Logic.grace && !delivered[alert.key]) {
                delivered[alert.key] = now
                // Save before displaying so a restart cannot repeat this alert.
                save()
                reminderDue(alert)
            }
        }
        Logic.pruneUpcoming(store, now)
        if (changed) save()
        if (queue.length) {
            alarm.interval = Math.max(1, Math.min(86400000, queue[0].due - now))
            alarm.start()
        }
    }

    // Reuse the clock's heartbeat to detect resume and clock changes. Refresh
    // cadence is measured in wall time, not only QML timer ticks during sleep.
    function clockTick(now) {
        var gap = now - lastClock
        lastClock = now
        if (authorized && (gap > 60000 || gap < 0 ||
                now - lastAgendaAttempt >= (lastError ? retryDelay : 10 * Logic.minute))) {
            refreshAll()
        }
        if (enabled && (gap > 60000 || gap < 0)) processDue()
    }

    property double lastAttempt: 0

    Timer { id: alarm; repeat: false; onTriggered: service.processDue() }
    Timer {
        interval: 10 * 60000
        repeat: true
        running: service.authorized
        onTriggered: service.refreshAll()
    }
    onRefreshCredentialChanged: {
        if (!initialized) return
        // Token rotation can keep the same account. Check calendar identity
        // before discarding delivery history, but invalidate in-flight requests.
        ++generation
        refreshing = false
        store = Logic.createStore()
        pendingMonths = ({})
        queue = []
        alarm.stop()
        refresh()
    }
    onEnabledChanged: {
        if (!initialized) return
        if (enabled) { refresh(); processDue() }
        else {
            ++generation
            refreshing = false
            alarm.stop()
            queue = []
            store.upcoming = []
            Logic.collect(store)
            save()
        }
    }
    onAuthorizedChanged: {
        if (initialized && !authorized) reset()
    }
    Component.onCompleted: {
        initialized = true
        if (enabled) { restore(); refresh(); processDue() }
    }
}
