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
	WaitTimer:	.byte 
	.label FlashTime = 25
	.label WaitTime = 95
	.label StartSeconds = 130


	Bonus:		.byte 0, 0, 0
	CurrentSeconds:	.byte 130
	


	ExplosionOffset: .byte 0, 24



	FrameUpdate: {

		lda Active
		beq Finish

		lda Stage
		cmp #2
		bcs NotFlash

		Flash:

			jsr FlashText

			lda Stage
			beq Finish

			lda WaitTimer
			beq Ready

			dec WaitTimer
			jmp Finish

			Ready:

				lda #2
				sta Stage

				lda #1
				sta FlashState

				lda #StartSeconds
				sta CurrentSeconds
	
				jsr ColourText
				jsr ShowBottom

			rts

		NotFlash:

			jsr CalculateTimeBonus
			jsr DrawBonus



		Finish:




		rts
	}	


	CalculateTimeBonus: {

		lda CurrentSeconds
		cmp #24
		bcc SetTo24

		cmp #131
		bcs SetTo130

		jmp GetBonus


		SetTo130:

			lda #130
			jmp GetBonus

		SetTo24:

			lda #24

		GetBonus:

			tax

			lda TimeLookupL, x
			sta Bonus

			lda TimeLookupM, x
			sta Bonus + 1

			lda TimeLookupH, x
			sta Bonus + 2


		dec CurrentSeconds
		lda CurrentSeconds
		cmp ROCKS.GameSeconds
		bcc ReachedTarget

		jmp Finish

		ReachedTarget:

			lda ROCKS.GameSeconds
			sta CurrentSeconds

			.break
			nop


		Finish:


		rts
	}


	DrawBonus: {

		lda Winner
		beq Player1

		Player2:

			jsr DrawPlayerTwoBonus
			rts

		Player1:

			jsr DrawPlayerOneBonus
			rts

	}



	DrawPlayerOneBonus: {

		ldy #5	// screen offset, right most digit
		ldx #ZERO	// score byte index
	
		ScoreLoop:

			lda Bonus,x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble
			jsr PlotDigit
			inx 
			cpx #3
			bne ScoreLoop

			rts

		PlotDigit: {

			cpy #0
			beq Skip

			asl
			adc #SCORING.CharacterSetStart
			sta SCREEN_RAM + 844, y

			clc
			adc #1
			sta SCREEN_RAM + 884, y

			ColourText:

				lda #YELLOW +8

				sta COLOR_RAM +844, y
				sta COLOR_RAM +884, y

			Skip:

			dey
			rts

		}


		rts
	}


	DrawPlayerTwoBonus: {

		ldy #5	// screen offset, right most digit
		ldx #ZERO	// score byte index
	
		ScoreLoop:

			lda Bonus,x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble
			jsr PlotDigit
			inx 
			cpx #3
			bne ScoreLoop

			rts

		PlotDigit: {

			cpy #0
			beq Skip

			asl
			adc #SCORING.CharacterSetStart
			sta SCREEN_RAM + 867, y

			clc
			adc #1
			sta SCREEN_RAM + 907, y

			ColourText:

				lda #YELLOW +8

				sta COLOR_RAM +867, y
				sta COLOR_RAM +907, y

			Skip:

			dey
			rts

		}


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



	ColourText: {

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
			jmp Colour

		TurnOn:

			lda #1
			sta FlashState

		Colour:

			jsr ColourText

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


		ldy #YELLOW+ 8
		ldx #3

		lda #1
		jsr TEXT.DrawTallDigits




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

		PlayerSprite:

			lda CAMPAIGN.PlayerPointers
			sta SPRITE_POINTERS + 1

			lda #63
			sta VIC.SPRITE_1_X

			lda #100
			sta VIC.SPRITE_1_Y

			lda CAMPAIGN.PlayerColours
			sta VIC.SPRITE_COLOR_1

			lda VIC.SPRITE_MSB
			and #%11111101
			sta VIC.SPRITE_MSB

			lda VIC.SPRITE_DOUBLE_Y
			ora #%00000010
			sta VIC.SPRITE_DOUBLE_Y

			lda VIC.SPRITE_DOUBLE_X
			ora #%00000010
			sta VIC.SPRITE_DOUBLE_X


		SetupText:

			lda #6
			sta ZP.TextColumn

			lda #15
			sta ZP.TextRow


		jsr YouWinBottom

		rts
	}


	PlayerTwoWinBottom: {

		GrabAddresses:

			lda #<SCREEN_RAM + 546
			sta ZP.ScreenAddress

			lda #>SCREEN_RAM + 546
			sta ZP.ScreenAddress + 1

			lda #<COLOR_RAM + 546
			sta ZP.ColourAddress

			lda #>COLOR_RAM + 546
			sta ZP.ColourAddress + 1

		PlayerSprite:

			lda CAMPAIGN.PlayerPointers + 1
			sta SPRITE_POINTERS + 0

			lda #255
			sta VIC.SPRITE_0_X

			lda #100
			sta VIC.SPRITE_0_Y

			lda CAMPAIGN.PlayerColours + 1
			sta VIC.SPRITE_COLOR_0

			lda VIC.SPRITE_MSB
			and #%11111110
			sta VIC.SPRITE_MSB

			lda VIC.SPRITE_DOUBLE_Y
			ora #%00000001
			sta VIC.SPRITE_DOUBLE_Y

			lda VIC.SPRITE_DOUBLE_X
			ora #%00000001
			sta VIC.SPRITE_DOUBLE_X


		SetupText:

			lda #30
			sta ZP.TextColumn

			lda #15
			sta  ZP.TextRow




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

		sty Loser

		lda #FlashTime
		sta FlashTimer

		lda #1
		sta FlashState
		sta Active

		lda #0
		sta Stage

		lda ROCKS.Opponent, y
		sta Winner

		bne RightWins

		LeftWins:

		jsr PlayerOneWins
		rts

		RightWins:

		jsr PlayerTwoWins

		rts
	}



	ShowBottom: {

		lda ROCKS.GameSeconds
		jsr TEXT.ByteToDigits

		lda Winner
		beq Player1

		Player2:

			jsr PlayerTwoWinBottom
			jmp Finish

		Player1:

			jsr PlayerOneWinBottom

		Finish:


		rts
	}

	ShowRest: {

		lda #1
		sta Stage

		lda #WaitTime
		sta WaitTimer




		rts
	}


}