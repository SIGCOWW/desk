module ReVIEW
  class LATEXBuilder
    def table_header(id, caption)
      puts '\begin{table}[!htbp]' # 配置を変える
      puts '\centering'
      if caption.present?
        @table_caption = true
        puts macro('reviewtablecaption', compile_inline(caption))
      end
      puts macro('label', table_label(id))
    end

    def inline_b(str)
      if str.chars[-1].bytesize == 1
        macro('textbf', escape(str))
      else
        # 最後が和文なら \kanjiskip 挿入のためこっち
        '{\bfseries ' + escape(str) + '}'
      end
    end

    def inline_tt(str)
      txt = escape(str).gsub(' ', '\ ')
      '\texttt{\seqsplit{' + txt + '}}'
    end

    def inline_fn(id)
      if @book.config["footnotetext"]
        macro("footnotemark[#{@chapter.footnote(id).number}]", "")
      else
        '\nolinebreak' + macro('footnote', compile_inline(@chapter.footnote(id).content.strip))
      end
    end

    def lead(lines)
      latex_block 'leadw', lines
    end

    def compile_href(url, label)
      if /\A[a-z]+:/ =~ url
        if label
          macro('href', escape_url(url), escape(label))
        else
          "\\href{#{escape_url(url)}}{\\seqsplit{#{escape(url)}}}"
        end
      else
        macro('ref', url)
      end
    end
  end

  class HTMLBuilder
    def image_image(id, caption, metric)
      unless metric.nil?
        tmp = metric.split('=')
        if tmp[0] === 'scale'
          min = 1
          argmin = 0
          num = tmp[1].to_f
          lst = [ 0.1, 0.2, 0.25, 0.3, 0.33, 0.4, 0.5, 0.6, 0.67, 0.70, 0.75, 0.80, 0.9, 1 ]
          lst.each_with_index do | v, i |
            diff = (num - v).abs
            if diff < min
              min = diff
              argmin = i
            end
          end
          metric = 'scale=' + lst[argmin].to_s
        end
      end

      metrics = parse_metric("html", metric)
      puts %Q[<div id="#{normalize_id(id)}" class="image">]
      puts %Q[<img src="#{@chapter.image(id).path.sub(/\A\.\//, "")}" alt="#{escape_html(compile_inline(caption))}"#{metrics} />]
      image_header id, caption
      puts %Q[</div>]
    end

    def make_math_image(str, path, fontsize = 12)
      fontsize2 = (fontsize * 1.2).round.to_i
      texsrc = <<-EOB
\\documentclass[12pt,uplatex]{jsarticle}
\\usepackage[deluxe,uplatex,jis2004]{otf}
\\usepackage[prefernoncjk]{pxcjkcat}
\\cjkcategory{sym18,sym19,grek,sym04,sym08}{cjk}
\\usepackage{suffix}
\\usepackage{textcomp}
\\usepackage[T1]{fontenc}
\\usepackage[dvipdfmx,hiresbb]{graphicx}
\\usepackage[dvipdfmx,table]{xcolor}
\\usepackage[utf8x]{inputenc}
\\usepackage{ascmac}
\\usepackage{amsmath}
\\usepackage{okumacro}
\\usepackage{amsfonts}
\\usepackage{bm}
\\usepackage{exscale}
\\usepackage{mathpazo}
\\renewcommand{\\ttdefault}{lmtt}
\\usepackage[scaled=0.95]{helvet}
\\usepackage{array}
\\usepackage{cases}
\\usepackage{tikz}
\\usetikzlibrary{calc}
\\usepackage{color}
\\usepackage{mathrsfs}
\\usepackage{mathtools}
\\usepackage{cancel}
\\usepackage[ppl]{mathcomp}
\\usepackage{dsfont}
\\usepackage{eucal}
\\usepackage{anyfontsize}
\\usepackage{bxcoloremoji}
\\pagestyle{empty}
\\begin{document}
\\fontsize{#{fontsize}}{#{fontsize2}}\\selectfont #{str}
\\end{document}
      EOB
      Dir.mktmpdir do |tmpdir|
        tex_path = File.join(tmpdir, 'tmpmath.tex')
        dvi_path = File.join(tmpdir, 'tmpmath.dvi')
        pdf_path = File.join(tmpdir, 'tmpmath.pdf')
        File.write(tex_path, texsrc)

        cmd = "uplatex --interaction=nonstopmode --output-directory=#{tmpdir} #{tex_path} > /dev/null 2>&1"
        cmd += "&& dvipdfmx #{dvi_path} -o #{pdf_path} > /dev/null 2>&1"
        cmd += "&& convert -antialias -density 300 -trim +repage #{pdf_path} #{path} > /dev/null 2>&1"
        system(cmd)
      end
    end
  end

  class PLAINTEXTBuilder
    def escape(str)
      str
    end
  end
end
