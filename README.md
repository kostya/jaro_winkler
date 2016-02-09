# JaroWinkler

Crystal implementation of Jaro-Winkler distance algorithm which supports UTF-8 string. Translated from ruby: https://github.com/tonytonyjan/jaro_winkler

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  jaro_winkler:
    github: kostya/jaro_winkler
```


## Usage


```crystal
require "jaro_winkler"

JaroWinkler.new.distance "MARTHA", "MARHTA"
# => 0.9611
JaroWinkler.new(ignore_case: true).distance "MARTHA", "marhta"
# => 0.9611
JaroWinkler.new(weight: 0.2).distance "MARTHA", "MARHTA"
# => 0.9778

```
