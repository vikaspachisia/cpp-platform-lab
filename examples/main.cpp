#include "platform.h"
#include <iostream>

int main()
{
    std::cout << "platform_app: invoking linked library\n";
    int rc = platform_lib_run();
    std::cout << "platform_app: library returned " << rc << "\n";
    return rc;
}