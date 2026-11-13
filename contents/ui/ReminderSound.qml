import QtQuick 2.15
import org.kde.plasma.plasma5support 2.0 as Plasma5Support

Item {
    id: soundSettings
    required property string sound
    property bool ready: false
    property string activeCommand: ""
    property bool pending: false
    function quote(value) { return "'" + value.replace(/'/g, "'\\''") + "'" }
    function apply() {
        if (!ready || !sound) return
        if (activeCommand) { pending = true; return }
        // KNotification reads per-user event overrides from this file.
        var base = 'kwriteconfig6 --file kde.jalaliCalendar.notifyrc --group Event/eventReminder '
        activeCommand = base + '--key Sound ' + quote(sound)
            + ' && ' + base + '--key Action ' + quote('Popup|Sound')
        writer.connectSource(activeCommand)
    }
    onSoundChanged: apply()
    Component.onCompleted: { ready = true; apply() }
    Plasma5Support.DataSource {
        id: writer
        engine: 'executable'
        onNewData: function(source, data) {
            if (data['exit code'] === undefined) return
            writer.disconnectSource(source)
            soundSettings.activeCommand = ''
            if (data['exit code'] !== 0) console.warn('Unable to save reminder sound:', data.stderr)
            if (soundSettings.pending) {
                soundSettings.pending = false
                soundSettings.apply()
            }
        }
    }
}
