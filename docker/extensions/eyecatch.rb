require 'base64'

module ReVIEW
  class Compiler
    defblock :eyecatch, 0..1, true
  end

  class Builder
    def eyecatch(lines, strength=nil)
    end
  end

  class LATEXBuilder
    def eyecatch(lines, strength=nil)
      idx = ['high', 'mid', 'low', 'urgent'].index(strength) || 0
      puts "\\begin{eyecatch}{#{idx}}"
      puts Base64.decode64(lines.join(''))
      puts '\end{eyecatch}'
    end
  end
end
