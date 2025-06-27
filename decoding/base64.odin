package decoding

import "core:fmt"
import "core:strings"

BASE64_LOOKUP_TABLE :: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

// Remember to call decoding.delete_dynamic_bytes() on the return value!
// This implementation ignores the '=' character, to avoid returning .Partial_Decode on '=' padded base64.
decode_base64 :: proc(bytes: []byte) -> ([dynamic]u8, Error) {
	sb: strings.Builder
	strings.builder_init_none(&sb)

	buffer: u8 = 0
	nBitsUntilChar: u8 = 0

	for b in bytes {
		if b == '=' {
			continue
		}
		
		index := strings.index_byte(BASE64_LOOKUP_TABLE, b)
		if index == -1 {
			if len(sb.buf) == 0 {
				return nil, .Failed
			} else {
				return sb.buf, .Partial_Decode
			}
		}

		for bitIndex := 5; bitIndex >= 0; bitIndex -= 1 {
			buffer <<= 1;
			buffer |= (u8(index) >> u8(bitIndex)) & 1

			if nBitsUntilChar == 7 {
				strings.write_byte(&sb, buffer)
				nBitsUntilChar = 0
				continue
			}
			nBitsUntilChar += 1
		}
	}

	return sb.buf, nil
}

// TODO: Add a special case for the last 4 bytes, to handle '=' padding
// Make sure to handle missing '=' padding aswell.
decode_base64_fast :: proc(bytes: []byte) -> ([dynamic]u8, Error) {
	assert(len(bytes) % 4 == 0)
	
	sb: strings.Builder
	strings.builder_init_len_cap(&sb, 0, len(bytes) * (3 / 4))
	
	for i := 0; i < len(bytes); i += 4 {
		idx0 := strings.index_byte(BASE64_LOOKUP_TABLE, bytes[i+0])
		idx1 := strings.index_byte(BASE64_LOOKUP_TABLE, bytes[i+1])
		idx2 := strings.index_byte(BASE64_LOOKUP_TABLE, bytes[i+2])
		idx3 := strings.index_byte(BASE64_LOOKUP_TABLE, bytes[i+3])
		
		if (idx0 | idx1 | idx2 | idx3) < 0 {
			break
		}
		
		b1: u8 = (u8(idx0) << 2) | (u8(idx1) >> 4)
		b2: u8 = (u8(idx1) << 4) | (u8(idx2) >> 2)
		b3: u8 = (u8(idx2) << 6) | u8(idx3)
		strings.write_bytes(&sb, {b1, b2, b3})
	}
	
	return sb.buf, nil
}