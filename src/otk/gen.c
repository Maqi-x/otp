#include <otk/defs.h>
#include <otk/gen.h>
#include <otk/key.h>

#include <stdlib.h>

#if __STDC_VERSION__ >= 202311L
    #define HAS_HAS_INCLUDE true
#elif defined(__has_include)
    #define HAS_HAS_INCLUDE true
#else
    #define HAS_HAS_INCLUDE false
#endif

#if HAS_HAS_INCLUDE
    #define HAS_GETRANDOM __has_include(<sys/random.h>)
    #if HAS_GETRANDOM
        #include <sys/random.h>
    #endif
#else
    #define HAS_GETRANDOM false
#endif

#ifndef OTK_USE_NCSPRNG
    #define OTK_USE_NCSPRNG true
#endif

#if !HAS_GETRANDOM && OTK_USE_NCSPRNG
#include <string.h>

// TODO: sloppy and theoretically UB. it's useless anyway but i'm bored.
//       using rand() for cryptography is just stupid. but as i said, i'm bored.
static bool ncsprng(byte* buffer, usize size) {
    int* ints = (int*)buffer;
    for (usize i = 0; i < size / 4; ++i) {
        ints[i] = rand();
    }

    int mod = size % 4;
    if (mod == 0) {
        return true;
    }

    int rest = rand();
    memcpy(buffer + size - mod, &rest, mod);
    return true;
}
#endif

bool otk_random_gen(byte* buffer, usize size) {
#if HAS_GETRANDOM
    return getrandom(buffer, size, 0) == (ptrdiff_t)size;
#else
    #if OTK_USE_NCSPRNG
        return ncsprng(buffer, size);
    #else
        #error The getrandom function is unavailable. UNSAFE: define OTK_USE_NCSPRNG=1 to use non cryptographically secure generator
    #endif
#endif
}

Otk* otk_generate(usize size) {
    Otk* otk = otk_alloc(size);
    if (otk == NULL) {
        return NULL;
    }

    if (!otk_random_gen(otk->data, size)) {
        free(otk);
        return NULL;
    }

    return otk;
}
