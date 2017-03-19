#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
# $ cat eq.tex | tex2svg.rb | tee output.svg
#
require 'fileutils'
require 'securerandom'

if __FILE__ == $0
	eq = $stdin.read
	tex = <<'EOF'
\documentclass[dvipdfmx,uplatex,b5j]{jsbook}
\usepackage[deluxe,uplatex]{otf}
\usepackage[prefernoncjk]{pxcjkcat}
\usepackage[T1]{fontenc}
\usepackage[dvipdfmx,hiresbb]{graphicx}
\usepackage[dvipdfmx,table]{xcolor}
\usepackage[utf8x]{inputenc}
\usepackage{ascmac}
\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage{bm}
\usepackage{array}
\usepackage{exscale}
\usepackage{mathpazo}
\usepackage{tikz}
\usepackage{cases}
\pagestyle{empty}
\begin{document}
\begin{eqnarray*}
EOF
	tex += eq + <<'EOF'
\end{eqnarray*}
\end{document}
EOF

	tmpdir = '/tmp/' + SecureRandom.hex(8)
	FileUtils.mkdir_p(tmpdir)
	Dir.chdir(tmpdir)

	File.write('eq.tex', tex)
	system("uplatex eq.tex > /dev/null")
	system("xdvipdfmx eq.dvi > /dev/null")
	system("pdfcrop.sh eq.pdf eq-crop.pdf > /dev/null")
	system("inkscape --without-gui --file=eq-crop.pdf --export-plain-svg=eq.svg > /dev/null")
	puts(File.read('eq.svg'))
	FileUtils.rm_rf(tmpdir, :secure => true)
end
