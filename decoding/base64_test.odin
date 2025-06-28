package decoding

import "core:testing"
import "core:log"
import "core:fmt"
import "core:strings"
import "core:bytes"
import time "core:time"

BENCHMARK :: #config(BENCHMARK, false)

@(test)
test_decode_base64 :: proc(t: ^testing.T) {
    data: string
    d: [dynamic]u8
    err: Error
    
    // "hello world!"
    data = "aGVsbG8gd29ybGQh"
    d, err = decode_base64(transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    testing.expect_value(t, string(d[:]), "hello world!")
    delete_dynamic_bytes(&d)

    // Every byte value from 0x00 to 0xFF, inclusive
    data = "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="
    d, err = decode_base64(transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    for i := 0; i < 256; i += 1 {
        testing.expect_value(t, d[i], u8(i))
        break
    }
    delete_dynamic_bytes(&d)

    // We ignore '=' characters, even when it is technically invalid base64.
    data = "====a====G====V==s=b=G=8gd==29ybGQh===="
    d, err = decode_base64(transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    testing.expect_value(t, string(d[:]), "hello world!")
    delete_dynamic_bytes(&d)

    // Invalid character
    data = ")))))))aGkgaGVsbG8="
    d, err = decode_base64(transmute([]u8)data)
    testing.expect_value(t, err, Error.Failed)
    fmt.println(d)
    //testing.expect_value(t, &d, nil)
    delete_dynamic_bytes(&d)
}

@(test)
benchmark :: proc(t: ^testing.T) {
    when !BENCHMARK {
        return
    }
    
    time.sleep(500 * time.Millisecond)
    
    log.info("BENCHMARKING start")
    
    // Base64 benchmark
    // Every byte value from 0x00 to 0xFF, inclusive
    data := "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="
    start := time.now()
    base64Count := 1500000
    for i := 0; i < base64Count; i += 1 {
        d, _ := decode_base64(transmute([]u8)data)
        delete_dynamic_bytes(&d)
    }
    base64Avg := time.duration_microseconds(time.since(start)) / f64(base64Count)
    log.info("Base64 avg:", base64Avg, "microseconds")

    start = time.now()
    for i := 0; i < base64Count; i += 1 {
        d, _ := decode_base64_fast1(transmute([]u8)data)
        delete_dynamic_bytes(&d)
    }
    base64Fast1Avg := time.duration_microseconds(time.since(start)) / f64(base64Count)
    log.info("Base64fast1 avg:", base64Fast1Avg, "microseconds")

    start = time.now()
    for i := 0; i < base64Count; i += 1 {
        d, _ := decode_base64_fast2(transmute([]u8)data)
        delete_dynamic_bytes(&d)
    }
    base64Fast2Avg := time.duration_microseconds(time.since(start)) / f64(base64Count)
    log.info("Base64fast2 avg:", base64Fast2Avg, "microseconds")

    start = time.now()
    for i := 0; i < base64Count; i += 1 {
        //decode_base64_fast3(transmute([]u8)data)
        d, _ := decode_base64_fast3(transmute([]u8)data)
        delete_dynamic_bytes(&d)
    }
    base64Fast3Avg := time.duration_microseconds(time.since(start)) / f64(base64Count)
    log.info("Base64fast3 avg:", base64Fast3Avg, "microseconds")

    start = time.now()
    for i := 0; i < base64Count; i += 1 {
        d, _ := decode_base64_fast4(transmute([]u8)data)
        delete_dynamic_bytes(&d)
    }
    base64Fast4Avg := time.duration_microseconds(time.since(start)) / f64(base64Count)
    log.info("Base64fast4 avg:", base64Fast4Avg, "microseconds")
    
    lt := new_lookup_table()
    start = time.now()
    for i := 0; i < base64Count; i += 1 {
        d, _ := decode_base64_fast5(&lt, transmute([]u8)data)
        delete_dynamic_bytes(&d)
    }
    base64Fast5Avg := time.duration_microseconds(time.since(start)) / f64(base64Count)
    log.info("Base64fast5 avg:", base64Fast5Avg, "microseconds")
    
    time.sleep(10000 * time.Second)
}