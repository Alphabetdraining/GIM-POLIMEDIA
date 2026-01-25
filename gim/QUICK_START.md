# 🎮 QUICK START - TETRIS ACTION SURVIVAL

## ✅ STATUS PROJECT

**Game:** Tetris Action Survival  
**Engine:** Godot 4.5  
**Status:** ✅ PLAYABLE  
**Naming Convention:** lowercase_with_underscore

---

## 🚀 CARA MENJALANKAN

1. Buka Godot 4.5
2. Load project: `/home/brojack/GodotFiles/GIM-POLIMEDIA/gim`
3. Press **F5** atau klik **Play**
4. Enjoy! 🎮

---

## 🎮 KONTROL

**Player:**
- A/D - Move
- Space - Jump/Double Jump
- J - Dash

**Tetris:**
- Arrow Keys - Move/Drop
- Q/E - Rotate
- Space - Hard Drop

---

## 📊 FITUR YANG SUDAH JADI

✅ Player movement & collision  
✅ Health system (3 HP)  
✅ Respawn system  
✅ Player bisa berdiri di atas balok  
✅ HP display (MC & Enemy panel)  
✅ Scoring system (line clear → damage enemy)  
✅ Power-up system (spawn setiap 3 lines)  
✅ Tetris mechanic (SRS rotation)  
✅ Game over screen  

---

## 📁 FILE PENTING

**Modified:**
- `script/player.gd` - Player logic
- `script/ui.gd` - UI display
- `script/spawner.gd` - Signal connector
- `script/board.gd` - Board manager
- `Scenes/piece.tscn` - Piece dengan Platform
- `Scenes/main.tscn` - Ground & Player position

**Created:**
- `script/powerup.gd` - Power-up logic
- `Scenes/powerup.tscn` - Power-up scene

---

## 🔧 YANG PERLU DIKERJAKAN

### Priority HIGH:
- [ ] Sprite untuk HP 2/3 (pusing)
- [ ] Sprite untuk HP 1/3 (sekarat)
- [ ] MC Portrait (normal, pusing, sekarat)
- [ ] Enemy Portrait

### Priority MEDIUM:
- [ ] Dynamic map (penyempitan arena)
- [ ] Special blocks (non-scoring)

### Priority LOW:
- [ ] Dialog system (Dialogic)
- [ ] Level progression (1, 2, 3)

---

## ⚠️ CATATAN PENTING

1. **Balok Warna = PLACEHOLDER!**
   - Saat HP 1/3, player jadi balok warna
   - Ini BUKAN bug, tapi placeholder animasi critical
   - Replace dengan sprite asli nanti

2. **Dual Collision System:**
   - Piece punya Area2D (damage) + StaticBody2D (platform)
   - Player bisa berdiri di atas balok
   - Player tetap damage saat sentuh balok

3. **Spawn Position:**
   - Ground: Y = 590
   - Player: Y = 480
   - Player di ATAS ground (480 < 590)

4. **Naming Convention:**
   - Function: `lowercase_with_underscore`
   - Signal handler: `on_signal_name`
   - Example: `take_damage()`, `on_player_hp_changed()`

---

## 📚 DOKUMENTASI LENGKAP

Baca **README_LENGKAP.md** untuk:
- Analisis struktur project
- Cara kerja sistem collision
- Troubleshooting
- Pengembangan selanjutnya

---

## 🐛 TROUBLESHOOTING CEPAT

**Player jatuh terus?**
→ Check Ground position: 590, Player position: 480

**Player tembus balok?**
→ Check piece.tscn ada Platform (StaticBody2D)

**HP tidak update?**
→ Check console: "update_hp_display called with HP: X"

**Power-up tidak spawn?**
→ Clear 3 lines, check console: "Power-up spawned!"

---

## 🎯 QUICK REFERENCE

**Collision Layers:**
- Layer 1: Ground & Platform
- Layer 2: Player
- Layer 4: Piece (damage)
- Layer 8: Power-up

**Constants:**
- SPEED: 130
- JUMP_VELOCITY: -300
- MAX_HP: 3
- INVULNERABLE_TIME: 1.5s

**Spawn Position:**
- Default: Vector2(-16, 480)
- Ground: Vector2(0, 590)

---

**SELAMAT CODING!** 🚀

Untuk detail lengkap, baca **README_LENGKAP.md**
