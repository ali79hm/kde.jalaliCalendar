import "../lib/AppText.js" as AppText
import "../lib/GoogleEventManager.js" as GoogleEventManager
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.4 as Kirigami

Item {
    id: root
    property bool showAccountDetails: false
    property string accountEmail: ""

    function loadAccountEmail() {
        if (!showAccountDetails || !isAuthorized()) return;
        manager.ensureValidAccessToken(function(token) {
            var request = new XMLHttpRequest();
            request.open("GET", "https://www.googleapis.com/calendar/v3/calendars/primary");
            request.setRequestHeader("Authorization", "Bearer " + token);
            request.onreadystatechange = function() {
                if (request.readyState !== XMLHttpRequest.DONE) return;
                if (request.status === 200 && token === plasmoid.configuration.accessToken) {
                    try {
                        var calendar = JSON.parse(request.responseText);
                        root.accountEmail = calendar.id && calendar.id.indexOf("@") > 0 ? calendar.id : "";
                    } catch (error) { root.accountEmail = ""; }
                }
            };
            request.send();
        });
    }
    Component.onCompleted: loadAccountEmail()
    LayoutMirroring.enabled: plasmoid.configuration.language === "fa"
    LayoutMirroring.childrenInherit: true
    implicitWidth: 560
    implicitHeight: column.implicitHeight

    function nowSec() { return Math.floor(Date.now() / 1000); }
    function isAuthorized() {
        return (plasmoid.configuration.accessToken || "").length > 0;
    }

    function mask(tok) {
        if (!tok || tok.length < 12) return tok || "";
        return tok.slice(0, 6) + "…" + tok.slice(-6);
    }
    function ttlString(ts) {
        if (!ts || ts <= 0) return AppText.tr(plasmoid.configuration.language, "not set");
        const s = ts - nowSec(); if (s <= 0) return AppText.tr(plasmoid.configuration.language, "expired");
        const m = Math.floor(s/60), h = Math.floor(m/60), d = Math.floor(h/24);
        if (d > 0) return AppText.tr(plasmoid.configuration.language, "%1 day(s)", d);
        if (h > 0) return AppText.tr(plasmoid.configuration.language, "%1 hour(s)", h);
        return AppText.tr(plasmoid.configuration.language, "%1 minute(s)", m);
    }

    ColumnLayout {
        id: column
        width: parent.width
        spacing: Kirigami.Units.largeSpacing

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            source: "../icons/google.svg"
            fillMode: Image.PreserveAspectFit
        }
        Kirigami.Heading {
            Layout.alignment: Qt.AlignHCenter
            level: 2
            text: AppText.tr(plasmoid.configuration.language, root.showAccountDetails ? "Google Account" : "Google Events")
        }
        Button {
            id: authBtn
            visible: !root.isAuthorized()
            Layout.alignment: Qt.AlignHCenter
            text: AppText.tr(plasmoid.configuration.language, "Authorize with Google")
            onClicked: {
                manager.startAuth(plasmoid.configuration.latestClientId,
                                  plasmoid.configuration.latestClientSecret);
            }
        }
        Label {
            Layout.alignment: Qt.AlignHCenter
            visible: root.isAuthorized() && !root.showAccountDetails
            text: AppText.tr(plasmoid.configuration.language, "Connected to Google")
        }

        // --- STATUS VIEW (signed-in) ---
        GroupBox {
            title: AppText.tr(plasmoid.configuration.language, "Google Account Status")
            Layout.fillWidth: true
            visible: root.showAccountDetails && root.isAuthorized()

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                Label {
                    Layout.fillWidth: true
                    visible: root.accountEmail.length > 0
                    text: AppText.tr(plasmoid.configuration.language, "Email:") + " " + root.accountEmail
                    elide: Text.ElideMiddle
                }
                Label {
                    Layout.fillWidth: true
                    text: AppText.tr(plasmoid.configuration.language, "Access token: ") + mask(plasmoid.configuration.accessToken)
                    elide: Text.ElideRight
                }
                Label {
                    Layout.fillWidth: true
                    text: AppText.tr(plasmoid.configuration.language, "Token type: ") + (plasmoid.configuration.accessTokenType || "—")
                }
                Label {
                    Layout.fillWidth: true
                    text: AppText.tr(plasmoid.configuration.language, "Expires in: ") + ttlString(plasmoid.configuration.accessTokenExpiresAt)
                }
                Label {
                    Layout.fillWidth: true
                    text: AppText.tr(plasmoid.configuration.language, "refresh token: ") + mask(plasmoid.configuration.refreshToken)
                    elide: Text.ElideRight
                }

                RowLayout {
                    spacing: 8
                    Button {
                        text: AppText.tr(plasmoid.configuration.language, "Logout")
                        onClicked: {
                            // optional revoke; otherwise just clear locally
                            root.accountEmail = "";
                            if (manager.signOut) manager.signOut();
                            plasmoid.configuration.accessToken = "";
                            plasmoid.configuration.accessTokenType = "";
                            plasmoid.configuration.accessTokenExpiresAt = 0;
                            plasmoid.configuration.refreshToken = "";
                            plasmoid.configuration.refreshTokenIssuedAt = 0;
                        }
                    }
                    Button {
                        text: AppText.tr(plasmoid.configuration.language, "Refresh Token")
                        visible: plasmoid.configuration.refreshToken !== ""
                        onClicked: {
                            // trigger refresh manually
                            GoogleEventManager.manualRefreshToken().then(function(token){
                                console.log("Refreshed successfully")
                            }).catch(function(err){
                                console.log("Refresh failed: " + err)
                            })
                        }
                    }
                }
            }
        }


    }

    // ---- login manager instance & signal wiring ----
    GoogleLoginManager {
        id: manager

        // NOTE: authorized now has 4 args (last one is refreshToken)
        onAuthorized: function(token, tokenType, expiresIn, refreshToken) {
            root.accountEmail = "";
            plasmoid.configuration.accessToken = token;
            plasmoid.configuration.accessTokenType = tokenType;
            plasmoid.configuration.accessTokenExpiresAt = Math.floor(Date.now()/1000) + (expiresIn || 0);

            if (refreshToken && refreshToken.length > 0) {
                plasmoid.configuration.refreshToken = refreshToken;
                plasmoid.configuration.refreshTokenIssuedAt = Math.floor(Date.now()/1000);
            }

            root.loadAccountEmail();
        }

        onAuthError: function(message) { console.warn("Google authorization: " + message); }
    }
}
