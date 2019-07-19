#!/usr/bin/nodejs
/*
return the actual point release of a given stable or old stable release
in the same format as /etc/debian_version
*/

const XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

const stableURL = 'http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/';
const oldStableURL = 'http://cdimage.debian.org/mirror/cdimage/archive/latest-oldstable/amd64/iso-cd/';

// change this after each major debian release
const releaseMap = {
  stretch: oldStableURL,
  buster: stableURL,
  bullseye: '',
  bookworm: '',
  testing: ''
}

const develVersion = '10.0';

// main
const codename = getArgs();
let lastMajorMinor;

if (! /^http/.test(releaseMap[codename])) {
  lastMajorMinor = develVersion;
} else {
  lastMajorMinor = getlastRelease(releaseMap[codename]);
}

console.log(lastMajorMinor);

function usage() {
  console.log(`usage: ${process.argv[1]} debian_release_codename (buster ...)`);
  process.exit(1);
}

function getArgs() {
  if (process.argv.length != 3) usage();

  const release = process.argv[2].replace(/^contrib-/, '');
  if (!release) {
    console.error(`usage:  ${process.argv[1]} Debian_release_codename`);
    process.exit(1);
  }
  if (releaseMap[release.replace()] == null) {
    console.log(`unkown release: ${release}`);
    process.exit(1);
  }
  return release;
}

function getlastRelease(releaseURL) {
  const req = new XMLHttpRequest();
  req.open('GET', releaseURL + 'SHA256SUMS', false);
  req.send(null);

  if (req.status >= 400) {
    console.error(`error fetching ${releaseURL}SHA256SUMS, got HTTP status code ${req.status}`);
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

