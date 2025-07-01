package main

import "core:fmt"
import "core:strings"
import "decoding"
import time "core:time"

main :: proc() {
	//data := "aGVsbG8gd29ybGQhIHhE"
	data := "68656c6c6f20776f726c6421"

	dd := transmute([]u8)data[:]
	fmt.printfln("%s", dd)
	lt := decoding.base64_new_lookup_table()
	d1, err1 := decoding.hex_decode(dd)
	d2, err2 := decoding.base64_decode(&lt, dd)

	//fmt.println(err)
	fmt.print(err1)
	fmt.printfln(" %s", d1)
	fmt.print(err2)
	fmt.printfln(" %s", d2)

	/*lt := decoding.new_lookup_table()
	
	start := time.now()
	data := "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="
	base64FastCount := 1000000
	for i := 0; i < base64FastCount; i += 1 {
		//d, _ := decoding.decode_base64_fast4(transmute([]u8)data)
		d, _ := decoding.decode_base64_fast5(&lt, transmute([]u8)data)
		//d, _ := decoding.decode_base64(transmute([]u8)data)
		decoding.delete_dynamic_bytes(&d)
	}
	fmt.println("time spent:", time.duration_milliseconds(time.since(start)), " milliseconds")*/
}
