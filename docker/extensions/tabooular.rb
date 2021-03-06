require 'json'
require 'open3'
require 'base64'

module ReVIEW
  class Compiler
    defblock :tabletabooular, 0..2
    defblock :tabletabooularw, 0..2
  end

  class Builder
    def tabletabooular(lines, id, caption)
      begin
        table_header id, caption if caption.present?
      rescue KeyError
        error "no such table: #{id}"
      end

      table_begin(123)
      puts Base64.decode64(lines.join(''))
      table_end
    end

    def tabletabooularw(lines, id, caption)
      tabletabooular(lines, id, caption)
    end

    protected
    def tabooular_to(format, lines)
      def compile(row)
        row.each do | col |
          next unless col['type'] === 'cell'
          col['data'] = compile_inline(col['data'])
        end
      end

      def header(row)
        row.each do | col |
          next unless col['type'] === 'cell'
          col['data'] = "\\tabooularhead{#{compile_inline(col['data'])}}"
        end
      end

      plain = Base64.decode64(lines.join(''))
      stdout = Open3.capture3("tabooular -if plain -of json", :stdin_data => plain)[0]

      json = JSON.parse(stdout)
      (json['head'] || []).each{ |row| (format == 'latex') ? header(row) : compile(row) }
      json['body'].each do | rows |
        rows.each{ |row| compile(row) }
      end

      return Open3.capture3("tabooular -if json -of #{format}", :stdin_data => JSON.generate(json))[0]
    end
 end

  class LATEXBuilder
    def tabletabooular(lines, id, caption)
      begin
        puts '\begin{tabooular}'
        puts macro('reviewtablecaption', compile_inline(caption))
        puts macro('label', table_label(id))
        puts tabooular_to('latex', lines)
        puts '\end{tabooular}'
        blank
      rescue KeyError
        error "no such table: #{id}"
      end
    end

    def tabletabooularw(lines, id, caption)
      puts '\swap\tabooular\tabooularw'
      puts '\swap\endtabooular\endtabooularw'
      tabletabooular(lines, id, caption)
      puts '\swap\tabooularw\tabooular'
      puts '\swap\endtabooularw\endtabooular'
    end
  end

  class HTMLBuilder
    def tabletabooular(lines, id, caption)
      begin
        puts %Q[<div id="#{normalize_id(id)}" class="table">]
        table_header(id, caption)
        puts tabooular_to('html', lines)
        puts %Q[</div>]
      rescue KeyError
        error "no such table: #{id}"
      end
    end
  end
end
