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
RUN wget -q https://github.com/prh/rules/archive/master.zip -O rules.zip && unzip -q rules.zip
RUN mv rules-master/ rules && rm -rf rules.zip
COPY rule.yml /
RUN mv rule.yml rules/languages/ja/ && sed -ie "s/^\(imports:\)\s*$/\1\n  - ..\/languages\/ja\/rule.yml/" /rules/media/techbooster.yml
RUN gem install diff-lcs --no-rdoc --no-ri
RUN wget -q https://github.com/faelys/libsoldout/archive/trunk.zip && unzip trunk.zip
RUN cd libsoldout-trunk/ && make mkd2latex mkd2html && mv libsoldout.so* /usr/lib/ && mv mkd2html mkd2latex /usr/bin/
RUN strip `which mkd2html` && strip `which mkd2latex`
RUN apk add openssh-client
RUN gem install gemoji --no-rdoc --no-ri
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
