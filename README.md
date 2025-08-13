# Linglong Flake

一个用于部署玲珑（Linglong）容器的 Nix Flake 项目。

## 什么是玲珑容器？

玲珑（Linglong）是一个跨发行版的包管理器，支持沙盒化应用和共享运行时。它允许您：

- 在不同 Linux 发行版上运行相同的应用
- 使用沙盒技术隔离应用环境
- 共享运行时库，减少磁盘占用
- 支持 OCI 容器标准

## 快速开始

### 1. 构建包

```bash
# 使用默认配置构建
nix build .#linyaps-box
nix build .#linyaps
```

### 2. 在 NixOS 中使用

在您的 `flake.nix` 中添加：

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

## 项目结构

```
.
├── flake.nix              # 主配置文件
├── pkgs/                  # 包定义
│   ├── default.nix        # linyaps 包定义
│   └── linyaps-box.nix    # linyaps-box 包定义
└── README.md              # 本文件
```

## 依赖说明

- **linyaps-box**: 简单的 OCI 运行时，主要用于 linyaps
- **linyaps**: 主要的包管理器，提供完整的玲珑容器功能

## 相关链接

- [玲珑官网](https://linglong.org.cn/)
- [GitHub 仓库](https://github.com/OpenAtom-Linyaps/linyaps)
- [官方文档](https://linglong.org.cn/docs/)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目采用 MIT 许可证。

---

参考了 [nur-packages](https://github.com/HHR2020/nur-packages) 项目。