require 'open3'
require 'base64'

module ReVIEW
  class Compiler
    defblock :pandoc, 0..1
  end

  class Builder
    def pandoc(lines, from)
      puts pandoc_from_to(lines, from, 'plain')
    end

    protected
    def pandoc_from_to(lines, from, to)
      plain = Base64.decode64(lines.join(''))
      return Open3.capture3("pandoc -f #{from} -t #{to}", :stdin_data => plain)[0]
    end
  end

  class LATEXBuilder
    def pandoc(lines, from)
      puts pandoc_from_to(lines, from, 'latex')
    end
  end

  class HTMLBuilder
    def pandoc(lines, from)
      puts pandoc_from_to(lines, from, 'html5')
    end
  end
end
