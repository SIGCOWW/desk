module ReVIEW
  class Compiler
    definline :seqsplit
  end

  class Builder
    def inline_seqsplit(str)
      escape(str)
    end
  end

  class LATEXBuilder
    def inline_seqsplit(str)
      "\\seqsplit{#{escape(str)}}"
    end
  end
end
