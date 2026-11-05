#include "otk/util.h"
#include <kjc_argparse.h>

#include <string.h>
#include <stdio.h>

// used but clangd is stupid (as usual)
#include <errno.h> // IWYU pragma: keep

#include <otp/crypt.h>
#include <otk/key.h>

#define eprint(fmt, ...) fprintf(stderr, "Error: " fmt "\n", ##__VA_ARGS__)

typedef struct {
    const char* in;
    const char* out;
    const char* key;
} Args;

int crypt(Args* args) {
    // TODO: reduce boilerplate
    FILE* key = fopen(args->key, "r+");
    if (key == NULL) {
        eprint("failed to open %s for reading: %s", args->key, strerror(errno));
        return 1;
    }

    FILE* in = fopen(args->in, "r");
    if (in == NULL) {
        eprint("failed to open %s for reading: %s", args->in, strerror(errno));
        return 1;
    }

    FILE* out = fopen(args->out, "w");
    if (out == NULL) {
        eprint("failed to open %s for writing: %s", args->out, strerror(errno));
        return 1;
    }

    usize keysize;
    Otk* otk = otk_read(key, &keysize);

    if (otk == NULL) {
        eprint("not a valid one-time key file: %s", args->key);
        return 1;
    }

    usize datasize;
    char* input_str = otk_read_entire_file(in, &datasize);

    if (!otk_has_enough_key_material(otk, keysize, datasize)) {
        eprint("not enough key material: %zu needed, %zu left",
               datasize, keysize);
        return 1;
    }

    byte* data = (byte*)input_str;
    otp_crypt(datasize, keysize, data, otk);

    fwrite(data, 1, datasize, out);
    otk_write(otk, keysize, key);

    fclose(in);
    fclose(out);
    fclose(key);

    return 0;
}

int main(int argc, char** argv) {
    Args args = {0};

    ARGPARSE(argc, argv) {
        ARG_STRING('k', "key", "The one-time key (.otk)", key) {
            if (args.key != NULL) {
                eprint("duplicated option: -k/--key");
                ARGPARSE_HELP(); return 2;
            }

            args.key = key;
        }

        ARG_STRING('o', "output", "The output file path", out) {
             if (args.out != NULL) {
                eprint("duplicated option: -o/--output");
                ARGPARSE_HELP(); return 2;
            }

            args.out = out;
        }

        ARG_POSITIONAL("<input>", in) {
            if (args.in != NULL) {
                eprint("unexpected positional argument");
                ARGPARSE_HELP(); return 2;
            }

            args.in = in;
        }

        ARG_END {
            if (args.key == NULL) {
                eprint("key unspecified");
                ARGPARSE_HELP(); return 2;
            }
            if (args.in == NULL) {
                eprint("input file unspecified");
                ARGPARSE_HELP(); return 2;
            }
            if (args.out == NULL) {
                eprint("output file unspecified");
                ARGPARSE_HELP(); return 2;
            }

            return crypt(&args);
        }
    }
}
