module ReVIEW
  class LATEXBuilder
    def compile_ruby(base, ruby)
      type = ruby.include?('|') ? 'j' : 'g'
      "\\jruby[#{type}f]{#{escape(base.strip)}}{#{ruby.strip}}"
    end
  end

  module BuilderRuby
    def compile_ruby(base, ruby)
      super(base.strip, ruby.delete('|').strip)
    end
  end
  HTMLBuilder.send(:prepend, BuilderRuby) if defined? HTMLBuilder
end
