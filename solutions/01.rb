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
    frequencies = {}
    uniq.each { |element| frequencies[element] = count(element) }
    frequencies
  end

  def average
    raise ArgumentError, "Method undefined for empty array." if empty?
    reduce { |sum, element| sum + element }.to_f / size
  end

  def drop_every(n)
    reject.with_index { |_, index| (index + 1) % n == 0 }
  end

  def combine_with(other)
    combined = []
    (0...[size, other.size].max).each do |index|
      combined << self[index] unless self[index].nil?
      combined << other[index] unless other[index].nil?
    end
    combined
  end
end
