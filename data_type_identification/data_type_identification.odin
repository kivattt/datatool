package data_type_identification

import "core:strings"

HEX_ALPHABET :: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

DataType :: enum {
    None_Or_Unknown,
    Hash_MD5,
    Hash_SHA1,
    Hash_SHA3,
    Hash_SHA256,
    Hash_SHA384,
    Hash_SHA512,
    Hexadecimal,
}

/*TypesRanked :: struct {
    
}

rank_all_types :: proc(bytes: []byte) -> DataType {
    
}*/

check_hash_type :: proc(bytes: []byte) -> DataType {
    if len(bytes) > 128 {
        return .None_Or_Unknown
    }
    
    for e in bytes {
        if !strings.contains_rune(HEX_ALPHABET, rune(e)) {
            return .None_Or_Unknown
        }
    }
    
    if len(bytes) == 32 do return .Hash_MD5
    if len(bytes) == 40 do return .Hash_SHA1
    if len(bytes) == 56 do return .Hash_SHA3 // or sha-224
    if len(bytes) == 64 do return .Hash_SHA256
    if len(bytes) == 96 do return .Hash_SHA384
    if len(bytes) == 128 do return .Hash_SHA512
    
    return .None_Or_Unknown
}

