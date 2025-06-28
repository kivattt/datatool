package decoding

import "core:fmt"
import "core:strings"
import "base:intrinsics"

base64_new_lookup_table :: proc() -> [256]int {
	out: [256]int
	for i := 0; i < 256; i += 1 {
		out[i] = b64_to_index(u8(i))
	}
	return out
}

@(private)
b64_to_index :: proc(b: u8) -> int {
	switch b {
	case 'A'..='Z':
		return int(b - 'A')
	case 'a'..='z':
		return int(b - 'a' + 26)
	case '0'..='9':
		return int(b - '0' + 52)
	case '+':
		return 62
	case '/':
		return 63
	}

	return -1
}

// TODO: Add a special case for the last 4 bytes, to handle '=' padding
// Make sure to handle missing '=' padding aswell.
base64_decode :: proc(lt: ^[256]int, bytes: []byte) -> ([dynamic]u8, Error) {
	assert(len(bytes) % 4 == 0)

	sb: strings.Builder
	strings.builder_init_len_cap(&sb, 0, len(bytes) * (3 / 4))

	for i := 0; i < len(bytes); i += 4 {
		#no_bounds_check {
			i0 := lt[bytes[i+0]]
			i1 := lt[bytes[i+1]]
			i2 := lt[bytes[i+2]]
			i3 := lt[bytes[i+3]]

			if (i0 | i1 | i2 | i3) < 0 {
				break
			}

			n: u32 = u32(i0 << 26 | i1 << 20 | i2 << 14 | i3 << 8);
			n = intrinsics.byte_swap(n)
			strings.write_string(&sb, strings.string_from_ptr(transmute(^u8)&n, 3))
		}
	}

	return sb.buf, nil
}
