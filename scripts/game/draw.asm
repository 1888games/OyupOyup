DRAW: {

	*=* "Draw"


	MSB_On:		.byte %00000001, %00000010, %00000100,%00001000,%00010000,%00100000,%01000000,%10000000
	MSB_Off:	.byte %11111110, %11111101, %11111011,%11110111,%11101111,%11011111,%10111111,%01111111
	
	ScreenRowLSB:	.fill 25, <[i * $28]
	ScreenRowMSB:	.fill 25, >[i * $28]

	CharTimer:	.byte 3
	.label CharTime = 3

	ClearScreen: {

		ldx #0
		lda #0


		Loop:

			sta SCREEN_RAM + 0, x
			sta SCREEN_RAM + 250, x
			sta SCREEN_RAM + 500, x
			sta SCREEN_RAM + 750, x

			inx
			bne Loop



		rts
	}





	CalculateAddresses:{

		//get row for this position
		ldy ZP.Row
		lda ScreenRowLSB, y
	
		// Get CharAddress
		
		clc
		adc ZP.Column

		sta ZP.ScreenAddress
		sta ZP.ColourAddress

		lda ScreenRowMSB, y	
		adc #0  // get carry bit from above
		sta ZP.RowOffset

		lda #>SCREEN_RAM
		clc
		adc ZP.RowOffset
		sta ZP.ScreenAddress + 1

		lda #>COLOR_RAM
		clc
		adc ZP.RowOffset
		sta ZP.ColourAddress +1


		rts

	}



	GetCharacter: {

		sty ZP.Row
		stx ZP.Column
	
		jsr CalculateAddresses

		ldy #ZERO
		lda (ZP.ScreenAddress), y

		ldy ZP.Row
		ldx ZP.Column

		rts

	}



	GetColor: {

		sty ZP.Row
		stx ZP.Column
	
		jsr CalculateAddresses

		ldy #ZERO
		lda (ZP.ColourAddress), y
		and #%00001111

		ldy ZP.Row
		ldx ZP.Column

		rts

	}

	PlotCharacterWithAddress: {

		sty ZP.Row

		ldy #ZERO
		sta (ZP.ScreenAddress), y

		ldy ZP.Row


		Finish:

		rts


	}

	
	
	PlotCharacter: {

		cpx #40
		bcs Finish

		sty ZP.Row
		stx ZP.Column
		sta ZP.CharID

		jsr CalculateAddresses

		ldy #ZERO
		lda ZP.CharID
		sta (ZP.ScreenAddress), y


		ldy ZP.Row
		ldx ZP.Column
		lda ZP.CharID


		Finish:


		rts

	}

	LevelNumber: {

		lda CAMPAIGN.CurrentLevel
		clc
		adc #1
		asl
		clc
		adc #CAMPAIGN.NumberCharID

		sta SCREEN_RAM + 623
		clc
		adc #1
		sta SCREEN_RAM + 663

		lda #GREEN + 8
		sta COLOR_RAM + 623
		sta COLOR_RAM + 663



		rts
	}

	ColorCharacterOnly: {

		sty ZP.Row
		stx ZP.Column
		sta ZP.Colour

		jsr CalculateAddresses

		ldy #ZERO
		lda ZP.Colour

		sta (ZP.ColourAddress), y

		ldy ZP.Row
		ldx ZP.Column
		lda ZP.Colour

		rts



	}

	

	ColorCharacter: {

		cpx #40
		bcs Finish

		sty ZP.Row
		
		ldy #0
		sta (ZP.ColourAddress), y

		ldy ZP.Row

		
		Finish:

		rts
	}


	

	GameScreen: {

		ldx #0
		
		Loop:

			lda GAME_MAP + 0, x
			sta SCREEN_RAM + 0, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 0, x

			lda GAME_MAP + 250, x
			sta SCREEN_RAM + 250, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 250, x

			lda GAME_MAP + 500, x
			sta SCREEN_RAM + 500, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 500, x

			lda GAME_MAP + 750, x
			sta SCREEN_RAM + 750, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 750, x

			inx
			bne Loop


		rts
	}


	TowerScreen: {

		ldx #0
		
		Loop:

			lda TOWER_MAP + 0, x
			sta SCREEN_RAM + 0, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 0, x

			lda TOWER_MAP  + 250, x
			sta SCREEN_RAM + 250, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 250, x

			lda TOWER_MAP  + 500, x
			sta SCREEN_RAM + 500, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 500, x

			lda TOWER_MAP + 750, x
			sta SCREEN_RAM + 750, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 750, x

			inx
			bne Loop


		rts
	}



	GameOpponentName: {

		// a = textID
		// y = bank
		// x = colour
		// TextColumn
		// TextRow

		lda #4
		sta ZP.TextRow

		lda #21
		sta ZP.TextColumn

		ldx #WHITE

		lda CAMPAIGN.OpponentID

		jsr TEXT.Draw

		rts
	}



	CycleChars: {

		lda CharTimer
		beq Ready

		dec CharTimer
		rts


		Ready:

		lda #CharTime
		sta CharTimer

		ldx #0

		Loop:

			lda CHAR_SET + 1616, x
			sta ZP.Amount

			lda CHAR_SET + 1617, x
			sta CHAR_SET + 1616, x

			lda CHAR_SET + 1618, x
			sta CHAR_SET + 1617, x

			lda CHAR_SET + 1619, x
			sta CHAR_SET + 1618, x

			lda CHAR_SET + 1620, x
			sta CHAR_SET + 1619, x

			lda CHAR_SET + 1621, x
			sta CHAR_SET + 1620, x

			lda CHAR_SET + 1622, x
			sta CHAR_SET + 1621, x

			lda CHAR_SET + 1623, x
			sta CHAR_SET + 1622, x

			lda ZP.Amount
			sta CHAR_SET + 1623, x

			txa
			clc
			adc #8
			tax

			cpx #32
			bcc Loop


		rts
	}
		

	HideSprites: {


		lda #0
		sta VIC.SPRITE_0_Y
		sta VIC.SPRITE_1_Y
		sta VIC.SPRITE_2_Y
		sta VIC.SPRITE_3_Y
		sta VIC.SPRITE_4_Y
		sta VIC.SPRITE_5_Y
		sta VIC.SPRITE_6_Y
		sta VIC.SPRITE_7_Y

		rts


	}


	SettingScreen: {

		ldx #0
		
		Loop:

			lda SETTINGS_MAP + 0, x
			sta SCREEN_RAM + 0, x

			lda #LIGHT_GREEN
			sta COLOR_RAM + 0, x

			lda SETTINGS_MAP   + 250, x
			sta SCREEN_RAM + 250, x

			lda #LIGHT_GREEN
			sta COLOR_RAM + 250, x

			lda SETTINGS_MAP   + 500, x
			sta SCREEN_RAM + 500, x

			lda #LIGHT_GREEN
			sta COLOR_RAM + 500, x

			lda SETTINGS_MAP + 750, x
			sta SCREEN_RAM + 750, x

			lda #LIGHT_GREEN
			sta COLOR_RAM + 750, x

			inx
			bne Loop


		rts




		rts
	}



	GamePlayerSprites: {

		lda CAMPAIGN.PlayerPointers
		sta SPRITE_POINTERS + 4

		lda CAMPAIGN.PlayerColours
		sta VIC.SPRITE_COLOR_4

		
		lda CAMPAIGN.PlayerPointers + 1
		sta SPRITE_POINTERS + 5

		lda CAMPAIGN.PlayerColours + 1
		sta VIC.SPRITE_COLOR_5


		lda #50
		sta VIC.SPRITE_4_Y
		sta VIC.SPRITE_5_Y

		lda #144
		sta VIC.SPRITE_4_X

		lda #198
		sta VIC.SPRITE_5_X

		lda VIC.SPRITE_MSB
		and #%11001111
		sta VIC.SPRITE_MSB

		rts

	
	}


	MenuScreen: {

		ldx #0
		
		Loop:

			lda MENU_MAP + 0, x
			sta SCREEN_RAM + 0, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 0, x

			lda MENU_MAP  + 250, x
			sta SCREEN_RAM + 250, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 250, x

			lda MENU_MAP  + 500, x
			sta SCREEN_RAM + 500, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 500, x

			lda MENU_MAP + 750, x
			sta SCREEN_RAM + 750, x

			tay
			lda CHAR_COLORS, y
			sta COLOR_RAM + 750, x

			inx
			bne Loop


		rts

	}


	
}
