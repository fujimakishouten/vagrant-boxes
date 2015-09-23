#!/usr/bin/nodejs

/*
helper to upload vagrant base boxes to atlas

boxes hosted on atlas have the following schema:
accountName/codename/version/provider

which means we have to 
 * create first our account (debian)
 * then our codename (testing64)
 * then our version (9.0-beta)
 * then our provider (virtualbox)

*/

// not part of Javascript standard, so requires the xmlthttprequest node module
var XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

// var atlasToken = process.env.ATLAS_TOKEN || process.exit(255);
var codename = process.env.CODENAME || 'jessie64' 
var version = process.env.VERSION || '8.2.0';

// these are not going to change
const PROVIDER = 'virtualbox';
const ATLAS_URL = 'https://atlas.hashicorp.com/api/v1/box/debian/';

var checkStatus = function (codename, version) {
	var xhr = new XMLHttpRequest();
	var url = ATLAS_URL + codename + '/version/' +  version + '/provider/' + PROVIDER;
	xhr.open('GET', url, false);
	xhr.send(null);
	return xhr.responseText;
};

var createVersion = function(version, description) {
	version = {
		version: version,
		description: description
	};
	var xhr = new XMLHttpRequest();
	xhr.open('POST', ATLAS_URL + codename + '/versions', false);
	xhr.send(version);
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

console.log(checkStatus(codename,version));
