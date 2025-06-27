package main

import "core:fmt"
import "core:strings"
import "decoding"

main :: proc() {
	data := "aGVsbG8gd29ybGQhIHhE"

	dd := transmute([]u8)data[:]
	fmt.printfln("%s", dd)
	d, err := decoding.decode_base64(dd)

	fmt.println(err)
/*	for b in d {
		fmt.println(b)
		//fmt.printf("%c", u8(b))
	}

	fmt.println()*/
	fmt.printfln("%s", d)
	//fmt.wprintln(strings.to_writer(d))
}
