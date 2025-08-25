    .inesprg 1
    .ineschr 1
    .inesmap 0
    .inesmir 1

    .rsset $0000
direction .rs 1 ; 0 0 (f 0 is top left, f f is top right, 0 f is bottom right)


    .bank 0
    .ORG $C000
RESET:
    SEI
    CLD

SetupPPU:
    ; set PPU addr as 3f00
    LDA $2002
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
; clear OAM before start
    LDA #$FF
    LDX #$00
ClearOAMLoop:
    STA $0200, X
    INX
    BNE ClearOAMLoop
; set the pallet
    LDX #$00
LoadPalleteLoop:
    LDA pallete, X
    STA $2007 ; load pallete to 2007
    INX
    CPX #$20 ; "compare X"
    BNE LoadPalleteLoop

    ; set some PPU settings
    LDA #%10000000
    STA $2000
    LDA #%00010110
    STA $2001

; load the sprites in the center
    LDX #$00
LoadSpritesLoop:
    LDA sprites, X
    STA $0200, X ; here shall stay the sprites
    INX
    CPX #$10 ; 16
    BNE LoadSpritesLoop

StartCode:
    LDA #$0f ; set direction as down right
    STA direction



Forever:
    JMP Forever




; subroutines here!!!

IncXBy4:
    INX
    INX
    INX
    INX
    RTS






NMI: ; when ppu waiting
    ; start DMA transfer
    LDA #$00
    STA $2003
    LDA #$02
    STA $4014

GameLoop:
    ; move ball
    LDX #$00
DrawMario1: ; if direction is f0 then do up code else down
    LDA direction
    AND #$f0
    BNE MarioUp
    JMP MarioDn ; for readability
MarioDn:
    LDA $0200, X
    CLC
    ADC #$02
    STA $0200, X
    JSR IncXBy4
    CPX #$10
    BNE MarioDn
    JMP DoneDU
MarioUp:
    LDA $0200, X
    SEC
    SBC #$02
    STA $0200, X
    JSR IncXBy4
    CPX #$10
    BNE MarioUp
DoneDU

    LDX #$00
DrawMario2:
    LDA direction
    AND #$0f
    BEQ MarioRi
    JMP MarioLe
MarioLe:
    LDA $0203, X
    CLC
    ADC #$01
    STA $0203, X
    JSR IncXBy4
    CPX #$10
    BNE MarioLe
    JMP DoneLR
MarioRi:
    LDA $0203, X
    SEC
    SBC #$01
    STA $0203, X
    JSR IncXBy4
    CPX #$10
    BNE MarioRi
DoneLR:
    
;;;;; Collision Check
    LDA $0200
    CMP #$e0
    BCC NoFlip1 ;if coords is less than #$e0
    LDA direction
    ORA #$f0
    STA direction
NoFlip1:
    LDA $0200
    CMP #$04
    BCS NoFlip2 ;if coords is more than #$04
    LDA direction
    AND #$0f
    STA direction
NoFlip2:
    LDA $0203
    CMP #$e0
    BCC NoFlip3 ;if coords is less than #$e0
    LDA direction
    AND #$f0
    STA direction
NoFlip3:
    LDA $0203
    CMP #$04
    BCS NoFlip4 ;if coords is more than #$04
    LDA direction
    ORA #$0f
    STA direction
NoFlip4:


    RTI
; NMI DONE


    .bank 1
    .ORG $E000
pallete:
    .DB $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F ;background
	.DB $0F,$16,$36,$0F,$0F,$0F,$30,$16,$0F,$1C,$15,$14,$0F,$02,$38,$3C ;foregrounds
sprites:
	; 80, 0, 0, 80 (y pos, tile number, color pallete no flipping etc, x pos)
	.DB $81, $32, $00, $61
	.DB $81, $33, $00, $69
	.DB $89, $34, $00, $61
	.DB $89, $35, $00, $69


    .ORG $FFFA
    .DW NMI
    .DW RESET
    .DW 0


    .bank 2
    .ORG $0000
    .incbin "chr/mario.chr"