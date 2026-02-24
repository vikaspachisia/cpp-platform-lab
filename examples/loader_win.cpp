#include "loader.h"
#include <windows.h>
#include <string>
#include <iostream>
#include <memory>

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

std::unique_ptr<Loader> make_loader()
{
    return std::make_unique<WinLoader>();
}