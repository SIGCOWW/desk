require 'json'
require 'open3'
require 'base64'

module ReVIEW
  class Compiler
    defblock :profile, 0..2, true
  end

  class Builder
    def profile(lines, author='', title='')
      puts author
      puts title
      puts lines
    end
  end

  class LATEXBuilder
    def profile(lines, author='', title='')
      puts "\\begin{profile}{#{escape(author)}}{#{compile_inline(title)}}"
      puts lines
      puts '\end{profile}'
    end
  end

  class HTMLBuilder
    def profile(lines, author='', title='')
      puts "<dl><dt>#{escape(author)}</dt><dd>#{lines.join('')}</dd></dl>"
    end
  end
end
