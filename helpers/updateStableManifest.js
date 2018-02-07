#!/usr/bin/nodejs
/*  update a packer json manifest when a new stable release
 *  appears on cdimage.debian.org
 *
 * debian packages required for this script:
 * nodejs node-semver node-xmlhttprequest
 */

const fs = require('fs');
const semver = require('semver');
const XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

const debug = false;
const releaseURL = 'http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/';
//const releaseURL = 'http://cdimage.debian.org/mirror/cdimage/archive/8.11.0/amd64/iso-cd/';

const pathToManifest = getArgs();
const manifestVersion = getManifestVersion(pathToManifest);
const onlineRelease = getlastRelease(releaseURL);

console.log("manifest has", manifestVersion);
console.log("cdimage has ", onlineRelease.version);

const outdated = isManifestOutdated(onlineRelease.version, manifestVersion);

if (outdated) {
  console.log("updating ", pathToManifest);
  updateManifest(onlineRelease, pathToManifest);
}
else {
  console.log("no update needed");
}

function usage() {
  console.error('usage: ' + process.argv[1] + ' manifest to update');
  process.exit(1);
}

function getArgs() {
  debug && console.error(getArgs.name);

  let targetFile;

  if (process.argv[2]) {
    targetFile = process.argv[2];
  } else {
    usage();
  }
  debug && console.error(targetFile);
  return targetFile;
}

function getManifestVersion(pathToManifest, debug) {
  debug && console.error(getManifestVersion.name);
  const jsonFile = fs.readFileSync(pathToManifest, 'utf-8');
  if (!jsonFile) {
    usage();
  }
  debug && console.error(jsonFile.toString());

  let manifest;
  try {
    manifest = JSON.parse(jsonFile);
  }
  catch (e) {
    console.error('error parsing ' + pathToManifest);
    usage();
  }

  const version = manifest.variables.box_version;
  debug && console.error(version);

  return version;
}

function getlastRelease(releaseURL, debug) {
  debug && console.error(getlastRelease.name);
  const req = new XMLHttpRequest();
  req.open('GET', releaseURL + 'SHA256SUMS', false);
  req.send(null);

  // req.status from the XMLHttpRequest node module is buggy,
  // it appends the responseText to the HTTP status code
  // TODO: replace with node-fetch ?
  const realStatus = parseInt(req.status.slice(0, 3));

  if (realStatus >= 400 ) {
    console.error(`error fetching ${releaseURL}SHA256SUMS, got HTTP status code ${realStatus}`);
    usage();
  }

  const lines = req.responseText.split('\n');
  let netinst;
  //isoName: debian string and three digits separated dots
  const isoRegex = /(debian-\d+\.\d+\.\d+-amd64-netinst.iso$)/;

  for (let line of lines) {
    if (isoRegex.test(line)) {
      netinst = line;
      break;
    }
  }

  let lastRelease = {};
  // sha256 sum: 64 characters at beginning of line, followed by two spaces
  lastRelease.sha256sum = netinst.match(/^(\S{64})\s{2}/)[1];
  // version: three digits separated by dots and ended by string amd64..
  lastRelease.version = netinst.match(/(\d+\.\d+\.\d+)-amd64-netinst.iso$/)[1];
  lastRelease.url = releaseURL + netinst.match(isoRegex)[1];


  if (debug) {
    for (prop in lastRelease) {
      if (lastRelease.hasOwnProperty(prop)) {
        console.error(prop, lastRelease[prop]);
      }
    }
  }
  return lastRelease;
}

function isManifestOutdated(releasedVersion, manifestVersion, debug) {
  debug && console.error(isManifestOutdated.name);
  const isOutdated = semver.gt(releasedVersion, manifestVersion);
  debug && console.error('isOutdated:', isOutdated);
  return isOutdated;
}

function updateManifest(lastRelease, pathToManifest, debug) {
  debug && console.error(updateManifest.name);
  const manifest = fs.readFileSync(pathToManifest, 'utf-8');

  const lines = manifest.split('\n');
  lines.forEach((elt, i) => {
    if (/"box_version"/.test(elt)) {
      lines[i] = elt.replace(/\d+\.\d+\.\d+/, lastRelease.version);
      debug && console.error(lines[i]);
    }
    else if (/"iso_checksum"/.test(lines[i])) {
      lines[i] = elt.replace(/"iso_checksum": ".*",/, '"iso_checksum": "' + lastRelease.sha256sum + '",');
      debug && console.error(lines[i]);
    }
    else if (/"iso_url"/.test(lines[i])) {
      lines[i] = elt.replace(/"iso_url": ".*",/, '"iso_url": "' + lastRelease.url + '",');
      debug && console.error(lines[i]);
    }
  });

  let fileToWrite = '';
  lines.forEach((elt, i) => {
    if (lines[i] !== lines[lines.length - 1]) {
      fileToWrite += elt + '\n';
    }
  });
  fs.writeFileSync(pathToManifest, fileToWrite);

  debug && console.error(fs.readFileSync(pathToManifest, 'utf-8'));
  return 'TODO';
}