#ifndef EXAMPLES_PLATFORM_FACTORY_H
#define EXAMPLES_PLATFORM_FACTORY_H

#include "loader.h"
#include <memory>

// Abstract Factory: produces platform-specific products (start with Loader).
class PlatformFactory
{
public:
    virtual ~PlatformFactory() = default;

    // Create the Loader product.
    virtual std::unique_ptr<Loader> create_loader() = 0;

    // Future products can be added here:
    // virtual std::unique_ptr<OtherProduct> create_other() = 0;
};

// Returns a platform-appropriate factory instance.
// Each platform translation unit provides its own implementation.
std::unique_ptr<PlatformFactory> make_platform_factory();

#endif // EXAMPLES_PLATFORM_FACTORY_H