require "bit_array"

struct JaroWinkler
  VERSION = "0.1"

  DEFAULT_ADJ_TABLE = [
    ['A', 'E'], ['A', 'I'], ['A', 'O'], ['A', 'U'], ['B', 'V'], ['E', 'I'], ['E', 'O'], ['E', 'U'], ['I', 'O'],
    ['I', 'U'], ['O', 'U'], ['I', 'Y'], ['E', 'Y'], ['C', 'G'], ['E', 'F'], ['W', 'U'], ['W', 'V'], ['X', 'K'],
    ['S', 'Z'], ['X', 'S'], ['Q', 'C'], ['U', 'V'], ['M', 'N'], ['L', 'I'], ['Q', 'O'], ['P', 'R'], ['I', 'J'],
    ['2', 'Z'], ['5', 'S'], ['8', 'B'], ['1', 'I'], ['1', 'L'], ['0', 'O'], ['0', 'Q'], ['C', 'K'], ['G', 'J'],
    ['E', ' '], ['Y', ' '], ['S', ' '],
  ].reduce(Hash(Char, Hash(Char, Bool)).new) do |hash, elem|
    c1, c2 = elem
    hash[c1] ||= Hash(Char, Bool).new
    hash[c2] ||= Hash(Char, Bool).new
    hash[c1][c2] = true
    hash[c2][c1] = true
    hash
  end

  def initialize(@weight = 0.1, @threshold = 0.7, @ignore_case = false, @adj_table = false)
    raise ArgumentError.new("weight should be > 0.25") if @weight > 0.25
  end

  def distance(s1 : String, s2 : String)
    _distance(s1.chars, s2.chars)
  end

  def distance(s1 : Array(Char), s2 : Array(Char))
    _distance(s1, s2)
  end

  def jaro_distance(s1 : String, s2 : String)
    _jaro_distance(s1.chars, s2.chars)
  end

  def jaro_distance(s1 : Array(Char), s2 : Array(Char))
    _jaro_distance(s1, s2)
  end

  private def _distance(codes1, codes2)
    jaro_distance = _jaro_distance(codes1, codes2)

    if jaro_distance < @threshold
      jaro_distance
    else
      codes1, codes2 = codes2, codes1 if codes1.size > codes2.size
      len1, len2 = codes1.size, codes2.size
      max_4 = len1 > 4 ? 4 : len1
      prefix = 0
      while prefix < max_4 && codes1[prefix] == codes2[prefix]
        prefix += 1
      end
      jaro_distance + prefix * @weight * (1 - jaro_distance)
    end
  end

  private def _jaro_distance(codes1, codes2)
    codes1, codes2 = codes2, codes1 if codes1.size > codes2.size
    len1, len2 = codes1.size, codes2.size
    return 0.0 if len1 == 0 || len2 == 0

    if @ignore_case
      codes1.map! { |c| c = c.ord; c >= 97 && c <= 122 ? (c - 32).chr : c.chr }
      codes2.map! { |c| c = c.ord; c >= 97 && c <= 122 ? (c - 32).chr : c.chr }
    end

    window = len2 / 2 - 1
    window = 0 if window < 0
    flags1, flags2 = BitArray.new(len1), BitArray.new(len2)

    # count number of matching characters
    match_count = 0
    (0...len1).each do |i|
      left = (i >= window) ? i - window : 0
      right = (i + window <= len2 - 1) ? (i + window) : (len2 - 1)
      right = len2 - 1 if right > len2 - 1
      (left..right).each do |j|
        next if flags2[j]

        if codes1[i] == codes2[j]
          flags1[i] = true
          flags2[j] = true
          match_count += 1
          break
        end
      end
    end

    return 0.0 if match_count == 0

    # count number of transpositions
    transposition_count = k = 0

    (0...len1).each do |i|
      next unless flags1[i]

      j = (k...len2).each do |j|
        if flags2[j]
          k = j + 1
          break j
        end
      end

      transposition_count += 1 if codes1[i] != codes2[j]
    end

    # count similarities in nonmatched characters
    similar_count = 0
    if @adj_table && len1 > match_count
      (0...len1).each do |i|
        next if flags1[i]
        (0...len2).each do |j|
          next if flags2[j]

          if DEFAULT_ADJ_TABLE[codes1[i]]?.try &.[]?(codes2[j])
            similar_count += 3
            break
          end
        end
      end
    end

    m = match_count.to_f
    t = transposition_count / 2
    m = similar_count / 10.0 + m if @adj_table
    (m / len1 + m / len2 + (m - t) / m) / 3
  end
end
