FROM frolvlad/alpine-glibc:alpine-3.6
ENV LANG=ja_JP.UTF-8	\
	PATH=$PATH:/usr/local/texlive/2017/bin/x86_64-linux

#
# Base
#
COPY texlive.profile otf-up-source.map jumoline.sty redpen-conf.xml /
RUN apk add --update ruby zip openjdk8-jre fontconfig ghostscript imagemagick poppler-utils ruby-json nodejs \
	&& apk add --virtual build-builddeps wget xz coreutils ca-certificates fontconfig binutils findutils git perl gcc nodejs-npm \
	&& mkdir -p /usr/local/bin \
	&& wget -q http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
	&& tar zxvf install-tl-unx.tar.gz \
	&& ./install-tl-*/install-tl -profile "texlive.profile" \
	&& mv jumoline.sty "$(kpsewhich -var-value TEXMFLOCAL)/tex/latex/local/" \
	&& mkdir -p "$(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype" \
	&& wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Medium.otf?raw=true" -O "SourceHanSans-Medium.otf" \
	&& wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Bold.otf?raw=true" -O "SourceHanSans-Bold.otf" \
	&& wget -q "https://github.com/adobe-fonts/source-han-serif/blob/release/OTF/Japanese/SourceHanSerif-Regular.otf?raw=true" -O "SourceHanSerif-Regular.otf" \
	&& mv SourceHan*.otf "$(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/" \
	&& mkdir -p "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx" \
	&& mv "otf-up-source.map" "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/" \
	&& ln -s "$(kpsewhich ptex-ipaex.map)" "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/ptex-source.map" \
	&& ln -s "$(kpsewhich uptex-ipaex.map)" "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/uptex-source.map" \
	&& ln -s "$(kpsewhich otf-ipaex.map)" "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/otf-source.map" \
	&& mktexlsr \
	&& kanji-config-updmap-sys source \
	&& sed -i "s/^\(  \/\(Courier\|Helvetica\|Times-Roman\|Symbol\) \/.*\)/%\1/" /usr/share/ghostscript/*/Resource/Init/gs_pdfwr.ps \
	&& mkdir -p /usr/share/fonts \
	&& ln -s "$(kpsewhich -var-value TEXMFLOCAL)/fonts/truetype/public/ipaex/ipaexg.ttf" /usr/share/fonts/ipaexg.ttf \
	&& fc-cache -fv \
	&& rm -rf "$(kpsewhich -var-value TEXMFLOCAL)/install-tl"* \
	&& rm -rf /install-tl* /texlive.profile \
#	&& rm -rf /usr/local/texlive/201*/tlpkg/ \
	&& rm -rf /usr/local/texlive/201*/texmf-dist/fonts/truetype/public/ipaex/ipagp.ttf \
	&& rm -rf /usr/local/texlive/201*/texmf-dist/fonts/truetype/public/ipaex/ipamp.ttf \
	&& rm -rf /usr/local/texlive/201*/texmf-dist/fonts/truetype/public/ipaex/ipam.ttf \
	&& rm -rf /usr/local/texlive/201*/texmf-dist/fonts/truetype/public/ipaex/ipag.ttf \
	&& cd /usr/share/ghostscript/*/Resource/CIDFSubst/ && rm -f "DroidSansFallback.ttf" \
	&& ln -s "/usr/share/fonts/ipaexg.ttf" "DroidSansFallback.ttf" && cd / \
	&& rm -rf /usr/local/texlive/201*/texmf-dist/fonts/afm	\
	&& rm -rf /usr/local/texlive/201*/texmf-dist/fonts/misc	\
	&& rm -rf /usr/local/texlive/201*/texmf-dist/fonts/opentype \
	&& gem install math_ml --no-rdoc --no-ri \
	&& gem install review -v 2.3.0 --no-rdoc --no-ri \
	&& wget -q https://github.com/redpen-cc/redpen/releases/download/redpen-1.9.0/redpen-1.9.0.tar.gz \
	&& tar zxvf redpen-*.tar.gz \
	&& mv redpen-distribution-*/ redpen/ \
	&& mv /redpen-conf.xml /redpen/bin/ \
	&& rm -rf /redpen/js \
	&& git clone --depth 1 https://github.com/kongou-ae/redpen-validator.git /redpen/js \
	&& rm -rf /redpen/bin/redpen-server* /redpen/sample-doc/ /redpen-*.tar.gz \
	&& npm install -g tabooular \
	&& echo "Base"



#
# Debug
#
RUN wget -q https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-1-amd64.deb -O pandoc.deb \
	&& ar vx pandoc.deb \
	&& tar zxvf data.tar.gz './usr/bin/pandoc'

COPY ku1010.js typo.js build.rb reviewhook.rb /
RUN mv ku1010.js typo.js /redpen/js \
	&& mv build.rb reviewhook.rb /usr/local/bin/ \
#	&& cd /usr/local/texlive/2*/texmf-dist/ \
#	&& rm -rf ./fonts/map/dvips ./fonts/pk/ljfour/public/cm \
#		./fonts/source ./dvips/ ./fonts/tfm/ptex-fonts/standard/ \
#	&& find ./ \
#		-name "*korea*" -o -name "*chinese*" | xargs rm -rf \
#	&& find ./fonts/ -type d \
#		-name "times" -o -name "cm-super" -o -name "courier" \
#		-o -name "ncntrsbk" -o -name "avantgar" -o -name "bookman" \
#		-o -name "zapfchan" -o -name "tex-gyre" -o -name "charter" \
#		-o -name "utopia" -o -name "euler" | xargs rm -rf \
#	&& strip /usr/bin/getconf /usr/bin/iconv /usr/bin/getent \
#	&& rm -rf /usr/share/gtk-doc/ \
#	&& rm -rf /usr/lib/ruby/gems/*/cache/ \
#	&& find /usr -name "*.tex" | grep -v "pg" | xargs rm -rf \
#	&& find / -path "/proc" -prune	\
#		-o -name "*.log" -o -name "*.html" -o -name "*.md" -o -name "*.ini" \
#		-o -name "*.example" -o -name "*.lua" -o -name "*.c" -o -name "*.h" -o -name "*.ins" \
#		-o -name "*.gif" -o -name "*.jpg" -o -name "*.png" -o -name "*.eps" -o -name "*.ico" \
#		-o -name "*.pdf" -o -name "*.zip" -o -name "*.exe" -o -name "*.*gz"	-o -iname "*COPYING*" \
#		-o -iname "*README*" -o -name "*LICENSE*"  -o -name "*.py" -o -name "*.pyc" -o -name "*hiramin*" \
#		-o -name "*hirakaku*" -o -name "*hiramaru*" -o -name "*.svg" -type f | grep -xv "/proc" | xargs rm -rf \
#	&& find / -path "/proc" -prune \
#		-o -name "doc" -o -iname "*sample*" -o -iname "*example*" -o -iname "*manual*" \
#		-o -name "*beamer*" -o -iname "demo" -o -iname "tests" -o -iname "source" \
#		-o -name "lua*tex" -o -name "ptex" -o -name "uptex" -o -name "xe*tex" \
#		-o -iname "images" -o -name "VLGothic" -type d | grep -xv "/proc" | xargs rm -rf \
#	&& find / -path "/usr/share/ghostscript" -prune	\
#		-o -name "*.ps" -type f | grep -xv "/usr/share/ghostscript" | xargs rm -rf	\
#	&& find / -name "*.cls" -type f | grep -v "jsbook" | xargs rm -rf	\
#	&& find /usr/ -empty -type d | xargs rm -rf	\
#	&& apk del --purge build-builddeps	\
#	&& rm -rf /var/cache/apk/*
	&& echo "Debug"
