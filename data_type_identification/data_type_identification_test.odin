package data_type_identification

import "core:testing"

@(test)
test_check_hash_type :: proc(t: ^testing.T) {
    // Empty string "" inputs
    md5 := "d41d8cd98f00b204e9800998ecf8427e"
    sha1 := "da39a3ee5e6b4b0d3255bfef95601890afd80709"
    sha256 := "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    
    type = check_hash_type(transmute([]u8)md5)
    testing.expect_value(t, type, DataType.Hash_MD5)
    
    type = check_hash_type(transmute([]u8)sha1)
    testing.expect_value(t, type, DataType.Hash_SHA1)
    
    type = check_hash_type(transmute([]u8)sha256)
    testing.expect_value(t, type, DataType.Hash_SHA256)
}