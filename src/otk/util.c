#include <otk/util.h>

#include <stdlib.h>

char* otk_read_entire_file(FILE* fp, usize* size) {
    if (fseek(fp, 0, SEEK_END) != 0) return NULL;

    long slen = ftell(fp);
    if (slen < 0) return NULL;

    rewind(fp);

    usize len = slen;

    char* buf = malloc(len);
    if (buf == NULL) return NULL;

    if (fread(buf, 1, len, fp) != len) {
        free(buf);
        return NULL;
    }

    *size = len;
    return buf;
}
