FROM alpine:3.8
ENV LANG=ja_JP.UTF-8 \
    PATH=$PATH:/usr/local/texlive/2018/bin/x86_64-linuxmusl \
    NODE_PATH=/usr/lib/node_modules
COPY texlive.profile jumoline.sty otf-up-source.map rule.yml *.rb colorpicker.js qr.js pdfcrop.sh extensions/*.rb locale.yml /
RUN apk add --update git fontconfig ghostscript imagemagick poppler-utils libc6-compat ruby zip ruby-json nodejs python openssh-client py2-pip py2-pillow \
    && apk add --virtual build-builddeps perl wget xz ca-certificates coreutils binutils findutils nodejs-npm pkgconfig cairo-dev pango-dev make g++ libjpeg-turbo-dev file \
    && wget -q http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
    && tar zxf install-tl-unx.tar.gz \
    && ./install-tl-*/install-tl -profile texlive.profile \
    && mv jumoline.sty $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/local/ \
    && mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype \
    && wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Medium.otf?raw=true" -O SourceHanSans-Medium.otf \
    && wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Bold.otf?raw=true" -O SourceHanSans-Bold.otf \
    && wget -q "https://github.com/adobe-fonts/source-han-sans/raw/master/LICENSE.txt" -O SourceHanSans-LICENSE.txt \
    && wget -q "https://github.com/adobe-fonts/source-han-serif/blob/release/OTF/Japanese/SourceHanSerif-Regular.otf?raw=true" -O SourceHanSerif-Regular.otf \
    && wget -q "https://github.com/adobe-fonts/source-han-serif/raw/master/LICENSE.txt" -O SourceHanSerif-LICENSE.txt \
    && mv SourceHan*.otf SourceHan*.txt $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/ \
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
    && gem install review -v 2.5.0 --no-rdoc --no-ri \
    && npm install -g tabooular \
    && npm install -g prh \
    && tlmgr update --self \
    && tlmgr install seqsplit caption bigfoot xcolor framed multirow cases pgf ifoddpage jknapltx rsfs pxpgfmark subfig marginfix tcolorbox mathtools calrsfs calligra cancel mathcomp doublestroke lm anyfontsize etoolbox kastrup ec ucs environ trimspaces palatino helvetic mathpazo pdfpages titlesec qrcode xkeyval \
    && wget -q https://github.com/zr-tex8r/BXcoloremoji/archive/v0.6.zip -O BXcoloremoji.zip \
    && unzip -q BXcoloremoji.zip \
    && mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji \
    && mv BXcoloremoji*/*.sty $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji \
    && mv BXcoloremoji*/LICENSE $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji \
    && mv BXcoloremoji*/emoji_images $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji \
    && mktexlsr \
    && cd /usr/lib/ && npm install canvas && cd / \
    && npm install -g colibrijs \
    && npm install -g canvas@1.6.13 --unsafe-perm \
    && wget -q https://github.com/prh/rules/archive/master.zip -O rules.zip && unzip -q rules.zip \
    && mv rules-master/ rules && rm -rf rules.zip \
    && mv rule.yml rules/languages/ja/ && sed -ie "s/^\(imports:\)\s*$/\1\n  - ..\/languages\/ja\/rule.yml/" /rules/media/techbooster.yml \
    && gem install diff-lcs --no-rdoc --no-ri \
    && wget -q https://github.com/faelys/libsoldout/archive/trunk.zip && unzip trunk.zip \
    && cd libsoldout-trunk/ && make mkd2latex mkd2html && mv libsoldout.so* /usr/lib/ && mv mkd2html mkd2latex /usr/bin/ \
    && strip `which mkd2html` && strip `which mkd2latex` \
    && gem install gemoji --no-rdoc --no-ri \
    && npm install -g sharp --unsafe-perm \
    && pip install CuteR \
    && rm -rf $(kpsewhich -var-value TEXMFLOCAL)/install-tl* /install-tl* /texlive.profile \
    && rm -rf /usr/local/texlive/20*/tlpkg/ /usr/local/texlive/20*/install-tl \
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
    && rm -rf trunk.zip libsoldout-trunk/ BXcoloremoji* \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/map/dvips \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/pk/ljfour/public/cm \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/source \
    && rm -rf /usr/local/texlive/20*/texmf-dist/dvips/ \
    && rm -rf /usr/local/texlive/20*/texmf-dist/fonts/tfm/ptex-fonts/standard/ \
    && find /usr/local/texlive/20*/texmf-dist/ -iname "*korea*" -o -iname "*chinese*" | grep -v '/proc/' | xargs rm -rf \
    && find /usr/local/texlive/20*/texmf-dist/fonts/ -iname "times" -o -iname "cm-super" -o -iname "courier" -o -iname "ncntrsbk" -o -iname "avantgar" -o -iname "bookman" -o -iname "zapfchan" -o -iname "tex-gyre" -o -iname "charter" -o -iname "utopia" | grep -v '/proc/' | xargs rm -rf \
    && rm -rf /usr/share/gtk-doc/ \
    && rm -rf /usr/lib/ruby/gems/*/cache/ \
    && rm -rf /usr/share/X11 /usr/share/alsa \
    && find / -iname "*.log" -o -iname "*.html" -o -iname "*.md" -o -iname "*.ini" -o -iname "*.example" -o -iname "*.lua" -o -iname "*.c" -o -iname "*.h" -o -iname "*.ins" -o -iname "*.gif" -o -iname "*.jpg" -o -iname "*.ico" -o -iname "*.zip" -o -iname "*.exe" -o -iname "*.*gz" -o -iname "*README*" -o -iname "*hiramin*" -o -iname "*hirakaku*" -o -iname "*hiramaru*" -o -iname "*.svg" -o -iname "doc" -o -iname "*sample*" -o -iname "*example*" -o -iname "*manual*" -o -iname "*beamer*" -o -iname "demo" -o -iname "tests" -o -iname "debian" -o -iname "lua*tex" -o -iname "ptex" -o -iname "uptex" -o -iname "xe*tex" -o -iname "images" -o -iname "VLGothic" -o -iname "*.png" -o -iname "*.lock" -o -iname "*.git" -o -iname "test.js" -o -iname "test" -o -iname "Makefile" -o -iname "*jlreq*" -o -iname "*.pl" | grep -v '/proc/' | xargs rm -rf \
    && find / -name '*.pdf' -type f | grep -v BXcoloremoji | xargs rm -rf \
    && find /usr/local/texlive/ -iname "*.ps" -o -iname "*.eps" | grep -v '/proc/' | xargs rm -rf \
    && find / -name '*.cls' -type f | grep -v jsbook | grep -v jsarticle | xargs rm -rf \
    && find /usr/ -empty -type d | xargs rm -rf \
    && find / -executable -type f | xargs file | grep "not stripped" | cut -d":" -f1 | xargs strip \
    && rm -rf /root/.ash_history /root/.config /root/.gem /root/.node-gyp /root/.npm /root/.wget-hsts \
    && rm -rf /usr/bin/npm /usr/lib/node_modules/npm \
    && cd  /usr/local/texlive/*/bin/x86_64-linuxmusl/ && rm -rf *mpost pdf*tex teckit_compile xdvi-xaw luatex53 makeindex *mendex && cd / \
    && cd /usr/local/texlive/*/texmf-dist/ && rm -rf fonts/truetype/public/arphic-ttf/ fonts/map/pdftex/ scripts/ makeindex/ && cd / \
    && find / -executable -type f | xargs grep "__rawmemchr" | cut -d":" -f1 | xargs rm -rf \
    && find / -xtype l | grep -v "/proc/" | xargs rm -rf \
    && rm -rf /usr/libexec/ /usr/x86_64-alpine-linux-musl/ /usr/lib/python3.6 \
    && rm -rf /usr/local/texlive/texmf-local/fonts/source \
    && echo lrks/desk > /etc/desk-release \
    && mkdir -p /usr/local/bin \
    && mv build.rb colorpicker.js qr.js pdfcrop.sh /usr/local/bin/ \
    && mkdir -p /extensions \
    && mv *.rb locale.yml /extensions \
    && apk del --purge build-builddeps \
    && find / -name apk | xargs rm -rf \
    && rm -rf /tmp/*
