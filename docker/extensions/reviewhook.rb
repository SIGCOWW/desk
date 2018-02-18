#!/usr/bin/env ruby
if __FILE__ == $0
  Dir::chdir(ARGV[0])
  Dir.glob('*.tex').each do | file |
    txt = File.read(file)
    pat = /(\\begin{reviewsubfig}{.+?})((?:\s|\\subfloat\[.+?\]{.+?}\\hfill)*)\\begin{reviewimage}\s*(\\includegraphics.+?)\s*\\caption{(.+?)}\s*(\\label{.+?})\s*\\end{reviewimage}/m

    loop do
      ret = txt.gsub!(pat) { $1 + $2 + '\subfloat[' + $4 + ']{' + $3 + $5 + '}\hfill' }
      break if ret.nil?
    end

    txt.gsub!(/(\\end{review(?:list|emlist|cmd|source)})\s(\s*)(\\end{widepage})/m) { $1 + "\n" + $3 + $2 }
    #txt.gsub!(/\s(\\begin{review(?:list|emlist|cmd|source)})/m) { $1 }
    #txt.gsub!(/(\\end{review(?:list|emlist|cmd|source)})\s/m) { $1 }

    File.write(file, txt)
  end
end
