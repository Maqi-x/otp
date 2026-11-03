#pragma once

#include <otk/defs.h>
#include <stdio.h>

typedef struct {
    usize cursor;
    byte data[];
} Otk;

Otk* otk_alloc(usize size);
void otk_write(Otk* otk, usize size, FILE* out);
