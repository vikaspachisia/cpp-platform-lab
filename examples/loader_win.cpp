#include "loader.h"
#include "platform_factory.h"
#include <windows.h>
#include <string>
#include <iostream>
#include <memory>

// Concrete product: WinLoader
class WinLoader : public Loader
{
public:
    WinLoader() : handle_(nullptr) {}
    ~WinLoader() override { close(); }

    bool open(const std::string &name) override
    {
        std::string fname = name + ".dll";
        handle_ = LoadLibraryA(fname.c_str());
        if (!handle_) {
            std::cerr << "loader_app: failed to LoadLibraryA(" << fname << ")\n";
            return false;
        }
        return true;
    }

    void *get_symbol(const char *symbol) override
    {
        if (!handle_) return nullptr;
        return reinterpret_cast<void *>(GetProcAddress(handle_, symbol));
    }

    void close() override
    {
        if (handle_) {
            FreeLibrary(handle_);
            handle_ = nullptr;
        }
    }

private:
    HMODULE handle_;
};

// Concrete factory: WinFactory produces WinLoader
class WinFactory : public PlatformFactory
{
public:
    std::unique_ptr<Loader> create_loader() override
    {
        return std::make_unique<WinLoader>();
    }
};

std::unique_ptr<PlatformFactory> make_platform_factory()
{
    return std::make_unique<WinFactory>();
}