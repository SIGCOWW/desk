module ReVIEW
  class LATEXBuilder
    def tip(lines, caption = nil)
      caption = '' if caption.nil?
      puts "\\begin{tips}{#{escape(caption)}}\n"
      blocked_lines = split_paragraph(lines)
      puts blocked_lines.join("\n\n")
      puts "\\end{tips}\n"
    end
  end
end
