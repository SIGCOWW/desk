FROM alpine:3.9
RUN apk --update stats
ENV LANG=ja_JP.UTF-8
ENV PATH=$PATH:/usr/local/texlive/2019/bin/x86_64-linuxmusl
RUN apk add git
RUN apk add perl
RUN apk add wget
RUN apk add xz
RUN apk add ca-certificates
RUN apk add coreutils
RUN apk add fontconfig
RUN apk add ghostscript
RUN apk add imagemagick6
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
RUN wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/SubsetOTF/JP/SourceHanSansJP-Medium.otf?raw=true" -O SourceHanSans-Medium.otf
RUN wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/SubsetOTF/JP/SourceHanSansJP-Bold.otf?raw=true" -O SourceHanSans-Bold.otf
RUN wget -q "https://github.com/adobe-fonts/source-han-sans/raw/master/LICENSE.txt" -O SourceHanSans-LICENSE.txt
RUN wget -q "https://github.com/adobe-fonts/source-han-serif/blob/release/SubsetOTF/JP/SourceHanSerifJP-Regular.otf?raw=true" -O SourceHanSerif-Regular.otf
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
RUN gem install review -v 2.5.0 -N
RUN apk add nodejs
RUN apk add nodejs-npm
RUN npm install -g tabooular
RUN npm install -g prh
RUN tlmgr update --self
RUN tlmgr install seqsplit caption bigfoot xcolor framed multirow cases pgf ifoddpage jknapltx rsfs pxpgfmark subfig marginfix tcolorbox mathtools calrsfs calligra cancel mathcomp doublestroke lm anyfontsize etoolbox kastrup ec ucs environ trimspaces palatino helvetic mathpazo pdfpages titlesec qrcode xkeyval
RUN mkdir -p $(kpsewhich -var-value TEXMFSYSVAR)/web2c/euptex && mktexfmt uplatex && mv $(kpsewhich -var-value TEXMFVAR)/web2c/euptex/uplatex.fmt $(kpsewhich -var-value TEXMFSYSVAR)/web2c/euptex/
RUN wget -q https://github.com/zr-tex8r/BXcoloremoji/archive/v0.7.zip -O BXcoloremoji.zip
RUN unzip -q BXcoloremoji.zip
RUN mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji
RUN mv BXcoloremoji*/*.sty $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji
RUN mv BXcoloremoji*/LICENSE $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji
RUN mv BXcoloremoji*/emoji_images $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/BXcoloremoji
RUN mktexlsr
RUN wget -q https://github.com/prh/rules/archive/master.zip -O rules.zip && unzip -q rules.zip
RUN mv rules-master/ rules && rm -rf rules.zip
COPY rule.yml /
RUN mv rule.yml rules/languages/ja/ && sed -ie "s/^\(imports:\)\s*$/\1\n  - ..\/languages\/ja\/rule.yml/" /rules/media/techbooster.yml
RUN gem install diff-lcs -N
RUN apk add make
RUN apk add g++
RUN wget -q https://github.com/faelys/libsoldout/archive/trunk.zip && unzip trunk.zip
RUN cd libsoldout-trunk/ && make mkd2latex mkd2html && mv libsoldout.so* /usr/lib/ && mv mkd2html mkd2latex /usr/bin/
RUN strip `which mkd2html` && strip `which mkd2latex`
RUN apk add openssh-client
RUN gem install gemoji -N
RUN apk add ruby-dev
RUN apk add imagemagick6-dev
RUN find /usr/bin/ -name '*-6' | xargs -L1 -I{} sh -c 'mv {} $(echo {} | sed s/-6//)'
RUN gem install cuterb -v 0.2.1 -N
RUN apk add zstd
RUN apk add curl
RUN wget -q https://github.com/lrks/phonto/releases/download/v0.0.3/phonto -O /usr/bin/phonto
RUN chmod +x /usr/bin/phonto
RUN apk add vim
RUN apk add file
RUN rm -rf $(kpsewhich -var-value TEXMFLOCAL)/install-tl* /install-tl* /texlive.profile /root/.texlive*/ /usr/local/texlive/20*/tlpkg/ /usr/local/texlive/20*/install-tl /usr/local/texlive/20*/release-texlive.txt /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/baekmuk/ /usr/local/texlive/20*/texmf-dist/scripts/tlcockpit /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipagp.ttf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipamp.ttf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipam.ttf /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ipag.ttf
RUN cd /usr/local/texlive/20*/texmf-dist/fonts/truetype/public/ipaex/ && rm -f ipaexm.ttf && ln -s ipaexg.ttf ipaexm.ttf && cd /
RUN cd /usr/share/ghostscript/*/Resource/CIDFSubst/ && rm -f DroidSansFallback.ttf && ln -s /usr/share/fonts/ipaexg.ttf DroidSansFallback.ttf && cd /
RUN rm -rf /usr/local/texlive/20*/texmf-dist/fonts/afm /usr/local/texlive/20*/texmf-dist/fonts/misc /usr/local/texlive/20*/texmf-dist/fonts/opentype trunk.zip libsoldout-trunk/ BXcoloremoji* /usr/local/texlive/20*/texmf-dist/fonts/map/dvips /usr/local/texlive/20*/texmf-dist/fonts/pk/ljfour/public/cm /usr/local/texlive/20*/texmf-dist/fonts/source /usr/local/texlive/20*/texmf-dist/dvips/ /usr/local/texlive/20*/texmf-dist/fonts/tfm/ptex-fonts/standard/
RUN find /usr/local/texlive/20*/texmf-dist/ -iname "*korea*" -o -iname "*chinese*" | grep -v '/proc/' | xargs rm -rf
RUN find /usr/local/texlive/20*/texmf-dist/fonts/ -iname "times" -o -iname "cm-super" -o -iname "courier" -o -iname "ncntrsbk" -o -iname "avantgar" -o -iname "bookman" -o -iname "zapfchan" -o -iname "tex-gyre" -o -iname "charter" -o -iname "utopia" | grep -v '/proc/' | xargs rm -rf
RUN rm -rf /usr/share/gtk-doc/ /usr/lib/ruby/gems/*/cache/ /usr/share/X11 /usr/share/alsa
RUN find / -iname "*.log" -o -iname "*.html" -o -iname "*.md" -o -iname "*.ini" -o -iname "*.example" -o -iname "*.lua" -o -iname "*.c" -o -iname "*.h" -o -iname "*.ins" -o -iname "*.gif" -o -iname "*.jpg" -o -iname "*.ico" -o -iname "*.zip" -o -iname "*.exe" -o -iname "*.*gz" -o -iname "*README*" -o -iname "*hiramin*" -o -iname "*hirakaku*" -o -iname "*hiramaru*" -o -iname "*.svg" -o -iname "doc" -o -iname "*sample*" -o -iname "*example*" -o -iname "*manual*" -o -iname "*beamer*" -o -iname "demo" -o -iname "tests" -o -iname "debian" -o -iname "lua*tex" -o -iname "ptex" -o -iname "uptex" -o -iname "xe*tex" -o -iname "images" -o -iname "VLGothic" -o -iname "*.png" -o -iname "*.lock" -o -iname "*.git" -o -iname "test.js" -o -iname "test" -o -iname "Makefile" -o -iname "*jlreq*" -o -iname "*.pl" | grep -v '/proc/' | xargs rm -rf
RUN find / -name '*.pdf' -type f | grep -v BXcoloremoji | xargs rm -rf
RUN find /usr/local/texlive/ -iname "*.ps" -o -iname "*.eps" | grep -v '/proc/' | xargs rm -rf
RUN find / -name '*.cls' -type f | grep -v jsbook | grep -v jsarticle | xargs rm -rf
RUN find /usr/ -empty -type d | xargs rm -rf
RUN find / -executable -type f | xargs file | grep "not stripped" | cut -d":" -f1 | xargs strip
RUN rm -rf /root/.ash_history /root/.config /root/.gem /root/.node-gyp /root/.npm /root/.wget-hsts /usr/bin/npm /usr/lib/node_modules/npm
RUN cd  /usr/local/texlive/*/bin/x86_64-linuxmusl/ && rm -rf *mpost pdf*tex teckit_compile xdvi-xaw luatex53 makeindex *mendex && cd /
RUN cd /usr/local/texlive/*/texmf-dist/ && rm -rf fonts/truetype/public/arphic-ttf/ fonts/map/pdftex/ scripts/ makeindex/ && cd /
RUN find / -executable -type f | xargs -L1 -I{} ldd {} 2>&1 1>/dev/null | grep "symbol not found" | cut -d":" -f1 | cut -d" " -f3 | uniq | xargs rm -rf
RUN find / -xtype l | grep -v "/proc/" | xargs rm -rf
RUN rm -rf /usr/libexec/ /usr/x86_64-alpine-linux-musl/ /usr/local/texlive/texmf-local/fonts/source /usr/share/fonts/Type1
RUN apk add python
RUN apk add py-pip
RUN pip install fonttools
RUN find / -name '*.ttf' -type f -o -name '*.otf' -type f | xargs -L1 -I{} sh -c 'pyftsubset {} --unicodes=U+0000-04FF,U+1E00-243F,U+2460-27BF,U+2900-29FF,U+2B00-2BFF,U+2E80-2FDF,U+3000-30FF,U+3190-319F,U+31F0-4DBF,U+4E00-9FFF,U+E000-FB4F,U+FE10-FE1F,U+FE30-FE4F,U+FF00-FFEF,U+1F100-1F2FF,U+20000-2A6DF,U+2A700-2B81F,U+2F800-2FA1F --layout-features-='valt','vert','vkrn','vpal','vrt2','frac','numr','dnom','ljmo','vjmo','tjmo','abvs','blws','abvm','blwm','nukt','akhn','rphf','rkrf','pref','blwf','half','abvf','pstf','cfar','vatu','cjct','init','pres','abvs','blws','psts','haln','dist','abvm','blwm','init','medi','fina','isol','med2','fin2','fin3','cswh','mset','stch' --output-file=/tmp/$(basename {}); mv /tmp/$(basename {}) {}'
RUN rm -rf /root/.cache/ /usr/lib/python2.7 /usr/bin/pyft* /usr/bin/fonttools
RUN ls -1d /usr/local/texlive/*/texmf-dist/fonts/map/dvipdfmx/ptex-fontmaps/* | grep -v ipa | xargs rm -rf
RUN rm -rf /usr/local/texlive/*/texmf-dist/fonts/map/dvipdfmx/morisawa /usr/local/texlive/*/texmf-dist/fonts/tfm/public/morisawa /usr/local/texlive/*/texmf-dist/fonts/vf/public/morisawa /usr/local/texlive/*/texmf-dist/tex/latex/morisawa
RUN echo lrks/desk:kancolle > /etc/desk-release
RUN mkdir -p /usr/local/bin
COPY *.rb /
COPY pdfcrop.sh /
RUN mv build.rb pdfcrop.sh /usr/local/bin/
RUN mkdir -p /extensions
COPY extensions/*.rb /
COPY locale.yml /
RUN mv *.rb locale.yml /extensions
