var express = require('express');
var restler = require('restler');
var Y = require('yui').use('promise');

var app = express();

var _JENKINS_API_BASE_URL = 'http://ci.liferay.org.es/jenkins';
var _JENKINS_API_SUFFIX_URL = 'api/json';

var _AUTH_OPTIONS = {
	username: 'liferay',
	password: 'r3m3mb3r',
};

var _builds = [];
var _content = "";

app.use(express.logger());

app.all('/', function(request, response) {
	var jobName = request.query.jobName;

	if (!jobName) {
		/*jobName = 'liferay-portal-master-clone';*/
		jobName = 'mdelapenya';
	}

	_content += htmlize("h1", jobName);

	getJob(jobName)
		.then(getBuilds)
		.then(loopBuilds)
		.then(render);
});

var getJob = function(jobName) {
	console.log("Getting the job [" + jobName + "]");

	return new Y.Promise(function(resolve, reject) {
		var jenkinsJobURL = _JENKINS_API_BASE_URL + '/job/' + jobName + '/' + _JENKINS_API_SUFFIX_URL;

		_requestData(jenkinsJobURL, resolve, reject);
	});
}

var getBuilds = function(jenkinsJob) {
	console.log("Getting the builds...");

	return new Y.Promise(function(resolve, reject) {
		var builds = jenkinsJob.builds;

		resolve(builds);
	});
}

var loopBuilds = function(builds) {
	console.log("Iterating though [" + builds.length + "] builds...");

	return new Y.Promise(function(resolve, reject) {
		builds.forEach(function(build) {
			getBuild(build)
				.then(printBuild);
		});
	});
}

var getBuild = function(build) {
	return new Y.Promise(function(resolve, reject) {
		var buildURL = build.url;

		var jenkinsBuildURL = buildURL + 'testReport/' + _JENKINS_API_SUFFIX_URL;

		_requestData(jenkinsBuildURL, resolve, reject);
	});
}

var printBuild = function(build) {
	return new Y.Promise(function(resolve, reject) {
		_builds.push(build);

		resolve(_builds);
	});
}

var render = function (value) {
	console.log("Builds loaded.");

	value.forEach(function(build) {
	/*
		console.log("Printing the build...");

		var passCount = build.passCount;
		var skipCount = build.skipCount;
		var failCount = build.failCount;

		console.log("Pass Count: " + passCount);
		console.log("Skip Count: " + skipCount);
		console.log("Fail Count: " + failCount);
		console.log("Total Count: " + (passCount + skipCount + failCount));
	*/
		console.log("build.passCount: " + build.passCount);
	});

	console.log("Builds printed.");
}

var _requestData = function(apiURL, resolve, reject) {
	var request = restler.get(apiURL, _AUTH_OPTIONS);

	request.setMaxListeners(0);

	request.on('complete', function(data) {
		console.log(apiURL);

		resolve(data);
	});

	request.on('failure', function(error) {
		reject(error);
	});
}

var htmlize = function (tag, content) {
	return "<" + tag + ">" + content + "</" + tag + ">"
}

var port = process.env.PORT || 5000;

app.listen(port, function() {
	console.log("Listening on " + port);
});