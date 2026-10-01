# Dodge the Creeps

这是一个使用 Godot 4 制作的 2D 科幻风格类幸存者小游戏。

## 游戏玩法

控制英雄移动，躲避不断出现的敌人并自动攻击。击杀敌人可以获得普通经验和蓝色技能点，升级时从三个随机选项中选择一个。

## 英雄

- **英雄 1**：自动从移动方向发射子弹。普通升级可以增加正面子弹，技能点升级可以从身后增加子弹。
- **英雄 2**：使用与英雄 1 相同的人物模型，但初始拥有两把围绕自身旋转的科幻刀。普通经验可以增加刀的旋转距离或转速；技能点可以让距离升级翻倍，或从身后增加一把刀。

两名英雄都拥有移动速度、身体缩小、额外生命和闪避等通用升级。

## 游戏系统

- 开始时有 3 秒保护时间，升级选择完成后有 1 秒保护时间。
- 击杀敌人会掉落蓝色技能球，收集后可触发技能点升级。
- 开始界面提供英雄选择和排行榜。
- 排行榜会保存最高 10 局成绩，记录保存在 Godot 的 `user://leaderboard.json`。

## 操作方式

| 按键 | 功能 |
|---|---|
| W | 向上移动 |
| A | 向左移动 |
| S | 向下移动 |
| D | 向右移动 |
| Space | 解锁闪避后进行闪避 |

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
knife.tscn     英雄 2 的旋转刀场景
knife.gd       旋转刀移动和击中敌人逻辑
skill_orb.tscn 蓝色技能球场景
skill_orb.gd   技能点收集逻辑
hud.tscn       游戏界面
hud.gd         开始界面、英雄选择、升级面板和排行榜逻辑
art/           图片、音频等素材
fonts/         字体资源
```

## 开发环境

- Godot 4.7.2
- Windows x86_64

## 许可证

本项目用于学习 Godot 游戏开发。项目中的素材来自 Godot 官方 Dodge the Creeps 教程资源。
