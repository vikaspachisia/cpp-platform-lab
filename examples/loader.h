#ifndef EXAMPLES_LOADER_H
#define EXAMPLES_LOADER_H

#include <memory>
#include <string>

class Loader
{
public:
    virtual ~Loader() = default;

    // Open library by base name (implementation may add prefixes/suffixes).
    virtual bool open(const std::string &name) = 0;

    // Return symbol pointer or nullptr on failure.
    virtual void *get_symbol(const char *symbol) = 0;

    // Close/unload library.
    virtual void close() = 0;
};

// Factory: returns a platform-appropriate loader instance.
std::unique_ptr<Loader> make_loader();

#endif // EXAMPLES_LOADER_H