package main

import "core:fmt"
import "core:strings"
import "decoding"
import time "core:time"
import os "core:os"

is_printable_ascii_range :: proc(b: byte) -> bool {
	return b >= 0x20 && b <= 0x7e
}

byte_color :: proc(b: byte) -> string {
	switch b {
	case 0:
		return "\x1b[1;37m" // White
	case ' ', 0xff:
		return "\x1b[1;34m" // Blue
	case '\n', '\r', '\t':
		return "\x1b[1;33m" // Yellow
	}

	if is_printable_ascii_range(b) {
		return "\x1b[1;32m" // Green
	}

	return "\x1b[1;31m" // Red
}

print_line :: proc(name: string, output: []u8, error: decoding.Error) {
	fmt.print(name, error)
	fmt.print(" ")
	
	for b in output {
		fmt.print(byte_color(b))
		if is_printable_ascii_range(b) {
			fmt.printf("%c", b)
		} else {
			fmt.print(".")
		}
	}
	
	fmt.println("\x1b[0m")
}

main :: proc() {
	fi, err := os.fstat(os.stdin)
	if err != nil {
		fmt.println("Failed to stat stdin")
		os.exit(1)
	}
	
	if fi.mode & os.File_Mode_Char_Device == 0 {
		buf := make([dynamic]u8, 10000000)
		defer delete(buf)
		
		n, err := os.read_full(os.stdin, buf[:])
		if n == 0 {
			os.exit(0)
		} else if err != nil {
			fmt.println("Piped input was larger than 10 MB. Ignored!")
			os.exit(1)
		}
		
		lt := decoding.base64_new_lookup_table()
		base64, base64Err := decoding.base64_decode(&lt, buf[:n])
		hex, hexErr := decoding.hex_decode(buf[:n])
		
		defer decoding.delete_dynamic_bytes(&base64)
		defer decoding.delete_dynamic_bytes(&hex)
		
		print_line("base64", base64[:], base64Err)
		print_line("hex", hex[:], hexErr)
	}
	
	/*
	start := time.now()
	//data := "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="
	data := "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
	base64FastCount := 2000000
	for i := 0; i < base64FastCount; i += 1 {
		d, _ := decoding.hex_decode(transmute([]u8)data)
		decoding.delete_dynamic_bytes(&d)
	}
	fmt.println("time spent:", time.duration_milliseconds(time.since(start)), " milliseconds")*/
}
