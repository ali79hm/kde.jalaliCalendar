import QtQuick 2.0

Item {
    id: session
    // ExecUtil { id: executable }
	property int callbackListenPort: 8001

    readonly property string authorizationCodeUrl: {
		var url = 'https://accounts.google.com/o/oauth2/v2/auth'
		url += '?scope=' + encodeURIComponent('https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/tasks')
		url += '&response_type=code'
		url += '&redirect_uri=' + encodeURIComponent("http://127.0.0.1:" + callbackListenPort.toString() + "/")
		url += '&client_id=' + encodeURIComponent(plasmoid.configuration.latestClientId)
		return url
	}

    function fetchAccessToken() {
		var cmd = [
			'python3',
			plasmoid.file("", "lib/google_redirect.py"),
			"--client_id", plasmoid.configuration.latestClientId,
			"--client_secret", plasmoid.configuration.latestClientSecret,
			"--listen_port", callbackListenPort.toString(),
		]

		Qt.openUrlExternally(authorizationCodeUrl);

		executable.exec(cmd, function(cmd, exitCode, exitStatus, stdout, stderr) {
			if (exitCode) {
				logger.log('fetchAccessToken.stderr', stderr)
				logger.log('fetchAccessToken.stdout', stdout)
				return
			}

			try {
				var data = JSON.parse(stdout)
				updateAccessToken(data)
			} catch (e) {
				logger.log('fetchAccessToken.e', e)
				handleError('Error parsing JSON', null)
				return
			}

		})
	}

    function updateAccessToken(data) {
		plasmoid.configuration.sessionClientId = plasmoid.configuration.latestClientId
		plasmoid.configuration.sessionClientSecret = plasmoid.configuration.latestClientSecret
		plasmoid.configuration.accessToken = data.access_token
		plasmoid.configuration.accessTokenType = data.token_type
		plasmoid.configuration.accessTokenExpiresAt = Date.now() + data.expires_in * 1000
		plasmoid.configuration.refreshToken = data.refresh_token
		newAccessToken()
	}

}