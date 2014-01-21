class Integer
  def prime?
    return false if self < 2
    self == 2 or
    (2..Math.sqrt(self).ceil).none? { |divisor| (self % divisor).zero? }
  end

  def prime_factors
    return [] if zero? or self == 1
    factor = (2..abs).find { |number| (abs % number).zero? }
    [factor] + (abs / factor).prime_factors
  end

  def harmonic
    (1..self).reduce { |sum, number| sum + Rational(1, number) }
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    uniq.each_with_object({}) do |element, frequencies|
      frequencies[element] = count(element)
    end
  end

  def average
    reduce(&:+).to_f / size
  end

  def drop_every(n)
    reject.with_index { |_, index| (index + 1) % n == 0 }
  end

  def combine_with(other)
    short, long = self.size > other.size ? [other, self] : [self, other]
    take(short.size).zip(other.take(short.size)).flatten(1) +
    long.drop(short.size)
  end
end
