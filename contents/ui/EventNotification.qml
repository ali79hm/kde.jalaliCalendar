import QtQuick 2.15
import org.kde.notification 1.0 as Notifications
import "lib/AppText.js" as AppText
import "lib/EventCountdown.js" as Countdown

Notifications.Notification {
    id: notification
    property var reminder
    property string language: "en"
    property Notifications.NotificationAction meetAction: Notifications.NotificationAction {
        label: AppText.tr(notification.language, "Join meeting")
        onActivated: Qt.openUrlExternally(notification.reminder.meeting)
    }
    property Notifications.NotificationAction openAction: Notifications.NotificationAction {
        label: AppText.tr(notification.language, "Open event")
        onActivated: Qt.openUrlExternally(notification.reminder.link)
    }
    componentName: "kde.jalaliCalendar"
    eventId: "eventReminder"
    title: reminder.title === '(no title)' ? AppText.tr(language, '(no title)') : reminder.title
    text: (reminder.allDay ? AppText.tr(language, "All day")
        : Qt.formatTime(new Date(reminder.start), "HH:mm")
            + (typeof reminder.end === 'number' && isFinite(reminder.end)
                ? " - " + Qt.formatTime(new Date(reminder.end), "HH:mm") : ""))
        + "\n" + Countdown.remainingText(reminder.start, Date.now(), language)
    iconName: "view-calendar"
    autoDelete: true
    actions: reminder.meeting && reminder.link ? [meetAction, openAction]
        : reminder.meeting ? [meetAction] : reminder.link ? [openAction] : []
}
