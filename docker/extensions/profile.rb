require 'json'
require 'open3'
require 'base64'

module ReVIEW
  class Compiler
    defblock :profile, 0..1, true
  end

  class Builder
    def profile(lines, author='')
      puts author
      puts lines
    end
  end

  class LATEXBuilder
    def profile(lines, author='')
      puts "\\begin{profile}{#{escape(author)}}"
      puts lines
      puts '\end{profile}'
    end
  end

  class HTMLBuilder
    def profile(lines, author='')
      puts "<dl><dt>#{escape(author)}</dt><dd>#{lines.join('')}</dd></dl>"
    end
  end
end
