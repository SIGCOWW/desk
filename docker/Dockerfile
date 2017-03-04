FROM alpine:3.5

ENV LANG=ja_JP.UTF-8	\
	PATH=$PATH:/usr/local/texlive/2016/bin/x86_64-linux

RUN apk add --update ruby zip libc6-compat openjdk8-jre fontconfig ghostscript imagemagick poppler-utils
RUN apk add --virtual build-builddeps wget xz coreutils ca-certificates perl fontconfig binutils findutils
RUN ln -s /lib/ /lib64
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN tar zxvf install-tl-unx.tar.gz

COPY texlive.profile jumoline.sty otf-up-source.map ./
RUN ./install-tl-*/install-tl --profile="texlive.profile"
RUN mv jumoline.sty /usr/local/texlive/texmf-local/tex/latex/local/
RUN wget "https://github.com/adobe-fonts/source-han-sans/blob/release/SubsetOTF/JP/SourceHanSansJP-Medium.otf?raw=true" -O "SourceHanSansJP-Medium.otf"
RUN wget "https://github.com/adobe-fonts/source-han-sans/blob/release/SubsetOTF/JP/SourceHanSansJP-Bold.otf?raw=true" -O "SourceHanSansJP-Bold.otf"
RUN mkdir -p "$(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype"
RUN mv "SourceHanSansJP-Medium.otf" "SourceHanSansJP-Bold.otf" "$(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/"
RUN mkdir -p "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx"
RUN mv "otf-up-source.map" "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/"
RUN ln -s "$(kpsewhich ptex-ipaex.map)" "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/ptex-source.map"
RUN ln -s "$(kpsewhich uptex-ipaex.map)" "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/uptex-source.map"
RUN ln -s "$(kpsewhich otf-ipaex.map)" "$(kpsewhich -var-value TEXMFLOCAL)/fonts/map/dvipdfmx/otf-source.map"
RUN mktexlsr
RUN kanji-config-updmap-sys source
RUN sed -i "s/^\(  \/\(Courier\|Helvetica\|Times-Roman\|Symbol\) \/.*\)/%\1/" /usr/share/ghostscript/*/Resource/Init/gs_pdfwr.ps
RUN mkdir -p /usr/share/fonts
RUN ln -s "$(kpsewhich -var-value TEXMFLOCAL)/fonts/truetype/public/ipaex/ipaexg.ttf" /usr/share/fonts/ipaexg.ttf
#RUN rm -f /usr/share/ghostscript/*/Resource/CIDFSubst/DroidSansFallback.ttf
#RUN ln -s /usr/share/fonts/ipaexg.ttf /usr/share/ghostscript/*/Resource/CIDFSubst/DroidSansFallback.ttf
RUN fc-cache -fv
RUN gem install math_ml --no-rdoc --no-ri
RUN gem install review -v 2.1.0 --no-rdoc --no-ri

COPY redpen-conf.xml ./
RUN wget https://github.com/redpen-cc/redpen/releases/download/redpen-1.7.6/redpen-1.7.6.tar.gz
RUN tar zxvf redpen-1.7.6.tar.gz
RUN mv redpen-distribution-1.7.6/ redpen/
RUN mv /redpen-conf.xml /redpen/bin/
RUN rm -rf /redpen/bin/redpen-server* /redpen/sample-doc/ /install-tl* /texlive.profile /redpen-1.7.6.tar.gz

COPY print.sh binding.sh check.sh ./
RUN mv print.sh /usr/local/bin/
RUN mv binding.sh /usr/local/bin/
RUN mv check.sh /usr/local/bin/

RUN strip /usr/bin/getconf /usr/bin/iconv /usr/bin/getent
RUN rm -rf "$(kpsewhich -var-value TEXMFLOCAL)/install-tl"*

RUN apk add ruby-json
RUN apk add nodejs
RUN npm install -g tabooular@0.0.2

COPY slashbox.sty ./
RUN mv slashbox.sty /usr/local/texlive/texmf-local/tex/latex/local/
RUN mktexlsr

COPY compile.rb ./
RUN mv compile.rb /usr/local/bin/
