#include <signal.h>

void nocrash_handler(int sig) {
    return;
}

__attribute__((constructor))
void install_handler() {
    signal(SIGBUS, nocrash_handler);
    signal(SIGILL, nocrash_handler);
    signal(SIGSEGV, nocrash_handler);
    signal(SIGTRAP, nocrash_handler);
}
