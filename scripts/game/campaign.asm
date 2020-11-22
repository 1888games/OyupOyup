CAMPAIGN: {


	.label MaxLevels = 6
	.label PlayerNamePointer = 48

	.label PlayerSpriteY = 102
	.label CloudPointer = 66
	.label CloudTime = 3
	.label BeanTime = 5
	.label NumberCharID = 206


	CurrentLevel:	.byte 0
	Matches:		.byte 0


	Rows:	.byte 21, 17, 13, 9, 6, 3

	CloudY:	.byte 56, 91, 119, 143, 168, 192
	CloudX:	.byte 73, 20, 173, 230, 30, 110
	CloudX_MSB:	.byte 0, 0, 0, 0, 1, 0

	CloudTimer: .byte 3, 2, 1, 2, 3, 4
	CloudTimes:	.byte 3, 2, 1, 2, 3, 1




	BeanTimer:	.byte 3
	BeanFrame:	.byte 129


	PlayerPointers:	.byte 53, 54
	PlayerColours:	.byte YELLOW, LIGHT_GREEN
	PlayerX:		.byte 43, 43


	Colours:	.byte RED, GREEN, YELLOW, BLUE, PURPLE, CYAN	

	NextLevel:	.byte $00, $15, $01
	Remaining:	.byte $00, $15, $01


	OpponentID:		.byte 0
	LastOpponentID: .byte 255
	LastChoiceID:	.byte 255
	RandomChoices:	.byte 20
	RandomTimer:	.byte 20
	RandomTimes:	.byte 35, 25, 20, 15, 10, 5, 3



	Levels:		.byte $01, $50, $00, $00
				.byte $04, $50, $00, $00
				.byte $08, $00, $00, $00
				.byte $12, $00, $00, $00
				.byte $15, $00, $00, $00
				.byte $20, $00, $00, $00






	NewGame: {

		lda #0
		sta CurrentLevel

		lda SETTINGS.DropSpeeds
		sta PLAYER.CurrentAutoDropTime

		rts
	}




	Show: {

		lda #1
		jsr ChangeTracks
		
		jsr MAIN.SetupVIC

		jsr SetupColours

		jsr DRAW.TowerScreen

		jsr PlayerSprites
		jsr Clouds
		jsr DrawBean
		jsr ColourText
		jsr DrawLevelData


		lda RandomTimes + 6
		sta RandomTimer

		jsr RANDOM.Get
		and #%00000111
		clc
		adc #16
		sta RandomChoices

		jsr ChooseOpponent

		lda #15
		sta RandomTimer

		lda #GAME_MODE_TOWER
		sta IRQ.Mode

		lda SETTINGS.BeanColours
		sta PANEL.MaxColours
		sta PANEL.MaxColours + 1

		ldx CurrentLevel
		lda SETTINGS.DropSpeeds
		sta PLAYER.CurrentAutoDropTime
		sta PLAYER.CurrentAutoDropTime + 1

		jmp CampaignLoop

	}



	

	CampaignLoop: {
		
		WaitForRasterLine:

			lda VIC.RASTER_LINE
			cmp #160
			bne WaitForRasterLine

		lda RandomChoices
		bne Finish

		ldy #1
		lda INPUT.FIRE_UP_THIS_FRAME, y
		beq Finish


		jmp MAIN.StartGame

		Finish:

		jmp CampaignLoop

	}	




	HandleOpponentShow: {

		lda RandomChoices
		beq Finish

		lda RandomTimer
		beq Ready

		dec RandomTimer
		jmp Finish


		Ready:

		ldx RandomChoices
		dex
		stx RandomChoices

		cpx #7
		bcc UseTable

		lda #2
		sta RandomTimer
		jmp Skip

		UseTable:

		lda RandomTimes, x
		sta RandomTimer

		Skip:

		ldx #SFX_MOVE
		sfxFromX()

		jsr ChooseOpponent 

		Finish:


		rts
	}


	FrameUpdate: {


		jsr HandleOpponentShow

		lda BeanTimer
		beq Ready

		dec BeanTimer
		jmp Finish

		Ready:

			lda #BeanTime
			sta BeanTimer

			lda BeanFrame
			cmp #129
			beq Make233

		Make129:

			lda #129
			sta BeanFrame
			jmp Draw

		Make233:

			lda #233
			sta BeanFrame

		Draw:

			jsr DrawBean

		Finish:



		rts
	}





	ChooseOpponent: {

		jsr RANDOM.Get
		and #%00000111
		sta ZP.Amount


		lda CurrentLevel
		asl
		asl
		asl
		clc
		adc ZP.Amount
		sta OpponentID

		cmp LastChoiceID
		beq ChooseOpponent

		sta LastChoiceID

		tax

		lda OPPONENTS.Pointers, x
		sta PlayerPointers + 1
		sta SPRITE_POINTERS + 1

		lda OPPONENTS.Colours, x
		sta VIC.SPRITE_COLOR_1
		sta PlayerColours + 1


		txa

		ldx #10
		stx ZP.TextRow

		ldx #34
		stx ZP.TextColumn

		ldy #0
		ldx #WHITE

		jsr TEXT.Draw

			// a = textID
		// y = bank
		// x = colour
		// TextColumn
		// TextRow


		rts



	}


	IncreaseLevel: {

		inc CurrentLevel
		lda CurrentLevel
		asl
		asl
		tax

		lda Levels, x
		sta NextLevel + 2
		sta Remaining + 2


		lda Levels + 1, x
		sta NextLevel + 1
		sta Remaining + 1

		lda Levels + 2, x
		sta NextLevel
		sta Remaining

		rts
	}

	DrawLevelData: {

		lda CurrentLevel
		asl
		asl
		tax

		lda Levels, x
		sta NextLevel + 2

		lda Levels + 1, x
		sta NextLevel + 1

		lda Levels + 2, x
		sta NextLevel

		jsr SCORING.DrawExperience
		jsr DrawTarget

		Level:

			lda CurrentLevel
			clc
			adc #1
			asl
			clc
			adc #NumberCharID

			sta SCREEN_RAM + 116
			clc
			adc #1
			sta SCREEN_RAM + 156

			lda #YELLOW + 8
			sta COLOR_RAM + 116
			sta COLOR_RAM + 156

		Match:

			lda Matches
			clc
			adc #1
			asl
			clc
			adc #NumberCharID

			sta SCREEN_RAM + 196
			clc
			adc #1
			sta SCREEN_RAM + 236

			lda #YELLOW + 8
			sta COLOR_RAM + 196
			sta COLOR_RAM + 236



		
		ldx #0

		Loop:

			lda #PURPLE + 8

			sta COLOR_RAM + 108, x
			sta COLOR_RAM + 148, x

			lda #BLUE+ 8

			sta COLOR_RAM + 188, x
			sta COLOR_RAM + 228, x

			inx
			cpx #6
			bcc Loop

		


		rts
	}


	DrawTarget: {


		ldy #5	// screen offset, right most digit
		ldx #ZERO	// score byte index
	
		ScoreLoop:

			lda NextLevel,x
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

			asl
			adc #SCORING.CharacterSetStart
			sta SCREEN_RAM + 166, y

			clc
			adc #1
			sta SCREEN_RAM + 206, y

			ColourText:

				lda #CYAN +8

				sta COLOR_RAM +166, y
				sta COLOR_RAM +206, y

			dey
			rts

		}


		rts
	}





	SetupColours: {

		lda #BLACK
		sta VIC.BACKGROUND_COLOUR

		lda #LIGHT_GREEN
		sta VIC.BORDER_COLOUR

		lda #WHITE
		sta VIC.EXTENDED_BG_COLOR_1
		lda #GRAY
		sta VIC.EXTENDED_BG_COLOR_2

		lda #LIGHT_RED
		sta VIC.SPRITE_MULTICOLOR_1

		lda #WHITE
		sta VIC.SPRITE_MULTICOLOR_2


		rts
	}




	PlayerSprites: {


		lda #%11111111
		sta VIC.SPRITE_MULTICOLOR

		lda #%11111111
		sta VIC.SPRITE_ENABLE

		lda #%00000000
		sta VIC.SPRITE_PRIORITY
		sta VIC.SPRITE_DOUBLE_Y
		sta VIC.SPRITE_DOUBLE_X



		lda PlayerPointers
		sta SPRITE_POINTERS

		lda PlayerColours
		sta VIC.SPRITE_COLOR_0

		lda #PlayerSpriteY
		sta VIC.SPRITE_0_Y

		lda #PlayerSpriteY
		sta VIC.SPRITE_1_Y

		lda PlayerX
		sta VIC.SPRITE_0_X

		lda PlayerX + 1
		sta VIC.SPRITE_1_X

		lda VIC.SPRITE_MSB
		and #%11111100
		ora #%00000010
		sta VIC.SPRITE_MSB

		rts

	
	}


	Clouds: {

		lda #CloudPointer
		sta SPRITE_POINTERS + 2
		sta SPRITE_POINTERS + 3
		sta SPRITE_POINTERS + 4
		sta SPRITE_POINTERS + 5
		sta SPRITE_POINTERS + 6
		sta SPRITE_POINTERS + 7


		lda #LIGHT_GRAY

		sta VIC.SPRITE_COLOR_2
		sta VIC.SPRITE_COLOR_3
		sta VIC.SPRITE_COLOR_4
		sta VIC.SPRITE_COLOR_5
		sta VIC.SPRITE_COLOR_6
		sta VIC.SPRITE_COLOR_7

		ldx #0
		ldy #0

		Loop:	

			lda CloudTimer, x
			beq Ready

			dec CloudTimer, x
			jmp Okay


			Ready:

			lda CloudTimes, x
			sta CloudTimer, x

			lda CloudX, x
			sec
			sbc #1
			sta CloudX, x

			lda CloudX_MSB, x
			sbc #00
			sta CloudX_MSB, x

			cmp #255
			bne Okay

			lda #1
			sta CloudX_MSB, x

			lda #120
			sta CloudX, x

			Okay:

			lda CloudX, x
			sta VIC.SPRITE_2_X, y

			lda CloudY, x
			sta VIC.SPRITE_2_Y, y

			lda CloudX_MSB, x
			beq NoMSB

			MSB:	

				inx
				inx

				lda VIC.SPRITE_MSB
				ora DRAW.MSB_On, x
				sta VIC.SPRITE_MSB
				jmp EndLoop

			NoMSB:

				inx
				inx

				lda VIC.SPRITE_MSB
				and DRAW.MSB_Off, x
				sta VIC.SPRITE_MSB

			
			EndLoop:
			dex
			iny
			iny

			cpx #6
			bcc Loop
	



		rts
	}




	ColourText: {







		rts
	}



	DrawCharacter: {

		lda ZP.CharID

		jsr DRAW.PlotCharacter

		lda ZP.BeanColour
		jsr DRAW.ColorCharacter

		NoDraw:

		rts
	}



	DrawBean: {


		// y = 0-3

	
		GetPosition:
			
			lda #19
			sta ZP.Column

			ldy CurrentLevel
			lda Rows, y
			sta ZP.Row

		GetColour:

			lda Colours, y
			clc
			adc #8
			sta ZP.BeanColour

		GetChars:

			lda BeanFrame
			sta ZP.CharID

		TopLeft:
		
			ldx ZP.Column
			ldy ZP.Row
			jsr DrawCharacter
				
		TopRight:

			inx
			dec ZP.CharID		
			jsr DrawCharacter

		BottomRight:

			iny
			dec ZP.CharID
			jsr DrawCharacter
	

		BottomLeft:

			dex
			dec ZP.CharID		
			jsr DrawCharacter


		Finish:


		rts
	}







}