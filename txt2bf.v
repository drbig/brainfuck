import os
import flag
import strings
import strings.textscanner

const (
	version            = 'v0.0.1'
	def_build_buf_size = 4096
	bf_nops            = ['<>', '><', '+-', '-+']
)

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('txt2rb')
	fp.description('The text rarefication engine!')
	fp.version(version)
	fp.limit_free_args(0, 0)
	fp.skip_executable()

	chunk_size := fp.int('chunk_size', 0, 16, 'Text chunk size')
	width := fp.int('width', 0, 80, 'Output block width')

	fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		return
	}

	print('Write your message: ')
	msg := os.get_line()

	mut msg_scn := textscanner.new(msg)
	mut bldr_out := strings.new_builder(def_build_buf_size)
	mut bldr_chunk := strings.new_builder(chunk_size)
	mut done := false
	for {
		for _ in 0 .. chunk_size {
			c := msg_scn.next()
			if c == -1 {
				done = true
				break
			}
			bldr_chunk.write_b(byte(c))
		}

		bldr_out.write_string('++++++++++[')
		for i := 0; i < bldr_chunk.len; i++ {
			bldr_out.write_b(`>`)
			bldr_out.write_string(strings.repeat(`+`, bldr_chunk.byte_at(i) / 10))
		}
		bldr_out.write_string(strings.repeat(`<`, bldr_chunk.len))
		bldr_out.write_string('-]')

		for i := 0; i < bldr_chunk.len; i++ {
			bldr_out.write_b(`>`)
			bldr_out.write_string(strings.repeat(`+`, bldr_chunk.byte_at(i) % 10))
			bldr_out.write_b(`.`)
		}
		bldr_out.write_b(`>`)

		bldr_chunk.cut_to(0)
		if done {
			break
		}
	}

	pad_len := width - (bldr_out.len % width)
	parity := pad_len % 2
	lines := (bldr_out.len + pad_len) / 80
	for i in 0 .. ((pad_len - parity) / 2) {
		bldr_out.write_string(bf_nops[i % bf_nops.len])
	}
	if parity > 0 {
		bldr_out.write_b(`>`)
	}

	out_str := bldr_out.str()
	for i := 0; i < lines; i++ {
		println(out_str[(i * width)..((i + 1) * width)])
	}
}
