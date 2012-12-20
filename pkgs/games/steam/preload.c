#define _GNU_SOURCE
#include <sys/types.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <dirent.h>
#include <dlfcn.h>

#ifdef DEBUG
#include <stdio.h>
#endif

static const char *nix_allowed = NULL;

const char *default_allowed[] = {
    "/dev/urandom"
};

int __is_allowed(const char *path)
{
    const char *start, *end;
    int i, len;

    if (nix_allowed == NULL &&
       (nix_allowed = getenv("NIX_STEAM_ALLOWED_PATHS")) == NULL)
        /* if environment variable is unset, _always_ allow everything */
        return 1;

    for (i = 0; i < (sizeof(default_allowed) / sizeof(const char*)); i++)
        if (strncmp(default_allowed[i], path, strlen(default_allowed[i])) == 0)
            return 1;

    start = nix_allowed;

    for (;;) {
        if ((end = strchr(start, ':')) == NULL)
            len = strlen(start);
        else
            len = end - start;

        if (strncmp(start, path, len) == 0)
            return 1;

        if (end == NULL)
            break;

        start = end + 1;
    }

    return 0;
}

#ifdef DEBUG
inline int __verbose_is_allowed(const char *path, const char *file, int line)
{
    int result;
    fprintf(stderr, "%s:%d: Checking access for %s...", file, line, path);
    result = __is_allowed(path);
    if (result)
        fprintf(stderr, " granted.\n");
    else
        fprintf(stderr, " denied!\n");
    return result;
}
#define is_allowed(path) __verbose_is_allowed(path, __func__, __LINE__)
#else
#define is_allowed(path) __is_allowed(path)
#endif

#define WRAP_REAL(rtype, fun, ...) \
    typedef rtype (*__type_##fun)(__VA_ARGS__); \
    static __type_##fun __real_##fun = NULL; \
    __type_##fun __get_real_##fun(void) { \
        if (__real_##fun == NULL) \
            __real_##fun = (rtype(*)())(intptr_t)dlsym(RTLD_NEXT, #fun); \
        return __real_##fun; \
    }

#define WRAP(rtype, fun, ...) \
    WRAP_REAL(rtype, fun, __VA_ARGS__) \
    rtype fun(__VA_ARGS__)

#define CALL_REAL(fun, ...) __get_real_##fun()(__VA_ARGS__)

#define WRAP_FILTER_OPEN(fun) \
    WRAP_REAL(int, fun, const char *pathname, int flags, mode_t mode)  \
    int fun(const char *pathname, int flags, ...)                      \
    {                                                                  \
        va_list va_mode;                                               \
        mode_t mode = 0;                                               \
                                                                       \
        if (!is_allowed(pathname)) {                                   \
            errno = EACCES;                                            \
            return -1;                                                 \
        }                                                              \
                                                                       \
        if (flags & O_CREAT) {                                         \
            va_start(va_mode, flags);                                  \
            mode = va_arg(va_mode, mode_t);                            \
            va_end(va_mode);                                           \
        }                                                              \
                                                                       \
        return CALL_REAL(fun, pathname, flags, mode);                  \
    }

#define WRAP_FILTER_INT2(fun, t1, a1, t2, a2) \
    WRAP(int, fun, t1 a1, t2 a2)               \
    {                                          \
        if (is_allowed(a1))                    \
            return CALL_REAL(fun, a1, a2);     \
                                               \
        errno = EACCES;                        \
        return -1;                             \
    }

WRAP_FILTER_OPEN(open)
WRAP_FILTER_OPEN(open64)

WRAP_FILTER_INT2(access, const char *, pathname, int, mode)
WRAP_FILTER_INT2(stat, const char *, path, struct stat *, buf)
WRAP_FILTER_INT2(lstat, const char *, path, struct stat *, buf)
WRAP_FILTER_INT2(stat64, const char *, path, struct stat *, buf)

WRAP(DIR *, opendir, const char *name)
{
    if (is_allowed(name))
        return CALL_REAL(opendir, name);

    errno = EACCES;
    return NULL;
}
