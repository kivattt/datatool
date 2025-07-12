package decoding

import "core:fmt"
import "core:strings"
import "core:simd"
import "base:intrinsics"
import slice "core:slice"

// TODO: Read through https://datatracker.ietf.org/doc/html/rfc4648.html

@(private="file")
BYTES_PER_ITERATION :: 16

// FIXME: Don't do this at runtime...
base64_new_lookup_table :: proc() -> [256]int {
	out: [256]int
	for i := 0; i < 256; i += 1 {
		out[i] = base64_to_index(u8(i))
	}
	return out
}

@(private)
base64_to_index :: proc(b: u8) -> int {
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
	
	buf: [12]u8

	i: int
	data: #simd[BYTES_PER_ITERATION]u8
	for i = 0; i < len(bytes) - BYTES_PER_ITERATION; i += BYTES_PER_ITERATION {
		#no_bounds_check {
			data = simd.from_slice(#simd[BYTES_PER_ITERATION]u8, slice.from_ptr(&bytes[i], BYTES_PER_ITERATION))
		}

		// 'A' through 'Z'
		a := simd.saturating_sub(data, 'A' - 1)
		aMask := simd.lanes_lt(a, 26 + 1)
		a = simd.bit_and(a, aMask)

		// 'a' through 'z'
		b := simd.saturating_sub(data, 'a' - 26 - 1)
		bMask := simd.lanes_ge(b, 26 + 1)
		bMask = simd.bit_and(bMask, simd.lanes_lt(b, 26 + 26 + 1))
		b = simd.bit_and(b, bMask)
		
		// '0' through '9'
		c := simd.saturating_add(data, 52 - '0' + 1)
		cMask := simd.lanes_ge(c, 52 + 1)
		cMask = simd.bit_and(cMask, simd.lanes_lt(c, 52 + 10 + 1))
		c = simd.bit_and(c, cMask)
		
		// '+'
		d := simd.saturating_sub(simd.lanes_eq(data, '+'), 255 - 62 - 1)
		
		// '/'
		e := simd.saturating_sub(simd.lanes_eq(data, '/'), 255 - 63 - 1)
		
		res := simd.bit_or(a, b)
		res = simd.bit_or(res, c)
		res = simd.bit_or(res, d)
		res = simd.bit_or(res, e)
		
		invalid := simd.reduce_or(simd.lanes_eq(res, 0)) != 0
		if invalid {
			break
		}
		
		res = simd.saturating_sub(res, 1)
		
		i0 := (#simd[4]u32)(simd.shuffle(res, res, 0, 4, 8,  12))
		i1 := (#simd[4]u32)(simd.shuffle(res, res, 1, 5, 9,  13))
		i2 := (#simd[4]u32)(simd.shuffle(res, res, 2, 6, 10, 14))
		i3 := (#simd[4]u32)(simd.shuffle(res, res, 3, 7, 11, 15))
		
		i0 = simd.shl(i0, 26)
		i1 = simd.shl(i1, 20)
		i2 = simd.shl(i2, 14)
		i3 = simd.shl(i3, 8)
		
		result := simd.bit_or(i0, i1)
		result = simd.bit_or(result, i2)
		result = simd.bit_or(result, i3)
		
		for j := 0; j < 4; j += 1 {
			n: u32 = simd.extract(result, j)
			n = intrinsics.byte_swap(n) // FIXME: Only do this when the CPU byte endianness requires it
			buf[j*3 + 0] = (transmute([^]u8)&n)[0]
			buf[j*3 + 1] = (transmute([^]u8)&n)[1]
			buf[j*3 + 2] = (transmute([^]u8)&n)[2]
		}
		strings.write_bytes(&sb, buf[:])
	}
	
	// Last n <= BYTES_PER_ITERATION bytes
	remaining := min(BYTES_PER_ITERATION, len(bytes) - i)
	
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
