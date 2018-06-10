module ReVIEW
  module PDFMakerOkuduke
    def make_colophon
      super
      t = Time.now
      t.localtime("+09:00")

      rows = []
      rows << ['発行日', Date.parse(@config["date"]).strftime("%Y年%-m月%-d日")]
      if @config.key?('pbl')
        rows << ['発　行', @config["pbl"].to_s]
        rows << ['',       @config["oth"].to_s] if @config.key?('oth')
      end
      rows << ['連絡先', @config["edt"].to_s] if @config.key?('edt')
      rows << ['', @config["feedback"].to_s] if @config.key?('feedback')
      rows << ['印刷所', @config["prt"].to_s] if (@config.key?('prt') and not(ENV['ONESIDE']))
      rows << ['ビルド', t.to_s]
      rows << ['', `review-pdfmaker --version`]
      rows << ['', `uplatex --version | head -n1`]
      rows << ['', "Alpine Linux #{`cat /etc/alpine-release`.strip} (Linux Kernel #{`uname -r`.strip})"]
      rows << ['', "SIGCOWW/desk https://hub.docker.com/r/lrks/desk/"]

      ret = ''
      rows.each do | r |
        ret += "{\\bfseries #{r[0]}} & \\textgt{#{escape_latex(r[1])}} \\\\\n"
      end
      return ret.strip
    end
  end
  PDFMaker.send(:prepend, PDFMakerOkuduke) if defined? PDFMaker
end