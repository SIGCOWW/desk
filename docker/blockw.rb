module ReVIEW
  class Compiler
    defblock :listw, 2..3
    defblock :emlistw, 0..2
    defblock :listnumw, 2..3
    defblock :emlistnumw, 0..2
    defblock :cmdw, 0..1
  end

  class Builder
    def listw(lines, id, caption, lang = nil) list(lines, id, caption, lang) end
    def emlistw(lines, caption = nil, lang = nil) emlist(lines, caption, lang) end
    def listnumw(lines, id, caption, lang = nil) listnum(lines, id, caption, lang) end
    def emlistnumw(lines, caption = nil, lang = nil) emlistnum(lines, caption, lang) end
    def cmdw(lines, caption = nil, lang = nil) cmd(lines, caption) end
  end

  class LATEXBuilder
    def listw(lines, id, caption, lang = nil)
      puts '\begin{widepage}'
      list(lines, id, caption, lang)
      puts '\end{widepage}'
    end

    def emlistw(lines, caption = nil, lang = nil)
      puts '\begin{widepage}'
      emlistw(lines, caption, lang)
      puts '\end{widepage}'
    end

    def listnumw(lines, id, caption, lang = nil)
      puts '\begin{widepage}'
      listnum(lines, id, caption, lang)
      puts '\end{widepage}'
    end

    def emlistnumw(lines, caption = nil, lang = nil)
      puts '\begin{widepage}'
      emlistnum(lines, caption, lang)
      puts '\end{widepage}'
    end

    def cmdw(lines, caption = nil, lang = nil)
      puts '\begin{widepage}'
      cmd(lines, caption, lang)
      puts '\end{widepage}'
    end
  end
end
