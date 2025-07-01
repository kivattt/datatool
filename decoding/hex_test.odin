package decoding

import "core:testing"
import "core:time"
import "core:log"
import "core:strings"

@(test)
hex_test :: proc(t: ^testing.T) {
    data: string
    d: [dynamic]u8
    err: Error
    
    // Lowercase hex
    data = "68656c6c6f20776f726c6421"
    d, err = hex_decode(transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    testing.expect_value(t, string(d[:]), "hello world!")
    delete_dynamic_bytes(&d)

    // Uppercase hex
    data = "68656C6C6F20776F726C6421"
    d, err = hex_decode(transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    testing.expect_value(t, string(d[:]), "hello world!")
    delete_dynamic_bytes(&d)

    // Mixed-case hex
    data = "68656c6C6F20776f726C6421"
    d, err = hex_decode(transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    testing.expect_value(t, string(d[:]), "hello world!")
    delete_dynamic_bytes(&d)

    // Empty
    data = ""
    d, err = hex_decode(transmute([]u8)data)
    testing.expect_value(t, err, Error.Failed)
    testing.expect_value(t, string(d[:]), "")
    delete_dynamic_bytes(&d)

    // Invalid
    data = "random data"
    d, err = hex_decode(transmute([]u8)data)
    testing.expect_value(t, err, Error.Failed)
    testing.expect_value(t, string(d[:]), "")
    delete_dynamic_bytes(&d)

    // Partial, odd length
    data = "fff"
    d, err = hex_decode(transmute([]u8)data)
    testing.expect_value(t, err, Error.Partial_Decode)
    testing.expect_value(t, string(d[:]), "\xff")
    delete_dynamic_bytes(&d)
    
    // Make sure it only accepts valid characters
    dataMutable: strings.Builder
    strings.builder_init(&dataMutable)
    strings.write_string(&dataMutable, "66656e6e656373")
    defer strings.builder_destroy(&dataMutable)
    for i := 0; i < 256; i += 1 {
        byte := u8(i)
        
        dataMutable.buf[0] = byte
        
        d, err = hex_decode(dataMutable.buf[:])
        if hex_to_index(byte) == -1 {
            testing.expect_value(t, err, Error.Failed)
        } else {
            testing.expect_value(t, err, Error.None)
        }
        
        delete_dynamic_bytes(&d)
    }

    // Every byte value from 0x00 to 0xFF, inclusive
    data = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
    d, err = hex_decode(transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    for i := 0; i < 256; i += 1 {
        testing.expect_value(t, d[i], u8(i))
        break
    }
    delete_dynamic_bytes(&d)
}

@(test)
hex_benchmark :: proc(t: ^testing.T) {
    when !BENCHMARK {
        return
    }
    
    // Every byte value from 0x00 to 0xFF, inclusive
    data := "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
    
    count := 1000000
    start := time.now()
    for i := 0; i < count; i += 1 {
        d, _ := hex_decode(transmute([]u8)data)
        delete_dynamic_bytes(&d)
    }
    avg := time.duration_microseconds(time.since(start)) / f64(count)
    log.info("Hex avg:", avg, "microseconds")
}