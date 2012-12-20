#include <linux/filter.h>
#include <linux/seccomp.h>
#include <linux/unistd.h>
#include <sys/prctl.h>
#include <stdio.h>
#include <unistd.h>
#include <stddef.h>
#include <errno.h>
#include <stdlib.h>

// types and definitions needed for specific syscalls
#include <sys/socket.h>
#include <signal.h>

#define GET_OFFSET(pos) \
    offsetof(struct seccomp_data, args[(pos)])

#define ACC_ARG(pos) \
    BPF_STMT(BPF_LD+BPF_W+BPF_ABS, GET_OFFSET(pos))

#define SIMPLE_ALLOW(op) \
    BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_##op, 0, 1), \
    BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_ALLOW)

#define SIMPLE_SKIP(op) \
    BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_##op, 0, 1), \
    BPF_STMT(BPF_RET+BPF_K, 0)

#define RET_EPERM \
    BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_ERRNO | (EPERM & SECCOMP_RET_DATA))

static int install_filter(void)
{
    struct sock_filter filter[] = {
        BPF_STMT(BPF_LD+BPF_W+BPF_ABS, offsetof(struct seccomp_data, nr)),

        // basic stuff
        SIMPLE_ALLOW(execve),
        SIMPLE_ALLOW(rt_sigreturn),
        SIMPLE_ALLOW(exit_group),
        SIMPLE_ALLOW(exit),
        SIMPLE_ALLOW(read),

        // only allow write on stderr/stdout
        BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_write, 0, 6),
        ACC_ARG(0),
        BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, STDOUT_FILENO, 1, 0),
        BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, STDERR_FILENO, 0, 1),
        BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_ALLOW),
        RET_EPERM,

        // only allow PF_FILE socket
        BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_socketcall, 0, 4),
        ACC_ARG(0),
        BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, PF_FILE, 2, 0),
        RET_EPERM,

        // goodbye breakpad :-)
        BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_sigaltstack, 0, 1),
        BPF_STMT(BPF_RET+BPF_K, 0),
        BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_rt_sigaction, 0, 3),
        BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, SIGSEGV, 1, 0),
        BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, SIGILL, 0, 1),
        BPF_STMT(BPF_RET+BPF_K, 0),

        // memory stuff
        SIMPLE_ALLOW(brk),
        SIMPLE_ALLOW(mmap),
        SIMPLE_ALLOW(mmap2),
        SIMPLE_ALLOW(munmap),
        SIMPLE_ALLOW(mprotect),

        // timing stuff
        SIMPLE_ALLOW(gettimeofday),
        SIMPLE_ALLOW(nanosleep),
        SIMPLE_ALLOW(time),

        // process/threading stuff
        SIMPLE_ALLOW(set_thread_area),
        SIMPLE_ALLOW(set_tid_address),
        SIMPLE_ALLOW(getpid),

        // file stuff - FIXME: more restrictive rules
        SIMPLE_ALLOW(open),
        SIMPLE_ALLOW(close),
        SIMPLE_ALLOW(lseek),
        SIMPLE_ALLOW(_llseek),
        SIMPLE_ALLOW(access),
        SIMPLE_ALLOW(stat64),
        SIMPLE_ALLOW(fstat64),
        SIMPLE_ALLOW(readlink),
        SIMPLE_ALLOW(chdir),
        SIMPLE_ALLOW(getcwd),

        // fs writes - simulate but don't do anything
        SIMPLE_SKIP(mkdir),

        RET_EPERM,
    };

    struct sock_fprog prog = {
        .len = (unsigned short)(sizeof(filter) / sizeof(filter[0])),
        .filter = filter,
    };

    if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0) == -1) {
        perror("prctl(NO_NEW_PRIVS)");
        return 0;
    }

    if (prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &prog) == -1) {
        perror("prctl(SECCOMP_BPF)");
        return 0;
    };

    return 1;
}

int main(int argc, char **argv, char **envp)
{
    if (argc <= 1) {
        fprintf(stderr, "Usage: %s PROGRAM [...]\n", *argv);
        return EXIT_FAILURE;
    }

    ++argv;

    if (!install_filter())
        return EXIT_FAILURE;

    if (execve(*argv, argv, envp) == -1) {
        perror("execve");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
