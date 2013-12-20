var express = require('express');
var restler = require('restler');

var app = express();

var _JENKINS_API_BASE_URL = 'http://ci.liferay.org.es/jenkins';
var _JENKINS_API_SUFFIX_URL = 'api/json';

app.use(express.logger());

app.all('/', function(request, response) {
	var jobName = request.query.jobName;

	if (!jobName) {
		jobName = 'liferay-portal-master-clone';
	}

	console.log("jobName: " + jobName);

	var content = "";

	content += htmlize("h1", jobName);

	_jenkinsToJSON(jobName);

	response.send(content);
});

var htmlize = function (tag, content) {
	return "<" + tag + ">" + content + "</" + tag + ">"
}

var _buildToJSON = function(build) {
	var buildNumber = build.number;
	var buildURL = build.url;

	var jenkinsBuildURL = buildURL + 'testReport/' + _JENKINS_API_SUFFIX_URL;

	restler.get(jenkinsBuildURL, options).on('complete', function(jenkinsBuild) {
		var passCount = jenkinsBuild.passCount;
		var skipCount = jenkinsBuild.skipCount;
		var failCount = jenkinsBuild.failCount;

		content += "<ul>" + buildNumber;
		content += htmlize("li", "Passing Tests: " + passCount);
		content += htmlize("li", "Skipped Tests: " + skipCount);
		content += htmlize("li", "Failing Tests: " + failCount);
		content += htmlize("li", "Total Tests: " + (passCount + skipCount + failCount));
		content += "</ul>";
	});
}

var _jenkinsToJSON = function(jobName) {
	var options = {
			username: 'liferay',
  			password: 'r3m3mb3r',
	};

	var jenkinsJobURL = _JENKINS_API_BASE_URL + '/job/' + jobName + '/' + _JENKINS_API_SUFFIX_URL;

	restler.get(jenkinsJobURL, options).on('complete', function(jenkinsJob) {
		var builds = jenkinsJob.builds;

		console.log(builds);

		builds.forEach(function(build) {
			console.log(build.number);
		});
	});
}

var port = process.env.PORT || 5000;

app.listen(port, function() {
	console.log("Listening on " + port);
});