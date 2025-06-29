package decoding

// nil meaning no error
Error :: enum u32 {
	None,
	None_But_Nonstandard,
	Partial_Decode,
	Failed,
}

delete_dynamic_bytes :: proc(buf: ^[dynamic]u8) {
	delete(buf^)
	buf^ = nil
}
