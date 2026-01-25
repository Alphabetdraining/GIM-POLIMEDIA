# 📚 DOKUMENTASI LENGKAP - TETRIS ACTION SURVIVAL

**Versi:** 1.0  
**Tanggal:** 2024  
**Game Engine:** Godot 4.5  
**Naming Convention:** lowercase_with_underscore

---

## 📋 DAFTAR ISI

1. [Analisis Struktur Project](#1-analisis-struktur-project)
2. [Fitur Yang Diimplementasikan](#2-fitur-yang-diimplementasikan)
3. [Perubahan File](#3-perubahan-file)
4. [Sistem Collision](#4-sistem-collision)
5. [Cara Kerja Game](#5-cara-kerja-game)
6. [Kontrol Game](#6-kontrol-game)
7. [Troubleshooting](#7-troubleshooting)
8. [Pengembangan Selanjutnya](#8-pengembangan-selanjutnya)

---

## 1. ANALISIS STRUKTUR PROJECT

### 📁 Struktur Folder

```
gim/
├── addons/
│   └── dialogic/          # Plugin dialog system (Dialogic)
├── assets/
│   ├── placeholder/       # Sprite placeholder (knight, balok warna)
│   ├── Border.png         # Border game
│   ├── Grid.png           # Grid tetris
│   └── [tetris pieces]    # Blue, Cyan, Green, Orange, Purple, Red, Yellow
├── resources/
│   └── [pieces_data.tres] # Data tetromino (I, J, L, O, S, T, Z)
├── Scenes/
│   ├── main.tscn          # Scene utama
│   ├── player.tscn        # Player character
│   ├── piece.tscn         # Piece tetromino (dengan Platform)
│   ├── tetromino.tscn     # Tetromino parent
│   ├── ui.tscn            # UI (HP, Enemy HP, Game Over)
│   ├── powerup.tscn       # Power-up
│   └── ground.tscn        # Ground platform (optional)
└── script/
	├── player.gd          # Player logic
	├── piece.gd           # Piece logic
	├── tetromino.gd       # Tetromino logic
	├── board.gd           # Board manager
	├── spawner.gd         # Spawner & signal connector
	├── ui.gd              # UI manager
	├── powerup.gd         # Power-up logic
	├── shared.gd          # Shared data (autoload)
	└── pieces_data.gd     # Pieces data resource
```

### 🎮 Sistem Utama

#### **A. Player System**
- **Type:** CharacterBody2D
- **Collision:** Layer 2, Mask 1
- **Features:**
  - Movement (A/D)
  - Jump & Double Jump (Space)
  - Dash (J) - cooldown 2 detik
  - HP System (3/3)
  - Invulnerability (1.5 detik setelah damage)
  - Respawn system
  - Animasi: idle, run, jump (+ _hurt, _critical variants)

#### **B. Tetris System**
- **Board:** 10 kolom × 20 baris
- **Tetromino:** I, J, L, O, S, T, Z
- **Rotation:** SRS (Super Rotation System) dengan wall kicks
- **Controls:** Arrow keys, Q/E rotate, Space hard drop
- **Scoring:** Line clear → damage enemy

#### **C. Piece System (PENTING!)**
- **Dual Collision:**
  - **Area2D** (collision_layer 4) → Damage detection
  - **StaticBody2D Platform** (collision_layer 1) → Physics collision
- **Ini memungkinkan:**
  - Player bisa berdiri di atas balok
  - Player tetap damage saat sentuh balok

#### **D. UI System**
- **MC Panel** (kiri): Player portrait + HP display
- **Enemy Panel** (kanan): Enemy portrait + HP display
- **Game Over Screen:** Restart button

#### **E. Power-Up System**
- **Types:** DOUBLE_JUMP, SPEED_BOOST, INVINCIBLE
- **Spawn:** Setiap 3 line cleared
- **Lifetime:** 10 detik
- **Auto-pickup:** Collision dengan player

---

## 2. FITUR YANG DIIMPLEMENTASIKAN

### ✅ Fitur Selesai

#### **1. Player Movement**
- Kanan/Kiri (A/D) - SPEED: 130
- Jump (Space) - JUMP_VELOCITY: -300
- Double Jump - MAX_JUMPS: 2
- Dash (J) - DASH_SPEED: 400, cooldown 2s

#### **2. Health System**
- **HP:** 3/3 (MAX_HP = 3)
- **Damage:** Tertimpa balok = -1 HP
- **Respawn:** Cari posisi aman di grid
- **Invulnerability:** 1.5 detik (blinking effect)
- **Death:** HP 0 = Game Over

#### **3. Visual Health**
- **HP 3/3:** Animasi normal (knight sprite)
- **HP 2/3:** Animasi hurt (balok warna cyan/purple/blue/green)
- **HP 1/3:** Animasi critical (balok warna berkedip)
- **Note:** Balok warna adalah PLACEHOLDER, bukan bug!

#### **4. Collision System**
- **HitDetector (Area2D):** Detect piece untuk damage
- **Platform (StaticBody2D):** Player bisa berdiri di atas balok
- **Dual system:** Damage + Physics collision

#### **5. Respawn System**
- **Spawn Position:** Vector2(-16, 480)
- **Safe Position Finder:** Scan grid 10×20
- **Validation:** Tidak spawn di dalam balok
- **Invulnerability:** 1.5 detik setelah respawn

#### **6. UI Display**
- **MC Panel:** HP: 3/3
- **Enemy Panel:** Enemy HP: 10/10
- **Real-time Update:** Via signals
- **Portrait System:** Siap untuk texture (mc_portraits dictionary)

#### **7. Scoring System**
- **Line Clear:** 1 line = 1 damage ke enemy
- **Enemy HP:** 10/10
- **Win Condition:** Enemy HP = 0
- **Power-up:** Spawn setiap 3 lines cleared

#### **8. Power-Up System**
- **DOUBLE_JUMP:** Reset jump count
- **SPEED_BOOST:** (placeholder)
- **INVINCIBLE:** 3 detik invulnerability
- **Spawn:** Random position, jatuh ke bawah
- **Lifetime:** 10 detik

---

## 3. PERUBAHAN FILE

### 📝 File Yang Dimodifikasi

#### **A. script/player.gd**
**Perubahan:**
1. Tambah signals: `hp_changed(new_hp)`, `player_died()`
2. Tambah variables: `is_invulnerable`, `invulnerable_timer`
3. Tambah functions:
   - `take_damage(amount)` - Handle damage
   - `die()` - Game over sequence
   - `respawn_to_safe_position()` - Respawn logic
   - `find_safe_positions()` - Scan grid
   - `is_position_safe(pos, board)` - Validate position
   - `_on_hit_detector_area_entered(area)` - Collision detection
4. Update `play_animation()` - Aktifkan animasi hurt/critical
5. Update spawn position: 190 → 480 (turun 5 blok)

**Naming Convention:** lowercase_with_underscore

#### **B. Scenes/piece.tscn**
**Perubahan:**
1. Tambah child node: **Platform (StaticBody2D)**
2. Tambah CollisionShape2D untuk Platform
3. Platform collision_layer = 1 (untuk physics)
4. Area2D tetap collision_layer = 4 (untuk damage)

**Struktur:**
```
Piece (Area2D)
├── Sprite2D
├── CollisionShape2D (Area2D)
└── Platform (StaticBody2D)  ← BARU!
	└── CollisionShape2D
```

#### **C. script/ui.gd**
**Perubahan:**
1. Fix node path: `MCPanel/VBoxContainer/Portrait` (bukan `MCPanel/Portrait`)
2. Tambah debug prints untuk tracking
3. Tambah functions:
   - `update_hp_display(hp)` - Update player HP
   - `update_enemy_hp_display(hp)` - Update enemy HP
   - `damage_enemy(amount)` - Kurangi enemy HP

**Naming Convention:** lowercase_with_underscore

#### **D. script/spawner.gd**
**Perubahan:**
1. Connect player signals: `hp_changed`, `player_died`
2. Tambah `hit_count` untuk power-up spawn
3. Tambah functions:
   - `on_player_hp_changed(new_hp)` - Handle HP change
   - `on_player_died()` - Handle death
   - `spawn_random_powerup()` - Spawn power-up
4. Tambah delay 0.1s untuk UI ready

**Naming Convention:** lowercase_with_underscore

#### **E. script/board.gd**
**Perubahan:**
1. Tambah signal: `line_cleared(count)`
2. Update `clear_board_pieces()` - Return lines cleared count
3. Emit signal saat line cleared

**Naming Convention:** lowercase_with_underscore

#### **F. Scenes/main.tscn**
**Perubahan:**
1. Ground position: 300 → 590 (turun 5 blok)
2. Player position: 190 → 480 (turun 5 blok)

**Koordinat:**
- Ground: Vector2(0, 590)
- Player: Vector2(-16, 480)

### 📝 File Yang Dibuat Baru

#### **A. script/powerup.gd**
**Purpose:** Power-up logic
**Features:**
- Random type selection
- Auto-apply saat pickup
- Lifetime 10 detik
- Gravity physics

#### **B. Scenes/powerup.tscn**
**Purpose:** Power-up scene
**Structure:**
- Area2D (collision_layer 8, mask 2)
- Sprite2D (visual)
- CollisionShape2D (CircleShape2D radius 20)

#### **C. Scenes/ground.tscn** (optional)
**Purpose:** Ground platform template
**Note:** Sudah ada di main.tscn, file ini optional

---

## 4. SISTEM COLLISION

### 🎯 Collision Layers

```
Layer 1: Ground & Platform (StaticBody2D)
Layer 2: Player (CharacterBody2D)
Layer 4: Piece Damage Detection (Area2D)
Layer 8: Power-up (Area2D)
```

### 🔄 Collision Matrix

| Object | Layer | Mask | Collision Dengan |
|--------|-------|------|------------------|
| Player | 2 | 1 | Ground, Platform |
| HitDetector | 0 | 4 | Piece (Area2D) |
| Piece (Area2D) | 4 | 0 | HitDetector |
| Platform | 1 | 0 | Player |
| Ground | 1 | 0 | Player |
| Power-up | 8 | 2 | Player |

### 🎮 Cara Kerja Dual Collision

**Piece memiliki 2 collision:**

1. **Area2D (Layer 4):**
   - Untuk damage detection
   - HitDetector player detect ini
   - Saat detect → `take_damage(1)`

2. **StaticBody2D Platform (Layer 1):**
   - Untuk physics collision
   - Player collision_mask = 1
   - Player bisa berdiri di atas

**Hasil:**
- Player bisa berdiri di atas balok (physics)
- Player tetap damage saat sentuh balok (area detection)

---

## 5. CARA KERJA GAME

### 🎮 Game Loop

```
1. Game Start
   ↓
2. Spawner spawn tetromino random
   ↓
3. Tetromino jatuh (timer auto-move down)
   ↓
4. Player control tetromino (arrow keys, rotate, hard drop)
   ↓
5. Tetromino lock → emit signal
   ↓
6. Board check:
   - Game over? (pieces reach top)
   - Line clear? (horizontal line penuh)
   ↓
7. If line clear:
   - Clear row
   - Move pieces down
   - Emit line_cleared signal
   - Damage enemy
   - Check power-up spawn (setiap 3 lines)
   ↓
8. Spawn tetromino baru
   ↓
9. Loop ke step 3
```

### 💔 Damage & Respawn Flow

```
1. Player collision dengan Piece (Area2D)
   ↓
2. HitDetector detect → _on_hit_detector_area_entered()
   ↓
3. take_damage(1)
   ↓
4. HP -= 1
   ↓
5. Emit hp_changed signal
   ↓
6. UI update HP display
   ↓
7. If HP > 0:
   - respawn_to_safe_position()
   - Set invulnerable (1.5s)
   - Blinking effect
   ↓
8. If HP = 0:
   - die()
   - Emit player_died signal
   - Slow motion (time_scale 0.5)
   - Reload scene
```

### 🎁 Power-Up Flow

```
1. Line cleared (3x total)
   ↓
2. spawn_random_powerup()
   ↓
3. Power-up spawn di atas, jatuh ke bawah
   ↓
4. Player collision dengan power-up
   ↓
5. Apply effect:
   - DOUBLE_JUMP: Reset jump count
   - INVINCIBLE: Set invulnerable 3s
   ↓
6. Power-up queue_free()
```

---

## 6. KONTROL GAME

### ⌨️ Player Controls

| Action | Key | Function |
|--------|-----|----------|
| Move Left | A | Gerak kiri (SPEED: 130) |
| Move Right | D | Gerak kanan (SPEED: 130) |
| Jump | Space | Lompat (VELOCITY: -300) |
| Double Jump | Space (udara) | Lompat kedua |
| Dash | J | Dash cepat (SPEED: 400, cooldown 2s) |

### 🎮 Tetris Controls

| Action | Key | Function |
|--------|-----|----------|
| Move Left | ← | Geser tetromino kiri |
| Move Right | → | Geser tetromino kanan |
| Soft Drop | ↓ | Turun cepat |
| Hard Drop | Space | Langsung jatuh |
| Rotate Left | Q | Putar counter-clockwise |
| Rotate Right | E | Putar clockwise |

### 🎁 Power-Up Controls

| Action | Key | Function |
|--------|-----|----------|
| Use Power-up 1 | J | Gunakan power-up slot 1 |
| Use Power-up 2 | K | Gunakan power-up slot 2 |

**Note:** Saat ini power-up auto-apply saat pickup, tidak perlu press J/K.

---

## 7. TROUBLESHOOTING

### ❌ Masalah Umum & Solusi

#### **1. Player Jatuh Terus (Void)**
**Penyebab:** Ground position salah atau player spawn di bawah ground.

**Solusi:**
- Ground position: Vector2(0, 590)
- Player position: Vector2(-16, 480)
- Player harus di ATAS ground (480 < 590)

#### **2. Player Tembus Balok**
**Penyebab:** Piece tidak punya StaticBody2D Platform.

**Solusi:**
- Check piece.tscn
- Pastikan ada child node: Platform (StaticBody2D)
- Platform collision_layer = 1

#### **3. HP Display Tidak Update**
**Penyebab:** Signal tidak connected atau UI node path salah.

**Solusi:**
- Check spawner.gd: `player.hp_changed.connect(on_player_hp_changed)`
- Check ui.gd node path: `$MCPanel/VBoxContainer/HPLabel`
- Check console: "update_hp_display called with HP: X"

#### **4. Player Tidak Damage**
**Penyebab:** HitDetector collision_mask salah atau Piece collision_layer salah.

**Solusi:**
- HitDetector collision_mask = 4
- Piece (Area2D) collision_layer = 4
- Check signal connection: `area_entered` → `_on_hit_detector_area_entered`

#### **5. Power-Up Tidak Spawn**
**Penyebab:** hit_count tidak reset atau powerup_scene null.

**Solusi:**
- Check spawner.gd: `hit_count >= 3`
- Check powerup_scene preload: `preload("res://Scenes/powerup.tscn")`
- Check console: "Power-up spawned!"

#### **6. Animasi Tidak Berubah**
**Penyebab:** Animasi _hurt/_critical tidak ada di SpriteFrames.

**Solusi:**
- Check player.tscn → AnimatedSprite2D → SpriteFrames
- Pastikan ada animasi: idle_hurt, run_hurt, jump_hurt, idle_critical, run_critical, jump_critical
- Jika tidak ada, player akan jadi balok warna (placeholder)

---

## 8. PENGEMBANGAN SELANJUTNYA

### 🚀 Fitur Yang Belum Diimplementasikan

#### **A. Visual Health (Priority: HIGH)**
**Task:**
1. Buat sprite untuk HP 2/3 (pusing)
2. Buat sprite untuk HP 1/3 (sekarat)
3. Replace placeholder balok warna di player.tscn
4. Update mc_portraits dictionary di ui.gd

**File:**
- `assets/player_hurt_idle.png`, `player_hurt_run.png`, `player_hurt_jump.png`
- `assets/player_critical_idle.png`, `player_critical_run.png`, `player_critical_jump.png`

#### **B. MC & Enemy Portrait (Priority: MEDIUM)**
**Task:**
1. Buat portrait MC (normal, pusing, sekarat)
2. Buat portrait Enemy
3. Load texture di ui.gd `_ready()`

**Code:**
```gdscript
# Di ui.gd _ready()
mc_portraits[3] = preload("res://assets/mc_normal.png")
mc_portraits[2] = preload("res://assets/mc_pusing.png")
mc_portraits[1] = preload("res://assets/mc_sekarat.png")
enemy_portrait.texture = preload("res://assets/enemy.png")
```

#### **C. Dynamic Map (Priority: MEDIUM)**
**Task:**
1. Penyempitan arena berdasarkan HP/waktu
2. Update tetromino bounds saat arena menyempit

**Logic:**
```gdscript
# Di board.gd atau spawner.gd
func shrink_arena():
	tetromino.bounds["min_x"] += 58  # Sempit dari kiri
	tetromino.bounds["max_x"] -= 58  # Sempit dari kanan
```

#### **D. Special Blocks (Priority: LOW)**
**Task:**
1. Blok yang tidak bisa scoring di vertical line samping
2. Spawn saat enemy hit 3, 5, 7

**Logic:**
```gdscript
# Di board.gd
var special_blocks = []
func spawn_special_block():
	# Spawn di kolom 0 atau 9 (paling samping)
	pass
```

#### **E. Dialog System (Priority: LOW)**
**Task:**
1. Integrasi Dialogic plugin
2. Buat timeline untuk story
3. Trigger dialog saat event tertentu

**File:**
- Dialogic sudah terinstall di `addons/dialogic/`
- Buat timeline di Dialogic editor

#### **F. Level Progression (Priority: LOW)**
**Task:**
1. Level 1: Introduction
2. Level 2: Enemy Ability (Lightning, Bomb)
3. Level 3: Arena sempit dari awal

**Logic:**
```gdscript
# Di spawner.gd atau main.gd
var current_level = 1
func load_level(level_number):
	match level_number:
		1: setup_level_1()
		2: setup_level_2()
		3: setup_level_3()
```

---

## 📊 SUMMARY

### ✅ Status Implementasi

| Fitur | Status | Priority |
|-------|--------|----------|
| Player Movement | ✅ Selesai | - |
| Health System | ✅ Selesai | - |
| Collision System | ✅ Selesai | - |
| Respawn System | ✅ Selesai | - |
| UI Display | ✅ Selesai | - |
| Scoring System | ✅ Selesai | - |
| Power-Up System | ✅ Selesai | - |
| Tetris Mechanic | ✅ Selesai | - |
| Visual Health Sprites | ❌ Belum | HIGH |
| MC/Enemy Portrait | ❌ Belum | MEDIUM |
| Dynamic Map | ❌ Belum | MEDIUM |
| Special Blocks | ❌ Belum | LOW |
| Dialog System | ❌ Belum | LOW |
| Level Progression | ❌ Belum | LOW |

### 📁 File Summary

**Modified:** 6 files
- script/player.gd
- script/ui.gd
- script/spawner.gd
- script/board.gd
- Scenes/piece.tscn
- Scenes/main.tscn

**Created:** 2 files
- script/powerup.gd
- Scenes/powerup.tscn

**Total Lines Changed:** ~200 lines

---

## 🎯 QUICK START GUIDE

### Untuk Developer Baru:

1. **Clone/Pull Project**
2. **Buka di Godot 4.5**
3. **Run Scene (F5)**
4. **Test Fitur:**
   - Player movement (A/D/Space/J)
   - Tetris controls (Arrow keys/Q/E/Space)
   - Damage system (tertimpa balok)
   - Respawn system (HP berkurang)
   - Power-up (clear 3 lines)

5. **Baca Dokumentasi:**
   - Struktur project (section 1)
   - Sistem collision (section 4)
   - Troubleshooting (section 7)

6. **Mulai Development:**
   - Pilih fitur dari section 8
   - Follow naming convention: lowercase_with_underscore
   - Test sebelum commit

---

## 📞 KONTAK & SUPPORT

**Project:** Tetris Action Survival  
**Engine:** Godot 4.5  
**Naming Convention:** lowercase_with_underscore  
**Documentation:** README_LENGKAP.md

**Catatan:**
- Semua function menggunakan lowercase_with_underscore
- Signal handlers menggunakan on_signal_name
- Placeholder animasi (balok warna) bukan bug!
- Ground position: 590, Player position: 480

---


Dokumentasi ini mencakup semua yang dikerjakan dari awal hingga akhir.
Untuk melanjutkan development, lihat section 8: Pengembangan Selanjutnya.
