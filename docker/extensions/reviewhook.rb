#!/usr/bin/env ruby
if __FILE__ == $0
  Dir::chdir(ARGV[0])
  Dir.glob('*.tex').each do | file |
    txt = File.read(file)
    pat = /(\\begin{reviewsubfig}{\S+?})((?:\s|\\subfloat\[\S+?\]{\S+?}\\hfill)*)\\begin{reviewimage}(?:%%\S*?)?\s*(\\includegraphics\S+?)\s*\\caption{(\S+?)}\s*(\\label{\S+?})\s*\\end{reviewimage}/m
    loop do
      ret = txt.gsub!(pat) { $1 + $2 + '\subfloat[' + $4 + ']{' + $3 + $5 + '}\hfill' }
      break if ret.nil?
    end

    txt.gsub!(/(\\end{review(?:list|emlist|cmd|source)})\s(\s*)(\\end{widepage})/m) { $1 + "\n" + $3 + $2 }
    loop do
      ret = txt.gsub!(/(\\textunderscore\{\})(\\textunderscore\{\})/, '\1\kern0.25ex\2')
      break if ret.nil?
    end

    File.write(file, txt)
  end
end
