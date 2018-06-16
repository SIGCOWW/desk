module ReVIEW
  module BuilderAuthor
    def bind(compiler, chapter, location)
      @author = nil
      @katagaki = nil
      super
    end

    def headline(level, label, caption)
      m = caption.match(/^(.*)（(.*?) 著）$/)
      if not(m.nil?)
        caption = m[1]
        parts = m[2].rpartition(',')
        if not(parts[0].empty?)
          @katagaki = escape(parts[0])
        end
        @author = escape(parts[2])
      end
      super
    end
  end
  LATEXBuilder.send(:prepend, BuilderAuthor) if defined? LATEXBuilder
  HTMLBuilder.send(:prepend, BuilderAuthor) if defined? HTMLBuilder

  module LATEXBuilderAuthor
    def headline_prefix(level)
      if level === 1
        author = @author.nil? ? '' : "\\authorsub{#{@author}}"
        katagaki = @katagaki.nil? ? '' : "\\katagakisub{#{@katagaki}}"
        puts macro('renewcommand', '\\authorname', author)
        puts macro('renewcommand', '\\katagakiname', katagaki)
      end
      super
    end
  end
  LATEXBuilder.send(:prepend, LATEXBuilderAuthor) if defined? LATEXBuilder

  module HTMLBuilderAuthor
    def headline_prefix(level)
      ret = super
      return (level != 1 || @author.nil?) ? ret : ["著・#{@author} #{ret[0]}", ret[1]]
    end
  end
  HTMLBuilder.send(:prepend, HTMLBuilderAuthor) if defined? HTMLBuilder
end
