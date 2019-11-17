# frozen_string_literal: true

# https://stackoverflow.com/questions/3852755/ruby-array-subtraction-without-removing-items-more-than-once
class Array
  # Subtract each passed value once:
  #   %w(1 2 3 1).subtract_once %w(1 1 2) # => ["3"]
  #   [ 1, 1, 2, 2, 3, 3, 4, 5 ].subtract_once([ 1, 2, 4 ]) => [1, 2, 3, 3, 5]
  # Time complexity of O(n + m)
  def subtract_once(values)
    counts = values.each_with_object(Hash.new(0)) { |v, h| h[v] += 1; }
    reject { |e| counts[e] -= 1 unless counts[e].zero? }
  end

  def same_values?
    self.uniq.length == 1
  end
end
