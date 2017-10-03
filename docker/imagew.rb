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
      puts '\let\temp\reviewimage'
      puts '\let\endtemp\endreviewimage'
      puts '\let\reviewimage\reviewimagew'
      puts '\let\endreviewimage\endreviewimagew'
      image(lines, id, caption, metric)
      puts '\let\reviewimage\temp'
      puts '\let\endreviewimage\endtemp'
    end
  end
end
