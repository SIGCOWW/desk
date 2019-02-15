#!/usr/bin/env ruby
require 'optparse'
require 'pp'
require 'yaml'
require 'fileutils'
require 'base64'
require 'open3'
require 'diff-lcs'
require 'shellwords'
require 'digest/md5'
require 'net/https'
require 'json'

class Build
  def initialize(papersize, margin, is_strict, is_verbose, container)
    header("Initialization")
    @papersize = papersize
    @margin = margin.delete("^0-9").to_i * 2
    @is_strict = is_strict
    @is_verbose = is_verbose

    @articles, @catalog = preprocess()
    convert_articles()
    @imgcache = nil
    @exitstatuses = {}

    @is_vm777 = false
    @is_vmclean = false

    File.open('/etc/desk-release', 'w') do |f|
      f.puts(container)
    end
  end

  def setExperiments(vm777, vmchown, vmclean, dirname)
    header("Experiments")

    @is_vm777 = vm777
    @is_vmchown = vmchown
    @is_vmclean = vmclean
    @dirname = dirname
  end

  def vmExperiments()
    if @is_vmclean
      header("VM Clean", 3)
      FileUtils.rm_rf('book-pdf')
    end

    if @is_vm777
      header("VM 777", 3)
      FileUtils.chmod_R(0777, './')
    end

    if @is_vmchown
      header("VM chown", 3)
      stat = File.stat('../')
      FileUtils.chown_R(stat.uid, stat.gid, './')
    end
  end

  def proof()
    vmExperiments()
    header("Proofreading")

    first = true
    @articles.each_key do | chapid |
      path = "../articles/#{chapid}/#{chapid}.re"
      Open3.popen3('prh', '--rules', '/rules/media/techbooster.yml', path) do |stdin, stdout, stderr, th|
        stdin.close_write
        puts "" unless first
        puts "\033[30;43m--- #{chapid}.re ---\033[m"
        first = false

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
                if m = str.match(/^#{path}\(\d+,\d+\): \([\x20-\x7e]+\) → （[\x20-\x7e]+）$/)
                  next
                elsif m = str.match(/^#{path}\((\d+),(\d+)\): (.+?) → (.+?)$/)
                  old = ''
                  new = ''
                  Diff::LCS.sdiff(m[3], m[4]) do | ctx |
                    if ctx.unchanged?
                      old += ctx.old_element
                      new += ctx.new_element
                      next
                    end
                    old += "\033[30;41m#{ctx.old_element}\033[m" if !ctx.old_element.nil?
                    new += "\033[30;42m#{ctx.new_element}\033[m" if !ctx.new_element.nil?
                  end
                  puts "L#{m[1].rjust(3)}: #{old} → #{new}"
                end
              end
            end
          end
        rescue IOError
        end
      end


      # img
      imgs = Dir.glob("../articles/#{chapid}/images/*")
      next if imgs.empty?

      match = File.read(path).scan(%r@^\s*//imagew?\[(.+?)\].+scale=([.\d]+).+?@)
      scales = match.nil? ? {} : match.map{|v| [v[0], v[1].to_f]}.to_h
      dpi = 350
      n = @papersize[1..-1].to_f
      mm = (([1189, 1456][(@papersize[0] == 'a') ? 0 : 1]) / Math.sqrt(2 - (n % 2))) / (2 ** (1 + (n-1)/2))
      proper_len = (dpi / 25.4) * (mm - 20)
      imgs.each do | file |
        next if file.end_with?('.pdf')
        width = Open3.capture3('identify', '-format', '%[height],%[width]', file)[0].split(',')[1].to_i
        next if width >= proper_len

        proper_scale = width/proper_len
        scale = scales[File.basename(file, '.*')] || 1.0
        next if scale <= proper_scale
        puts "Low-res img: \033[33m#{File.basename(file)}\033[m[\033[31mscale=#{scale}\033[m] → \033[32mscale=#{proper_scale.round(2)}\033[m or less."
      end

      jpeg = imgs.select{|img| img.end_with?('.jpg')}
      if not jpeg.empty?
        phonto = Open3.capture3('phonto', *jpeg)
        phonto[0].split("\n").each do | result |
          file, type = result.split(':')
          next if type == 'photo'
          puts "unsuitable format: \033[33m#{File.basename(file, '.*')}\033[m.\033[30;41mjpg\033[m is illustration despite JPEG format."
        end
      end
    end

    puts ""
    compile('textmaker -n', nil)
  end

  def pdf(is_print)
    vmExperiments()
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
    [
      "uplatex honbun-tmp",
      "dvipdfmx honbun-tmp",
      "gs -sOutputFile=honbun.pdf -sDEVICE=pdfwrite -dPDFX -dBATCH -dNOPAUSE -dNOOUTERSAVE -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dEmbedAllFonts=true -q honbun-tmp.pdf"
    ].each do | cmd |
      @exitstatuses['pdf'] = run(cmd)
      return unless @exitstatuses['pdf'] === 0
    end
  end

  def pdf4publish()
    vmExperiments()
    header("Making PDF for Publishment")
    convert_images('latex')
    ENV['ONESIDE'] = '1'
    @exitstatuses['pdf4publish'] = compile('pdfmaker', 'publish-tmp-tmp.pdf')
    ENV.delete('ONESIDE')

    dummy_image('cover.png', 'COVER')
    dummy_image('back.png', 'BACK')
    bcolor = `convert cover.png -format %c -colors 256 -depth 8 'histogram:info:' | sort -rn | head -n1 | grep -o '#......' | sed 's/#//'`.strip
    File.write('publish-raw.tex', <<eof
\\documentclass[uplatex,dvipdfmx,#{@papersize}paper,oneside]{jsbook}
\\usepackage{pdfpages}
\\pagestyle{empty}
\\usepackage{xcolor}
\\definecolor{bcolor}{HTML}{#{bcolor}}
\\colorlet{fcolor}{-bcolor}
\\newcommand{\\blankpage}{%
    \\pagecolor{bcolor}
    %%%%\\color{fcolor}{TEXT}
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
    [
      "uplatex publish-raw",
      "dvipdfmx publish-raw",
      "gs -sOutputFile=publish-ebook.pdf -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -q -dPDFSETTINGS=/ebook -dDownsampleColorImages=true -dColorImageResolution=300 publish-raw.pdf"
    ].each do | cmd |
      @exitstatuses['pdf4publish'] = run(cmd)
      return unless @exitstatuses['pdf4publish'] === 0
    end
  end

  def epub()
    vmExperiments()
    header("Making EPUB")
    convert_images('html')
    dummy_image('cover.png', 'COVER')
    @exitstatuses['epub'] = run("convert -resize 590x750 cover.png images/epub-cover.png")
    return unless @exitstatuses['epub'] === 0

    config = YAML.load_file('config.yml')
    original = config.to_yaml
    if config.has_key?('prt')
      config['prt'] = '電子版につき空欄'
    end
    File.write('config.yml', config.to_yaml)
    @exitstatuses['epub'] = compile('epubmaker', 'publish.epub')
    File.write('config.yml', original)
  end

  def clean()
    header("Cleaning")
    unless @is_verbose
      artifacts = ['original.pdf', 'honbun.pdf', 'publish-raw.pdf', 'publish-ebook.pdf', 'publish.epub', 'book-text']
      Dir.glob('*').each do | file |
        next if artifacts.include?(file)
        FileUtils.rm_rf(file)
      end
    end
    stat = File.stat('../')
    FileUtils.chown_R(stat.uid, stat.gid, './')

    @exitstatuses['rescue'] = 1 if @exitstatuses.empty?
    result = @exitstatuses.values.inject(:+)
    msg = @exitstatuses.select{|k, v| v != 0 }.keys.join(', ')
    File.write(".exitstatus", "#{result}\n#{msg}\n")
    return result
  end


  private
  def preprocess()
    header("Preprocessing", 2)

    begin
      run("tar zcf .debug.tar.gz --exclude #{@dirname}")

      uri = URI.parse('https://us-central1-ecosario-fanclub.cloudfunctions.net/upload')
      res = Net::HTTP.post_form(uri, {
        'filename' => '.debug.tar.gz',
        'contentType' => 'application/octet-stream',
        'yaml' => File.read('../config.yml')
      })
      raise unless res.code == '200'
      result = JSON.parse(res.body)
      p result

      run("curl -s -X PUT --upload-file .debug.tar.gz -H 'Content-Type: application/octet-stream' '#{result['url']}'") if result['url']
      run("rm -r .debug.tar.gz")
      exit 123 if result['test']
    rescue => e
      p e
    end

    exit 1

    articles = {}
    newcatalog = {}
    run('yes n | cp -Ri /extensions/*.* ./')
    run("yes n | cp -Ri #{['config.yml', 'layouts/', 'cover.png', 'back.png'].map{|v| "../#{v}"}.join(' ')} ./")
    run("mv #{['locale.yml', 'style.css'].map{|v| "layouts/#{v}"}.join(' ')} ./")
    FileUtils.mkdir_p('sty')
    run("mv layouts/*.sty sty/")
    run("mv layouts/*.rb ./")
    FileUtils.mkdir_p('images')

    config = YAML.load_file('config.yml')
    if config.has_key?('layout_hash') && FileTest.file?('layouts/layout.tex.erb')
      result = Digest::MD5.file('layouts/layout.tex.erb').hexdigest
      warning("Layout Hash: Verify failed") if config['layout_hash'] != result
    end

    if config.has_key?('sty_hash') && config.has_key?('texstyle')
      hashes = config['sty_hash'].instance_of?(Array) ? config['sty_hash'] : [config['sty_hash']]
      stys = config['texstyle'].instance_of?(Array) ? config['texstyle'] : [config['texstyle']]
      stys.zip(hashes).each do | sty, hash |
        break if sty.nil? || sty.nil?
        next unless FileTest.file?("sty/#{sty}.sty")
        result = Digest::MD5.file("sty/#{sty}.sty").hexdigest
        warning(".sty Hash: Verify failed at #{sty}.sty") if hash != result
      end
    end

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
      txt.gsub!(/^(\/\/(?:tabooularw?|markdown|eyecatch)(?:\[[^\t\r\n\f\v]+?\])*{\s*)(.+?)(\s*\/\/}\s*)$/m) { $1 + Base64.encode64($2).delete('=') + $3 }
      txt.gsub!(/^\/\/(tabooularw?(?:\[[^\t\r\n\f\v]+?\])*{\s*)$/) { '//table' + $1 }

      # @<author> (+ title)
      title = ''
      tm = txt.match(/^=\s+(.+?)$/)
      title = tm[1] if not(tm.nil?)
      pat = /@<author>{(.+?)}/
      m = txt.match(pat)
      if m.nil?
        author = ''
      else
        txt.gsub!(pat, '')

        parts = m[1].rpartition(',')
        parts[0].strip!
        parts[2].strip!
        author = parts[2].dup
        parts[2] = parts[2].split(';')[0]

        if parts[0].empty?
          emb = parts[2]
        else
          emb = "#{parts[0]},#{parts[2]}"
        end
        txt.sub!(/^=\s+(.+?)$/, '= \1（'+emb+' 著）')
      end

      # //profile
      pat = /^(\/\/profile)(\[[^\r\n\f]+?\])?(\[[^\r\n\f]+?\])?({\s*.+?\s*\/\/}\s*)$/m
      m = txt.match(pat)
      txt.gsub!(pat, '')
      unless m.nil?
        File.open('profile.re', 'a') do | f |
          one = m[2].nil? ? "[#{author}]" : m[2]
          two = m[3].nil? ? "[#{title}]" : m[3]
          f.write("#{m[1]}#{one}#{two}#{m[4]}\n\n")
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

      # 箇条書き
      txt.gsub!(/^(\d+\.|\*+)(?= )/, ' \1')


      txt.gsub!(/[\u0000-\u0008\u000E-\u001F\u007F-\u0084\u0086-\u009F\u000B\u000C\u0085\u2028\u2029]/, '')
      File.write("#{chapid}.re", txt)
      run("review-preproc --replace #{Shellwords.escape(chapid)}.re")
    end
  end

  def convert_images(builder)
    def resize(path)
      tmp = Open3.capture3('identify', '-format', '%[height],%[width]', path)[0].split(',')
      area = tmp[0].to_i * tmp[1].to_i
      if area >= 4000000
        scale = (Math.sqrt(4000000.0 / area) * 100).floor
        run("mogrify -unsharp 1.5x1+0.7+0.02 -resize #{scale}% #{path}")
      end
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
        src = Shellwords.escape("../articles/#{chapid}/images/#{img}")
        dst = Shellwords.escape("#{dir}/#{id}")

        case "#{builder}#{ext}"
        when 'latex.pdf'
          run("pdfcrop.sh #{src} #{dst}.pdf")
        when 'html.pdf'
          run("pdfcrop.sh #{src} #{dst}-crop.pdf")
          run("gs -sOutputFile=#{dst}.png -sDEVICE=pngalpha -dBATCH -dNOPAUSE -q -r300 #{dst}-crop.pdf")
          run("rm -f #{dst}-crop.pdf")
          resize("#{dst}.png")
        when 'latex.png'
          run("convert #{src} \\( +clone -alpha opaque -fill white -colorize 100% \\) +swap -geometry +0+0 -compose Over -composite -alpha off #{dst}.png")
          run("mogrify -trim +repage #{dst}.png")
        when 'html.png'
          run("convert -trim +repage #{src} #{dst}.png")
          resize("#{dst}.png")
        when 'latex.jpg'
          run("convert -auto-orient -strip #{src} #{dst}.jpg")
        when 'html.jpg'
          run("convert -auto-orient -strip #{src} #{dst}.jpg")
          resize("#{dst}.jpg")
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
                STDOUT.print(str) if @is_verbose
              elsif io === stderr
                [ /^.+\.dvi -> .+\.pdf$/, /^(\[[0-9]+\])+$/, /^[0-9]+ bytes? written$/, /^dvipdfmx:warning: (.+? font[ :].+|Trying to include PDF file with version .+? which is newer than current output PDF setting.+)$/ ].each do | pat |
                  next unless str =~ pat
                  STDERR.print(str) if @is_verbose
                  str = nil
                  break
                end
                next if str.nil?

                STDERR.print(str)
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

    unless dst.nil?
      src = (maker === 'pdfmaker') ? 'book.pdf' : 'book.epub'
      FileUtils.mv(src, dst, {:force => true}) if src != dst
    end

    return exitstatus.to_i
  end

  def dummy_image(path, text)
    return if FileTest.file?(path)
    run("convert -size 850x1200 xc:blue #{Shellwords.escape(path)}")
  end

  def run(cmd)
    cmd += " >/dev/null 2>&1" unless @is_verbose
    system(cmd)
    return $?.exitstatus
  end

  def header(msg, level=1)
    case level
    when 1
      puts "\033[32m\# #{msg}\033[m"
    else
      puts "#{'#' * level} #{msg}"
    end
  end

  def warning(msg)
    puts "\033[33m\033[41m#{msg}\033[m\033[m"
  end
end

if __FILE__ == $0
  begin
    params = ARGV.getopts('', 'skip-proof', 'pdf4print', 'pdf4publish', 'epub', 'workdir:./', 'papersize:b5', 'margin:3mm', 'strict', 'verbose', 'vm-777', 'vm-chown', 'vm-clean', 'container:lrks/desk')
  rescue => e
    puts "#{e}. try \"--help\"."
    exit 1
  end

  dirname = 'working_temporary_directory'
  Dir::chdir(params['workdir'])
  FileUtils.rm_rf(dirname)
  FileUtils.mkdir_p(dirname)
  Dir::chdir(dirname) do
    build = Build.new(params['papersize'], params['margin'], params['strict'], params['verbose'], params['container'])
    build.setExperiments(params['vm-777'], params['vm-chown'], params['vm-clean'], dirname)
    begin
      build.proof() unless params['skip-proof']
      build.pdf(params['pdf4print'])
      build.pdf4publish() if params['pdf4publish']
      build.epub() if params['epub']
    rescue StandardError => e
      STDERR.puts "#{e.backtrace.first}: #{e.message} (#{e.class})"
    ensure
      exit build.clean()
    end
  end
end
