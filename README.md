# Dodge the Creeps

这是一个使用 Godot 4 制作的 2D 类幸存者小游戏。

## 游戏玩法

控制角色移动，躲避不断出现的敌人。玩家会自动向最近的敌人发射子弹，碰到敌人后游戏结束，存活时间越长，分数越高。

## 操作方式

| 按键 | 功能 |
|---|---|
| W | 向上移动 |
| A | 向左移动 |
| S | 向下移动 |
| D | 向右移动 |

## 运行游戏

### 直接运行 Windows 版本

在 Windows 系统中，双击运行：

```text
DodgeTheCreeps.exe
```

`DodgeTheCreeps.exe`、`DodgeTheCreeps.pck` 和 `DodgeTheCreeps.console.exe` 应保持在同一个文件夹中。

### 在 Godot 中打开项目

1. 使用 Godot 4.7.2 或更高版本导入本项目。
2. 打开 `project.godot`。
3. 运行 `main.tscn`，或按 `F6` 运行当前主场景。

## 项目结构

```text
project.godot  项目配置
main.tscn      游戏主场景
main.gd        游戏流程、计分和敌人生成
player.tscn    玩家场景
player.gd      玩家移动和碰撞逻辑
mob.tscn       敌人场景
mob.gd         敌人动画和离屏清理逻辑
bullet.tscn    自动攻击子弹场景
bullet.gd      子弹移动和击中敌人逻辑
hud.tscn       游戏界面
hud.gd         分数、提示和开始按钮逻辑
art/           图片、音频等素材
fonts/         字体资源
```

## 开发环境

- Godot 4.7.2
- Windows x86_64

## 许可证

本项目用于学习 Godot 游戏开发。项目中的素材来自 Godot 官方 Dodge the Creeps 教程资源。
