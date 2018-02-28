module ReVIEW
  module BuilderAuthor
    def bind(compiler, chapter, location)
      @author = nil
      super
    end

    def headline(level, label, caption)
      m = caption.match(/^(.*)（(.*?) 著）$/)
      if not(m.nil?)
        caption = m[1]
        @author = escape(m[2])
      end
      super
    end
  end
  LATEXBuilder.send(:prepend, BuilderAuthor) if defined? LATEXBuilder
  HTMLBuilder.send(:prepend, BuilderAuthor) if defined? HTMLBuilder

  module LATEXBuilderAuthor
    def headline_prefix(level)
      if level === 1
        str = @author.nil? ? '' : @author + '~著'
        puts macro('renewcommand', '\\authorname', str)
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
