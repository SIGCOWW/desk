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
    @subfigenv = nil
    def beginsubfig(env, caption)
      @subfigenv = env
      if @subfigenv == 'subfigw'
        puts '\swap\reviewsubfig\reviewsubfigw'
        puts '\swap\endreviewsubfig\endreviewsubfigw'
      end
      puts "\\begin{reviewsubfig}{#{escape(caption)}}"
    end

    def endsubfig()
      puts '\end{reviewsubfig}'
      if @subfigenv == 'subfigw'
        puts '\swap\reviewsubfig\reviewsubfigw'
        puts '\swap\endreviewsubfig\endreviewsubfigw'
      end
      @subfigenv = nil
    end
  end
end
