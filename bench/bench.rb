# gem install jaro_winkler

require 'jaro_winkler'

ary = [['al', 'al'], ['martha', 'marhta'], ['jones', 'johnson'], 
  ['abcvwxyz', 'cabvwxyz'], ['dwayne', 'duane'], ['dixon', 'dicksonx'], ['fvie', 'ten']]

def test(str1, str2, n = 100000)
  t = Time.now
  s = 0.0
  n.times do
    s += JaroWinkler.distance(str1, str2)
  end
  puts "#{str1} -- #{n} -- #{s} -- #{Time.now - t}"
end

t = Time.now

ary.each do |elem|
  str1, str2 = elem
  test(str1, str2, 1000000)
end

p Time.now - t 