var FULLSTOP = {};
var COMMA = {};


function add(obj, key) {
	if (!(key in obj)) obj[key] = 0;
	obj[key] += 1;
}

function argmax(obj) {
	var key = null;
	var max = 0;

	Object.keys(obj).forEach(function(k) {
		if (obj[k] < max) return;
		key = k;
		max = obj[k];
	});

	return key;
}


function preValidateSentence(sentence) {
	for (var i=0; i<sentence.tokens.length; i++) {
		switch(sentence.tokens[i].tags[1]) {
		case '句点':
			add(FULLSTOP, sentence.tokens[i].surface);
			break;
		case '読点':
			add(COMMA, sentence.tokens[i].surface);
			break;
		}
	}
}

function validateSentence(sentence) {
	for (var i=0; i<sentence.tokens.length; i++) {
		switch(sentence.tokens[i].tags[1]) {
		case '句点':
			var k = argmax(FULLSTOP);
			if (k !== sentence.tokens[i].surface)
				addError('句点「'+sentence.tokens[i].surface+'」は「'+k+'」だと思います。', sentence);
			break;
		case '読点':
			var k = argmax(COMMA);
			if (k !== sentence.tokens[i].surface)
				addError('読点「'+sentence.tokens[i].surface+'」は「'+k+'」だと思います。', sentence);
			break;
		}
	}
}
