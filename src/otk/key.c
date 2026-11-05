#include <otk/key.h>
#include <otk/util.h>

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

Otk* otk_read(FILE* fp, usize* size) {
    usize raw_size;
    char* raw = otk_read_entire_file(fp, &raw_size);
    if (raw == NULL) return NULL;

    if (raw_size < sizeof(Otk)) {
        free(raw);
        return NULL;
    }

    *size = raw_size - sizeof(Otk);
    return (Otk*)raw;
}

bool otk_has_enough_key_material(Otk* otk, usize size, usize needed) {
    return size - otk->cursor >= needed;
}
