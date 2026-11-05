#pragma once

#include <otk/defs.h>
#include <stdio.h>

typedef struct {
    usize cursor;
    byte data[];
} Otk;

Otk* otk_alloc(usize size);

Otk* otk_read(FILE* fp, usize* size);
void otk_write(Otk* otk, usize size, FILE* out);

bool otk_has_enough_key_material(Otk* otk, usize size, usize needed);
