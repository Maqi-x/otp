#include <kjc_argparse.h>

#include <otk/gen.h>

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

// used but clangd is stupid (as usual)
#include <errno.h> // IWYU pragma: keep

#define SENTINEL SIZE_MAX

#define eprint(fmt, ...) fprintf(stderr, "Error: " fmt "\n", ##__VA_ARGS__)

typedef struct {
    usize size;
    const char* out;
} GenArgs;

typedef struct {
    const char* file;
} ResetArgs;

int handle_gen(const GenArgs* args) {
    FILE* out = fopen(args->out, "w");
    if (out == NULL) {
        eprint("failed to open %s for writing: %s", args->out, strerror(errno));
        return 1;
    }

    Otk* otk = otk_generate(args->size);
    if (otk == NULL) {
        eprint("key generation failed");
        return 1;
    }

    otk_write(otk, args->size, out);
    fclose(out);

    return 0;
}

int handle_reset(const ResetArgs* args) {
    printf("file: %s\n", args->file);
    return 0;
}

int main(int argc, char** argv) {
    union {
        GenArgs gen;
        ResetArgs reset;
    } args;

    ARGPARSE(argc, argv) {
        ARG_COMMAND("gen", "Generate a random one-time key with the given size") {
            args.gen.size = SENTINEL;
            args.gen.out = NULL;

            ARGPARSE_NESTED {
				ARG('h', "help", "Help for the gen command") {
					ARGPARSE_HELP();
					break;
				}

                ARG_STRING('o', "output", "The output file path", path) {
                    if (args.gen.out != NULL) {
                        eprint("duplicated option: -o/--output");
                        ARGPARSE_HELP(); return 2;
                    }

                    args.gen.out = path;
                }

                ARG_POSITIONAL("<size>", size_str) {
                    if (args.gen.size != SENTINEL) {
                        eprint("unexpected positional argument");
                        ARGPARSE_HELP(); return 2;
                    }

                    // TODO: parse sizes like 4kb or 128b
                    //       and handle parse errors
                    args.gen.size = atoi(size_str);
                }

                ARG_END {
                    if (args.gen.size == SENTINEL) {
                        eprint("size argument unspecified");
                        ARGPARSE_HELP(); return 2;
                    }

                    if (args.gen.out == NULL) {
                        eprint("output file path unspecified");
                        ARGPARSE_HELP(); return 2;
                    }

                    return handle_gen(&args.gen);
                }
            }
        }

        ARG_COMMAND("reset", "Reset the cursor of an one-time key") {
            args.reset.file = NULL;

            ARGPARSE_NESTED {
                ARG_POSITIONAL("<file>", path) {
                    if (args.reset.file != NULL) {
                        eprint("unexpected positonal argument");
                        ARGPARSE_HELP(); return 2;
                    }

                    args.reset.file = path;
                }

                ARG_END {
                    if (args.reset.file == NULL) {
                        eprint("target file path unspecified");
                        ARGPARSE_HELP(); return 2;
                    }

                    return handle_reset(&args.reset);
                }
            }
        }

        ARG_COMMAND("help", "Print this help message") {
            ARGPARSE_HELP();
        }

        ARG('h', "help", "Print this help message") {
            ARGPARSE_HELP();
            break;
        }

		ARG_END {
			ARGPARSE_HELP();
		}
    }
}
