#include <otk/key.h>

#include <stdio.h>
#include <stdlib.h>

Otk* otk_alloc(usize size) {
    return malloc(sizeof(Otk) + size);
}

void otk_write(Otk* otk, usize size, FILE* out) {
    fwrite(otk, sizeof(Otk) + size, 1, out);
}
