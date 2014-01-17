module Asm
  def self.asm(&block)
    memory = Memory.new
    memory.instance_eval(&block)
    memory.execute
    memory.table.values
  end

  class Memory
    attr_reader :table

    def initialize
      @table = { ax: 0, bx: 0, cx: 0, dx: 0 }
      @instructions = []
      @labels = {}
      @comparison = 0
      @counter = 0
    end

    INSTRUCTIONS = {
    mov: ->(destination_register, source) do
      @table[destination_register] = source.is_a?(Symbol) ? @table[source] : source
    end,

    inc: ->(destination_register, value = 1) do
      @table[destination_register] += value.is_a?(Symbol) ? @table[value] : value
    end,

    dec: ->(destination_register, value = 1) do
      @table[destination_register] -= value.is_a?(Symbol) ? @table[value] : value
    end,

    cmp: ->(register, value) do
      @comparison = if value.is_a?(Symbol)
        table[register] <=> table[value]
        else
          table[register] <=> value
        end
    end,

    jmp: ->(where) do
      where.is_a?(Integer) ? @counter = where  : @counter = @labels[where] - 1
    end,

    je:  ->(where) do
      if @comparison == 0
        where.is_a?(Integer) ? @counter = where - 1  : @counter = @labels[where] - 1
      end
    end,

    jne: ->(where) do
      unless @comparison == 0
        where.is_a?(Integer) ? @counter = where - 1  : @counter = @labels[where] - 1
      end
    end,

    jl:  ->(where) do
      if @comparison < 0
        where.is_a?(Integer) ? @counter = where - 1  : @counter = @labels[where] - 1
      end
    end,

    jle: ->(where) do
      if @comparison <= 0
        where.is_a?(Integer) ? @counter = where - 1  : @counter = @labels[where] - 1
      end
    end,

    jg:  ->(where) do
      if @comparison > 0
        where.is_a?(Integer) ? @counter = where - 1  : @counter = @labels[where] - 1
      end
    end,

    jge: ->(where) do
      if @comparison >= 0
        where.is_a?(Integer) ? @counter = where - 1  : @counter = @labels[where] - 1
      end
    end
    }

    def method_missing(name, *args)
      if INSTRUCTIONS.keys.include?(name)
        @instructions << [name, args]
      elsif name == :label
        @labels[args.first] = @instructions.length
      else
        name
      end
    end

    def execute
      until @counter == @instructions.length
        instructions_result = self.instance_exec(*@instructions[@counter][1],
          &INSTRUCTIONS[@instructions[@counter][0]])
        @counter += 1
      end
    end
  end
end
