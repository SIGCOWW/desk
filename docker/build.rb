require 'optparse'
require 'pp'
require 'yaml'
require 'fileutils'
require 'base64'
require 'open3'

class Build
  def initialize(is_strict)
    @workdir = File.expand_path('working_temporary_directory')
    FileUtils.rm_rf(@workdir)
    FileUtils.mkdir_p(@workdir)
    @is_strict = is_strict

    @articles, @catalog = preprocess()
    articles_convert()

    @imgcache = nil
    @status = {}
  end

  def redpen()
    @articles.each_key do | chapid |
      dir = "/redpen/bin"
      path = "articles/#{chapid}/#{chapid}.re"
      stdout = Open3.capture3("#{dir}/redpen -c #{dir}/redpen-conf.xml -r plain2 -l 1000 #{path}")[0]

      breakline = false
      stdout.each do | line |
        if line.include?('Document:')
          puts "\n\n\033[33;41m#{line}       \033[m"
        elsif line.include?('Line:')
          puts "" if breakline
          puts "\033[32m#{line}\033[m"
          breakline = true
        elsif line.include?('Sentence:')
          puts "\033[36m#{line}\033[m"
        else
          puts line
        end
      end
    end
  end

  def pdf(is_print, margin)
    images_convert('latex')
    Dir::chdir(@workdir) do
      @status['pdf'] = compile('pdfmaker', 'original.pdf')
      margin = margin.delete("^0-9").to_i * 2
      File.write('honbun-tmp.tex', <<EOF
\\documentclass[uplatex,dvipdfmx,b5paper,oneside]{jsbook}
\\usepackage{pdfpages}
\\pagestyle{empty}
\\advance \\paperwidth #{margin}truemm
\\advance \\paperheight #{margin}truemm
\\begin{document}
\\includepdf[pages=-,noautoscale,offset=-0in 0in]{original.pdf}
\\end{document}
EOF
)
      system("uplatex honbun-tmp")
      system("dvipdfmx honbun-tmp")
      system("gs -sOutputFile=honbun.pdf -sDEVICE=pdfwrite -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dEmbedAllFonts=true -dCompatibilityLevel=1.5 -dNOPAUSE -dBATCH -q honbun-tmp.pdf")
    end
  end

  def pdf4publish()
    images_convert('latex')
    Dir::chdir(@workdir) do
      ENV['ONESIDE'] = '1'
      @status['pubpdf'] = compile('pdfmaker', 'publish-tmp-tmp.pdf')
      ENV.delete('ONESIDE')

      ['cover.png', 'back.png'].each do | file |
        next if FileTest.file?(file)
        system("convert -size 850x1200 -background gray -fill red -gravity center label:#{file} #{file}")
      end

      tmp = `convert cover.png -colors 256 -depth 8 -format %c histogram:info: | sort -r -k 1`
      r, g, b = tmp.match(/rgb\(([0-9]+),([0-9]+),([0-9]+)\)/)[1..3].map{|v| v.to_f / 255}
      max = [r, g, b].max
      min = [r, b, g].min
      d = max - min
      case min
      when b
        h = 60 * (g-r)/d + 60
      when r
        h = 60 * (b-g)/d + 180
      when g
        h = 60 * (r-b)/d + 300
      end
      h = h.to_i % 360
      #s = d / max
      #v = max

      File.write('publish-tmp.tex', <<EOF
\\documentclass[uplatex,dvipdfmx,b5paper,oneside]{jsbook}
\\usepackage{pdfpages}
\\pagestyle{empty}
\\usepackage{xcolor}
\\definecolor[frontcolor]{Hsb}{#{h},0.1,1.0}
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
EOF
)
      system("uplatex publish-tmp")
      system("dvipdfmx publish-tmp")
      system("gs -sOutputFile=publish.pdf -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -q -dPDFSETTINGS=/ebook -dDownsampleColorImages=true -dColorImageResolution=300 publish-tmp.pdf")
    end
  end

  def epub()
    images_convert('html')
    Dir::chdir(@workdir) do
      system("convert -size 850x1200 -background gray -fill red -gravity center label:cover.png cover.png") unless FileTest.file?(file)
      system("convert -resize 590x750 cover.png images/epub-cover.png")
      @status['epub'] = compile('epubmaker', 'publish.epub')
    end
  end

  def clean()
    artifacts = ['original.pdf', 'honbun.pdf', 'publish.pdf', 'publish.epub']
    Dir.glob('*').each do | file |
      next if artifacts.include?(file)
      FileUtils.rm_rf(file)
    end
  end


  private
  def preprocess()
    FileUtils.cp_r(['config.yml', 'locale.yml', 'style.css',
                    'layouts/', 'review-ext.rb', 'extensions/'], @workdir)

    articles = {}
    newcatalog = {}

    catalog = YAML.load_file('catalog.yml')
    catalog.each do | k, files |
      newcatalog[k] = []
      files.each do | file |
        chapid = File.basename(file, '.re')
        unless FileTest.file?("articles/#{chapid}/#{chapid}.re")
          msg = "articles/#{chapid}/#{chapid}.re is not found."
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
          image_list += Dir.glob("articles/#{chapid}/images/*.#{ext}")
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

  def articles_convert()
    @articles.each_key do | chapid |
      txt = File.read("articles/#{chapid}/#{chapid}.re").gsub(/\r\n/, "\n")
      txt = txt.gsub(/^(\/\/(?:tabooularw?|pandoc)(?:\[\S+?\])*{\s*)(.+?)(\s*\/\/})$/m) { $1 + Base64.encode64($2).delete('=') + $3 }
      txt = txt.gsub(/^\/\/(tabooularw?(?:\[\S+?\])*{\s*)$/) { '//table' + $1 }
      File.write("#{@workdir}/#{chapid}.re", txt)
      system("review-preproc --replace #{chapid}.re")
    end
  end

  def images_convert(builder)
    def margin?(path)
      tmp = Open3.capture3("convert #{path} -crop 1x1+0+0 -format \"%[fx:r],%[fx:g],%[fx:b],%[fx:a]\" info:")[0]
      rgba = tmp.split(',')
      return (rgba[3] === '0' || (rgba[0] === '1' && rgba[1] === '1' && rgba[2] === '1'))
    end

    return if builder === @imgcache
    @imgcache = builder
    FileUtils.rm_rf("#{@workdir}/images")
    @articles.each do | chapid, imgs |
      next if imgs.nil? || imgs.empty?

      dir = "#{@workdir}/images/#{builder}/#{chapid}"
      FileUtils.mkdir_p(dir)
      imgs.each do | img |
        ext = File.extname(img)
        id = File.basename(image, ext)
        src = "articles/#{chapid}/images/#{img}"
        dst = "#{dir}/#{id}"

        case "#{builder}#{ext}"
        when 'latex.pdf'
          system("pdfcrop #{src} #{dst}.pdf")
        when 'html.pdf'
          system("convert -antialias -density 300 #{src} #{dst}.png")
          system("mogrify -trim +repage #{dst}.png") if margin?("#{dst}.png")
        when 'latex.png'
          system("convert #{src} \\( +clone -alpha opaque -fill white -colorize 100% \\) +swap -geometry +0+0 -compose Over -composite -alpha off #{dst}.png")
          system("mogrify -trim +repage #{dst}.png") if margin?("#{dst}.png")
        when 'html.png'
          if margin?(src)
            system("convert -trim +repage #{src} #{dst}.png")
          else
            FileUtils.cp_r(src, "#{dst}.png")
          end
        when 'latex.jpg', 'html.jpg'
          system("convert -auto-orient -strip #{src} #{dst}.jpg")
        end
      end
    end
  end

  def compile(maker, dst)
    status = 0
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
            IO.select([stdout, stdin])[0].each do | io |
              str = io.readline
              next if str.nil? || str.empty?
              if io === stdout
                STDOUT.print(str)
              elsif io === stderr
                STDERR.print(str)
                errors += stderr.scan(/compile error in (.+?)\.(?:re|tex)/).map{|v| v[0]+'.re'}
              end
            end
          end
        rescue IOError
        end

        status = wait_thr.value.exitstatus
      end

      break if errors.empty?
      raise "compile error" if @strict

      puts "RETRY"
      catalog.each_key do | key |
        catalog[key].select!{ |v| not errors.include?(v) }
      end
    end
    src = (maker === 'pdfmaker') ? 'book.pdf' : 'book.epub'
    FileUtils.mv(src, dst, {:force => true}) if src != dst

    return status
  end
end



if __FILE__ == $0
  begin
    params = ARGV.getopts('', 'redpen', 'pdf4print', 'pdf4publish', 'epub', 'workdir:./', 'strict', 'margin:3mm')
  rescue => e
    puts "#{e}. try \"--help\"."
    exit 1
  end

  Dir::chdir(params['workdir']) do
    build = Build.new(params['strict'])
    build.redpen() if params['redpen']
    build.pdf(params['pdf4print'], params['margin'])
    build.pdf4publish() if params['pdf4publish']
    build.epub() if params['epub']
    build.clean()
  end
end
