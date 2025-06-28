package decoding

// nil meaning no error
Error :: enum u32 {
	None,
	Partial_Decode,
	Failed,
}

delete_dynamic_bytes :: proc(buf: ^[dynamic]u8) {
	delete(buf^)
	buf^ = nil
}
