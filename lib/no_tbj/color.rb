module NoTBJ::Color
  refine String do
    def red
      colorize(31)
    end

    def green
      colorize(32)
    end

    def blue
      colorize(94)
    end

    def yellow
      colorize(33)
    end

    def gray
      colorize(90)
    end

    alias error red
    alias success green
    alias info blue
    alias warn yellow
    alias minfo gray

    def colorize(color_code)
      if color_code == 90
        bright = 37
      else
        bright = color_code + 60
      end
      "\033[#{color_code}m#{self}\033[0m".gsub(/\{(.*?)\}/) { |m| "\033[#{bright}m#{$1}\033[#{color_code}m" }
    end
  end
end
