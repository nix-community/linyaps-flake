# Linglong Flake

一个用于部署玲珑（Linglong）容器的 Nix Flake 项目。

## 什么是玲珑容器？

玲珑（Linglong）是一个跨发行版的包管理器，支持沙盒化应用和共享运行时。它允许您：

- 在不同 Linux 发行版上运行相同的应用
- 使用沙盒技术隔离应用环境
- 共享运行时库，减少磁盘占用
- 支持 OCI 容器标准

## 项目特性

- 🚀 **跨平台兼容**: 支持多种 Linux 发行版
- 🔒 **沙盒安全**: 应用运行在隔离环境中
- 📦 **包管理**: 完整的包管理功能
- 🛠️ **开发友好**: 支持 Debug 和 Release 构建模式
- 🎯 **NixOS 集成**: 提供 NixOS 模块支持

## 快速开始

### 1. 构建包

```bash
# 使用默认配置构建
nix build .#linyaps-box
nix build .#linyaps
```

### 2. 在 NixOS 中使用

在您的 `configuration.nix` 或 `flake.nix` 中：

```nix
services.linyaps = {
  enable = true;
  debug = false; # 默认 Release 模式，设为 true 使用 Debug 版本
};
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

## 使用场景

- 🏠 **家庭用户**: 在不同发行版间迁移应用
- 👨‍💻 **开发者**: 开发和测试跨平台应用
- 🏢 **企业环境**: 标准化应用部署
- 🧪 **测试环境**: 应用兼容性测试

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