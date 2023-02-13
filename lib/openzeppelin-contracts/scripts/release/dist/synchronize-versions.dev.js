#!/usr/bin/env node
// Synchronizes the version in contracts/package.json with the one in package.json.
// This is run automatically when npm version is run.
"use strict";

var fs = require('fs');

var cp = require('child_process');

setVersion('contracts/package.json');

function setVersion(file) {
  var json = JSON.parse(fs.readFileSync(file));
  json.version = process.env.npm_package_version;
  fs.writeFileSync(file, JSON.stringify(json, null, 2) + '\n');
  cp.execFileSync('git', ['add', file]);
}