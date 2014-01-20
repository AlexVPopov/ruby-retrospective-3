class Integer
  def prime?
    return false if self < 2
    return true if self == 2
    return false if (2..Math.sqrt(self).ceil).any? { |n| (self % n).zero? }
    true
  end

  def prime_factors
    return [] if self.zero? or self == 1
    factor = (2..abs).find { |number| (abs % number).zero? }
    [factor] + (abs / factor).prime_factors
  end

  def harmonic
    raise ArgumentError, "Argument is not of type Integer" unless integer?
    raise ArgumentError, "Number can't be negative or null" if self <= 0
    (1..self).reduce { |sum, number| sum + Rational(1, number) }
  end

  def digits
    abs.to_s.chars.map { |digit| digit.to_i }
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
