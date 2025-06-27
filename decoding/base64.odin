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
