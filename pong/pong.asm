    .inesprg 1
    .ineschr 1
    .inesmap 0
    .inesmir 1

    .rsset $0000
direction .rs 1 ; 0 0 (f 0 is top left, f f is top right, 0 f is bottom right)
speedx    .rs 1 ; speed x
speedy    .rs 1 ; speed y
buttons   .rs 1 ; currently pressed buttons

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
    LDA marioSprites, X ; also loading brickSprites (happens to be right after mario)
    STA $0200, X ; here shall stay the sprites
    INX
    CPX #$20 ; 32  16 Mario + 16 brick
    BNE LoadSpritesLoop

StartCode:
    LDA #$0f ; set direction as down right
    STA direction
    LDA #$02
    STA speedx
    LDA #$03
    STA speedy



Forever:
    JMP Forever




; subroutines here!!!

IncXBy4:
    INX
    INX
    INX
    INX
    RTS

CollectInput:
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016 ; now controller gives current button bit
    LDX #$8
CollectInputLoop:
    LDA $4016
    LSR A
    ROL buttons
    DEX
    BNE CollectInputLoop
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
    ADC speedy
    STA $0200, X
    JSR IncXBy4
    CPX #$10
    BNE MarioDn
    JMP DoneDU
MarioUp:
    LDA $0200, X
    SEC
    SBC speedy
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
    ADC speedx
    STA $0203, X
    JSR IncXBy4
    CPX #$10
    BNE MarioLe
    JMP DoneLR
MarioRi:
    LDA $0203, X
    SEC
    SBC speedx
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
    CMP #$ec
    BCC NoFlip3 ;if coords is less than #$e0
    LDA direction
    AND #$f0
    STA direction
NoFlip3:
    LDA $0203
    CMP #$03
    BCS NoFlip4 ;if coords is more than #$04
    LDA direction
    ORA #$0f
    STA direction
NoFlip4:


;;;;;; input
    JSR CollectInput
    LDA buttons
    AND #$01
    BNE RightPressed
    LDA buttons
    AND #$02
    BNE LeftPressed
    ;AND #$04
    ;BNE DnPressed
    ;AND #$08
    ;BNE UpPressed
    JMP DoneMove
RightPressed:
    LDX #$00; before anything we set X as 0
RightPressedLoop:
    LDA $0213, X ; adress of block
    CLC
    ADC #$02
    STA $0213, X
    INX
    INX
    INX
    INX
    CPX #$10
    BNE RightPressedLoop
    JMP DoneMove
    LDX #$00; before anything we set X as 0
LeftPressed:
    LDA $0213, X ; adress of block
    SEC
    SBC #$02
    STA $0213, X
    INX
    INX
    INX
    INX
    CPX #$10
    BNE LeftPressed
DoneMove:

Collision:
CollisionYEval:
    LDA #$D0
    SEC
    SBC #$10
    CMP $0200
    BCS NoHit
    
CollisionXEval:
    LDA $0213
    CMP $0207
    BCS NoHit
    
    LDA $021f
    CMP $0207
    BCC NoHit
CollisionPositive:
    LDA direction
    ORA #$f0
    STA direction
NoHit:


    RTI
; NMI DONE






    .bank 1
    .ORG $E000
pallete:
    .DB $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F ;background
	.DB $0F,$16,$36,$30,$0F,$0F,$30,$16,$0F,$1C,$15,$14,$0F,$02,$38,$3C ;foregrounds
marioSprites:
	; 80, 0, 0, 80 (y pos, tile number, color pallete no flipping etc, x pos)
    .DB $81, $32, $00, $61
	.DB $81, $33, $00, $69
	.DB $89, $34, $00, $61
	.DB $89, $35, $00, $69

brickSprites:
    .DB $d0, $86, $00, $80
    .DB $d0, $86, $00, $88
    .DB $d0, $86, $00, $90
    .DB $d0, $86, $00, $98
        

    .ORG $FFFA
    .DW NMI
    .DW RESET
    .DW 0


    .bank 2
    .ORG $0000
    .incbin "chr/mario.chr"