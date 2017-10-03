module ReVIEW
  class Compiler
    defsingle :beginsubfig, 2
    defsingle :endsubfig, 0
    definline :newline
  end

  class Builder
    def beginsubfig(env, caption) '' end
    def endsubfig() '' end
    def inline_newline(str) '' end
  end

  class LATEXBuilder
    def beginsubfig(env, caption)
      puts '\let\temp\reviewsubfig'
      puts '\let\endtemp\endreviewsubfig'
      if env == 'subfigw'
        puts '\let\reviewsubfig\reviewsubfigw'
        puts '\let\endreviewsubfig\endreviewsubfigw'
      end
      puts "\\begin{reviewsubfig}{#{escape(caption)}}"
    end

    def endsubfig()
      puts "\\end{reviewsubfig}"
      puts '\let\reviewsubfig\temp'
      puts '\let\endreviewsubfig\endtemp'
    end
  end
end
