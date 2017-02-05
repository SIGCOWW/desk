#! /usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import subprocess
import re
import shutil
import tempfile

def run(cmd, conf):
	# Backup catalog.xml
	dirname = os.path.dirname(conf)
	catalog = dirname + './catalog.yml'
	bakcat = tempfile.mkstemp(suffix='.yml', dir=dirname)
	errmsg = tempfile.mkstemp(suffix='.re', dir=dirname)
	shutil.copyfile(catalog, bakcat[1])

	# Run
	code = None
	r = re.compile('compile error in (.+)\.(?:re|tex)')
	for i in range(10):
		p = subprocess.Popen([cmd, conf], stderr=subprocess.PIPE)
		stdout, stderr = p.communicate()
		sys.stderr.write(stderr)
		errors = r.findall(stderr)
		if len(errors) == 0:
			code = i*256 + p.returncode
			break

		# Modify catalog.xml
		print("RETRY")
		parts = []
		with open(catalog, 'r') as f: files = f.readlines()
		for line in files:
			if ':' in line: parts.append([ line ])
			if '-' in line and (True not in [ err in line for err in errors ]): parts[len(parts) - 1].append(line)
		parts[0].insert(1, '  - {0}\n'.format(os.path.basename(errmsg[1])))

		with open(catalog, 'w') as f:
			for part in parts:
				if len(part) < 2: continue
				for par in part: f.write(par)
				f.write('\n')
		with os.fdopen(errmsg[0], 'a') as f: f.write('= WARNING-{0}\n//emlist{{\n{1}//}}\n\n'.format(i, stderr))

	# Recovery catalog.xml
	shutil.copyfile(bakcat[1], catalog)
	os.remove(bakcat[1])
	os.remove(errmsg[1])
	return code


if __name__ == '__main__':
	argv = sys.argv
	argc = len(argv)
	if argc != 4: exit(1)

	status = run(argv[1], argv[2])
	if status is None: exit(1)
	with open(argv[3], 'w') as f: f.write('{0:d}'.format(status // 256))
	exit(0)
