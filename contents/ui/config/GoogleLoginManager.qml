import QtQuick 2.15
import QtQml 2.15
import QtQuick.Window 2.15
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root

    // Signals consumed by the config page
    // NOTE: includes refreshToken so the page can save it on first consent
    signal authorized(string accessToken, string tokenType, int expiresIn, string refreshToken)
    signal authError(string message)

    // --- Settings / internals ---
    property int listenPort: 0
    property string pendingCmd: ""
    property bool waitingForToken: false
    property string tokenEndpoint: "https://oauth2.googleapis.com/token"

    // --- Run external commands and capture stdout using Plasma's Executable engine ---
    PlasmaCore.DataSource {
        id: exec
        engine: "executable"

        onNewData: function (sourceName, data) {
            const out = (data.stdout || "").trim();
            const err = (data.stderr || "").trim();
            const exitCode = data["exit code"];

            // Helper prints token JSON to stdout. Parse it.
            if (out && out[0] === "{") {
                try {
                    const jd = JSON.parse(out);
                    const token      = jd.access_token || "";
                    const tokenType  = jd.token_type || "";
                    const expiresIn  = jd.expires_in || 0;
                    const refreshTok = jd.refresh_token || "";
                    waitingForToken = false;
                    root.authorized(token, tokenType, expiresIn, refreshTok);
                } catch (e) {
                    root.authError("Could not parse token response.");
                }
            }

            if (err && err.length > 0) {
                root.authError(err);
            }

            // cleanup when process ends
            if (exitCode !== undefined) {
                exec.disconnectSource(sourceName);
                pendingCmd = "";
                waitingForToken = false;
            }
        }
    }

    // --- Utilities ---
    function _nowSec() { return Math.floor(Date.now()/1000); }
    function _isNearExpiry() {
        // Absolute expiry stored in config (UNIX seconds).
        // Consider "near" when <= 10s left to avoid edge races.
        var expiresAt = plasmoid.configuration.accessTokenExpiresAt || 0;
        var tok = plasmoid.configuration.accessToken || "";
        return (!tok || _nowSec() >= (expiresAt - 10));
    }
    function urlToLocalPath(u) {
        if (!u) return "";
        return u.startsWith("file://") ? u.replace("file://", "") : u;
    }
    function pickPort() {
        // try a non-standard range to reduce collisions
        return 8765 + Math.floor(Math.random() * 135);
    }
    function buildAuthUrl(clientId, port) {
        const redirect = encodeURIComponent("http://127.0.0.1:" + port + "/");
        const scope = encodeURIComponent("https://www.googleapis.com/auth/calendar.readonly");
        const base = "https://accounts.google.com/o/oauth2/v2/auth";
        // IMPORTANT: access_type=offline + prompt=consent → refresh_token on first consent
        const params = "client_id=" + clientId
                     + "&redirect_uri=" + redirect
                     + "&response_type=code"
                     + "&access_type=offline"
                     + "&prompt=consent"
                     + "&scope=" + scope;
        return base + "?" + params;
    }

    // --- Initial OAuth (code → tokens via helper) ---
    function startAuth(clientId, clientSecret) {
        if (!clientId || !clientSecret) {
            root.authError("Client ID/Secret are required.");
            return;
        }

        listenPort = pickPort();

        // Resolve helper relative to this config dir: ../lib/google_redirect.py
        var helperUrl = Qt.resolvedUrl("../lib/google_redirect.py");
        var helperPath = urlToLocalPath(helperUrl);

        // Spawn python helper: it listens on localhost:<port>, receives "code",
        // exchanges it for tokens, then prints token JSON to stdout.
        pendingCmd = "python3 \"" + helperPath + "\""
                   + " --client_id \"" + clientId + "\""
                   + " --client_secret \"" + clientSecret + "\""
                   + " --listen_port " + listenPort;

        waitingForToken = true;
        exec.connectSource(pendingCmd);

        // Open browser to Google's consent page
        Qt.openUrlExternally(buildAuthUrl(clientId, listenPort));
    }

    // --- On-demand Refresh (absolute expiry) ---
    // POSTs to Google's token endpoint with the stored refresh_token.
    // On success, updates accessToken/accessTokenType/accessTokenExpiresAt in config.
    function refreshAccessToken(callback) {
        const refreshToken = plasmoid.configuration.refreshToken || "";
        const clientId     = plasmoid.configuration.latestClientId || "";
        const clientSecret = plasmoid.configuration.latestClientSecret || "";

        if (!refreshToken) { root.authError("No refresh token saved. Re-authorize once."); return; }
        if (!clientId || !clientSecret) { root.authError("Missing client credentials."); return; }

        const body = "client_id=" + encodeURIComponent(clientId) +
                     "&client_secret=" + encodeURIComponent(clientSecret) +
                     "&grant_type=refresh_token" +
                     "&refresh_token=" + encodeURIComponent(refreshToken);

        var xhr = new XMLHttpRequest();
        xhr.open("POST", tokenEndpoint, true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.timeout = 30000;

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;

            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    const jd = JSON.parse(xhr.responseText);
                    const token     = jd.access_token || "";
                    const tokenType = jd.token_type || "";
                    const expiresIn = jd.expires_in || 0;
                    if (!token) { root.authError("Refresh returned no access token."); return; }

                    // Save absolute expiry: now + expires_in (seconds)
                    plasmoid.configuration.accessToken = token;
                    plasmoid.configuration.accessTokenType = tokenType;
                    plasmoid.configuration.accessTokenExpiresAt = _nowSec() + expiresIn;

                    // Some providers rotate refresh_token; if present, store it
                    if (jd.refresh_token && jd.refresh_token.length > 0) {
                        plasmoid.configuration.refreshToken = jd.refresh_token;
                        // optional: plasmoid.configuration.refreshTokenIssuedAt = _nowSec();
                    }

                    if (callback) callback(token, tokenType, expiresIn);
                } catch (e) {
                    root.authError("Failed to parse refresh response.");
                }
                return;
            }

            // Error path
            var msg = "Refresh failed (HTTP " + xhr.status + ")";
            try {
                const er = JSON.parse(xhr.responseText);
                if (er && (er.error_description || (er.error && er.error.message))) {
                    msg = er.error_description || er.error.message;
                }
            } catch (e2) {}
            root.authError(msg);
        };

        xhr.ontimeout = function(){ root.authError("Refresh request timed out."); };
        xhr.onerror   = function(){ root.authError("Network error during refresh."); };
        xhr.send(body);
    }

    // Ensure a usable token right before an API call:
    // If absolute expiry says we're still valid, invoke callback immediately.
    // Otherwise refresh now, then invoke callback.
    function ensureValidAccessToken(callback) {
        if (!_isNearExpiry()) {
            if (callback) callback(plasmoid.configuration.accessToken,
                                   plasmoid.configuration.accessTokenType,
                                   Math.max(0, (plasmoid.configuration.accessTokenExpiresAt || 0) - _nowSec()));
            return;
        }
        refreshAccessToken(function(tok, typ, expIn){
            if (callback) callback(tok, typ, expIn);
        });
    }

    // Optional: revoke/cleanup (no-op here; we rely on clearing config on Logout)
    function signOut() {
        // You can call Google's revoke endpoint here if desired.
        // For this plasmoid, clearing tokens in the config page is sufficient.
    }
}