#include <iostream>
#include <chrono>
#include <thread>

int main(int argc, char** argv)
{
    std::cout << "template_app: started\n";
    for(int i=1;i<argc;++i) {
        std::cout << "  arg[" << i-1 << "] = " << argv[i] << "\n";
    }
    // small work to show threading and exit 0
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    std::cout << "template_app: done\n";
    return 0;
}