#include "platform.h"
#include "loader.h"
#include <iostream>
#include <string>

int main()
{
    std::cout << "loader_app: runtime loading library\n";

    auto loader = make_loader();
    if (!loader) {
        std::cerr << "loader_app: failed to create platform loader\n";
        return 1;
    }

    const std::string libname = "platformlib";
    if (!loader->open(libname)) {
        return 2;
    }

    using fn_t = int (*)();
    auto sym = reinterpret_cast<fn_t>(loader->get_symbol("platform_lib_run"));
    if (!sym) {
        std::cerr << "loader_app: failed to find symbol platform_lib_run\n";
        loader->close();
        return 3;
    }

    int rc = sym();
    loader->close();
    return rc;
}