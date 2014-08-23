#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern "C" {
#include "util/loader.h"
#include "version.h"
#include "util/opt.h"
#include "asset/node.h"
}

enum argtype {
    NO_ARG,
    REQUIRED,
    OPTIONAL
};

const struct {
    enum argtype arg;
    char s;
    const char *l, *h;
} help[] = {
    {REQUIRED,  'm', "modules", "Adds a directory to look for modules"},
    {REQUIRED,  'i', "ignore",  "Ignores a module while loading"},
    {NO_ARG,    'h', "help",    "Prints this message and exits"},
    {NO_ARG,    'v', "version", "Prints the version and exits"},
    {REQUIRED,  'd', "data",    "Adds a directory to look for data files"},
    {NO_ARG,      0, NULL,      NULL}
};

#ifndef DEMO_MODULES
#define DEMO_MODULES "modules"
#endif

ilA_fs demo_fs;

#define dep(n) extern "C" void il_load_##n();
dep(ilutil);
dep(ilcommon);
dep(ilasset);
dep(ilinput);
dep(ilmath);
dep(ilgraphics);
#undef dep

extern "C" void il_configure_ilgraphics(il_modopts *opts);
extern "C" void ilE_quit();

static il_optslice mk_optslice(const char *s)
{
    il_optslice o;
    o.str = s;
    o.len = strlen(s);
    return o;
}

char *strdup(const char*);
char *strndup(const char*, size_t);
int main(int argc, char **argv)
{
    int has_modules = 0;
    size_t i;
    il_opts opts = il_opt_parse(argc, argv);
    il_optslice empty;
    memset(&empty, 0, sizeof(il_optslice));
    il_modopts *main_opts = il_opts_lookup(&opts, empty);

    ilA_adddir(&demo_fs, ".", -1);

    for (i = 0; main_opts && i < main_opts->args.length; i++) {
        il_opt *opt = &main_opts->args.data[i];
        char *arg = strndup(opt->arg.str, opt->arg.len);
#define option(s, l) if (il_opts_cmp(opt->name, mk_optslice(s)) || il_opts_cmp(opt->name, mk_optslice(l)))
        option("m", "modules") {
            il_add_module_path(arg); //IL_APPEND(module_paths, strdup(optoption));
            has_modules = 1;
        }
        option("i", "ignore") {
            il_ignore_module(arg);
        }
        option("h", "help") {
            printf("IntenseLogic %s\n", il_version);
            printf("Usage: %s [OPTIONS]\n\n", argv[0]);
            printf("Each module may have its own options, see relavent documentation for those.\n\n");
            printf("Options:\n");
            for (i = 0; help[i].l; i++) {
                static const char *const arg_strs[] = {
                    "",
                    "[=arg]",
                    "=arg"
                };
                char longbuf[64];
                sprintf(longbuf, "%s%s%s",
                        help[i].l? "-" : " ",
                        help[i].l? help[i].l : "",
                        arg_strs[help[i].arg]
                );
                printf(" %c%c %-18s %s\n",
                       help[i].s? '-' : ' ',
                       help[i].s? help[i].s : ' ',
                       longbuf,
                       help[i].h
                );
            }
            return 0;
        }
        option("v", "version") {
            printf("IntenseLogic %s\n", il_version);
            printf("Commit: %s\n", il_commit);
            printf("Built: %s\n", __DATE__);
            return 0;
        }
        option("d", "data") {
            ilA_adddir(&demo_fs, arg, -1);
        }
        free(arg);
    }

    fprintf(stderr, "MAIN: Initializing engine.\n");
    fprintf(stderr, "MAIN: IntenseLogic %s\n", il_version);
    fprintf(stderr, "MAIN: Built %s\n", __DATE__);

    if (!has_modules) {
        il_add_module_path(DEMO_MODULES);
    }

#define dep(n) il_load_##n();
    dep(ilutil);
    dep(ilcommon);
    dep(ilasset);
    dep(ilinput);
    dep(ilmath);
    il_optslice gfx_name = mk_optslice("ilgraphics");
    il_modopts *gfx_opts = il_opts_lookup(&opts, gfx_name);
    il_configure_ilgraphics(gfx_opts);
    dep(ilgraphics);
#undef dep

    il_load_module_paths(&opts);

    il_postload_all();


    ilE_quit();

    return 0;
}
