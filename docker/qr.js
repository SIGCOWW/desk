#!/usr/bin/node
'use strict'
const sharp = require('sharp');
sharp(process.argv[2])
  .resize(Number(process.argv[4]), Number(process.argv[4]), {
    fit: sharp.fit.cover,
    position: sharp.strategy.entropy
  }).toFile(process.argv[3], (err, info) => {});
