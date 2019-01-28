require 'json'
require 'open3'
require 'base64'

module ReVIEW
  class Compiler
    defblock :profile, 0..2, true
  end

  class Builder
    def profile(lines, author='', title='')
      items = author_split(author)
      puts items['author']
      puts items['twitter'] if items.key?('twitter')
      puts title
      puts lines
    end

    private
    def author_split(str)
      items = str.split(';')
      ret = {'author' => items.shift}
      items.each do | item |
        tmp = item.split(':', 2)
        ret[tmp[0]] = tmp[1] || ''
      end
      return ret
    end
  end

  class LATEXBuilder
    def profile(lines, author='', title='')
      items = author_split(author)
      puts "\\begin{profile}{#{escape(items['author'])}}{#{compile_inline(title)}}{#{escape(items['twitter'] || '')}}{#{items['twitter'] || ''}}"
      puts lines
      puts '\end{profile}'
    end
  end

  class HTMLBuilder
    def profile(lines, author='', title='')
      items = author_split(author)
      aut = items.key?('twitter') ? "#{items['author']} (@#{items['twitter']})" : items['author']
      puts "<dl><dt>#{escape(aut)}</dt><dd>#{lines.join('')}</dd></dl>"
    end
  end
end
