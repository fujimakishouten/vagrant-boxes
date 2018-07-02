#!/usr/bin/nodejs

const XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

const stableURL = 'http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/';
const oldStableURL = 'http://cdimage.debian.org/mirror/cdimage/archive/latest-oldstable/amd64/iso-cd/';
const testingURL = 'https://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-cd/';

// change this after each major debian release
const releaseMap = {
  jessie: oldStableURL,
  'contrib-jessie': oldStableURL,
  stretch: stableURL,
  'contrib-stretch': stableURL,
  testing: testingURL,
  'contrib-testing': testingURL,
}

const testingVersion = 'buster/sid';

// main
const codename = getArgs();
let lastMajorMinor;

if (codename === 'testing') {
  lastMajorMinor = testingVersion;
} else {
  lastMajorMinor = getlastRelease(releaseMap[codename])
}

console.log(lastMajorMinor);

function getArgs() {
  let release;
  if (process.argv[2] && releaseMap[process.argv[2]] != null) {
    release = process.argv[2];
  } else {
    console.error(`usage:  ${process.argv[1]} Debian_release_codename`);
    process.exit(1);
  }

  return release;
}

function getlastRelease(releaseURL) {
  const req = new XMLHttpRequest();
  req.open('GET', releaseURL + 'SHA256SUMS', false);
  req.send(null);

  // req.status from the XMLHttpRequest node module is buggy,
  // it appends the responseText to the HTTP status code
  // TODO: replace with node-fetch ?
  const realStatus = parseInt(req.status.slice(0, 3));
  if (realStatus >= 400) {
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

  // version: two digits separated by dots, then the internal debian-cd version,
  // then the iso type
  const version = netinstChecksumLine.match(/(\d+\.\d+)\.\d+-amd64-netinst.iso$/)[1];

  return version;
}

