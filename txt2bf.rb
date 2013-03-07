#!/usr/bin/env ruby
#

CHUNK = ARGV.first.to_i or 255

STDIN.read.scan(Regexp.new(".{1,#{CHUNK}}")).each do |chunk|
  print '+' * 10
  print '['
  chunk.chars.each do |char|
    print '>'
    print '+' * (char.ord/10)
  end
  print '<' * chunk.length
  print '-]'
  
  chunk.chars.each do |char|
    print '>'
    print '+' * (char.ord%10)
    print '.'
  end
  print '>'
end
print "\n"
