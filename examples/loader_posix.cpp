#include "loader.h"
#include <dlfcn.h>
#include <string>
#include <vector>
#include <iostream>
#include <memory>

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

std::unique_ptr<Loader> make_loader()
{
    return std::make_unique<PosixLoader>();
}