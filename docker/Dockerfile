FROM alpine:3.8
RUN apk --update stats
ENV LANG=ja_JP.UTF-8
ENV PATH=$PATH:/usr/local/texlive/2018/bin/x86_64-linuxmusl
RUN apk add git
RUN apk add perl
RUN apk add wget
RUN apk add xz
RUN apk add ca-certificates
RUN apk add coreutils
RUN apk add fontconfig
RUN apk add ghostscript
RUN apk add imagemagick
RUN apk add poppler-utils
RUN apk add binutils
RUN apk add findutils
RUN apk add libc6-compat
RUN wget -q http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN tar zxf install-tl-unx.tar.gz
COPY texlive.profile /
RUN ./install-tl-*/install-tl -profile texlive.profile
COPY jumoline.sty /
RUN mv jumoline.sty $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/local/
RUN mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype
RUN wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Medium.otf?raw=true" -O SourceHanSans-Medium.otf
RUN wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Bold.otf?raw=true" -O SourceHanSans-Bold.otf
RUN wget -q "https://github.com/adobe-fonts/source-han-sans/raw/master/LICENSE.txt" -O SourceHanSans-LICENSE.txt
RUN wget -q "https://github.com/adobe-fonts/source-han-serif/blob/release/OTF/Japanese/SourceHanSerif-Regular.otf?raw=true" -O SourceHanSerif-Regular.otf
RUN wget -q "https://github.com/adobe-fonts/source-han-serif/raw/master/LICENSE.txt" -O SourceHanSerif-LICENSE.txt
RUN mv SourceHan*.otf SourceHan*.txt $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/
RUN mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx
COPY otf-up-source.map /
RUN mv otf-up-source.map $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/
RUN ln -s $(kpsewhich ptex-ipaex.map) $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/ptex-source.map
RUN ln -s $(kpsewhich uptex-ipaex.map) $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/uptex-source.map
RUN ln -s $(kpsewhich otf-ipaex.map) $(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/otf-source.map
RUN mktexlsr
RUN kanji-config-updmap-sys source
RUN sed -i "s/^\(  \/\(Courier\|Helvetica\|Times-Roman\|Symbol\) \/.*\)/%\1/" /usr/share/ghostscript/*/Resource/Init/gs_pdfwr.ps
RUN mkdir -p /usr/share/fonts
RUN ln -s $(kpsewhich -var-value TEXMFLOCAL)/fonts/truetype/public/ipaex/ipaexg.ttf /usr/share/fonts/ipaexg.ttf
RUN fc-cache -fv
RUN apk add ruby
RUN apk add zip
RUN apk add ruby-json
RUN gem install review -v 2.5.0 --no-rdoc --no-ri
RUN apk add nodejs
RUN apk add nodejs-npm
RUN npm install -g tabooular
RUN npm install -g prh
RUN tlmgr install seqsplit caption bigfoot xcolor framed multirow cases pgf ifoddpage jknapltx rsfs pxpgfmark subfig marginfix tcolorbox mathtools calrsfs calligra cancel mathcomp doublestroke lm anyfontsize etoolbox kastrup ec ucs environ trimspaces palatino helvetic mathpazo pdfpages titlesec
RUN wget -q https://github.com/zr-tex8r/BXcoloremoji/archive/v0.6.zip -O BXcoloremoji.zip
RUN unzip -q BXcoloremoji.zip
RUN mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji
RUN mv BXcoloremoji*/*.sty $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji
RUN mv BXcoloremoji*/LICENSE $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji
RUN mv BXcoloremoji*/emoji_images $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji
RUN mktexlsr
RUN apk add python
RUN apk add pkgconfig
RUN apk add cairo-dev
RUN apk add pango-dev
RUN apk add make
RUN apk add g++
RUN apk add libjpeg-turbo-dev
RUN cd /usr/lib/ && npm install canvas && cd /
RUN npm install -g colibrijs
ENV NODE_PATH=/usr/lib/node_modules
RUN wget -q https://github.com/prh/rules/archive/master.zip -O rules.zip
RUN unzip -q rules.zip
RUN mv rules-master/ rules
RUN rm -rf rules.zip
RUN gem install diff-lcs --no-rdoc --no-ri
RUN wget -q https://github.com/faelys/libsoldout/archive/trunk.zip
RUN unzip trunk.zip
RUN cd libsoldout-trunk/ && make mkd2latex mkd2html && mv libsoldout.so* /usr/lib/ && mv mkd2html mkd2latex /usr/bin/
RUN strip `which mkd2html`
RUN strip `which mkd2latex`
RUN apk add openssh-client
RUN gem install gemoji --no-rdoc --no-ri
RUN apk add file
RUN rm -rf $(kpsewhich -var-value TEXMFLOCAL)/install-tl*
RUN rm -rf /install-tl* /texlive.profile
RUN rm -rf /usr/local/texlive/20*/tlpkg/
RUN rm -rf /usr/local/texlive/20*/install-tl
RUN rm -rf /usr/local/texlive/20*/release-texlive.txt
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/baekmuk/
RUN rm -rf /usr/local/texlive/20*/texmf-dist/scripts/tlcockpit
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipagp.ttf
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipamp.ttf
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipam.ttf
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipag.ttf
RUN cd /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ && rm -f ipaexm.ttf && ln -s ipaexg.ttf ipaexm.ttf && cd /
RUN cd /usr/share/ghostscript/*/Resource/CIDFSubst/ && rm -f DroidSansFallback.ttf && ln -s /usr/share/fonts/ipaexg.ttf DroidSansFallback.ttf && cd /
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/afm
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/misc
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/opentype
RUN rm -rf trunk.zip libsoldout-trunk/
RUN rm -rf BXcoloremoji*
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/map/dvips
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/pk/ljfour/public/cm
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/source
RUN rm -rf /usr/local/texlive/20*/texmf-dist/dvips/
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/tfm/ptex-fonts/standard/
RUN find /usr/local/texlive/20*/texmf-dist/ -iname "*korea*" -o -iname "*chinese*" | grep -v '/proc/' | xargs rm -rf
RUN find /usr/local/texlive/20*/texmf-dist/fonts/ -iname "times" -o -iname "cm-super" -o -iname "courier" -o -iname "ncntrsbk" -o -iname "avantgar" -o -iname "bookman" -o -iname "zapfchan" -o -iname "tex-gyre" -o -iname "charter" -o -iname "utopia" | grep -v '/proc/' | xargs rm -rf
RUN rm -rf /usr/share/gtk-doc/
RUN rm -rf /usr/lib/ruby/gems/*/cache/
RUN rm -rf /usr/share/X11 /usr/share/alsa
RUN find / -iname "*.log" -o -iname "*.html" -o -iname "*.md" -o -iname "*.ini" -o -iname "*.example" -o -iname "*.lua" -o -iname "*.c" -o -iname "*.h" -o -iname "*.ins" -o -iname "*.gif" -o -iname "*.jpg" -o -iname "*.ico" -o -iname "*.zip" -o -iname "*.exe" -o -iname "*.*gz" -o -iname "*README*" -o -iname "*.py" -o -iname "*.pyc" -o -iname "*hiramin*" -o -iname "*hirakaku*" -o -iname "*hiramaru*" -o -iname "*.svg" -o -iname "doc" -o -iname "*sample*" -o -iname "*example*" -o -iname "*manual*" -o -iname "*beamer*" -o -iname "demo" -o -iname "tests" -o -iname "source" -o -iname "lua*tex" -o -iname "ptex" -o -iname "uptex" -o -iname "xe*tex" -o -iname "images" -o -iname "VLGothic" -o -iname "*.png" -o -iname "*.lock" -o -iname "*.git" -o -iname "test.js" -o -iname "test" -o -iname "Makefile" -o -iname "*jlreq*" -o -iname "*.pl" | grep -v '/proc/' | xargs rm -rf
RUN find / -name '*.pdf' -type f | grep -v BXcoloremoji | xargs rm -rf
RUN find /usr/local/texlive/ -iname "*.ps" -o -iname "*.eps" | grep -v '/proc/' | xargs rm -rf
RUN find / -name '*.cls' -type f | grep -v jsbook | grep -v jsarticle | xargs rm -rf
RUN find /usr/ -empty -type d | xargs rm -rf
RUN find / -executable -type f | xargs file | grep "not stripped" | cut -d":" -f1 | xargs strip
RUN rm -rf /root/.ash_history /root/.config /root/.gem /root/.node-gyp /root/.npm /root/.wget-hsts
RUN rm -rf /usr/bin/npm /usr/lib/node_modules/npm
RUN cd  /usr/local/texlive/*/bin/x86_64-linuxmusl/ && rm -rf *mpost pdf*tex teckit_compile xdvi-xaw luatex53 makeindex *mendex && cd /
RUN cd /usr/local/texlive/*/texmf-dist/ && rm -rf fonts/truetype/public/arphic-ttf/ fonts/map/pdftex/ scripts/ makeindex/ && cd /
RUN rm -rf /usr/libexec/
RUN find / -executable -type f | xargs grep "__rawmemchr" | cut -d":" -f1 | xargs rm -rf
RUN find / -xtype l | grep -v "/proc/" | xargs rm -rf
RUN rm -rf /usr/x86_64-alpine-linux-musl/
RUN mkdir -p /usr/local/bin
COPY *.rb /
RUN mv build.rb /usr/local/bin/
COPY colorpicker.js /
RUN mv colorpicker.js /usr/local/bin/
COPY pdfcrop.sh /
RUN mv pdfcrop.sh /usr/local/bin/
RUN mkdir -p /extensions
COPY extensions/*.rb /
COPY locale.yml /
RUN mv *.rb locale.yml /extensions
