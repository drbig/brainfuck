#!/usr/bin/env ruby
#
# bfbin.rb - Convert brainfuck source to binary code
# And vice-versa!
# © 2013 Piotr S. Staszewski
# License: If you make money of it contact me. I want my bottle of whisky.
#
# ,,Inspired by brainfuck, my code is perlish, yet again.''
#

if ARGV.length != 3
  STDERR.puts 'Usage: ./txt2bf.rb <in|out> <input:path> <output:path>'
  exit(2)
end

def die(msg)
  STDERR.puts msg
  exit(2)
end

SYMBOLS = Hash[%w{ > < + - . , [ ] } \
  .enum_for(:each_with_index).collect{|x,i| [x, i.to_s(2).rjust(3, '0')]}]

mode, input, output = ARGV

%w{ in out }.member? mode or die('Unknown mode, sorry.')
File.exists? input or die('Input file not found.')
File.exists? output and die('Output file already exists.')

case mode
when 'in'
  File.open(input, 'r') do |fi|
    File.open(output, 'wb') do |fo|
      uint_str = ''
      fi.each_char do |c|
        SYMBOLS.has_key? c or next
        uint_str += SYMBOLS[c]
        uint_str.length >= 8 and fo.write([ uint_str.slice!(0, 8).to_i(2) ].pack('C'))
      end
      uint_str.length > 0 and fo.write([ uint_str.ljust(8, '0').to_i(2) ].pack('C'))
    end
  end
when 'out'
  File.open(input, 'rb') do |fi|
    File.open(output, 'w') do |fo|
      uint_str = ''
      fi.each_byte do |c|
        uint_str += c.to_s(2).rjust(8, '0')
        while uint_str.length >= 3
          val = uint_str.slice!(0, 3)
          SYMBOLS.has_value? val or die("Unknown value '#{val}'.")
          fo.write(SYMBOLS.key(val))
        end
      end
    end
  end
else
  die('How come you got to this codepath?')
end
