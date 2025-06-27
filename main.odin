package main

import "core:fmt"
import "core:strings"
import "decoding"

main :: proc() {
	/*data := "aGVsbG8gd29ybGQhIHhE"

	dd := transmute([]u8)data[:]
	fmt.printfln("%s", dd)
	d, err := decoding.decode_base64_fast(dd)

	fmt.println(err)
	fmt.printfln("%s", d)*/

	data := "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="
	base64FastCount := 100000
	for i := 0; i < base64FastCount; i += 1 {
		d, _ := decoding.decode_base64_fast(transmute([]u8)data)
		decoding.delete_dynamic_bytes(&d)
	}
	fmt.println("hi")
}
