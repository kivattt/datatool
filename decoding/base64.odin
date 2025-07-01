package decoding

import "core:fmt"
import "core:strings"
import "base:intrinsics"

// TODO: Read through https://datatracker.ietf.org/doc/html/rfc4648.html

// FIXME: Don't do this at runtime...
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

base64_decode :: proc(lt: ^[256]int, bytes: []byte) -> ([dynamic]u8, Error) {
	sb: strings.Builder
	strings.builder_init_len_cap(&sb, 0, len(bytes) * (3 / 4))

	i0: int
	i1: int
	i2: int
	i3: int
	i: int
	for i = 0; i < len(bytes) - 4; i += 4 {
		#no_bounds_check {
			i0 = lt[bytes[i+0]]
			i1 = lt[bytes[i+1]]
			i2 = lt[bytes[i+2]]
			i3 = lt[bytes[i+3]]
		}

		if (i0 | i1 | i2 | i3) < 0 {
			break
		}

		n: u32 = u32(i0 << 26 | i1 << 20 | i2 << 14 | i3 << 8);
		n = intrinsics.byte_swap(n) // FIXME: Only do this when the CPU byte endianness requires it
		strings.write_string(&sb, strings.string_from_ptr(transmute(^u8)&n, 3))
	}

	// Last n <= 4 bytes
	remaining := min(4, len(bytes) - i)
	
	partial := false
	notPartial := false
	buffer: u8 = 0
	nBitsUntilByte: u8 = 0
	for j := 0; j < remaining; j += 1 {
		byte := bytes[i + j]
		index := lt[byte]
		if index < 0 {
			if byte == '=' {
				notPartial = true
			} else {
				partial = true
 			}
			break
		}
		
		for bitIndex := 5; bitIndex >= 0; bitIndex -= 1 {
			buffer <<= 1
			buffer |= (u8(index) >> u8(bitIndex)) & 1
			
			if nBitsUntilByte == 7 {
				strings.write_byte(&sb, buffer)
				nBitsUntilByte = 0
				continue
			}
			
			nBitsUntilByte += 1
		}
	}
	
	if !notPartial && nBitsUntilByte != 0 {
		partial = true
	}
	
	if len(sb.buf) == 0 {
		return nil, .Failed
	} else {
		if partial {
			return sb.buf, .Partial_Decode
		} else {
			if buffer << (8 - nBitsUntilByte) == 0 {
				return sb.buf, nil
			} else {
				return sb.buf, .None_But_Nonstandard
			}
		}
	}
}
