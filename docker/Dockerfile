FROM alpine:3.4

COPY texlive.profile builder.rb.patch jumoline.sty redpen-conf.xml check.sh otf-up-source.map rmsty.py binding.sh print.sh review.py ./

ENV LANG=ja_JP.UTF-8	\
	PATH=$PATH:/usr/local/texlive/2016/bin/x86_64-linux

RUN apk add --update python ruby zip libc6-compat py-pillow py-setuptools graphviz openjdk8-jre fontconfig ghostscript imagemagick poppler-utils	\
	&& apk add --virtual build-builddeps wget xz coreutils ca-certificates perl fontconfig gcc make python-dev musl-dev cairo-dev pango-dev	binutils findutils	\
	&& ln -s /lib/ /lib64	\
	&& wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz	\
	&& tar zxvf install-tl-unx.tar.gz	\
	&& ./install-tl-*/install-tl --profile="texlive.profile"	\
	&& mv jumoline.sty /usr/local/texlive/texmf-local/tex/latex/local/	\
	&& wget "https://github.com/adobe-fonts/source-han-sans/blob/release/SubsetOTF/JP/SourceHanSansJP-Medium.otf?raw=true" -O "SourceHanSansJP-Medium.otf"	\
	&& wget "https://github.com/adobe-fonts/source-han-sans/blob/release/SubsetOTF/JP/SourceHanSansJP-Bold.otf?raw=true" -O "SourceHanSansJP-Bold.otf"	\
	&& mkdir -p "/usr/local/texlive/texmf-local/fonts/opentype"	\
	&& mv "SourceHanSansJP-Medium.otf" "SourceHanSansJP-Bold.otf" "/usr/local/texlive/texmf-local/fonts/opentype/"	\
	&& mkdir -p "/usr/local/texlive/texmf-local/fonts/map/dvipdfmx"	\
	&& mv "otf-up-source.map" "/usr/local/texlive/texmf-local/fonts/map/dvipdfmx/"	\
	&& ln -s `kpsewhich ptex-ipaex.map` "/usr/local/texlive/texmf-local/fonts/map/dvipdfmx/ptex-source.map"	\
	&& ln -s `kpsewhich uptex-ipaex.map` "/usr/local/texlive/texmf-local/fonts/map/dvipdfmx/uptex-source.map"	\
	&& ln -s `kpsewhich otf-ipaex.map` "/usr/local/texlive/texmf-local/fonts/map/dvipdfmx/otf-source.map"	\
	&& mktexlsr	\
	&& kanji-config-updmap-sys source	\
	&& sed -ie "s/^\(  \/\(Courier\|Helvetica\|Times-Roman\|Symbol\) \/.*\)/%\1/" /usr/share/ghostscript/*/Resource/Init/gs_pdfwr.ps	\
	&& mkdir -p /usr/share/fonts	\
	&& ln -s /usr/local/texlive/2016/texmf-dist/fonts/truetype/public/ipaex/ipaexg.ttf /usr/share/fonts/ipaexg.ttf	\
	&& rm -f /usr/share/ghostscript/9.19/Resource/CIDFSubst/DroidSansFallback.ttf	\
	&& ln -s /usr/share/fonts/ipaexg.ttf /usr/share/ghostscript/9.19/Resource/CIDFSubst/DroidSansFallback.ttf	\
	&& fc-cache -fv	\
	&& gem install math_ml --no-rdoc --no-ri	\
	&& gem install review -v 2.1.0 --no-rdoc --no-ri	\
	&& cd /usr/lib/ruby/gems/*/gems/review-2.1.0/lib/review/ && patch -u < /builder.rb.patch && cd /	\
	&& easy_install-2.7 blockdiag seqdiag actdiag nwdiag reportlab	\
	&& echo -e "[blockdiag]\nfontpath = /usr/share/fonts/ipaexg.ttf\n" > $HOME/.blockdiagrc	\
	&& echo -e "[seqdiag]\nfontpath = /usr/share/fonts/ipaexg.ttf\n" >> $HOME/.blockdiagrc	\
	&& echo -e "[actdiag]\nfontpath = /usr/share/fonts/ipaexg.ttf\n" >> $HOME/.blockdiagrc	\
	&& echo -e "[nwdiag]\nfontpath = /usr/share/fonts/ipaexg.ttf\n" >> $HOME/.blockdiagrc	\
	&& wget https://sourceforge.net/projects/gnuplot/files/gnuplot/5.0.5/gnuplot-5.0.5.tar.gz	\
	&& tar zxvf gnuplot-5.0.5.tar.gz	\
	&& cd gnuplot-5.0.5/	\
	&& CFLAGS="-Os" CXXFLAGS="-Os" OBJCFLAGS="-Os" ./configure	\
	&& make	\
	&& make install	\
	&& strip /usr/local/bin/gnuplot	\
	&& cd /	\
	&& mv print.sh /usr/local/bin/	\
	&& mv binding.sh /usr/local/bin/	\
	&& mv check.sh /usr/local/bin/	\
	&& mv review.py /usr/local/bin/	\
	&& wget https://github.com/redpen-cc/redpen/releases/download/redpen-1.7.6/redpen-1.7.6.tar.gz	\
	&& tar zxvf redpen-1.7.6.tar.gz	\
	&& mv redpen-distribution-1.7.6/ redpen/	\
	&& mv /redpen-conf.xml /redpen/bin/	\
	&& rm -rf /redpen/bin/redpen-server* /redpen/sample-doc/	\
	&& rm -rf /gnuplot-5.0.5* /install-tl* /builder.rb.patch /texlive.profile /redpen-1.7.6.tar.gz	\
	&& strip /usr/bin/getconf /usr/bin/iconv /usr/bin/getent	\
	&& rm -rf /usr/local/texlive/2016/install-tl*	\
	&& rm -rf /usr/local/texlive/2016/texmf-dist/fonts/afm/public/cm-super/	\
	&& rm -rf /usr/share/gtk-doc/	\
	&& rm -rf /usr/lib/python2.7/lib2to3/ /usr/lib/python2.7/site-packages/pip-*.egg/	\
	&& rm -rf /usr/local/texlive/2016/texmf-dist/fonts/afm/public/cm-super/	\
	&& rm -rf /usr/lib/ruby/gems/2.3.0/cache/	\
	&& rm -rf /usr/local/texlive/2016/tlpkg/	\
	&& rm -rf /usr/local/texlive/2016/texmf-dist/fonts/truetype/public/ipaex/ipagp.ttf	\
	&& rm -rf /usr/local/texlive/2016/texmf-dist/fonts/truetype/public/ipaex/ipamp.ttf	\
	&& rm -rf /usr/local/texlive/2016/texmf-dist/fonts/truetype/public/ipaex/ipam.ttf	\
	&& rm -rf /usr/local/texlive/2016/texmf-dist/fonts/truetype/public/ipaex/ipag.ttf	\
	&& find / -path "/proc" -prune	\
		-o -name "*.log" -o -name "*.tex" -o -name "*.html" -o -name "*.md" -o -name "*.ini"	\
		-o -name "*.example" -o -name "*.lua" -o -name "*.c" -o -name "*.h" -o -name "*.ins"	\
		-o -name "*.gif" -o -name "*.jpg" -o -name "*.png" -o -name "*.eps" -o -name "*.ico"	\
		-o -name "*.pdf" -o -name "*.zip" -o -name "*.exe" -o -name "*.*gz"	-o -iname "*COPYING*"	\
		-o -iname "*README*" -o -name "*LICENSE*"  -o -name "*.pyc" -o -name "*hiramin*"	\
		-o -name "*hirakaku*" -o -name "*hiramaru*" -type f | grep -xv "/proc" | xargs rm -rf	\
	&& find / -path "/proc" -prune	\
		-o -name "doc" -o -iname "*sample*" -o -iname "*example*" -o -iname "*manual*"	\
		-o -name "*beamer*" -o -iname "demo" -o -iname "tests" -o -iname "source"	\
		-o -name "lua*tex" -o -name "ptex" -o -name "uptex" -o -name "xe*tex"	\
		-o -iname "images" -o -name "VLGothic" -type d | grep -xv "/proc" | xargs rm -rf \
	&& find / -path "/usr/share/ghostscript" -prune	\
		-o -name "*.ps" -type f | grep -xv "/usr/share/ghostscript" | xargs rm -rf	\
	&& find / -name "*.cls" -type f | grep -v "jsbook" | xargs rm -rf	\
	&& python /rmsty.py `find /usr/lib/ruby/gems/*/gems/review*/ -type f`	\
	&& rm -f /rmsty.py	\
	&& rm -rf /usr/local/texlive/2016/texmf-dist/fonts/afm	\
	&& rm -rf /usr/local/texlive/2016/texmf-dist/fonts/misc	\
	&& rm -rf /usr/local/texlive/2016/texmf-dist/fonts/opentype	\
	&& find /usr/ -empty -type d | xargs rm -rf	\
	&& apk del --purge build-builddeps	\
	&& rm -rf /var/cache/apk/*
