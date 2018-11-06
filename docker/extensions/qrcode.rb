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
      ret = '\vspace{0.5\baselineskip}\\\\{'
      ret += '\setlength\lineskiplimit{0pt}'
      ret += '\setlength\normallineskiplimit{0pt}'
      ret += "\\qrcode[tight,height=\\marginparwidth]{#{str}}"
      ret += '}\vspace{0.5\baselineskip}\\\\'
      return ret
    end
  end
end
