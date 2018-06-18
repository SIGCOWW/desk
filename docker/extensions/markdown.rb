require 'open3'
require 'base64'

module ReVIEW
  class Compiler
    defblock :markdown, 0
  end

  class Builder
    def markdown(lines)
      puts Base64.decode64(lines.join(''))
    end

    protected
    def markdown_to(lines, cmd)
      plain = Base64.decode64(lines.join(''))
      return Open3.capture3(cmd, :stdin_data => plain)[0]
    end
  end

  class LATEXBuilder
    def markdown(lines)
      inner = false
      markdown_to(lines, 'mkd2latex').each_line do | line |
        if inner
          break if line.strip == '\end{document}'
          puts line
        elsif line.strip == '\begin{document}'
          inner = true
        end
      end
    end
  end

  class HTMLBuilder
    def markdown(lines)
      puts markdown_to(lines, 'mkd2html')
    end
  end
end
