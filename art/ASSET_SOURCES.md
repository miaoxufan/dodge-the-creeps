# 美术制作记录 · 2026-10-02

## 参考检索

- Wildfrost / 雪居之地：https://store.steampowered.com/app/1811990/Wildfrost/
- Backpack Battles / 背包乱斗：https://store.steampowered.com/app/2427700/Backpack_Battles/
- Slay the Spire 2 / 杀戮尖塔 2：https://store.steampowered.com/app/2868840/Slay_the_Spire_2/

以上页面用于风格研究；没有下载它们的角色、截图或贴图放入游戏。实际采用的是新生成的原创角色设定和背景，以及代码原生绘制的 UI / 武器。

## 资产清单

使用内置 imagegen 工具生成，未使用 CLI/API fallback。角色和怪物使用真实透明背景，直接复制工具输出，未使用脚本抠图。启用 mipmap 改善游戏内缩小显示。

| 文件 | 用途 |
|---|---|
| heroes/ranger.png | 烬羽射手立绘、选择卡与游戏角色 |
| heroes/duelist.png | 月影刀客立绘、选择卡与游戏角色 |
| heroes/alchemist.png | 苔灵药师立绘、选择卡与游戏角色 |
| enemies/mushroom.png | 蘑菇怪 |
| enemies/bramble.png | 荆棘兽 |
| enemies/ghost.png | 披布幽灵 |
| menu-desk.png | 纸张、木桌、秋叶与灯笼菜单背景 |
| forest-arena.png | 俯视林间空地 |

## 最终提示词集

### Ranger

Use case: stylized-concept. Production 2D game character cutout, transparent background, no text. Original cute yet adventurous fantasy ranger for a hand-painted indie roguelike. Full body front three-quarter facing slightly right, stout chibi proportions 2.5 heads tall. Oversized burnt orange red hood and long red scarf flowing left, shaggy dark brown bangs, expressive confident dark eyes, cream tunic with dark leather belts, big brown boots, short wooden brass hand cannon held across belly pointing right. Strong thick dark chocolate ink contours, slightly imperfect hand-drawn shape language, warm muted colors with bold coral accent, gentle gouache texture and cel shadows. Charming illustrated tabletop adventure feeling, polished professional game key art. Body occupies 82 percent height, everything including scarf and gun inside frame, centered. No scenery, no floor shadow, no glow, no logo, no UI, no borders. Readable silhouette at 80 pixels. This is one hero asset for both gameplay and menu portrait, not a character sheet.

### Duelist / Alchemist

共同前缀：Use case: stylized-concept. Production 2D game character cutout with real transparent background, no text.

Duelist 主体：Original cute but formidable fantasy moonblade duelist, full body front three-quarter facing slightly right, stout chibi 2.5 heads tall. Oversized deep plum hood and asymmetric violet cape, pale silver hair, confident face partially covered by burgundy scarf mask with visible amber eyes, charcoal leather tunic, gold crescent brooch and buckles, heavy boots. Two short curved ivory silver sabres, one held outward on either side pointing down, gold and brown grips. Purple and warm ivory palette distinct from a red ranger.

Alchemist 主体：Original cute eccentric woodland alchemist, full body front three-quarter facing slightly right, stout chibi 2.5 heads tall. Oversized floppy sage green pointed hat with stitched patches and mushroom pin, round bronze goggles over bright expressive eyes, messy cream hair, ochre apron and green coat, dark leather boots. Large round emerald potion with cork held in right hand, leather satchel and three tiny colored potion bottles at waist. Sage green, amber and cream palette, distinct broad mushroom-hat silhouette.

共同后缀：Strong thick dark chocolate ink contours, hand-drawn slightly imperfect shapes, warm muted colors, delicate gouache texture and simple cel shadows. Charming illustrated tabletop roguelike adventure, polished professional game art. Full body centered occupies 82 percent height, all weapons and hat inside frame. No scenery, floor shadow, glow, logo, UI or borders. Readable at 80 pixels. Single hero asset for gameplay and menu, not a character sheet.

### Enemies

共同前缀：Use case: stylized-concept. A single original production 2D game enemy cutout, real transparent background.

Mushroom 主体：A squat mischievous mushroom monster. Giant burgundy and dusty red mushroom cap with cream spots, small tan stalk-body, angry cute black eyes under the cap, two tiny stubby feet, little moss patches. Broad domed silhouette. No weapons.

Bramble 主体：A round prickly woodland bramble beast, squat creature with a dark moss green spiky leaf-covered back, cinnamon brown face, tiny golden glowing eyes, two little ivory tusks and short claw feet. Broad hedgehog silhouette, adorable but hostile. No weapons.

Ghost 主体：A small floating haunted rag ghost, worn desaturated lavender grey hooded cloth silhouette, asymmetrical tattered bottom, deep dark face hollow with two warm amber eyes, a tiny bronze bell tied with twine at neck. Stubby little claw hands emerging sideways. Cute spooky, rounded teardrop silhouette. No weapons.

共同后缀：Full body front three quarter facing slightly right, centered, all details within frame with generous padding. Polished hand-painted indie fantasy roguelike illustration, dark chocolate ink outlines, gentle gouache paper texture, warm earthy muted palette with simple cel shadows. Same visual family as chibi hooded ranger, purple cloak rogue and mushroom-hat alchemist. Simplified strong shapes readable at 75 pixels. No scenery, text, logo, UI, floor or cast shadow.

### Menu

Use case: stylized-concept. Wide 16:9 illustrated game main menu background, no text no characters no UI. A charming hand-painted fantasy adventurers' desk seen from above: warm cream blank parchment map across left two-thirds, subtle faded drawn winding paths and mountain doodles only near margins, worn thick dark wood desk showing at edges, right third an atmospheric mossy woodland diorama with warm autumn leaves, little ivory mushrooms, tiny amber lantern and scattered brass coins. Painterly gouache illustration, warm ochre and sage forest palette, dark chocolate outlines, softly textured paper, cozy whimsical indie roguelike aesthetic. Keep central 85% of image light low contrast to support text and hero artwork on top, edges darker for vignette. Never photorealistic, no words, no symbols resembling text, no large items covering center. High quality bespoke 2D game scenery.

### Arena

Use case stylized-concept. Wide 16:9 2D top-down game arena ground background. Cozy hand-painted storybook forest clearing for a fantasy survivors game. Flat overhead orthographic view, no perspective horizon. Almost all (central 90%) is quiet desaturated moss-sage ground with subtle patches of ochre soil, tiny tufts of grass, faint old cobblestone ring embedded in soil. Outer 4% edge only has small rounded stones, burgundy fallen leaves, a few cream and red mushrooms, subtle dark foliage. Soft gouache texture, dark chocolate ink line accents, warm natural palette like a painted board game map. Important gameplay clarity: very low detail/contrast in center, medium light muted green ground to show small colored characters and bright blue pickups. No characters, enemies, weapons, text, interface, paths dividing arena, obstacles, buildings or dramatic lighting. Seamless-feeling single playable clearing.
