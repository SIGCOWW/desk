module ReVIEW
  class Compiler
    definline :emoji
  end

  class Builder
    def inline_emoji(str)
      ":#{escape(str)}:"
    end

    protected
    def emoji2latex(str)
      require 'gemoji'

      emoji_alias = {}
      emoji_alias["thinking"] = ["thinking_face"]
      emoji_alias.each do | key, arr |
        emoji = Emoji.find_by_alias(key)
        Emoji.edit_emoji(emoji) do | char |
          arr.each do | val |
            char.add_alias(val)
          end
        end
      end

      emoji = Emoji.find_by_alias(str)
      return ":#{escape(str)}:" if emoji.nil?

      codepoint = emoji.raw.each_codepoint.map{|n| n.to_s(16) }[0].upcase
      return "\\coloremojiucs{#{codepoint}}"
    end
  end

  class LATEXBuilder
    def inline_emoji(str)
      return emoji2latex(str)
    end
  end

  class HTMLBuilder
    def inline_emoji(str)
      return inline_m(emoji2latex(str))
    end
  end
end
