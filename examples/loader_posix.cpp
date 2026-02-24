#include "loader.h"
#include "platform_factory.h"
#include <dlfcn.h>
#include <string>
#include <vector>
#include <iostream>
#include <memory>

// Concrete product: PosixLoader
class PosixLoader : public Loader
{
public:
    PosixLoader() : handle_(nullptr) {}
    ~PosixLoader() override { close(); }

    bool open(const std::string &name) override
    {
        std::vector<std::string> candidates;
        candidates.push_back(std::string("lib") + name + ".so");
        candidates.push_back(std::string("lib") + name + ".dylib");
        candidates.push_back(name + ".so");

        for (const auto &cand : candidates) {
            handle_ = dlopen(cand.c_str(), RTLD_NOW);
            if (handle_) break;
        }

        if (!handle_) {
            std::cerr << "loader_app: failed to dlopen library: " << dlerror() << "\n";
            return false;
        }
        return true;
    }

    void *get_symbol(const char *symbol) override
    {
        if (!handle_) return nullptr;
        return dlsym(handle_, symbol);
    }

    void close() override
    {
        if (handle_) {
            dlclose(handle_);
            handle_ = nullptr;
        }
    }

private:
    void *handle_;
};

// Concrete factory: PosixFactory produces PosixLoader
class PosixFactory : public PlatformFactory
{
public:
    std::unique_ptr<Loader> create_loader() override
    {
        return std::make_unique<PosixLoader>();
    }
};

std::unique_ptr<PlatformFactory> make_platform_factory()
{
    return std::make_unique<PosixFactory>();
}