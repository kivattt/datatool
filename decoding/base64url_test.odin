package decoding

import "core:testing"
import "core:log"
import "core:fmt"
import "core:strings"
import "core:bytes"
import time "core:time"

@(test)
base64url_test :: proc(t: ^testing.T) {
    data: string
    d: [dynamic]u8
    err: Error
    
    lt := base64url_new_lookup_table()
    
    // "hello world!"
    data = "aGVsbG8gd29ybGQh"
    d, err = base64url_decode(&lt, transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    testing.expect_value(t, string(d[:]), "hello world!")
    delete_dynamic_bytes(&d)

    // Every byte value from 0x00 to 0xFF, inclusive
    data = "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0-P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn-AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq-wsbKztLW2t7i5uru8vb6_wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t_g4eLj5OXm5-jp6uvs7e7v8PHy8_T19vf4-fr7_P3-_w"
    d, err = base64url_decode(&lt, transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    for i := 0; i < 256; i += 1 {
        testing.expect_value(t, d[i], u8(i))
        break
    }
    delete_dynamic_bytes(&d)
    
    // Invalid character
    data = "====a====G====V==s=b=G=8gd==29ybGQh===="
    d, err = base64url_decode(&lt, transmute([]u8)data)
    testing.expect_value(t, err, Error.Failed)
    testing.expect_value(t, string(d[:]), "")
    delete_dynamic_bytes(&d)

    // Invalid character
    data = ")))))))aGkgaGVsbG8"
    d, err = base64url_decode(&lt, transmute([]u8)data)
    testing.expect_value(t, err, Error.Failed)
    testing.expect_value(t, string(d[:]), "")
    delete_dynamic_bytes(&d)
    
    data = "YQ"
    d, err = base64url_decode(&lt, transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    testing.expect_value(t, string(d[:]), "a")
    delete_dynamic_bytes(&d)

    data = "YR"
    d, err = base64url_decode(&lt, transmute([]u8)data)
    testing.expect_value(t, err, Error.None_But_Nonstandard)
    testing.expect_value(t, string(d[:]), "a")
    delete_dynamic_bytes(&d)

    data = ""
    d, err = base64url_decode(&lt, transmute([]u8)data)
    testing.expect_value(t, err, Error.Failed)
    testing.expect_value(t, string(d[:]), "")
    delete_dynamic_bytes(&d)
    
    data = "aGkg==aGVsbG8="
    d, err = base64url_decode(&lt, transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    testing.expect_value(t, string(d[:]), "hi ")
    delete_dynamic_bytes(&d)

    // Missing single '=' padding at the end allowed in base64url
    data = "aGVsbG8"
    d, err = base64url_decode(&lt, transmute([]u8)data)
    testing.expect_value(t, err, Error.None)
    testing.expect_value(t, string(d[:]), "hello")
    delete_dynamic_bytes(&d)
}

@(test)
base64url_benchmark :: proc(t: ^testing.T) {
    when !BENCHMARK {
        return
    }
    
    // Every byte value from 0x00 to 0xFF, inclusive
    data := "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0-P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn-AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq-wsbKztLW2t7i5uru8vb6_wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t_g4eLj5OXm5-jp6uvs7e7v8PHy8_T19vf4-fr7_P3-_w"
    
    count := 100000
    lt := base64url_new_lookup_table()
    start := time.now()
    for i := 0; i < count; i += 1 {
        d, _ := base64url_decode(&lt, transmute([]u8)data)
        delete_dynamic_bytes(&d)
    }
    avg := time.duration_microseconds(time.since(start)) / f64(count)
    log.info("Base64url avg:", avg, "microseconds")
}
