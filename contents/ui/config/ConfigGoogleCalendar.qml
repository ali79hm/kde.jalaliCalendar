import "../lib/AppText.js" as AppText
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../lib/GoogleEventManager.js" as GoogleEventManager

Item {
    id: root
    LayoutMirroring.enabled: plasmoid.configuration.language === "fa"
    LayoutMirroring.childrenInherit: true
    width: 560
    implicitHeight: column.implicitHeight

    // ---- helpers ----
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
        anchors.fill: parent
        spacing: 14

        // --- AUTH VIEW (not signed-in) ---
        GroupBox {
            title: AppText.tr(plasmoid.configuration.language, "Google OAuth")
            Layout.fillWidth: true
            visible: !isAuthorized()

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                TextField {
                    id: clientId
                    Layout.fillWidth: true
                    placeholderText: AppText.tr(plasmoid.configuration.language, "Client ID")
                    text: plasmoid.configuration.latestClientId
                    onTextChanged: plasmoid.configuration.latestClientId = text
                }

                TextField {
                    id: clientSecret
                    Layout.fillWidth: true
                    placeholderText: AppText.tr(plasmoid.configuration.language, "Client Secret")
                    echoMode: TextInput.Password
                    text: plasmoid.configuration.latestClientSecret
                    onTextChanged: plasmoid.configuration.latestClientSecret = text
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: AppText.tr(plasmoid.configuration.language, "Redirect URI: http://127.0.0.1:<random-port>/ (handled by the built-in helper)")
                }

                RowLayout {
                    spacing: 8
                    Button {
                        id: authBtn
                        text: AppText.tr(plasmoid.configuration.language, "Authorize with Google")
                        enabled: clientId.text.length > 0 && clientSecret.text.length > 0
                        onClicked: {
                            err.sourceMessage = "";
                            manager.startAuth(plasmoid.configuration.latestClientId,
                                              plasmoid.configuration.latestClientSecret);
                        }
                    }
                    Label {
                        id: err
                        property string sourceMessage: ""
                        color: "tomato"
                        visible: text.length > 0
                        text: AppText.tr(plasmoid.configuration.language, sourceMessage)
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        // --- STATUS VIEW (signed-in) ---
        GroupBox {
            title: AppText.tr(plasmoid.configuration.language, "Google Account Status")
            Layout.fillWidth: true
            visible: isAuthorized()

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

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

        Item { Layout.fillHeight: true }
    }

    // ---- login manager instance & signal wiring ----
    GoogleLoginManager {
        id: manager

        // NOTE: authorized now has 4 args (last one is refreshToken)
        onAuthorized: function(token, tokenType, expiresIn, refreshToken) {
            plasmoid.configuration.accessToken = token;
            plasmoid.configuration.accessTokenType = tokenType;
            plasmoid.configuration.accessTokenExpiresAt = Math.floor(Date.now()/1000) + (expiresIn || 0);

            if (refreshToken && refreshToken.length > 0) {
                plasmoid.configuration.refreshToken = refreshToken;
                plasmoid.configuration.refreshTokenIssuedAt = Math.floor(Date.now()/1000);
            }

            err.sourceMessage = "";
        }

        onAuthError: function(message) { err.sourceMessage = message || "Authorization failed."; }
    }
}
