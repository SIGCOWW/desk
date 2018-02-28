FROM alpine:3.7
ENV LANG=ja_JP.UTF-8 \
    PATH=$PATH:/usr/local/texlive/2017/bin/x86_64-linux \
    NODE_PATH=/usr/lib/node_modules
COPY texlive.profile jumoline.sty otf-up-source.map *.rb colorpicker.js pdfcrop.sh extensions/*.rb locale.yml /
RUN apk add --update git perl fontconfig ghostscript imagemagick poppler-utils libc6-compat ruby zip ruby-json nodejs gzip openssh-client \
    && apk add --virtual build-builddeps wget xz ca-certificates coreutils binutils findutils nodejs-npm python pkgconfig cairo-dev make g++ libjpeg-turbo-dev \
    && wget -q http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
    && tar zxf install-tl-unx.tar.gz \
    && ./install-tl-*/install-tl -profile texlive.profile \
    && mv jumoline.sty $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/local/ \
    && mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype \
    && wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Medium.otf?raw=true" -O SourceHanSans-Medium.otf \
    && wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Bold.otf?raw=true" -O SourceHanSans-Bold.otf \
    && wget -q "https://github.com/adobe-fonts/source-han-serif/blob/release/OTF/Japanese/SourceHanSerif-Regular.otf?raw=true" -O SourceHanSerif-Regular.otf \
    && mv SourceHan*.otf $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/ \
    && mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx \
    && mv otf-up-source.map $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/ \
    && ln -s $(kpsewhich ptex-ipaex.map) $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/ptex-source.map \
    && ln -s $(kpsewhich uptex-ipaex.map) $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/uptex-source.map \
    && ln -s $(kpsewhich otf-ipaex.map) $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/otf-source.map \
    && mktexlsr \
    && kanji-config-updmap-sys source \
    && sed -i "s/^\(  \/\(Courier\|Helvetica\|Times-Roman\|Symbol\) \/.*\)/%\1/" /usr/share/ghostscript/*/Resource/Init/gs_pdfwr.ps \
    && mkdir -p /usr/share/fonts \
    && ln -s $(kpsewhich -var-value TEXMFLOCAL)/fonts/truetype/public/ipaex/ipaexg.ttf /usr/share/fonts/ipaexg.ttf \
    && fc-cache -fv \
    && gem install review -v 2.4.0 --no-rdoc --no-ri \
    && npm install -g tabooular \
    && npm install -g prh \
    && wget -q https://github.com/jgm/pandoc/releases/download/2.1.1/pandoc-2.1.1-1-amd64.deb \
    && ar x pandoc-*.deb \
    && tar Jxf data.tar.xz "./usr/bin/pandoc" \
    && gzexe /usr/bin/pandoc \
    && tlmgr install dvipng seqsplit float caption bigfoot xcolor framed wrapfig multirow cases pgf ifoddpage jknapltx rsfs pxpgfmark subfig marginfix tcolorbox mathtools listings calrsfs calligra cancel mathcomp doublestroke qrcode \
    && tlmgr install lm anyfontsize \
    && tlmgr install etoolbox kastrup ec ucs environ trimspaces palatino helvetic mathpazo pdfpages \
    && wget -q https://github.com/zr-tex8r/BXcoloremoji/archive/v0.5.zip -O BXcoloremoji.zip \
    && unzip -q BXcoloremoji.zip \
    && mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji \
    && mv BXcoloremoji*/*.sty $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji \
    && mv BXcoloremoji*/emoji_images $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji \
    && mktexlsr \
    && cd /usr/lib/ && npm install canvas && cd / \
    && npm install -g colibrijs \
    && git clone --depth 1 https://github.com/prh/rules.git \
    && gem install diff-lcs --no-rdoc --no-ri \
    && rm -rf $(kpsewhich -var-value TEXMFLOCAL)/install-tl* \
    && rm -rf /install-tl* /texlive.profile \
    && rm -rf /usr/local/texlive/20*/tlpkg/ \
    && rm -rf /usr/local/texlive/20*/install-tl \
    && rm -rf /usr/local/texlive/20*/release-texlive.txt \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/baekmuk/ \
    && rm -rf /usr/local/texlive/20*/texmf-dist/scripts/tlcockpit \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipagp.ttf \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipamp.ttf \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipam.ttf \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipag.ttf \
    && cd /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ && rm -f ipaexm.ttf && ln -s ipaexg.ttf ipaexm.ttf && cd / \
    && cd /usr/share/ghostscript/*/Resource/CIDFSubst/ && rm -f DroidSansFallback.ttf && ln -s /usr/share/fonts/ipaexg.ttf DroidSansFallback.ttf && cd / \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/afm \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/misc \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/opentype \
    && rm -rf /redpen/bin/redpen-server* /redpen/sample-doc/ /redpen-*.tar.gz \
    && rm -rf /redpen/js/symbol.js \
    && rm -rf pandoc-*.deb data.tar.xz debian-binary control.tar.gz \
    && rm -rf BXcoloremoji* \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/map/dvips \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/pk/ljfour/public/cm \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/source \
    && rm -rf /usr/local/texlive/20*/texmf-dist/dvips/ \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/tfm/ptex-fonts/standard/ \
    && find /usr/local/texlive/20*/texmf-dist/ -iname "*korea*" -o -iname "*chinese*" | grep -v '/proc/' | xargs rm -rf \
    && find /usr/local/texlive/20*/texmf-dist/fonts/ -iname "times" -o -iname "cm-super" -o -iname "courier" -o -iname "ncntrsbk" -o -iname "avantgar" -o -iname "bookman" -o -iname "zapfchan" -o -iname "tex-gyre" -o -iname "charter" -o -iname "utopia" | grep -v '/proc/' | xargs rm -rf \
    && strip /usr/bin/getconf /usr/bin/iconv /usr/bin/getent /usr/lib/libxml2.so.* \
    && rm -rf /usr/share/gtk-doc/ \
    && rm -rf /usr/lib/ruby/gems/*/cache/ \
    && rm -rf /usr/share/X11 /usr/share/alsa \
    && find / -iname "*.log" -o -iname "*.html" -o -iname "*.md" -o -iname "*.ini" -o -iname "*.example" -o -iname "*.lua" -o -iname "*.c" -o -iname "*.h" -o -iname "*.ins" -o -iname "*.gif" -o -iname "*.jpg" -o -iname "*.ico" -o -iname "*.zip" -o -iname "*.exe" -o -iname "*.*gz" -o -iname "*COPYING*" -o -iname "*README*" -o -iname "*LICENSE*" -o -iname "*.py" -o -iname "*.pyc" -o -iname "*hiramin*" -o -iname "*hirakaku*" -o -iname "*hiramaru*" -o -iname "*.svg" -o -iname "doc" -o -iname "*sample*" -o -iname "*example*" -o -iname "*manual*" -o -iname "*beamer*" -o -iname "demo" -o -iname "tests" -o -iname "source" -o -iname "lua*tex" -o -iname "ptex" -o -iname "uptex" -o -iname "xe*tex" -o -iname "images" -o -iname "VLGothic" | grep -v '/proc/' | xargs rm -rf \
    && find / -type d -name BXcoloremoji -prune -o -type f -name '*.png' | xargs rm -rf \
    && find / -type d -name BXcoloremoji -prune -o -type f -name '*.pdf' | xargs rm -rf \
    && find /usr/local/texlive/ -iname "*.ps" -o -iname "*.eps" | grep -v '/proc/' | xargs rm -rf \
    && find / -name '*.cls' -type f | grep -v jsbook | grep -v jsarticle | xargs rm -rf \
    && find /usr/ -empty -type d | xargs rm -rf \
    && mkdir -p /usr/local/bin \
    && mv build.rb /usr/local/bin/ \
    && mv colorpicker.js /usr/local/bin/ \
    && mv pdfcrop.sh /usr/local/bin/ \
    && mkdir -p /extensions \
    && mv *.rb locale.yml /extensions \
    && apk del --purge build-builddeps \
    && rm -rf /var/cache/apk* \
    && rm -rf /tmp/*
