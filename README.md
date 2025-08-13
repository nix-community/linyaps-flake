# Linglong Flake

A Nix Flake project for deploying Linglong containers.

## What is Linglong?

Linglong is a cross-distribution package manager that supports sandboxed applications and shared runtime environments. It enables you to:

- Run the same applications across different Linux distributions
- Isolate application environments using sandbox technology
- Share runtime libraries to reduce disk usage
- Support OCI container standards

## Quick Start

### 1. Build Packages

```bash
# Build with default configuration
nix build .#linyaps-box
nix build .#linyaps
```

### 2. Use in NixOS

Include the nixos module in your configuration：

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    linglong-flake.url = "github:wineee/linglong-flake";
  };

  outputs = { self, nixpkgs, linglong-flake, ... }: {
    nixosConfigurations = {
      my-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          linglong-flake.nixosModules.linyaps
          {
            services.linyaps.enable = true;
          }
        ];
      };
    };
  };
}
```

## Project Structure

```
.
├── flake.nix              # Main configuration file
├── pkgs/                  # Package definitions
│   ├── default.nix        # linyaps package definition
│   └── linyaps-box.nix    # linyaps-box package definition
└── README.md              # This file
```

## Dependencies

- **linyaps-box**: Simple OCI runtime, primarily used by linyaps
- **linyaps**: Main package manager, providing complete Linglong container functionality

## Related Links

- [Linglong Website](https://linglong.org.cn/)
- [GitHub Repository](https://github.com/OpenAtom-Linyaps/linyaps)
- [Official Documentation](https://linglong.org.cn/docs/)

## Contributing

Issues and Pull Requests are welcome!

## License

This project is licensed under the MIT License.

---

Inspired by [nur-packages](https://github.com/HHR2020/nur-packages) project.
