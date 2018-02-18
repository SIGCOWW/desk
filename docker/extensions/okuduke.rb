module ReVIEW
  module PDFMakerOkuduke
    def make_colophon
      super

      ENV['TZ'] = 'Asia/Tokyo'
      rows = [
        ['発行日', Date.parse(@config["date"]).strftime("%Y年%-m月%-d日")],
        ['発　行', @config["pbl"].to_s],
        ['', @config["oth"].to_s],
        ['連絡先', @config["edt"].to_s],
        ['印刷所', ENV['ONESIDE'] ? '電子版につき空欄' : @config["prt"].to_s],
        ['ビルド', Time.now.to_s],
        ['', `review-pdfmaker --version`],
        ['', `uplatex --version | head -n1`],
        ['', "Alpine Linux #{`cat /etc/alpine-release`.strip} (Linux Kernel #{`uname -r`.strip})"],
        ['', "SIGCOWW/desk \\url{https://hub.docker.com/r/lrks/desk/}"]
      ]

      ret = ''
      rows.each do | r |
        ret += "{\\bfseries #{r[0]}} & \\textgt{#{escape_latex(r[1])}} \\\\\n"
      end
      return ret.strip
    end
  end
  PDFMaker.send(:prepend, PDFMakerOkuduke) if defined? PDFMaker
end
