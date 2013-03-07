#!/usr/bin/env ruby
#

if ARGV.length != 2
  STDERR.puts 'Usage: ./txt2bf.rb <chunk_size:int> <logo:text>'
  exit(2)
end

CHUNK = ARGV.shift.to_i
LOGO = `figlet -w 80 -c -f block #{ARGV.shift} | sed '/^ *$/d'`
NOPS = %w{ <> >< +- -+ }

code = String.new

STDIN.read.scan(Regexp.new(".{1,#{CHUNK}}")).each do |chunk|
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

padding = 80 - ((LOGO.gsub("\n", '').gsub(' ', '').length + code.length) % 80)
code_lines = code.length / 80
logo_lines = LOGO.lines.to_a.length

if code_lines < logo_lines
  padding += 80 * (logo_lines - code_lines + 4)
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

line = pos = logo_idx = 0
in_logo = true

data = code.chars.to_a
while data.length > 0
  if line >= start_line
    if in_logo
      if LOGO[logo_idx] == "\n"
        in_logo = false
      elsif LOGO[logo_idx] != ' '
        print ' ' #print LOGO[logo_idx]
        pos += 1
      end
      logo_idx += 1
    end
  end

  unless in_logo and (LOGO[logo_idx] != ' ' and LOGO[logo_idx] != "\n")
    print data.shift
    pos += 1
  end

  if pos % 80 == 0
    print "\n"
    pos = 0
    line += 1
    if logo_idx < LOGO.length
      in_logo = true
    end
  end
end
