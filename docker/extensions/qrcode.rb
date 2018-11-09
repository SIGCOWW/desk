module ReVIEW
  class Compiler
    definline :qrcode
  end

  class Builder
    def inline_qrcode(str)
    end
  end

  class LATEXBuilder
    def inline_qrcode(str)
      str.gsub!(/[\\\{\}]/) { |s| '\\' + s }
      return "\\reviewqr{#{str}}"
    end
  end
end
