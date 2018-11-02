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
      idx = ['high', 'mid', 'low'].index(strength) || 0
      puts "\\begin{eyecatch}{#{idx}}"
      puts lines
      puts '\end{eyecatch}'
    end
  end
end
