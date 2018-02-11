FROM alpine:3.7
RUN apk --update stats
ENV LANG=ja_JP.UTF-8
ENV PATH=$PATH:/usr/local/texlive/2017/bin/x86_64-linux
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
RUN wget -q http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN tar zxf install-tl-unx.tar.gz
COPY texlive.profile /
RUN apk add libc6-compat
RUN ./install-tl-*/install-tl -profile texlive.profile
COPY jumoline.sty /
RUN mv jumoline.sty $(kpsewhich -var-value TEXMFLOCAL)/tex/latex/local/
RUN mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype
RUN wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Medium.otf?raw=true" -O SourceHanSans-Medium.otf
RUN wget -q "https://github.com/adobe-fonts/source-han-sans/blob/release/OTF/Japanese/SourceHanSans-Bold.otf?raw=true" -O SourceHanSans-Bold.otf
RUN wget -q "https://github.com/adobe-fonts/source-han-serif/blob/release/OTF/Japanese/SourceHanSerif-Regular.otf?raw=true" -O SourceHanSerif-Regular.otf
RUN mv SourceHan*.otf $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/
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
RUN gem install review -v 2.4.0 --no-rdoc --no-ri
RUN apk add nodejs
RUN apk add nodejs-npm
RUN npm install -g tabooular
RUN npm install -g prh
RUN apk add ghc
RUN apk add cabal
RUN git clone --depth 1 https://github.com/jgm/pandoc.git /pandoc
RUN apk add musl-dev
RUN cd /pandoc && cabal update && cd /
RUN cd /pandoc && cabal install --only-dependencies && cd /
RUN cd /pandoc && cabal configure --disable-library-vanilla --enable-shared --enable-executable-dynamic --flags=-https && cd /
RUN cd /pandoc && cabal build && cd /
