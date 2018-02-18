module ReVIEW
  class Compiler
    definline :author
  end

  class Builder
    @author = nil
    def inline_author(str)
      @author = str
      return ''
    end
  end

  module BuilderAuthor
    def bind(compiler, chapter, location)
      @author = nil
      super
    end
  end
  Builder.send(:prepend, BuilderAuthor)

  module LATEXBuilderAuthor
    def headline_prefix(level)
      if level === 1
        str = @author.nil? ? '' : ecape(@author) + '~著'
        puts macro('renewcommand', '\\authorname', str)
      end
      super
    end
  end
  LATEXBuilder.send(:prepend, LATEXBuilderAuthor) if defined? LATEXBuilder

  module HTMLBuilderAuthor
    def headline_prefix(level)
      ret = super
      return (level != 1 || @author.nil?) ? ret : ["著・#{escape(@author)} #{ret[0]}", ret[1]]
    end
  end
  HTMLBuilder.send(:prepend, HTMLBuilderAuthor) if defined? HTMLBuilder
end
