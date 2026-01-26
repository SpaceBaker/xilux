#include <stdio.h>
#include <unistd.h>
#include <sys/utsname.h>
#include "hello-userspace.h"

int main() {
    // Create a struct to hold system information
    struct utsname sys_info;

    // The uname() function gets system information.
    // A return value of -1 indicates an error.
    if (uname(&sys_info) == -1) {
        perror("uname error");
        return 1;
    }

    printf(HELLO_STR);
    printf("This app was cross-compiled\n");
    printf("-------------------------------------\n");
    printf("System Name:  %s\n", sys_info.sysname);
    printf("Node Name:    %s\n", sys_info.nodename);
    printf("Release:      %s\n", sys_info.release);
    printf("Version:      %s\n", sys_info.version);
    printf("Machine Arch: %s\n", sys_info.machine);
    printf("-------------------------------------\n");

    return 0;
}