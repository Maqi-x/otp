#include <otk/key.h>

#include <stdio.h>
#include <stdlib.h>

Otk* otk_alloc(usize size) {
    Otk* otk = malloc(sizeof(Otk) + size);
    if (otk != NULL) otk->cursor = 0;
    return otk;
}

void otk_write(Otk* otk, usize size, FILE* out) {
    fwrite(otk, sizeof(Otk) + size, 1, out);
}
