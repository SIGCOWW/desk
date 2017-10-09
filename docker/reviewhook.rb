#!/usr/bin/env ruby
if __FILE__ == $0
  Dir::chdir(ARGV[0])
  Dir.glob('*.tex').each do | file |
    txt = File.read(file)
    pat = /(?<=\\begin{reviewsubfig})(.*?)\\begin{reviewimage}\s*(\\includegraphics.+?)\s*\\caption{(.+?)}\s*(\\label{.+?}).*?\\end{reviewimage}(.*?)(?=\\end{reviewsubfig})/m
    loop do
      ret = txt.gsub!(pat) { $1 + '\subfloat[' + $3 + ']{' + $2 + $4 + '}\hfill' + $5 }
      break if ret.nil?
    end

    txt.gsub!(/(\\end{review(?:list|emlist|cmd|source)})\s(\s*)(\\end{widepage})/m) { $1 + "\n" + $3 + $2 }
    File.write(file, txt)
  end
end
