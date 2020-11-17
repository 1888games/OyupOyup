ROUND_OVER: {

	// Quickest possible = 24

					//    24   25   26   27   28   29   30   31   32   33   34   35   36   37   38   39   40   41   42   43   44   45   46   47   48   49   50   51   52   53   54   55   56   57   58   59   60   61   62   63   64   65   66   67   68   69   70   71   72   73   74   75   76   77   78   79   80   81   82   83   84   85   86   87   88   89   90   91   92   93   94   95   96   97   98   99  100  101  102  103  104  105  106  107  108  109  110  111  112  113  114  115  116  117  118  119  120  121  122  123  124  125  126  127  128  129  130
	TimeLookupH:	.byte $03, $03, $03, $03, $03, $03, $03, $03, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	TimeLookupM:	.byte $37, $30, $24, $18, $12, $06, $00, $94, $88, $82, $76, $70, $65, $59, $53, $48, $43, $37, $32, $27, $21, $16, $11, $06, $01, $96, $92, $87, $82, $77, $73, $68, $64, $59, $55, $51, $47, $42, $38, $34, $30, $26, $22, $19, $15, $11, $08, $04, $00, $97, $94, $90, $87, $84, $81, $78, $75, $72, $69, $66, $63, $60, $58, $55, $52, $50, $48, $45, $43, $41, $38, $36, $34, $32, $30, $28, $27, $25, $23, $21, $20, $18, $17, $15, $14, $13, $12, $10, $09, $08, $07, $06, $05, $05, $04, $03, $03, $02, $01, $01, $01, $00, $00, $00, $00, $00, $00
	TimeLookupL:	.byte $08, $75, $48, $27, $12, $03, $00, $03, $12, $27, $48, $75, $08, $47, $92, $43, $00, $63, $32, $07, $88, $75, $68, $67, $72, $83, $00, $23, $52, $87, $28, $75, $28, $87, $52, $23, $00, $83, $72, $67, $68, $75, $88, $07, $32, $63, $00, $43, $92, $47, $08, $75, $48, $27, $12, $03, $00, $03, $12, $27, $48, $75, $08, $47, $92, $43, $00, $63, $32, $07, $88, $75, $68, $67, $72, $83, $00, $23, $52, $87, $28, $75, $28, $87, $52, $23, $00, $83, $72, $67, $68, $75, $88, $07, $32, $63, $00, $43, $92, $47, $08, $75, $48, $27, $12, $03, $00
 

	Winner:		.byte 0
	Loser:		.byte 0

	Active:		.byte 0
	Stage:		.byte 0

	GameOver:	.byte 0
	FlashState:	.byte 0

	FlashTimer:	.byte 30
	Colours:	.byte 0, 8 +GREEN
	.label FlashTime = 25


	ExplosionOffset: .byte 0, 16



	FrameUpdate: {

		lda Active
		beq Finish

		lda Stage
		bne NotFlash

		Flash:

			jsr FlashText
			rts

		NotFlash:


		Finish:




		rts
	}	



	RandomRow: {

		jsr RANDOM.Get
		and #%00000011
		clc
		adc #6
		sta ZP.Row


		rts
	}

	RandomColumn: {


		ldx Winner
		

		jsr RANDOM.Get
		and #%00000011
		clc
		adc #3
		clc
		adc ExplosionOffset, x
		sta ZP.Column


		rts
	}

	RandomExplosion: {

		jsr RandomRow
		jsr RandomColumn

		jsr RANDOM.Get
		and #%00001111
		sta ZP.BeanColour
		
		jsr RANDOM.Get
		and #%00000001
		clc
		adc #1
		tax

		jsr EXPLOSIONS.StartExplosion

		rts
	}


	FlashText: {

		lda FlashTimer
		beq Ready

		dec FlashTimer
		rts


		Ready:

		lda #FlashTime
		sta FlashTimer

		jsr RandomExplosion

		lda FlashState
		beq TurnOn

		TurnOff:


			lda #0
			sta FlashState
			jmp CheckSide

		TurnOn:

			lda #1
			sta FlashState


		CheckSide:

			ldy FlashState
			lda Colours, y
			ldx #0

			ldy Winner
			beq LeftSide

		RightSide:

			Loop2:
				sta COLOR_RAM + 148, x
				sta COLOR_RAM + 188, x

				inx
				cpx #8
				bcc Loop2
			
			jmp Finish

		LeftSide:

			Loop:
				sta COLOR_RAM + 124, x
				sta COLOR_RAM + 164, x

				inx
				cpx #8
				bcc Loop


		Finish:

		rts
	}

	MoveDownRow: {


	 	lda ZP.ScreenAddress
	 	clc
	 	adc #40
	 	sta ZP.ScreenAddress

	 	lda ZP.ScreenAddress + 1
	 	adc #0
	 	sta ZP.ScreenAddress + 1

	 	lda ZP.ColourAddress
	 	clc
	 	adc #40
	 	sta ZP.ColourAddress

	 	lda ZP.ColourAddress + 1
	 	adc #0
	 	sta ZP.ColourAddress + 1


		rts
	}



	YouWinTop: {


		ldx #0
		ldy #0

		Loop:

			stx ZP.X

		 	lda WIN_LEFT, x
		 	sta (ZP.ScreenAddress), y

		 	tax
		 	lda CHAR_COLORS, x
		 	sta (ZP.ColourAddress), y

		 	iny
		 	cpy #12
		 	bcc Okay

		 	ldy #0

		 	jsr MoveDownRow

		 	Okay:

		 	ldx ZP.X

		 	inx
		 	cpx #144
		 	bcc Loop

		rts
	}

	YouWinBottom: {

		 ldx #0
		 ldy #0

		 Loop2:

		 	stx ZP.X

		 	lda WIN_LEFT + 144, x
		 	sta (ZP.ScreenAddress), y

		 	tax
		 	lda CHAR_COLORS, x
		 	sta (ZP.ColourAddress), y

		 	iny
		 	cpy #12
		 	bcc Okay2

		 	ldy #0

		 	jsr MoveDownRow

		 	Okay2:

		 	ldx ZP.X

		 	inx
		 	cpx #144
		 	bcc Loop2



		rts
	}

	BlankBottom: {


		 ldx #0
		 ldy #0

		 Loop2:

		 	stx ZP.X

		 	lda WIN_BOTTOM, x
		 	sta (ZP.ScreenAddress), y

		 	tax
		 	lda CHAR_COLORS, x
		 	sta (ZP.ColourAddress), y

		 	iny
		 	cpy #12
		 	bcc Okay2

		 	ldy #0

		 	jsr MoveDownRow

		 	Okay2:

		 	ldx ZP.X

		 	inx
		 	cpx #144
		 	bcc Loop2



		rts
	}

	PlayerOneWinBottom: {

		lda #<SCREEN_RAM + 522
		sta ZP.ScreenAddress

		lda #>SCREEN_RAM + 522
		sta ZP.ScreenAddress + 1

		lda #<COLOR_RAM + 522
		sta ZP.ColourAddress

		lda #>COLOR_RAM + 522
		sta ZP.ColourAddress + 1

		jsr YouWinBottom

		rts
	}


	PlayerTwoWinBottom: {

		lda #<SCREEN_RAM + 546
		sta ZP.ScreenAddress

		lda #>SCREEN_RAM + 546
		sta ZP.ScreenAddress + 1

		lda #<COLOR_RAM + 546
		sta ZP.ColourAddress

		lda #>COLOR_RAM + 546
		sta ZP.ColourAddress + 1

		jsr YouWinBottom
		rts
	}

	PlayerTwoWins: {

		lda #GREEN
		sta VIC.BORDER_COLOUR

		
		lda #<SCREEN_RAM + 66
		sta ZP.ScreenAddress

		lda #>SCREEN_RAM + 66
		sta ZP.ScreenAddress + 1

		lda #<COLOR_RAM + 66
		sta ZP.ColourAddress

		lda #>COLOR_RAM + 66
		sta ZP.ColourAddress + 1

		jsr YouWinTop
		jsr BlankBottom

	
		rts
	}


	PlayerOneWins: {

		lda #GREEN
		sta VIC.BORDER_COLOUR

		lda #<SCREEN_RAM + 42
		sta ZP.ScreenAddress

		lda #>SCREEN_RAM + 42
		sta ZP.ScreenAddress + 1

		lda #<COLOR_RAM + 42
		sta ZP.ColourAddress

		lda #>COLOR_RAM + 42
		sta ZP.ColourAddress + 1

		jsr YouWinTop
		jsr BlankBottom

	
		rts
	}


	Show: {



		stx Loser

		lda #FlashTime
		sta FlashTimer

		lda #1
		sta FlashState
		sta Active

		lda #0
		sta Stage

		lda ROCKS.Opponent, x
		sta Winner

		bne RightWins

		LeftWins:

		jsr PlayerOneWins
		rts

		RightWins:

		jsr PlayerTwoWins

		rts
	}



}