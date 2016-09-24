#!/usr/bin/nodejs
/* 
 * debian packages required for this script:
 * nodejs node-semver node-xmlhttprequest
 */

const fs = require('fs');
const semver = require('semver');
const XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

const debug = true;
const noDebug = false;
const currentURL = 'http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/';

var main = function() {
    var pathToManifest = getArgs(noDebug);
    var manifestVersion = getManifestVersion(pathToManifest, noDebug);
    var lastRelease = getlastRelease(currentURL, noDebug);

    console.log("manifest has", manifestVersion);
    console.log("cdimage has ", lastRelease.version);

    var outdated = isManifestOutdated(lastRelease.version, manifestVersion, noDebug);

    if (outdated) {
	console.log("updating ", pathToManifest);
	updateManifest(lastRelease, pathToManifest, noDebug);
    }
    else {
	console.log("no update needed");
    }
}

var usage = function() {
    console.error('usage: ' + process.argv[1] + ' manifest to update');
    process.exit(1);
}

var getArgs = function getArgs(debug) {
    debug && console.error(getArgs.name);

    var targetFile;

    if (process.argv[2]) {
	targetFile = process.argv[2];
    } else {
	usage();
    }
    debug && console.error(targetFile);
    return  targetFile;
}

var getManifestVersion = function getManifestVersion(pathToManifest, debug) {
    debug && console.error(getManifestVersion.name);
    var jsonFile = fs.readFileSync(pathToManifest, 'utf-8');
    if (!jsonFile) {
	usage();
    }
    debug && console.error(jsonFile.toString());
    
    try {
	var manifest = JSON.parse(jsonFile);
    }
    catch(e) {
	console.error('error parsing ' + pathToManifest);
	usage();
    }
    var version = manifest.variables.box_version;
    debug && console.error(version);
    
    return version;
}

var getlastRelease = function getlastRelease(currentURL, debug) {
    debug && console.error(getlastRelease.name);
    var req = new XMLHttpRequest();
    req.open('GET', currentURL + 'SHA256SUMS', false);
    req.send(null);

    var lines = req.responseText.split('\n');
    var netinst;

    for (var i = 0; i < lines.length; i++) {
	if (/debian-\d+\.\d+\.\d+-amd64-netinst.iso$/.test(lines[i])) {
	    netinst = lines[i];
	    break;
	}
    }

    var lastRelease = {};
    var sumAndIso = netinst.split('  ');
    var isoComponents = sumAndIso[1].split('-');

    lastRelease.sha256sum = sumAndIso[0];
    lastRelease.url = currentURL + sumAndIso[1];
    lastRelease.version = isoComponents[1];

    if (debug) {
	for (prop in lastRelease) {
	    if (lastRelease.hasOwnProperty(prop)) {
		console.error(prop, lastRelease[prop]);
	    }
	}
    }
    return lastRelease;
}

var isManifestOutdated = function isManifestOutdated(releasedVersion, manifestVersion, debug) {
    debug && console.error(isManifestOutdated.name);
    var isOutdated = semver.gt(releasedVersion, manifestVersion);
    debug && console.error('isOutdated:', isOutdated);
    return  isOutdated;
}

var updateManifest = function updateManifest(lastRelease, pathToManifest, debug) {
    debug && console.error(updateManifest.name);
    var manifest = fs.readFileSync(pathToManifest, 'utf-8');

    var lines = manifest.split('\n');
    lines.forEach(function(elt, i) {
    	if (/"box_version"/.test(elt)) {
    	    lines[i] = elt.replace(/\d+\.\d+\.\d+/, lastRelease.version);
    	    debug && console.error(lines[i]);
    	}
    	else if (/"iso_checksum"/.test(lines[i])) {
    	    lines[i] = elt.replace(/"iso_checksum": ".*",/, '"iso_checksum": "' + lastRelease.sha256sum + '",')
    	    debug && console.error(lines[i]);
    	}
    	else if(/"iso_url"/.test(lines[i])) {
    	    lines[i] = elt.replace(/"iso_url": ".*",/, '"iso_url": "' + lastRelease.url + '",');
    	    debug && console.error(lines[i]);
    	}
    });

    var fileToWrite ='';
   lines.forEach(function(elt, i) {
   	if (lines[i] !== lines[lines.length -1]) {
   	    fileToWrite += elt + '\n';
   	}
   });
    fs.writeFileSync(pathToManifest, fileToWrite);
    
    debug && console.error(fs.readFileSync(pathToManifest, 'utf-8'));
    return 'TODO';
}

main();