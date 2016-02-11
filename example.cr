require "./src/jaro_winkler"

p JaroWinkler.new.distance "MARTHA", "MARHTA"
# => 0.961111
p JaroWinkler.new(ignore_case: true).distance "MARTHA", "marhta"
# => 0.961111
p JaroWinkler.new(weight: 0.2).distance "MARTHA", "MARHTA"
# => 0.977778
p JaroWinkler.new(adj_table: true).distance "month15", "m0nth1S"
# => 0.854286
