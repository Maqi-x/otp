#include <otp/crypt.h>
#include <otk/key.h>

#include <assert.h>

void otp_raw_crypt(usize size, byte* inout, const byte* key) {
    for (usize i = 0; i < size; ++i) {
        inout[i] ^= key[i];
    }
}

void otp_crypt(usize datasize, usize keysize, byte* data, Otk* otk) {
    byte* keydata = otk->data + otk->cursor;
    assert(keysize - otk->cursor >= datasize);

    otk->cursor += datasize;
    return otp_raw_crypt(datasize, data, keydata);
}
