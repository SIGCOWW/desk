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
      print '\blockmargin\begin{widepage}'
      list(lines, id, caption, lang)
      print '\end{widepage}\unblockmargin\par'
    end

    def emlistw(lines, caption = nil, lang = nil)
      print '\blockmargin\begin{widepage}'
      emlist(lines, caption, lang)
      print '\end{widepage}\unblockmargin\par'
    end

    def listnumw(lines, id, caption, lang = nil)
      print '\blockmargin\begin{widepage}'
      listnum(lines, id, caption, lang)
      print '\end{widepage}\unblockmargin\par'
    end

    def emlistnumw(lines, caption = nil, lang = nil)
      print '\blockmargin\begin{widepage}'
      emlistnum(lines, caption, lang)
      puts '\end{widepage}\unblockmargin\par'
    end

    def cmdw(lines, caption = nil, lang = nil)
      print '\blockmargin\begin{widepage}'
      cmd(lines, caption, lang)
      print '\end{widepage}\unblockmargin\par'
    end
  end
end
