#!/usr/bin/node
'use strict'
const fs = require('fs');
const Colibri = require('colibrijs');
const Image = require('canvas').Image;

const img = new Image();
img.src = fs.readFileSync(process.argv[2]);
const result = Colibri.extractImageColors(img, 'hex');

let str = `\\definecolor{bcolor}{HTML}{${result.background.substring(1)}}`
if (result.content.length === 0) {
	str += "\\colorlet{fcolor}{-bcolor}"
} else {
	str += `\\definecolor{fcolor}{HTML}{${result.content[0].substring(1)}}`
}

console.log(str);
