module ReVIEW
  class LATEXBuilder
    def texequation(lines)
      blank
      puts macro('begin', 'equation*')
      puts '\copyable{%'
      lines.each do |line|
        puts unescape(line)
      end
      puts '}'
      puts macro('end', 'equation*')
      blank
    end

    def inline_m(str)
      "$\\copyable{#{str}}$"
    end
  end
end
