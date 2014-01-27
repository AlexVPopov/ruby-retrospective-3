module Graphics
  class Canvas
    attr_reader :width, :height
    attr_accessor :pixels

    def initialize(width, height)
      @width = width
      @height = height
      @pixels = {}
    end

    def set_pixel(x, y)
      @pixels[[x, y]] = true
    end

    def pixel_at?(x, y)
      @pixels[[x, y]]
    end

    def draw(figure)
      figure.draw_on(self)
    end

    def render_as(renderer)
      renderer.render(self)
    end
  end

  module Renderers
    module Ascii
      def self.render(canvas)
        0.upto(canvas.height.pred).map do |y|
          0.upto(canvas.width.pred).map do |x|
            canvas.pixels[[x, y]] ? '@' : '-'
          end.join('')
        end.join("\n")
      end
    end

    module Html
      HEADER = <<-EOS.gsub(/^ {6}/, '').freeze
        <!DOCTYPE html>
        <html>
        <head>
          <title>Rendered Canvas</title>
          <style type="text/css">
            .canvas {
              font-size: 1px;
              line-height: 1px;
            }
            .canvas * {
              display: inline-block;
              width: 10px;
              height: 10px;
              border-radius: 5px;
            }
            .canvas i {
              background-color: #eee;
            }
            .canvas b {
              background-color: #333;
            }
          </style>
        </head>
        <body>
          <div class="canvas">
      EOS

      FOOTER = <<-EOS.gsub(/^ {6}/, '').freeze
          </div>
        </body>
        </html>
      EOS

      def self.render(canvas)
        HEADER +
        canvas.canvas.map { |row| Renderers.process_row(row, '<b></b>', '<i></i>') }
        .join("<br>\n") +
        FOOTER
      end
    end

    private

    def self.fill_pixel(pixel, color, transparent)
      pixel ? color : transparent
    end

    def self.process_row(row, color, transparent)
      row.map { |pixel| Renderers.fill_pixel(pixel, color, transparent) }.join
    end
  end

  class Point
    include Graphics
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def draw_on(canvas)
      canvas.set_pixel x, y
    end
  end

  class Line
    include Graphics
    attr_reader :from, :to

    def initialize(from, to)
      @from, @to = from, to
    end


    def draw_on(canvas)
      rasterize(canvas, @from.x, @from.y, @to.x, @to.y)
    end

    private

    def rasterize(canvas, from_x, from_y, to_x, to_y)
      delta_x = (to_x - from_x).abs
      delta_y = (to_y - from_y).abs
      step_x  = from_x < to_x ? 1 : -1
      step_y  = from_y < to_y ? 1 : -1
      base_error = delta_x - delta_y

      loop do
        canvas.set_pixel from_x, from_y
        break if from_x == to_x and from_y == to_y
        error = 2 * base_error

        if error > -delta_y
          base_error -= delta_y
          from_x += step_x
        end

        if from_x == to_x and from_y == to_y
          canvas.set_pixel from_x, from_y
          break
        end

        if error < delta_x
          base_error += delta_x
          from_y += step_y
        end
      end
    end
  end

  class Rectangle
    include Graphics
    attr_reader :left, :right, :top_left, :top_left, :bottom_left, :bottom_right

    def initialize(first, second)
      @left_x, @right_x = [first.x, second.x].min, [first.x, second.x].max
      @top_y, @bottom_y = [first.y, second.y].min, [first.y, second.y].max
      set_corners
    end

    def draw_on(canvas)
      Graphics::Line.new(@top_left, @top_right).draw_on canvas
      Graphics::Line.new(@bottom_right, @top_right).draw_on canvas
      Graphics::Line.new(@top_left, @bottom_left).draw_on canvas
      Graphics::Line.new(@bottom_left, @bottom_right).draw_on canvas
    end

    private

    def set_corners
      @top_left     = @left  = Point.new @left_x, @top_y
      @top_right             = Point.new @right_x, @top_y
      @bottom_left           = Point.new @left_x, @bottom_y
      @bottom_right = @right = Point.new @right_x, @bottom_y
    end
  end

  def eql?(other)
    path == other.path
  end

  alias :== :eql?

  def hash
    @path.hash
  end
end
