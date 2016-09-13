#!/usr/bin/env ruby
START = 's'
EMPTY = '0'
BLOCK = '1'
UP = '^'
DOWN = 'v'
LEFT = '<'
RIGHT = '>'

class AutoCR
    attr_accessor :data, :l, :c, :start, :cursor, :path
    def initialize(data='', l=0, c=0, start=0)
        @data = data
        @l = l
        @c = c
        @start = start
        @cursor = @start
        @path = ''
        @data[@start] = START
    end

    def clone
        cr = AutoCR.new
        cr.data = @data.clone
        cr.l = @l
        cr.c = @c
        cr.start = @start
        cr.cursor = @cursor
        cr.path = @path.clone
        return cr
    end

    def up
        @path += 'u'
        x, y = cov1to2(@cursor)
        while x > 0
            x -= 1
            cursor = cov2to1(x, y)
            if @data[cursor] == EMPTY
                @data[cursor] = UP
                @cursor = cursor
            else
                return
            end
        end
    end

    def down
        @path += 'd'
        x, y = cov1to2(@cursor)
        while x < @l-1
            x += 1
            cursor = cov2to1(x, y)
            if @data[cursor] == EMPTY
                @data[cursor] = DOWN
                @cursor = cursor
            else
                return
            end
        end
    end

    def left
        @path += 'l'
        x, y = cov1to2(@cursor)
        while y > 0
            y -= 1
            cursor = cov2to1(x, y)
            if @data[cursor] == EMPTY
                @data[cursor] = LEFT
                @cursor = cursor
            else
                return
            end
        end
    end

    def right
        @path += 'r'
        x, y = cov1to2(@cursor)
        while y < @c-1
            y += 1
            cursor = cov2to1(x, y)
            if @data[cursor] == EMPTY
                @data[cursor] = RIGHT
                @cursor = cursor
            else
                return
            end
        end
    end

    def cov2to1(x, y)
        return x*@c+y
    end

    def cov1to2(i)
        return i / @c, i % @c
    end

    def is_covered?
        !@data.index(EMPTY)
    end

    def forward
        x, y = cov1to2(@cursor)
        u = x > 0    ? (@data[cov2to1(x-1, y)] == EMPTY) : false
        r = y < @c-1 ? (@data[cov2to1(x, y+1)] == EMPTY) : false
        d = x < @l-1 ? (@data[cov2to1(x+1, y)] == EMPTY) : false
        l = y > 0    ? (@data[cov2to1(x, y-1)] == EMPTY) : false
        return [u, r, d, l]
    end

    def show
        for i in 0...@l
            puts('- '*(@c*2+1))
            puts('| ' + @data.slice(i*@c, @c).split('').join(' | ') + ' |')
        end
        puts('- '*(@c*2+1))
    end

    def result
        x, y = cov1to2(@start)
        return "#{x+1} #{y+1} #@path"
    end
end

def solve(data, l, c)
    start = data.index(EMPTY)
    up = -> cr {cr.up}
    right = -> cr {cr.right}
    down = -> cr {cr.down}
    left = -> cr {cr.left}
    action = [up, right, down, left]
    while start < data.length
        crs = [AutoCR.new(data.clone, l, c, start)]
        until crs.empty?
            cr = crs.pop
            fwd = cr.forward
            for i in 0...4
                if fwd[i]
                    ccr = cr.clone
                    action[i].call(ccr)
                    if ccr.is_covered?
                        return ccr.result
                    else
                        crs.push(ccr)
                    end
                end
            end
        end
        start += 1
        while start < data.length && data[start] != EMPTY
            start += 1
        end
    end
end

x, y, map = ARGV
ret = solve(map.dup, x.to_i, y.to_i)
puts ret

