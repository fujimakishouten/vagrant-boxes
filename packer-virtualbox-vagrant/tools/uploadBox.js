#!/usr/bin/nodejs

/*
helper to upload vagrant base boxes to atlas

boxes hosted on atlas have the following schema:
accountName/codename/version/provider
CODENAME=wheezy64 VERSION=7.9.0 tools/uploadBox.js

which means we have to 
 * create first our account (debian)
 * then our codename (testing64)
 * then our version (9.0-beta)
 * then our provider (virtualbox)

*/

// not part of Javascript standard, so requires the xmlthttprequest node module from node-xmlhttprequest deb package
var XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

var atlasToken = process.env.ATLAS_TOKEN
if (!atlasToken) {
	console.log('ATLAS_TOKEN not set');
	 process.exit(255);
}
var codename = process.env.CODENAME || 'testing64'
var version = process.env.VERSION || '9.0.0';
var description = process.env.DESCRIPTION || '* new point release';

// these are not going to change for the momment
const PROVIDER = 'virtualbox';
const ATLAS_URL = 'https://atlas.hashicorp.com/api/v1/box/debian/';

var createVersion = function(version, description) {
	data = 'version[version]=' + version + '?' + 'version[description]=' + description;
	var xhr = new XMLHttpRequest();
	xhr.open('POST', ATLAS_URL + codename + '/versions', false);
	xhr.send(data);
	return xhr.responseText;
};

var createProvider = function(version) {
	provider = {
		name: PROVIDER
	};	
	var xhr = new XMLHttpRequest();
	xhr.open('POST', ATLAS_URL + codename + '/' 
	+ version +'/providers' + PROVIDER, false);
	xhr.send(provider);
	return xhr.responseText;
};

var getUploadPath = function(version) {
	var xhr = new XMLHttpRequest();
	xhr.open('GET', ATLAS_URL + codename + version + PROVIDER + '/upload?' + 'access_token=' + ATLAS_TOKEN, false);
	xhr.send(null);
	return xhr.responseText;
};

var uploadVersionProvider = function(version) {
	var xhr = new XMLHttpRequest();
	xhr.open('PUT', getUploadPath(version), false);
	xhr.send('debian-testing64.box');
	return xhr.responseText;
};

var logCall = function(restCall) {
	answer = JSON.parse(restCall);
	console.log(JSON.stringify(answer, null, 2));
}

logCall(createVersion(version, description));
