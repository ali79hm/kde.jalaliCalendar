// GoogleEventManager.js — on-demand refresh using absolute expiry (accessTokenExpiresAt)

function _nowSec(){ return Math.floor(Date.now()/1000); }
function _iso8601(d){
    if(!d) return null;
    if (typeof d==="string") return d;   // assume already RFC3339
    return new Date(d.getTime() - d.getTimezoneOffset()*60000).toISOString();
}
function _encode(params){
    var out=[]; for (var k in params){ var v=params[k];
        if(v===undefined||v===null||v==="") continue;
        out.push(encodeURIComponent(k)+"="+encodeURIComponent(v));
    } return out.join("&");
}
function _xhr(method, url, headers, body, timeoutMs){
    return new Promise(function(resolve,reject){
        var xhr=new XMLHttpRequest();
        xhr.open(method, url, true);
        if (headers){ for (var h in headers){ xhr.setRequestHeader(h, headers[h]); } }
        xhr.timeout = timeoutMs || 30000;
        xhr.onreadystatechange=function(){
            if (xhr.readyState!==XMLHttpRequest.DONE) return;
            var txt = xhr.responseText || "";
            if (xhr.status>=200 && xhr.status<300) {
                try { resolve(JSON.parse(txt)); } catch(e){ reject(new Error("Parse error")); }
            } else {
                var msg = "HTTP "+xhr.status;
                try {
                    var er=JSON.parse(txt);
                    if (er.error && (er.error.message || er.error_description)) {
                        msg = (er.error.message || er.error_description) + " (HTTP "+xhr.status+")";
                    }
                } catch(e){}
                var err = new Error(msg); err._status = xhr.status; reject(err);
            }
        };
        xhr.ontimeout=function(){ reject(new Error("Timeout")); };
        xhr.onerror=function(){ reject(new Error("Network error")); };
        xhr.send(body || null);
    });
}

// ---- absolute-expiry helpers ----
function _token(){ return plasmoid.configuration.accessToken || ""; }
function _expiry(){ return plasmoid.configuration.accessTokenExpiresAt || 0; }

// Only check the saved absolute expiry; refresh if now >= expiry - 10s
function _isExpiredOrNear(){
    return !_token() || (_nowSec() >= (_expiry() - 10));
}

function _refreshToken(){
    var refreshToken = plasmoid.configuration.refreshToken || "";
    if (!refreshToken) return Promise.reject(new Error("No refresh token; re-authorize once."));

    var clientId     = plasmoid.configuration.latestClientId || "";
    var clientSecret = plasmoid.configuration.latestClientSecret || "";
    if (!clientId || !clientSecret) return Promise.reject(new Error("Missing client credentials."));

    var body = "client_id="+encodeURIComponent(clientId)+
               "&client_secret="+encodeURIComponent(clientSecret)+
               "&grant_type=refresh_token"+
               "&refresh_token="+encodeURIComponent(refreshToken);

    return _xhr("POST", "https://oauth2.googleapis.com/token",
        {"Content-Type":"application/x-www-form-urlencoded"}, body, 30000
    ).then(function(jd){
        var token   = jd.access_token || "";
        var type    = jd.token_type || "";
        var expires = jd.expires_in || 0;
        if (!token) throw new Error("Refresh returned no access token.");

        // Save new token + absolute expiry (UNIX seconds)
        plasmoid.configuration.accessToken = token;
        plasmoid.configuration.accessTokenType = type;
        plasmoid.configuration.accessTokenExpiresAt = _nowSec() + expires;

        // Some providers rotate refresh_token on refresh; store if present
        if (jd.refresh_token && jd.refresh_token.length > 0) {
            plasmoid.configuration.refreshToken = jd.refresh_token;
            // (optional) plasmoid.configuration.refreshTokenIssuedAt = _nowSec();
        }
        return token;
    });
}

// Called right before hitting the API
function _ensureUsableToken(){
    if (!_isExpiredOrNear()) return Promise.resolve(_token());
    return _refreshToken();
}

// ---- calendar calls ----
function _eventsOnce(accessToken, calendarId, opts){
    calendarId = calendarId || "primary"; opts = opts || {};
    var params = {
        singleEvents: (opts.singleEvents!==undefined ? opts.singleEvents : true),
        orderBy: (opts.orderBy || "startTime"),
        maxResults: (opts.maxResults || 2500),
        timeMin: _iso8601(opts.timeMin),
        timeMax: _iso8601(opts.timeMax),
        pageToken: opts.pageToken,
        q: opts.q,
        fields: "items(id,summary,description,location,start,end,htmlLink,creator,organizer,hangoutLink,conferenceData),nextPageToken"
    };
    var base = "https://www.googleapis.com/calendar/v3/calendars/";
    var url = base + encodeURIComponent(calendarId) + "/events?" + _encode(params);
    return _xhr("GET", url, {"Authorization":"Bearer "+accessToken}, null, opts.timeoutMs || 30000);
}

function fetchEventsPage(calendarId, opts){
    // Lazy: use token if still valid; otherwise refresh now
    return _ensureUsableToken().then(function(tok){
        return _eventsOnce(tok, calendarId, opts);
    }).catch(function(err){
        // If server still says unauthorized, force one refresh and retry once
        if (err && (err._status===401 || /unauthori[sz]ed|invalid/i.test(err.message))) {
            return _refreshToken().then(function(tok){ return _eventsOnce(tok, calendarId, opts); });
        }
        throw err;
    });
}

function fetchAllEvents(calendarId, opts){
    var accum = []; opts = opts || {};
    function loop(pageToken){
        var po={}; for (var k in opts) po[k]=opts[k]; po.pageToken=pageToken;
        return fetchEventsPage(calendarId, po).then(function(res){
            if (res.items && res.items.length) {
                for (var i=0;i<res.items.length;i++){
                    var ev=res.items[i], s=(ev.start||{}), e=(ev.end||{});
                    ev._startISO = s.dateTime || s.date || null;
                    ev._endISO   = e.dateTime || e.date || null;
                    try{ ev._start = ev._startISO ? new Date(ev._startISO) : null;
                         ev._end   = ev._endISO ? new Date(ev._endISO) : null; } catch(e2){}
                    accum.push(ev);
                }
            }
            if (res.nextPageToken) return loop(res.nextPageToken);
            return accum;
        });
    }
    return loop(undefined);
}

// Convenience entrypoint
function fetchAllEventsFromConfig(calendarId, opts){
    return fetchAllEvents(calendarId || "primary", opts || {});
}

// Export
var GoogleEventManager = {
    fetchEventsPage: fetchEventsPage,
    fetchAllEvents: fetchAllEvents,
    fetchAllEventsFromConfig: fetchAllEventsFromConfig
};
