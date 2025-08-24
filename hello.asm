    .inesprg 1   ; 1x 16KB bank of PRG code
    .ineschr 1   ; 1x 8KB bank of CHR data
    .inesmap 0   ; mapper 0 = NROM, no bank swapping
    .inesmir 1   ; background mirroring (ignore for now)

;;;;;

    .bank 0
    .ORG $C000
RESET:
    SEI  ; disable IRQs
    CLD  ; disable decimal mode
	
	; set PPU address as $3F00
	LDA $2002 ; first read PPU status to reset latch to high
	LDA #$3F
	STA $2006
	LDA #$00
	STA $2006

; set pallet
	LDX #$00
LoadPalletesLoop:
	LDA PalleteData, X
	STA $2007
	INX
	CPX #$20 ; if == 32
	BNE LoadPalletesLoop ; if 32 then continue script
    LDA #%10000000 ; enable NMI
    STA $2000
	LDA #%00010000 ; no intensify
	STA $2001
	
LoadSprites:
	LDX #$00
LoadSpritesLoop:
	LDA sprites, X
	STA $0200, x
	INX
	CPX #$10
	BNE LoadSpritesLoop

LoadBackground:
	LDX #$00
LoadBackgroundLoop:
	LDA background, X
	STA $2007  ; ########################################################################### WTDF SECOND MENTISAION OF $2007 ADDRESS!!!
	INX
	CPX #$80 ; decimal 128
	BNE LoadBackgroundLoop
	
LoadAttribute:
	LDX #$00
LoadAttributeLoop:
	LDA attribute, x
	INX
	CPX #$08
	BNE LoadAttributeLoop

	
	


	
	
Forever:
    JMP Forever




NMI: ; when PPU not writing on screen
	LDA #$00 ; load $0002 to start DMA transfer
	STA $2003
	LDA #$02
	STA $4014
	
controllers:
	LDA #$01
	STA $4016
	LDA #$00
	STA $4016 ; now controllers give out current button bit
	;A, B, Select, Start, Up, Down, Left, Right.
	
	LDA $4016     ; player 1 - A
	AND #%00000001
	
	LDA $4016     ; player 1 - B
	AND #%00000001
	
	LDA $4016     ; player 1 - Select
	AND #%00000001
	
	LDA $4016     ; player 1 - Start
	AND #%00000001
	
ReadUp:
	LDA $4016     ; player 1 - Up
	AND #%00000001
	BEQ UpDone
	LDA $0200
	SEC
	SBC #$01
	STA $0200
UpDone:
ReadDown:
	LDA $4016     ; player 1 - Down
	AND #%00000001
	BEQ DownDone
	LDA $0200
	CLC
	ADC #$01
	STA $0200
DownDone:
	LDA $4016     ; player 1 - Left
	AND #%00000001
	
	LDA $4016     ; player 1 - Right
	AND #%00000001
	


	


    RTI


    .bank 1
	.ORG $E000
PalleteData:
	.DB $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F ;background
	.DB $0F,$16,$36,$0F,$0F,$0F,$30,$16,$0F,$1C,$15,$14,$0F,$02,$38,$3C ;foregrounds

sprites:
	; 80, 0, 0, 80 (y pos, tile number, color pallete no flipping etc, x pos)
	.DB $80, $32, $00, $80
	.DB $80, $33, $00, $88
	.DB $88, $34, $00, $80
	.DB $88, $35, $00, $88

nametable:
	.DB $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
	.DB $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky ($24 = sky)

	.DB $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 2
	.DB $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky	
	
	.DB $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24  ;;row 3
	.DB $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;;some brick tops	
	
	.DB $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24  ;;row 4
	.DB $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;;brick bottoms	

attribute: ; each att covers 4x4 tyles 
	.DB %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000


	
    .ORG $FFFA
    .DW NMI ; when NMI happens jump to NMI
    .DW RESET;when RST happens jump to RST
    .DW 0    ;cats NOT happens cups to POT


    .bank 2
    .ORG $0000
    .incbin "mario.chr"
; graphics