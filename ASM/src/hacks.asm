; Prevent Kokiri Sword from being added to inventory on game load
; Replaces:
;   sh      t9, 0x009C (v0)
.org 0xBAED6C ; In memory: 0x803B2B6C
    nop

;==================================================================================================
; Time Travel
;==================================================================================================


; Replaces:
;   jal     8006FDCC ; Give Item
.org 0xCB6874 ; Bg_Toki_Swd addr 809190F4 in func_8091902C
    jal	    give_master_sword

; Replaces:
;   lui/addiu a1, 0x8011A5D0
.org 0xAE5764
    j       before_time_travel
    nop

; After time travel
; Replaces:
;   jr      ra
.org 0xAE59E0 ; In memory: 0x8006FA80
    j       after_time_travel

;==================================================================================================
; Item Overrides
;==================================================================================================

; Patch NPCs to give override-compatible items
.org 0xDB13D3 :: .byte 0x76 ; Frog Ocarina Game
.org 0xDF264F :: .byte 0x76 ; Ocarina memory game
.org 0xE2F093 :: .byte 0x34 ; Bombchu Bowling Bomb Bag
.org 0xEC9CE7 :: .byte 0x7A ; Deku Theater Mask of Truth

; Runs when storing the pending item to the player instance
; Replaces:
;   sb      a2, 0x0424 (a3)
;   sw      a0, 0x0428 (a3)
.org 0xA98C30 ; In memory: 0x80022CD0
    jal     store_item_data_hook
    sw      a0, 0x0428 (a3)

; Override object ID (NPCs)
; Replaces:
;   lw      a2, 0x0030 (sp)
;   or      a0, s0, r0
;   jal     ...
;   lh      a1, 0x0004 (a2)
.org 0xBDA0D8 ; In memory: 0x803950C8
    jal     override_object_npc
    or      a0, s0, r0
.skip 4
    nop

; Override object ID (Chests)
; Replaces:
;   lw      t9, 0x002C (sp)
;   or      a0, s0, r0
;   jal     ...
;   lh      a1, 0x0004 (t9)
.org 0xBDA264 ; In memory: 0x80395254
    jal     override_object_chest
    or      a0, s0, r0
.skip 4
    nop

; Override graphic ID
; Replaces:
;   bltz    v1, A
;   subu    t0, r0, v1
;   jr      ra
;   sb      v1, 0x0852 (a0)
; A:
;   sb      t0, 0x0852 (a0)
;   jr      ra
.org 0xBCECBC ; In memory: 0x80389CAC
    j       override_graphic
    nop
    nop
    nop
    nop
    nop

; Override text ID
; Replaces:
;   lbu     a1, 0x03 (v0)
;   sw      a3, 0x0028 (sp)
.org 0xBE9AC0 ; In memory: 0x803A4AB0
    jal     override_text
    sw      a3, 0x0028 (sp)

; Override action ID
; Replaces:
;   lw      v0, 0x0024 (sp)
;   lw      a0, 0x0028 (sp)
;   jal     0x8006FDCC
;   lbu     a1, 0x0000 (v0)
.org 0xBE9AD8 ; In memory: 0x803A4AC8
    jal     override_action
    lw      a0, 0x0028 (sp)
.skip 4
    nop

; Inventory check
; Replaces:
;   jal     0x80071420
;   sw      a2, 0x0030 (sp)
.org 0xBDA0A0 ; In memory: 0x80395090
    jal     inventory_check
    sw      a2, 0x0030 (sp)

; Prevent Silver Gauntlets warp
; Replaces:
;   addiu   at, r0, 0x0035
.org 0xBE9BDC ; In memory: 0x803A4BCC
    addiu   at, r0, 0x8383 ; Make branch impossible



; Change Skulltula Token to give a different item
; Replaces
;    move    a0,s1
;    jal     0x0006fdcc                              ; call ex_06fdcc(ctx, 0x0071); VROM: 0xAE5D2C
;    li      a1,113
;    lw      t5,44(sp)                               ; t5 = what was *(ctx + 0x1c44) at the start of the function
;    li      t4,10                                   ; t4 = 0x0a
;    move    a0,s1
;    li      a1,180                                  ; at = 0x00b4 ("You destoryed a Gold Skulltula...")
;    move    a2,zero
;    jal     0x000dce14                              ; call ex_0dce14(ctx, 0x00b4, 0)
;    sh      t4,272(t5)                              ; *(t5 + 0x110) = 0x000a
.org 0xEC68BC
.area 0x28, 0
    lw      t5,44(sp)                    ; original code
    li      t4,10                        ; original code
    sh      t4,272(t5)                   ; original code
    jal     override_skulltula_token     ; call override_skulltula_token(_, actor)
    move    a1,s0
.endarea

.org 0xEC69AC
.area 0x28, 0
    lw      t5,44(sp)                    ; original code
    li      t4,10                        ; original code
    sh      t4,272(t5)                   ; original code
    jal     override_skulltula_token     ; call override_skulltula_token(_, actor)
    move    a1,s0
.endarea

;==================================================================================================
; Every frame hooks
;==================================================================================================

; Runs before the game state updates
; Replaces:
;   lw      t9, 0x0004 (s0)
;   or      a0, s0, r0
.org 0xB16B50 ; In memory: 0x800A0BF0
    jal     before_game_state_update
    nop

; Runs after the game state updates
; Replaces:
;   lui     t6, 0x8012
;   lbu     t6, 0x1212 (t6)
.org 0xB16B60 ; In memory: 0x800A0C00
    jal     after_game_state_update
    nop

;==================================================================================================
; File select hash
;==================================================================================================

; Runs after the file select menu is rendered
; Replaces: code that draws the fade-out rectangle on file load
.org 0xBAF738 ; In memory: 0x803B3538
.area 0x60, 0
    jal     draw_file_select_hash
    andi    a0, t8, 0xFF ; a0 = alpha channel of fade-out rectangle

    lw      s0, 0x18 (sp)
    lw      ra, 0x1C (sp)
    jr      ra
    addiu   sp, sp, 0x88
.endarea

;==================================================================================================
; Special item sources
;==================================================================================================

; Override Light Arrow cutscene
; Replaces:
;   addiu   t8, r0, 0x0053
;   ori     t9, r0, 0xFFF8
;   sw      t8, 0x0000 (s0)
;   b       0x80056F84
;   sw      t9, 0x0008 (s0)
.org 0xACCE88 ; In memory: 0x80056F28
    jal     override_light_arrow_cutscene
    nop
    nop
    nop
    nop

; Make all Great Fairies give an item
; Replaces:
;   jal     0x8002049C
;   addiu   a1, r0, 0x0038
.org 0xC89744 ; In memory: 0x801E3884
    jal     override_great_fairy_cutscene
    addiu   a1, r0, 0x0038

; Upgrade fairies check scene chest flags instead of magic/defense
; Mountain Summit Fairy
; Replaces:
;   lbu     t6, 0x3A (a1)
.org 0xC89868 ; In memory: 0x801E39A8
    lbu     t6, 0x1D28 (s0)
; Crater Fairy
; Replaces:
;   lbu     t9, 0x3C (a1)
.org 0xC898A4 ; In memory: 0x801E39E4
    lbu     t9, 0x1D29 (s0)
; Ganon's Castle Fairy
; Replaces:
;   lbu     t2, 0x3D (a1)
.org 0xC898C8 ; In memory: 0x801E3A08
    lbu     t2, 0x1D2A (s0)

; Upgrade fairies never check for magic meter
; Replaces:
;   lbu     t6, 0xA60A (t6)
.org 0xC892DC ; In memory: 0x801E341C
    li      t6, 1

; Item fairies never check for magic meter
; Replaces:
;   lbu     t2, 0xA60A (t2)
.org 0xC8931C ; In memory: 0x801E345C
    li      t2, 1

;==================================================================================================
; Pause menu
;==================================================================================================

; Create a blank texture, overwriting a Japanese item description
.org 0x89E800
.fill 0x400, 0

; Use a blank item description texture if the cursor is on an empty slot
; Replaces:
;   sll     t4, v1, 10
;   addu    a1, t4, t5
.org 0xBC088C ; In memory: 0x8039820C
    jal     menu_use_blank_description
    nop

;==================================================================================================
; Equipment menu
;==================================================================================================

; Left movement check
; Replaces:
;   beqz    t3, 0x8038D9FC
;   nop
.org 0xBB5EAC ; In memory: 0x8038D834
    nop
    nop

; Right movement check
; Replaces:
;   beqz    t3, 0x8038D9FC
;   nop
.org 0xBB5FD4 ; In memory: 0x8038D95C
nop
nop

; Upward movement check
; Replaces:
;   beqz    t6, 0x8038DB90
;   nop
.org 0xBB6134 ; In memory: 0x8038DABC
nop
nop

; Downward movement check
; Replaces:
;   beqz    t9, 0x8038DB90
;   nop
.org 0xBB61E0 ; In memory: 0x8038DB68
nop
nop

; Remove "to Equip" text if the cursor is on an empty slot
; Replaces:
;   lbu     v1, 0x0000 (t4)
;   addiu   at, r0, 0x0009
.org 0xBB6688 ; In memory: 0x8038E008
    jal     equipment_menu_prevent_empty_equip
    nop

; Prevent empty slots from being equipped
; Replaces:
;   addu    t8, t4, v0
;   lbu     v1, 0x0000 (t8)
.org 0xBB67C4 ; In memory: 0x8038E144
    jal     equipment_menu_prevent_empty_equip
    addu    t4, t4, v0

;==================================================================================================
; Item menu
;==================================================================================================

; Left movement check
; Replaces:
;   beq     s4, t5, 0x8038F2B4
;   nop
.org 0xBB77B4 ; In memory: 0x8038F134
    nop
    nop

; Right movement check
; Replaces:
;   beq     s4, t4, 0x8038F2B4
;   nop
.org 0xBB7894 ; In memory: 0x8038F214
    nop
    nop

; Upward movement check
; Replaces:
;   beq     s4, t4, 0x8038F598
;   nop
.org 0xBB7BA0 ; In memory: 0x8038F520
    nop
    nop

; Downward movement check
; Replaces:
;   beq     s4, t4, 0x8038F598
;   nop
.org 0xBB7BFC ; In memory: 0x8038F57C
    nop
    nop

; Remove "to Equip" text if the cursor is on an empty slot
; Replaces:
;   addu    s1, t6, t7
;   lbu     v0, 0x0000 (s1)
.org 0xBB7C88 ; In memory: 0x8038F608
    jal     item_menu_prevent_empty_equip
    addu    s1, t6, t7

; Prevent empty slots from being equipped
; Replaces:
;   lbu     v0, 0x0000 (s1)
;   addiu   at, r0, 0x0009
.org 0xBB7D10 ; In memory: 0x8038F690
    jal     item_menu_prevent_empty_equip
    nop

;==================================================================================================
; Song Fixes
;==================================================================================================

; Replaces:
;   lw      t5, 0x8AA0(t5)
.org 0xAE5DF0 ; In memory: 8006FE90
    jal     suns_song_fix

; Replaces:
;   addu    at, at, s3
.org 0xB54E5C ; In memory: 800DEEFC
    jal     suns_song_fix_event

; Replaces:
;   addu    at, at, s3
.org 0xB54B38 ; In memory: 800DEBD8
    jal     warp_song_fix

;==================================================================================================
; Initial save
;==================================================================================================

; Replaces:
;   sb      t0, 32(s1)
;   sb      a1, 33(s1)
.org 0xB06C2C ; In memory: ???
    jal     write_initial_save
    sb      t0, 32(s1)

;==================================================================================================
; Enemy Hacks
;==================================================================================================

; Replaces:
;   beq t1, at, 0x801E51E0
.org 0xD74964     ; In memory: 0x801E51B4
    b skip_steal_tunic  ; disable like-like stealing tunic
.org 0xD74990
    skip_steal_tunic:

;==================================================================================================
; Ocarina Song Cutscene Overrides
;==================================================================================================

; Replaces
;   addu    t8,t0,t7
;   sb      t6,0x74(t8)  ; store to fairy ocarina slot
.org 0xAE6E48
    jal     override_fairy_ocarina_cutscene
    addu    t8,t0,t7

; a3 = item ID
; Replaces
; li v0,0xFF
.org 0xAE5DF8
    jal     override_ocarina_songs
; sw $t7, 0xa4($t0)
.org 0xAE5E04
    nop

; Replaces
;lui  at,0x1
;addu at,at,s0
.org 0xAC9ABC
    jal     override_requiem_song
    nop

;lw $t7, 0xa4($v1)
;lui $v0, 0x200
;addiu $v0, $v0, 0x24a0
;and $t8, $t6, $t7
.org 0xE09F68
    lb  t7,0x0EDE(v1) ; check learned song from sun's song
.skip 4
.skip 4
    andi t8, t7, 0x04
;addiu $t7, $zero, 1
.org 0xE09FB0
    jal override_suns_song

; lw $t7, 0xa4($s0)
; lui $t3, 0x8010
; addiu $t3, $t3, -0x70cc
; and $t8, $t6, $t7
.org 0xB06400
    lb  t7,0x0EDE(s0) ; check learned song from ZL
.skip 4
.skip 4
    andi t8, t7, 0x02

; Impa does not despawn from Zelda Escape CS
.org 0xD12F78
    li  t7, 0

;li v1, 5
.org 0xE29388
    j   override_saria_song_check

;lh v0, 0xa4(t6)       ; v0 = scene
.org 0xE2A044
    jal  set_saria_song_flag

; li a1, 3
.org 0xDB532C
    jal override_song_of_time

;==================================================================================================
; Fire Arrow Chest
;==================================================================================================

; Don't require water temple
;   bne     t9,at,+0x0024
.org 0xE9E1D8
    li      t1, 0x4000

; Load chest contents
;   li      t0, 0x0007
.org 0xE9E1F0
    li      t0, 0x5B08

; Load actor type
;   li      a2, 0x010f
.org 0xE9E200
    li      a2, 0x000A

; Set rotation
;   sw      zero, 0x1C (sp)
.org 0xE9E20C
    sw      t1, 0x1C (sp)

;==================================================================================================
; Epona Check Override
;==================================================================================================
.org 0xA9E838
    j       Check_Has_Epona_Song

;==================================================================================================
; Shop Injections
;==================================================================================================

; Check sold out override
.org 0xC004EC
    j        Shop_Check_Sold_Out

; Allow Shop Item ID up to 100 instead of 50
; slti at, v1, 0x32
.org 0xC0067C
    slti     at, v1, 100

; Set sold out override
; lh t6, 0x1c(a1)
.org 0xC018A0
    jal      Shop_Set_Sold_Out

; Only run init function if ID is in normal range
; jr t9
.org 0xC6C7A8
    jal      Shop_Keeper_Init_ID
.org 0xC6C920
    jal      Shop_Keeper_Init_ID

; Override Deku Salescrub sold out check
; addiu at, zero, 2
; lui v1, 0x8012
; bne v0, at, 0xd8
; addiu v1, v1, -0x5a30
; lhu t9, 0xef0(v1)
.org 0xEBB85C
    jal     Deku_Check_Sold_Out
    .skip 4
    bnez    v0, @Deku_Check_True
    .skip 4
    b       @Deku_Check_False
.org 0xEBB8B0
@Deku_Check_True:
.org 0xEBB8C0
@Deku_Check_False:

; Ovveride Deku Scrub set sold out
; sh t7, 0xef0(v0)
.org 0xDF7CB0
    jal     Deku_Set_Sold_Out

;==================================================================================================
; Dungeon info display
;==================================================================================================

; Talk to Temple of Time Altar injection
; Replaces:
;   jal     0xD6218
.org 0xE2B0B4
    jal     set_dungeon_knowledge


;==================================================================================================
; V1.0 Scarecrow Song Bug
;==================================================================================================

; Replaces:
;   jal     0x80057030 ; copies Scarecrow Song from active space to save context
.org 0xB55A64 ; In memory 800DFB04
    jal     save_scarecrow_song

;==================================================================================================
; Override Player Name Text
;==================================================================================================

; Replaces
;   lui   t2,0x8012
;   addu  t2,t2,s3
;   lbu   t2,-23053(t2)
.org 0xB51694
    jal     get_name_char_1
    ;addi    a0, s3, -1
    ;ori     t2, v0, 0

; Replaces
;   lui   s0,0x8012
;   addu  s0,s0,s2
;   lbu   s0,-23052(s0)
.org 0xB516C4
    jal     get_name_char_2
    ;ori     a0, s2, 0
    ;ori     s0, v0, 0

; Replaces
;   lw      s6,48(sp)
;   lw      s7,52(sp)
;   lw      s8,56(sp)
.org 0xB52784
    jal     reset_player_name_id
    nop
    lw      ra, 0x3C (sp)

;==================================================================================================
; Text Fixes
;==================================================================================================

; Skip text overrides for GS Token and Biggoron Sword
; Replaces
;   li      at, 0x0C
.org 0xB5293C
    b       skip_GS_BGS_text
.org 0xB529A0
skip_GS_BGS_text:
