module ReVIEW
  class Compiler
    definline :kusodeka
  end

  class Builder
    def inline_kusodeka(str)
      inline_strong(str)
    end
  end

  class LATEXBuilder
    def inline_kusodeka(str)
      return "\\kusodeka{#{escape(str)}}"
    end
  end
end
