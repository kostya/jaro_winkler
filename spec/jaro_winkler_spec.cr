require "./spec_helper"

def assert_distance(score, str1, str2)
  JaroWinkler.new.distance(str1, str2).round(4).should eq score
end

def assert_distance_adj(score, str1, str2)
  JaroWinkler.new(adj_table: true).distance(str1, str2).round(4).should eq score
end

def assert_jaro_distance(score, str1, str2)
  JaroWinkler.new.jaro_distance(str1, str2).round(4).should eq score
end

describe JaroWinkler do
  it "test distance" do
    assert_distance 0.9667, "henka",       "henkan"
    assert_distance 1.0,    "al",          "al"
    assert_distance 0.9611, "martha",      "marhta"
    assert_distance 0.8324, "jones",       "johnson"
    assert_distance 0.9583, "abcvwxyz",    "cabvwxyz"
    assert_distance 0.84,   "dwayne",      "duane"
    assert_distance 0.8133, "dixon",       "dicksonx"
    assert_distance 0.0,    "fvie",        "ten"
    assert_distance 1.0,    "tony",        "tony"
    assert_distance 1.0,    "tonytonyjan", "tonytonyjan"
    assert_distance 1.0,    "x",           "x"
    assert_distance 0.0,    "",            ""
    assert_distance 0.0,    "tony",        ""
    assert_distance 0.0,    "",            "tony"
    assert_distance 0.8727, "tonytonyjan", "tony"
    assert_distance 0.8727, "tony",        "tonytonyjan"
    assert_distance 0.9407, "necessary",   "nessecary"
    assert_distance 0.9067, "does_exist",  "doesnt_exist"
    assert_distance 0.975,  "12345678",    "12345687"
    assert_distance 0.975,  "12345678",    "12345867"
    assert_distance 0.95,   "12345678",    "12348567"
  end

  it "jaro_distance" do
    assert_jaro_distance 0.9444, "henka",       "henkan"
    assert_jaro_distance 1.0,    "al",          "al"
    assert_jaro_distance 0.9444, "martha",      "marhta"
    assert_jaro_distance 0.7905, "jones",       "johnson"
    assert_jaro_distance 0.9583, "abcvwxyz",    "cabvwxyz"
    assert_jaro_distance 0.8222, "dwayne",      "duane"
    assert_jaro_distance 0.7667, "dixon",       "dicksonx"
    assert_jaro_distance 0.0,    "fvie",        "ten"
    assert_jaro_distance 1.0,    "tony",        "tony"
    assert_jaro_distance 1.0,    "tonytonyjan", "tonytonyjan"
    assert_jaro_distance 1.0,    "x",           "x"
    assert_jaro_distance 0.0,    "",            ""
    assert_jaro_distance 0.0,    "tony",        ""
    assert_jaro_distance 0.0,    "",            "tony"
    assert_jaro_distance 0.7879, "tonytonyjan", "tony"
    assert_jaro_distance 0.7879, "tony",        "tonytonyjan"
    assert_jaro_distance 0.9259, "necessary",   "nessecary"
    assert_jaro_distance 0.8444, "does_exist",  "doesnt_exist"
    assert_jaro_distance 0.9583, "12345678",    "12345687"
    assert_jaro_distance 0.9583, "12345678",    "12345867"
    assert_jaro_distance 0.9167, "12345678",    "12348567"
    assert_jaro_distance 0.604,  "tonytonyjan", "janjantony"
  end

  it "unicode" do
    assert_distance 0.9818, "變形金剛4:絕跡重生", "變形金剛4: 絕跡重生"
    assert_distance 0.8222, "連勝文",             "連勝丼"
    assert_distance 0.8222, "馬英九",             "馬英丸"
    assert_distance 0.6667, "良い",               "いい"
  end

  it "test_long_string" do
    assert_distance 1.0, "haisai" * 200, "haisai" * 200
  end

  it "ignore_case" do
    JaroWinkler.new(ignore_case: true).distance("MARTHA", "marhta").round(4).should eq 0.9611
  end

  it "weight" do
    JaroWinkler.new(weight: 0.2).distance("MARTHA", "MARHTA").round(4).should eq 0.9778
  end

  it "threshold" do
    JaroWinkler.new(threshold: 0.99).distance("MARTHA", "MARHTA").round(4).should eq 0.9444
  end

  it "raises" do
    expect_raises(ArgumentError) do
      JaroWinkler.new(weight: 0.26).distance("MARTHA", "MARHTA")
    end
  end

  it "adjusting_table" do
    assert_distance_adj 0.9667, "HENKA",    "HENKAN"
    assert_distance_adj 1.0,    "AL",       "AL"
    assert_distance_adj 0.9611, "MARTHA",   "MARHTA"
    assert_distance_adj 0.8598, "JONES",    "JOHNSON"
    assert_distance_adj 0.9583, "ABCVWXYZ", "CABVWXYZ"
    assert_distance_adj 0.8730, "DWAYNE",   "DUANE"
    assert_distance_adj 0.8393, "DIXON",    "DICKSONX"
    assert_distance_adj 0.0,    "FVIE",     "TEN"
  end

  it "work with array of chars" do
    assert_distance 0.9667, "henka".chars,       "henkan".chars
  end
end
