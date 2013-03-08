#!/usr/bin/env ruby
#
# txt2bf.rb - Convert a chunk of text to brainfuck code!
# Also adds (or actually subtracts) a figlet logo.
# © 2013 Piotr S. Staszewski
# License: If you make money of it contact me. I want my bottle of whisky.
#
# ,,Inspired by brainfuck, my code is perlish, yet again.''
#

if ARGV.length != 4
  STDERR.puts 'Usage: ./txt2bf.rb <chunk_size:int> <width:int> <font:str> <logo:str>'
  exit(2)
end

CHUNK_SIZE = ARGV.shift.to_i
WIDTH = ARGV.shift.to_i
LOGO = `figlet -w #{WIDTH} -c -f #{ARGV.shift} #{ARGV.shift}`
NOPS = %w{ <> >< +- -+ } # Note: only 2-symbol nops

# reformat figlet output (empty line squashing)
has_text = false
logo = Array.new
LOGO.lines.each do |line|
  if has_text
    if line =~ /^\s+$/
      logo << "\n"
      has_text = false
    else
      logo << line
    end
  else
    unless line =~ /^\s+$/
      logo << line
      has_text = true
    end
  end
end
logo.pop
logo = logo.join

# from text to Brainfuck
# modelled after the Wikipedia example, but without any 'smart' optimisations
code = String.new
STDIN.read.scan(Regexp.new(".{1,#{CHUNK_SIZE}}")).each do |chunk|
  code << '+' * 10 << '['
  chunk.chars.each do |char|
    code << '>' << '+' * (char.ord/10)
  end
  code << '<' * chunk.length << '-]'

  chunk.chars.each do |char|
    code << '>' << '+' * (char.ord%10) << '.'
  end
  code << '>'
end

# pad the code and center the logo
padding = WIDTH - ((logo.gsub("\n", '').gsub(' ', '').length + code.length) % WIDTH)
code_lines = code.length / WIDTH
logo_lines = logo.lines.to_a.length

if code_lines < logo_lines
  padding += WIDTH * (logo_lines - code_lines + 4)
  start_line = 3
else
  start_line = ((code_lines - logo_lines).to_f / 2.0).ceil + 1
end

while padding > 1
  code.insert(rand(code.length), NOPS.sample)
  padding -= 2
end
if padding == 1
  code << '>'
end

# print out the result!
line = pos = logo_idx = 0
in_logo = true
data = code.chars.to_a
while data.length > 0
  if line >= start_line
    if in_logo
      if logo[logo_idx] == "\n"
        in_logo = false
      elsif logo[logo_idx] != ' '
        print ' ' # or print logo[logo_idx] to actually add the logo
        pos += 1
      end
      logo_idx += 1
    end
  end

  unless in_logo and (logo[logo_idx] != ' ' and logo[logo_idx] != "\n")
    print data.shift
    pos += 1
  end

  if pos % WIDTH == 0
    print "\n"
    pos = 0
    line += 1
    if logo_idx < logo.length
      in_logo = true
    end
  end
end
