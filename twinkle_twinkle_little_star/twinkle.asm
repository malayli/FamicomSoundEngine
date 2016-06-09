frame=266
notelength=282
which_element=283
counter = 284
table_index = 285

A0 = $0A
B0 = $0B
C0 = $0C
D0 = $0D
E0 = $0E
F0 = $0F
G0 = $10
H0 = $11
I0 = $12
J0 = $13
K0 = $14
L0 = $15
M0 = $16
N0 = $17
O0 = $18
P0 = $19
Q0 = $1A
R0 = $1B
S0 = $1C
T0 = $1D
U0 = $1E
V0 = $1F
W0 = $20
X0 = $21
Y0 = $22
Z0 = $23

;Note: octaves in music traditionally start at C, not A

; Octave 1
A1 = $00    ;the "1" means Octave 1
As1 = $01   ;the "s" means "sharp"
Bb1 = $01   ;the "b" means "flat"  A# == Bb, so same value
B1 = $02

; Octave 2
C2 = $03 ; Do
Cs2 = $04
Db2 = $04
D2 = $05 ; Ré
Ds2 = $06
Eb2 = $06
E2 = $07 ; Mi
F2 = $08 ; Fa
Fs2 = $09
Gb2 = $09
G2 = $0A ; Sol
Gs2 = $0B
Ab2 = $0B
A2 = $0C ; La
As2 = $0D
Bb2 = $0D
B2 = $0E ; Si

; Octave 3
C3 = $0F ; Do
Cs3 = $10
Db3 = $10
D3 = $11 ; Ré
Ds3 = $12
Eb3 = $12
E3 = $13 ; Mi
F3 = $14 ; Fa
Fs3 = $15
Gb3 = $15
G3 = $16 ; Sol
Gs3 = $17
Ab3 = $17
A3 = $18 ; La
As3 = $19
Bb3 = $19
B3 = $1a ; Si

; Octave 4
C4 = $1b ; Do
Cs4 = $1c
Db4 = $1c
D4 = $1d ; Ré
Ds4 = $1e
Eb4 = $1e
E4 = $1f ; Mi
F4 = $20 ; Fa
Fs4 = $21
Gb4 = $21
G4 = $22 ; Sol
Gs4 = $23
Ab4 = $23
A4 = $24 ; La
As4 = $25
Bb4 = $25
B4 = $26 ; Si

; Octave 5
C5 = $27 ; Do
Cs5 = $28
Db5 = $28
D5 = $29 ; Ré
Ds5 = $2a
Eb5 = $2a
E5 = $2b ; Mi
F5 = $2c ; Fa
Fs5 = $2d
Gb5 = $2d
G5 = $2e ; Sol
Gs5 = $2f
Ab5 = $2f
A5 = $30 ; La
As5 = $31
Bb5 = $31
B5 = $32 ; Si

; Octave 6
C6 = $33 ; Do
Cs6 = $34
Db6 = $34
D6 = $35
Ds6 = $36
Eb6 = $36
E6 = $37
F6 = $38
Fs6 = $39
Gb6 = $39
G6 = $3a
Gs6 = $3b
Ab6 = $3b
A6 = $3c
As6 = $3d
Bb6 = $3d
B6 = $3e

; Octave 7
C7 = $3f ; Do
Cs7 = $40
Db7 = $40
D7 = $41
Ds7 = $42
Eb7 = $42
E7 = $43
F7 = $44
Fs7 = $45
Gb7 = $45
G7 = $46
Gs7 = $47
Ab7 = $47
A7 = $48
As7 = $49
Bb7 = $49
B7 = $4a

; Octave 8
C8 = $4b ; Do
Cs8 = $4c
Db8 = $4c
D8 = $4d
Ds8 = $4e
Eb8 = $4e
E8 = $4f
F8 = $50
Fs8 = $51
Gb8 = $51
G8 = $52
Gs8 = $53
Ab8 = $53
A8 = $54
As8 = $55
Bb8 = $55
B8 = $56

; Octave 9
C9 = $57 ; Do
Cs9 = $58
Db9 = $58
D9 = $59
Ds9 = $5a
Eb9 = $5a
E9 = $5b
F9 = $5c
Fs9 = $5d
Gb9 = $5d

  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  

;;;;;;;;;;;;;;;

  .rsset $0000       ; put pointers in zero page
pointerLo  .rs 1   ; pointer variables are declared in RAM
pointerHi  .rs 1   ; low byte first, high byte immediately after


;;;;;;;;;;;;;;;
    
  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs
  jsr initsound

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2


LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down

  jsr musicsetup

LoadSprites:
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$10              ; Compare X to hex $10, decimal 16
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going down
              
              
              
LoadBackground:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$20
  STA $2006             ; write the high byte of $2000 address
  LDA #$00
  STA $2006             ; write the low byte of $2000 address

  LDA #$00
  STA pointerLo       ; put the low byte of the address of background into pointer

  LDA #HIGH(background)
  STA pointerHi       ; put the high byte of the address into pointer
  
  LDX #$00            ; start at pointer + 0
  LDY #$00
  
OutsideLoop:
  
InsideLoop:
  LDA [pointerLo], y  ; copy one background byte from address in pointer plus Y
  STA $2007           ; this runs 256 * 4 times
  
  INY                 ; inside loop counter
  CPY #$00
  BNE InsideLoop      ; run the inside loop 256 times before continuing down
  
  INC pointerHi       ; low byte went 0 to 256, so high byte needs to be changed now
  
  INX
  CPX #$04
  BNE OutsideLoop     ; run the outside loop 256 times before continuing down

              
              
              
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001

Forever:
 jsr musicloop
 jsr vwait
  JMP Forever     ;jump back to Forever, infinite loop
  
 vwait:
  BIT $2002
  BPL vwait

vwait2:
  lda $2002
  bmi vwait2 ;//wait for end of retrace
 inc frame
 rts

initsound:
 lda #0
 sta $4015

 lda #%00000111 ;enable Sq1, Sq2 and Tri channels
 sta $4015

 rts

musicsetup:
 lda #0
 sta notelength
 sta counter
 sta table_index
 sta which_element

 rts

loadx:
 lda table_index
 cmp #0
 bne loadx2
 lda music_data1, x
 rts

loadx2:
 ;lda music_data2, x
 rts

musicloop:
 lda notelength
 cmp #0
 beq play_note
 dec notelength

 rts

update_index:
 lda table_index
 cmp #1
 beq reset_index
 inc table_index
 rts

reset_index:
 lda #0
 sta table_index
 rts

play_note:
 ldx which_element
 jsr loadx
 sta notelength

 lda counter
 cmp #48 ; elements count
 bne start_note

 lda #0
 sta counter
 sta which_element

 jsr update_index

 ldx which_element
 jsr loadx
 sta notelength

start_note:
 inc counter

 lda notelength
 cmp #0

 bne write_note

 inc which_element
 inc which_element

 lda #0
 sta $4000
 sta $4001
 sta $4002
 sta $4003
 sta $4004
 sta $4005
 sta $4006
 sta $4007
 sta $4008
 sta $4009
 sta $400A
 sta $400B

 rts

write_note:
    inc which_element
    ldx which_element

    ; Volume

    jsr loadx
    sta $4000
    sta $4004

    lda #0
    sta $4008

    inx

    jsr loadx
    asl a               ;multiply by 2 because we are indexing into a table of words
    tay

    lda note_table, y
    sta $4002 ; Low

    lda note_table+1, y
    sta $4003 ; High

    jsr play_square2

    rts

play_square2:
    inx

    jsr loadx
    asl a               ;multiply by 2 because we are indexing into a table of words
    tay

    lda note_table, y
    sta $4006 ; Low

    lda note_table+1, y
    sta $4007 ; High

    jsr finish

    rts

finish:
    lda which_element
    clc
    adc #3
    sta which_element
    rts

NMI:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer


LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons


ReadA: 
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BEQ ReadADone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203       ; load sprite X position
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0203       ; save sprite X position
ReadADone:        ; handling this button is done
  

ReadB: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadBDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0203       ; save sprite X position
ReadBDone:        ; handling this button is done


  ;;This is the PPU clean up section, so rendering the next frame starts properly.
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA $2005
  STA $2005
  
  RTI             ; return from interrupt
 
;;;;;;;;;;;;;;  
  
  
  
  .bank 1
  .org $E000    ;;align the background data so the lower address is $00
background:
  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,T0,W0,I0,N0,K0,L0,E0,$24,T0,W0,I0,N0,K0,L0,E0,$24,L0,I0,T0,T0,L0,E0,$24,S0,T0,A0,R0,$24,$24,$24 ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;

attributes:  ;8 x 8 = 64 bytes
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
  .db %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
  .db %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
  .db %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

palette:
  .db $30,$30,$30,$FF,  $01,$02,$03,$00,  $01,$02,$03,$00,  $01,$02,$03,$00   ;;background palette
  .db $FF,$1C,$15,$14,  $22,$02,$38,$3C,  $22,$1C,$15,$14,  $22,$02,$38,$3C   ;;sprite palette

sprites:
     ;vert tile attr horiz
  .db $80, $32, $00, $80   ;sprite 0
  .db $80, $33, $00, $88   ;sprite 1
  .db $88, $34, $00, $80   ;sprite 2
  .db $88, $35, $00, $88   ;sprite 3

note_table:
    .word                                                                $07F1, $0780, $0713 ; A1-B1 ($00-$02)
    .word $06AD, $064D, $05F3, $059D, $054D, $0500, $04B8, $0475, $0435, $03F8, $03BF, $0389 ; C2-B2 ($03-$0E)
    .word $0356, $0326, $02F9, $02CE, $02A6, $027F, $025C, $023A, $021A, $01FB, $01DF, $01C4 ; C3-B3 ($0F-$1A)
    .word $01AB, $0193, $017C, $0167, $0151, $013F, $012D, $011C, $010C, $00FD, $00EF, $00E2 ; C4-B4 ($1B-$26)
    .word $00D2, $00C9, $00BD, $00B3, $00A9, $009F, $0096, $008E, $0086, $007E, $0077, $0070 ; C5-B5 ($27-$32)
    .word $006A, $0064, $005E, $0059, $0054, $004F, $004B, $0046, $0042, $003F, $003B, $0038 ; C6-B6 ($33-$3E)
    .word $0034, $0031, $002F, $002C, $0029, $0027, $0025, $0023, $0021, $001F, $001D, $001B ; C7-B7 ($3F-$4A)
    .word $001A, $0018, $0017, $0015, $0014, $0013, $0012, $0011, $0010, $000F, $000E, $000D ; C8-B8 ($4B-$56)
    .word $000C, $000C, $000B, $000A, $000A, $0009, $0008                                    ; C9-F#9 ($57-$5D)

music_data1: ; note length, volume, sign (not used), note value square 1, note value square 2, note value triangle
  .db 16,145,C5,0
  .db 16,145,C5,0
  .db 16,145,G5,0
  .db 16,145,G5,0

  .db 16,145,A5,0
  .db 16,145,A5,0
  .db 25,145,G5,0

  .db 16,145,F5,0
  .db 16,145,F5,0
  .db 16,145,E5,0
  .db 16,145,E5,0

  .db 16,145,D5,0
  .db 16,145,D5,0
  .db 25,145,C5,0

  .db 16,145,G5,0
  .db 16,145,G5,0
  .db 16,145,F5,0
  .db 16,145,F5,0

  .db 16,145,E5,0
  .db 16,145,E5,0
  .db 25,145,D5,0

  .db 16,145,G5,0
  .db 16,145,G5,0
  .db 16,145,F5,0
  .db 16,145,F5,0

  .db 16,145,E5,0
  .db 16,145,E5,0
  .db 25,145,D5,0

  .db 16,145,C5,0
  .db 16,145,C5,0
  .db 16,145,G5,0
  .db 16,145,G5,0

  .db 16,145,A5,0
  .db 16,145,A5,0
  .db 25,145,G5,0

  .db 16,145,F5,0
  .db 16,145,F5,0
  .db 16,145,E5,0
  .db 16,145,E5,0

  .db 16,145,D5,0
  .db 16,145,D5,0
  .db 25,145,C5,0

  .db 16,145,0,0
  .db 16,145,0,0
  .db 16,145,0,0
  .db 16,145,0,0
  .db 16,145,0,0
  .db 25,145,0,0

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
;;;;;;;;;;;;;;  
  
  
  .bank 2
  .org $0000
  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1