#pragma once

#include <otp/defs.h>
#include <otk/key.h>

void otp_raw_crypt(usize size, byte* message, const byte* key);
void otp_crypt(usize datasize, usize keysize, byte* data, Otk* otk);
