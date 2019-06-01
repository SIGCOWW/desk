module ReVIEW
  class Compiler
    definline :texquote
  end

  class Builder
    def inline_texquote(str)
      return str[0] == '`' ? '“' : '”'
    end
  end

  class LATEXBuilder
    def inline_texquote(str)
      return str
    end
  end
end
