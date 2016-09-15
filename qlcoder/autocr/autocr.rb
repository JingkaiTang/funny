#!/usr/bin/env ruby
require 'parallel'

START = 's'
EMPTY = '0'
BLOCK = '1'
UP = '^'
DOWN = 'v'
LEFT = '<'
RIGHT = '>'
DYE = '#'

class AutoCR
    attr_accessor :data, :l, :c, :start, :cursor, :path, :empty, :dye

    def initialize(data='', l=0, c=0, start=0)
        @data = data
        @l = l
        @c = c
        @start = start
        @cursor = @start
        @path = ''
        @data[@start] = START
        @empty = EMPTY
        @dye = DYE
    end

    def clone
        cr = AutoCR.new
        cr.data = @data.clone
        cr.l = @l
        cr.c = @c
        cr.start = @start
        cr.cursor = @cursor
        cr.path = @path.clone
        cr.empty = @empty
        cr.dye = @dye
        return cr
    end

    def up
        @path += 'u'
        x, y = cov1to2(@cursor)
        while x > 0
            x -= 1
            cursor = cov2to1(x, y)
            if @data[cursor] == @empty
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
            if @data[cursor] == @empty
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
            if @data[cursor] == @empty
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
            if @data[cursor] == @empty
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
        !@data.index(@empty)
    end

    def forward
        x, y = cov1to2(@cursor)
        u = x > 0    ? (@data[cov2to1(x-1, y)] == @empty) : false
        r = y < @c-1 ? (@data[cov2to1(x, y+1)] == @empty) : false
        d = x < @l-1 ? (@data[cov2to1(x+1, y)] == @empty) : false
        l = y > 0    ? (@data[cov2to1(x, y-1)] == @empty) : false
        return [u, r, d, l]
    end

    def show
        for i in 0...@l
            puts('- '*(@c*2+1))
            puts('| ' + (@data.slice(i*@c, @c).split('')).join(' | ') + ' |')
        end
        puts('- '*(@c*2+1))
    end

    def result
        x, y = cov1to2(@start)
        return "#{x+1} #{y+1} #@path"
    end

    def solvable?
        s = @data.index(@empty)
        return true unless s
        go_dye(s)
        @empty, @dye = @dye, @empty
        return !@data.index(@dye)
    end

    def go_dye(i)
        return if @data[i] != @empty
        @data[i] = @dye
        x, y = cov1to2(i)
        go_dye(cov2to1(x-1, y)) if x > 0
        go_dye(cov2to1(x+1, y)) if x < @l-1
        go_dye(cov2to1(x, y-1)) if y > 0
        go_dye(cov2to1(x, y+1)) if y < @c-1
    end
end

def solve(data, l, c)
    starts = (0...data.length).select {|i| data[i] == EMPTY}
    starts.shuffle!
    up = -> cr {cr.up}
    right = -> cr {cr.right}
    down = -> cr {cr.down}
    left = -> cr {cr.left}
    actions = [up, right, down, left]
    Parallel.map(starts, in_processes: 2) do |start|
        crs = [AutoCR.new(data.clone, l, c, start)]
        until crs.empty?
            cr = crs.pop
            fwd = cr.forward.zip(actions).select {|f, a| f}
            if fwd.empty? && cr.is_covered?
                puts cr.result
                raise Parallel::Kill
            end
            fwd.each_with_index do |(_, action), i|
                ccr = (i+1 == fwd.length) ? cr : cr.clone
                action.call(ccr)
                if ccr.solvable?
                    crs.push(ccr)
                end
            end
        end
    end
end

x, y, map = ARGV
solve(map.dup, x.to_i, y.to_i)

