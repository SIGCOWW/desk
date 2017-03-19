var BLACKLIST = [
	/なほるど/,
	/得るする/,
	/をであり/,
	/技術書(展|店)/,
];

function validateSentence(sentence) {
	var txt = sentence.getContent();

	for (var i=0; i<BLACKLIST.length; i++) {
		if (!BLACKLIST[i].test(txt)) continue;
		addError(BLACKLIST[i] + ' は typo だと思います。', sentence);
	}
}
