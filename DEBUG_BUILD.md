# Debug 版本构建说明

## 概述

本项目现在**默认开启 Release 版本**，支持通过配置选项切换到 Debug 版本。Debug 版本包含调试信息和符号表，便于开发和调试。

## 构建 Debug 版本

### 方法 1: 使用默认的 Release 包（推荐）

```bash
# 构建 linyaps-box Release 版本（默认）
nix build .#linyaps-box

# 构建 linyaps Release 版本（默认）
nix build .#linyaps
```

### 方法 2: 修改 flake.nix 中的 debug 标志

现在默认开启 Release 版本。如需 Debug 版本，在 `flake.nix` 文件中将 `debug = false;` 改为 `debug = true;`：

```nix
# 添加 debug 配置选项
debug = true; # 设置为 true 来构建 Debug 版本
```

### 方法 3: 在 NixOS 配置中使用

在您的 `configuration.nix` 或 `flake.nix` 中：

```nix
services.linyaps = {
  enable = true;
  debug = false; # 默认 Release 模式，设为 true 使用 Debug 版本
};
```

### 方法 4: 使用预定义的 Debug 包

```bash
# 构建 Debug 版本
nix build .#linyaps-box-debug
nix build .#linyaps-debug
```

## Debug 版本特性

- 包含完整的调试信息 (`-g` 标志)
- 禁用优化 (`-O0` 标志)
- 保留符号表 (`dontStrip = true`)
- 使用 Debug 构建类型

## 使用场景

- 开发调试
- 性能分析
- 崩溃分析
- 符号解析

## 注意事项

- Debug 版本的文件大小会比 Release 版本大
- 性能可能比 Release 版本慢
- 现在默认开启 Release 版本，适合生产环境使用
- 如需开发调试，请切换到 Debug 版本 