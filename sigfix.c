#include <signal.h>
#include <stdlib.h>

void nocrash_handler(int sig) {
    // Komplett ignorieren, nichts tun, kein Log, kein Exit
    return;
}

__attribute__((constructor))
void install_handler() {
    struct sigaction sa;
    sa.sa_handler = nocrash_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_NODEFER | SA_RESTART;
    sigaction(SIGBUS, &sa, NULL);
    sigaction(SIGILL, &sa, NULL);
    sigaction(SIGSEGV, &sa, NULL);
    sigaction(SIGTRAP, &sa, NULL);
    sigaction(SIGABRT, &sa, NULL);
}
