module ReVIEW
  class Compiler
    definline :kusodeka
    definline :kusodekaw
  end

  class Builder
    def inline_kusodeka(str)
      inline_strong(str)
    end

    def inline_kusodekaw(str)
      inline_kusodeka(str)
    end
  end

  class LATEXBuilder
    def inline_kusodeka(str)
      return "\\kusodeka{#{escape(str)}}"
    end

    def inline_kusodekaw(str)
      return "\\kusodekaw{#{escape(str)}}"
    end
  end
end
