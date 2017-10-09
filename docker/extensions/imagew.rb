module ReVIEW
  class Compiler
    defblock :imagew, 2..3, true
  end

  class Builder
    def imagew(lines, id, caption, metric = nil)
      image(lines, id, caption, metric)
    end
  end

  class LATEXBuilder
    def imagew(lines, id, caption, metric = nil)
      puts '\swap\reviewimage\reviewimagew'
      puts '\swap\endreviewimage\endreviewimagew'
      image(lines, id, caption, metric)
      puts '\swap\reviewimagew\reviewimage'
      puts '\swap\endreviewimagew\endreviewimage'
    end
  end
end
