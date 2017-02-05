import sys
import re
import subprocess
import os
import shutil

def getPackages(filename):
	r = re.compile('\\\\(?:usepackage|RequirePackage).*?\{([\w,\s\-]+?)\}', re.MULTILINE | re.DOTALL)

	f = open(filename, 'r')
	names = r.findall(f.read())
	f.close()

	packages = set()
	for name in names:
		for tmp in name.split(','):
			packages.add(tmp.strip())

	return packages


if __name__ == '__main__':
	packages = set([
		'fancyhdr', 'xcolor', 'bm', 'pxjahyper', 'float', 'otf', 'framed', 'plext',
		'alltt', 'pdfpages', 'amsfonts', 'graphicx', 'wrapfig', 'jumoline', 'geometry',
		'okumacro', 'jlisting', 'listings', 'hyperref', 'amsmath', 'ascmac', 'fontenc',
		'inputenc', 'jslogo', 'fix-cm', 'fixltx2e', 'textcomp', 'lmodern'
	])

	for arg in sys.argv[1:]:
		packages = packages.union(getPackages(arg))

	traveled = set([])
	while packages:
		package = packages.pop()
		if package in traveled: continue

		p = subprocess.Popen("kpsewhich -progname=uplatex %s.sty" % package,
			shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		stdout, stderr = p.communicate()

		filename = stdout.strip()
		if not filename or not os.path.isfile(filename): continue
		packages = packages.union(getPackages(filename))

		traveled.add(package)

	for root, dirnames, filenames in os.walk('/usr/local/texlive/'):
		for filename in filenames:
			if not filename.endswith('.sty'): continue

			package = filename.replace('.sty', '')
			if package in traveled: continue

			try:
				if root.endswith(package):
					shutil.rmtree(root)
				else:
					os.remove(os.path.join(root, filename))
			except OSError:
				pass

