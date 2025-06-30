package decoding

import "core:strings"

@(private)
hex_to_index :: proc(b: u8) -> int {
    switch b {
        case '0'..='9':
            return int(b - '0')
        case 'a'..='f':
            return int(b - 'a' + 10)
        case 'A'..='F':
            return int(b - 'A' + 10)
    }
    
    return -1
}

hex_decode :: proc(bytes: []byte) -> ([dynamic]u8, Error) {
    length := len(bytes) - (len(bytes) & 1)
    
    sb: strings.Builder
    strings.builder_init_len_cap(&sb, 0, length / 2)
    
    for i := 0; i < length; i += 2 {
        a := hex_to_index(bytes[i + 0])
        b := hex_to_index(bytes[i + 1])
        
        if (a | b) < 0 {
            break
        }
        
        strings.write_byte(&sb, u8(a << 4 | b))
    }
    
    if len(sb.buf) == 0 {
        return sb.buf, .Failed
    }
    
    if len(sb.buf) != length / 2 {
        return sb.buf, .Partial_Decode
    }
    
    return sb.buf, nil
}