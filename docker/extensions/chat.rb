require 'pp'

module ReVIEW
  class Compiler
    defblock :chat, 1
    defblock :rchat, 1
  end

  class Builder
    def chat(lines, label)
      caption = label.split('_')[0]
      puts "#{caption}「#{lines}」"
    end

    def rchat(lines, label)
      chat(lines, label)
    end
  end

  class LATEXBuilder
    def chat(lines, label)
      caption = label.split('_')[0]
      path = @chapter.image_index.find_path(label)
      puts "\\begin{chat}{#{path}}{#{caption}}"
      puts lines
      puts "\\end{chat}"
    end

    def rchat(lines, label)
      caption = label.split('_')[0]
      path = @chapter.image_index.find_path(label)
      puts "\\begin{rchat}{#{path}}{#{caption}}"
      puts lines
      puts "\\end{rchat}"
    end
  end
end
