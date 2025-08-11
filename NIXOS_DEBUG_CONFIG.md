# NixOS 模块 Debug 配置说明

## 概述

`nixosModules.linyaps` 现在支持 `debug` 配置选项，允许您在 NixOS 系统级别控制是否使用 debug 版本。

## 配置选项

### services.linyaps.debug

- **类型**: `boolean`
- **默认值**: `false` (开启 Release 版本)
- **描述**: 是否启用 debug 版本（包含调试信息和符号表）

## 使用方法

### 1. 在 configuration.nix 中配置

```nix
{ config, lib, pkgs, ... }:

{
  services.linyaps = {
    enable = true;
    debug = true; # 默认开启，设为 false 使用 Release 版本
  };
}
```

### 2. 在 flake.nix 中配置

```nix
{
  inputs.linglong-flake.url = "path:./linglong-flake";
  
  outputs = { self, nixpkgs, linglong-flake }: {
    nixosConfigurations.your-system = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        linglong-flake.nixosModules.linyaps
        {
          services.linyaps = {
            enable = true;
            debug = false; # 默认 Release 模式
          };
        }
      ];
    };
  };
}
```

## Debug vs Release 版本

### Debug 版本 (debug = true)
- ✅ 包含完整的调试信息 (`-g` 标志)
- ✅ 禁用优化 (`-O0` 标志)
- ✅ 保留符号表 (`dontStrip = true`)
- ✅ 使用 Debug 构建类型
- ✅ 适合开发和调试环境

### Release 版本 (debug = false)
- ✅ 启用优化
- ✅ 移除调试信息
- ✅ 适合生产环境
- ✅ 文件大小更小
- ✅ 性能更好

## 动态切换

您可以在不重新构建整个系统的情况下切换 debug 模式：

```bash
# 切换到 Release 版本
sudo nixos-rebuild switch --flake .#your-system

# 在配置中设置 debug = false 后
```

## 注意事项

1. **默认行为**: 现在默认开启 Release 版本
2. **性能影响**: Debug 版本可能比 Release 版本慢
3. **文件大小**: Debug 版本文件更大
4. **生产环境**: 建议在生产环境中使用 Release 版本 (debug = false)

## 示例配置

参考 `example-configuration.nix` 文件获取完整的配置示例。 