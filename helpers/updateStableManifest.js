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

const releaseURL = 'http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/';
const oldReleaseURL = 'http://cdimage.debian.org/mirror/cdimage/archive/latest-oldstable/amd64/iso-cd/';

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
  let targetFile;

  if (process.argv[2]) {
    targetFile = process.argv[2];
  } else {
    usage();
  }

  return targetFile;
}

function getManifestVersion(pathToManifest) {

  const jsonFile = fs.readFileSync(pathToManifest, 'utf-8');
  if (!jsonFile) {
    usage();
  }

  let manifest;
  try {
    manifest = JSON.parse(jsonFile);
  }
  catch (e) {
    console.error('error parsing ' + pathToManifest);
    usage();
  }
  return manifest.variables.box_version
}

function getlastRelease(releaseURL, debug) {
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
  let netinstChecksumLine;
  //isoName: debian string and three digits separated dots
  const isoRegex = /(debian-\d+\.\d+\.\d+-amd64-netinst.iso$)/;
  for (let line of lines) {
    if (isoRegex.test(line)) {
      netinstChecksumLine = line;
      break;
    }
  }

  let lastRelease = {};
  // sha256 sum: 64 characters at beginning of line, followed by two spaces
  lastRelease.sha256sum = netinstChecksumLine.match(/^(\S{64})\s{2}/)[1];
  // version: three digits separated by dots and ended by string amd64..
  lastRelease.version = netinstChecksumLine.match(/(\d+\.\d+\.\d+)-amd64-netinst.iso$/)[1];
  lastRelease.url = releaseURL + netinstChecksumLine.match(isoRegex)[1];

  return lastRelease;
}

function isManifestOutdated(releasedVersion, manifestVersion, debug) {
  const isOutdated = semver.gt(releasedVersion, manifestVersion);
  return isOutdated;
}

function updateManifest(lastRelease, pathToManifest) {
  const manifest = fs.readFileSync(pathToManifest, 'utf-8');

  const lines = manifest.split('\n');
  lines.forEach((elt, i) => {
    if (/"box_version"/.test(elt)) {
      lines[i] = elt.replace(/\d+\.\d+\.\d+/, lastRelease.version);
    }
    else if (/"iso_checksum"/.test(lines[i])) {
      lines[i] = elt.replace(/"iso_checksum": ".*",/, '"iso_checksum": "' + lastRelease.sha256sum + '",');
    }
    else if (/"iso_url"/.test(lines[i])) {
      lines[i] = elt.replace(/"iso_url": ".*",/, '"iso_url": "' + lastRelease.url + '",');
    }
  });

  let fileToWrite = '';
  lines.forEach((elt, i) => {
    if (lines[i] !== lines[lines.length - 1]) {
      fileToWrite += elt + '\n';
    }
  });
  fs.writeFileSync(pathToManifest, fileToWrite);

  return fileToWrite;
}