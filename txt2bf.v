import os
import flag
import strings
import strings.textscanner

const (
	version            = 'v0.0.1'
	def_build_buf_size = 4096
)

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('txt2rb')
	fp.description('The text rarefication engine!')
	fp.version(version)
	fp.limit_free_args(0, 0)
	fp.skip_executable()

	chunk_size := fp.int('chunk_size', 0, 16, 'Text chunk size')

	fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		return
	}

	print('Write your message: ')
	msg := os.get_line()

	mut msg_scn := textscanner.new(msg)
	// mut bldr_out := strings.new_builder(def_build_buf_size)
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

		println('chunk: $bldr_chunk')
		bldr_chunk.cut_to(0)
		if done {
			break
		}
	}
}
