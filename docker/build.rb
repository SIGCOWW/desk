#!/usr/bin/env ruby
require 'optparse'
require 'pp'
require 'yaml'
require 'fileutils'
require 'base64'
require 'open3'

class Build
  def initialize(papersize, margin, is_strict, is_verbose)
    header("Initialization")
    @papersize = papersize
    @margin = margin.delete("^0-9").to_i * 2
    @is_strict = is_strict
    @is_verbose = is_verbose

    @articles, @catalog = preprocess()
    convert_articles()
    FileUtils.mv('../cover.png', './', {:force => true})
    FileUtils.mv('../back.png', './', {:force => true})

    @imgcache = nil
    @exitstatuses = {}
  end

  def redpen()
    header("RedPen")
    breakdoc = false
    @articles.each_key do | chapid |
      dir = "/redpen/bin"
      path = "../articles/#{chapid}/#{chapid}.re"

      breakline = false
      Open3.popen3("#{dir}/redpen -c #{dir}/redpen-conf.xml -r plain2 -l 1000 #{path}") do |stdin, stdout, stderr, th|
        stdin.close_write
        begin
          loop do
            break unless th.alive?
            IO.select([stdout, stderr])[0].each do | io |
              str = io.readline
              next if str.nil? || str.empty?

              case io
              when stderr
                next unless @is_verbose
                STDERR.print(str)
              when stdout
                str.strip!
                if str.include?('Document:')
                  #print "\n\n" if breakdoc
                  puts "\033[33;41m--- #{str} ---\033[m"
                  breakdoc = true
                elsif str.include?('Line:')
                  #print "\n" if breakline
                  puts "\033[32m#{str}\033[m"
                  breakline = true
                elsif str.include?('Sentence:')
                  slice = str[0..40]
                  slice += '...' if str != slice
                  str = slice
                  puts "  \033[36m#{str}\033[m"
                else
                  puts "    #{str}"
                end
              end
            end
          end
        rescue IOError
        end
      end
    end
  end

  def pdf(is_print)
    header("Making PDF")
    convert_images('latex')
    @exitstatuses['pdf'] = compile('pdfmaker', 'original.pdf')
    return unless @exitstatuses['pdf'] === 0

    return unless is_print
    header("Making PDF for Printers")
    File.write('honbun-tmp.tex', <<EOF
\\documentclass[uplatex,dvipdfmx,#{@papersize}paper,oneside]{jsbook}
\\usepackage{pdfpages}
\\pagestyle{empty}
\\advance \\paperwidth #{@margin}truemm
\\advance \\paperheight #{@margin}truemm
\\begin{document}
\\includepdf[pages=-,noautoscale,offset=-0in 0in]{original.pdf}
\\end{document}
EOF
)
    run("uplatex honbun-tmp")
    run("dvipdfmx honbun-tmp")
    run("gs -sOutputFile=honbun.pdf -sDEVICE=pdfwrite -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dEmbedAllFonts=true -dCompatibilityLevel=1.5 -dNOPAUSE -dBATCH -q honbun-tmp.pdf")
  end

  def pdf4publish()
    header("Making PDF for Publishment")
    convert_images('latex')
    ENV['ONESIDE'] = '1'
    @exitstatuses['pdf4publish'] = compile('pdfmaker', 'publish-tmp-tmp.pdf')
    ENV.delete('ONESIDE')

    dummy_image('cover.png', 'COVER')
    dummy_image('back.png', 'BACK')
    tmp = `convert cover.png -colors 256 -depth 8 -format %c histogram:info: | sort -r -k 1`
    r, g, b = tmp.match(/\(([0-9]+),([0-9]+),([0-9]+)\)/)[1..3].map{|v| v.to_f / 255}
    max = [r, g, b].max
    min = [r, b, g].min
    d = max - min
    case min
    when max
      h = 0
    when b
      h = 60 * (g-r)/d + 60
    when r
      h = 60 * (b-g)/d + 180
    when g
      h = 60 * (r-b)/d + 300
    end
    #s = d / max
    #v = max

    file.write('publish-tmp.tex', <<eof
\\documentclass[uplatex,dvipdfmx,#{@papersize}paper,oneside]{jsbook}
\\usepackage{pdfpages}
\\pagestyle{empty}
\\usepackage{xcolor}
\\definecolor{frontcolor}{hsb}{#{h},0.1,1.0}
\\newcommand{\\blankpage}{%
    \\pagecolor{frontcolor}
    \\mbox{}
    \\clearpage
    \\newpage
    \\pagecolor{white}}
\\begin{document}
\\includepdf{cover.png}
\\blankpage
\\includepdf[pages=-,noautoscale,offset=-0in 0in]{publish-tmp-tmp.pdf}
\\blankpage
\\includepdf{back.png}
\\end{document}
eof
)
    run("uplatex publish-tmp")
    run("dvipdfmx publish-tmp")
    run("gs -sOutputFile=publish.pdf -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -q -dPDFSETTINGS=/ebook -dDownsampleColorImages=true -dColorImageResolution=300 publish-tmp.pdf")
  end

  def epub()
    header("Making EPUB")
    convert_images('html')
    dummy_image('cover.png', 'COVER')
    run("convert -resize 590x750 cover.png images/epub-cover.png")
    @exitstatuses['epub'] = compile('epubmaker', 'publish.epub')
  end

  def clean()
    header("Cleaning")
    #unless @is_verbose
    #  artifacts = ['original.pdf', 'honbun.pdf', 'publish.pdf', 'publish.epub']
    #  Dir.glob('*').each do | file |
    #    next if artifacts.include?(file)
    #    FileUtils.rm_rf(file)
    #  end
    #end
    stat = File.stat('../')
    FileUtils.chown_R(stat.uid, stat.gid, './')

    result = @exitstatuses.values.inject(:+)
    msg = @exitstatuses.select{|k, v| v != 0 }.keys.join(', ')
    File.write(".exitstatus", "#{result}\n#{msg}\n")
  end


  private
  def preprocess()
    header("Preprocessing", 2)
    articles = {}
    newcatalog = {}
    FileUtils.cp_r(Dir.glob('../extensions/*.rb'), './')
    FileUtils.cp_r(['config.yml', 'layouts/'].map{|v| "../#{v}"}, './')
    FileUtils.mv(['locale.yml', 'style.css'].map{|v| "layouts/#{v}"}, './', {:force => true})
    FileUtils.mkdir_p('sty')
    FileUtils.mv(Dir.glob('layouts/*.sty'), 'sty', {:force => true})

    catalog = YAML.load_file('../catalog.yml')
    catalog.each do | k, files |
      newcatalog[k] = []
      files.each do | file |
        chapid = File.basename(file, '.re')
        unless FileTest.file?("../articles/#{chapid}/#{chapid}.re")
          msg = "#{chapid}.re is not found."
          if @is_strict
            raise msg
          else
            puts msg
            next
          end
        end
        articles[chapid] = []

        processed = []
        image_list = []
        ['pdf', 'png', 'jpg'].each do | ext |
          image_list += Dir.glob("../articles/#{chapid}/images/*.#{ext}")
        end

        image_list.each do | image |
          ext = File.extname(image)
          id = File.basename(image, ext)
          next if processed.include?(id)
          articles[chapid] << "#{id}#{ext}"
          processed << id
        end

        newcatalog[k] << "#{chapid}.re"
      end
    end

    newcatalog.delete_if { |k, v| v.nil? || v.empty? }
    return articles, newcatalog
  end

  def convert_articles()
    header("Converting Articles", 2)

    File.write('profile.re', "= 著者あとがき\n\n")
    @catalog = Marshal.load(Marshal.dump(@catalog))
    @catalog['POSTDEF'] = [] if @catalog['POSTDEF'].nil?
    @catalog['POSTDEF'] << 'profile.re' unless @catalog['POSTDEF'].include?('profile.re')

    @articles.each_key do | chapid |
      txt = File.read("../articles/#{chapid}/#{chapid}.re").gsub(/\r\n/, "\n")

      # ~raw
      txt.gsub!(/^(\/\/(?:tabooularw?|pandoc)(?:\[\S+?\])*{\s*)(.+?)(\s*\/\/}\s*)$/m) { $1 + Base64.encode64($2).delete('=') + $3 }
      txt.gsub!(/^\/\/(tabooularw?(?:\[\S+?\])*{\s*)$/) { '//table' + $1 }

      # @<author>
      pat = /@<author>{(.+?)}/
      m = txt.match(pat)
      txt = "#{m[0]}\n\n" + txt.gsub(pat, '') unless m.nil?
      author = m.nil? ? nil : m[1]

      # //profile
      pat = /^(\/\/profile)(\[\S+?\])?({\s*.+?\s*\/\/}\s*)$/m
      m = txt.match(pat)
      txt.gsub!(pat, '')
      unless m.nil?
        File.open('profile.re', 'a') do | f |
          if not(m[2].nil?) || author.nil?
            output = m[0]
          else
            output = m[1] + "[#{author}]" + m[3]
          end
          f.write(output + "\n\n")
        end
      end

      # @<m>
      idx = 0
      while idx = txt.index("@<m>{", idx) do
        idx += 5
        level = 0
        while level >= 0
          case txt[idx]
          when '{'
            level += 1
          when '}'
            if level != 0 && txt[idx-1] != "\\"
              txt = txt[0...idx] + "\\" + txt[idx..-1]
              idx += 1
            end
            level -= 1
          end
          idx += 1
        end
      end

      # subfig
      txt.gsub!(/^\/\/(subfigw?)\[(.+?)\]{\s*(.+?)\s*\/\/}/m) { '//beginsubfig[' + $1 + '][' + $2 + "]\n" + $3 + "\n" + '//endsubfig' }
      input_output = []
      txt.scan(/\/\/beginsubfig\[.+?\].*?\/\/endsubfig/m).each do | s |
        input_output << [ s, s.gsub(/^\s*$/, '@<newline>{}') ]
      end
      input_output.each do | io |
        txt.sub!(io[0], io[1])
      end
      File.write("#{chapid}.re", txt)
      run("review-preproc --replace #{chapid}.re")
    end
  end

  def convert_images(builder)
    def margin?(path)
      tmp = Open3.capture3("convert #{path} -crop 1x1+0+0 -format \"%[fx:r],%[fx:g],%[fx:b],%[fx:a]\" info:")[0]
      rgba = tmp.split(',')
      return (rgba[3] === '0' || (rgba[0] === '1' && rgba[1] === '1' && rgba[2] === '1'))
    end

    header("Converting Images for #{builder}", 2)
    return if builder === @imgcache
    @imgcache = builder
    FileUtils.rm_rf("images")
    @articles.each do | chapid, imgs |
      next if imgs.nil? || imgs.empty?

      dir = "images/#{builder}/#{chapid}"
      FileUtils.mkdir_p(dir)
      imgs.each do | img |
        ext = File.extname(img)
        id = File.basename(img, ext)
        src = "../articles/#{chapid}/images/#{img}"
        dst = "#{dir}/#{id}"

        case "#{builder}#{ext}"
        when 'latex.pdf'
          run("pdfcrop #{src} #{dst}.pdf")
        when 'html.pdf'
          run("convert -antialias -density 300 #{src} #{dst}.png")
          run("mogrify -trim +repage #{dst}.png") if margin?("#{dst}.png")
        when 'latex.png'
          run("convert #{src} \\( +clone -alpha opaque -fill white -colorize 100% \\) +swap -geometry +0+0 -compose Over -composite -alpha off #{dst}.png")
          run("mogrify -trim +repage #{dst}.png") if margin?("#{dst}.png")
        when 'html.png'
          if margin?(src)
            run("convert -trim +repage #{src} #{dst}.png")
          else
            FileUtils.cp_r(src, "#{dst}.png")
          end
        when 'latex.jpg', 'html.jpg'
          run("convert -auto-orient -strip #{src} #{dst}.jpg")
        end
      end
    end
  end

  def compile(maker, dst)
    header("Compiling PDF/EPUB with #{maker}", 2)
    exitstatus = 0
    catalog = Marshal.load(Marshal.dump(@catalog))

    (@articles.length).times do | i |
      catalog.delete_if { |k, v| v.nil? || v.empty? }
      break if catalog.empty?
      File.write('catalog.yml', catalog.to_yaml)

      errors = []
      Open3.popen3("review-#{maker} config.yml") do |stdin, stdout, stderr, wait_thr|
        stdin.close_write
        begin
          loop do
            break unless wait_thr.alive?
            IO.select([stdout, stderr])[0].each do | io |
              str = io.readline
              next if str.nil? || str.empty?
              if io === stdout
                STDERR.print(str) if @is_verbose
              elsif io === stderr
                [ /^.+\.dvi -> .+\.pdf$/, /^(\[[0-9]+\])+$/, /^[0-9]+ bytes? written$/ ].each do | pat |
                  next unless str =~ pat
                  STDERR.print(str) if @is_verbose
                  str = nil
                  break
                end
                next if str.nil?

                STDOUT.print(str)
                errors += str.scan(/compile error in (.+?)\.(?:re|tex)/).map{|v| v[0]+'.re'}
              end
            end
          end
        rescue IOError
        end

        exitstatus = wait_thr.value.exitstatus
      end

      break if errors.empty?
      raise "compile error" if @is_strict

      puts "RETRY"
      catalog.each_key do | key |
        catalog[key].select!{ |v| not errors.include?(v) }
      end
    end
    src = (maker === 'pdfmaker') ? 'book.pdf' : 'book.epub'
    FileUtils.mv(src, dst, {:force => true}) if src != dst

    return exitstatus.to_i
  end

  def dummy_image(path, text)
    return if FileTest.file?(path)
    run("convert -size 850x1200 -background gray -fill red -gravity center label:#{text} #{path}")
  end

  def run(cmd)
    cmd += " >/dev/null 2>&1" unless @is_verbose
    system(cmd)
    return $?
  end

  def header(msg, level=1)
    case level
    when 1
      puts "\033[32m\# #{msg}\033[m"
    else
      puts "\#\# #{msg}"
    end
  end
end

if __FILE__ == $0
  begin
    params = ARGV.getopts('', 'redpen', 'pdf4print', 'pdf4publish', 'epub', 'workdir:./', 'papersize:b5', 'margin:3mm', 'strict', 'verbose')
  rescue => e
    puts "#{e}. try \"--help\"."
    exit 1
  end

  dirname = 'working_temporary_directory'
  Dir::chdir(params['workdir'])
  FileUtils.rm_rf(dirname)
  FileUtils.mkdir_p(dirname)
  Dir::chdir(dirname) do
    build = Build.new(params['papersize'], params['margin'], params['strict'], params['verbose'])
    build.redpen() if params['redpen']
    build.pdf(params['pdf4print'])
    build.pdf4publish() if params['pdf4publish']
    build.epub() if params['epub']
    build.clean()
  end
end
