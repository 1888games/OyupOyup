CAMPAIGN: {


	.label MaxLevels = 6
	.label PlayerNamePointer = 48

	.label PlayerSpriteY = 102
	.label CloudPointer = 66
	.label CloudTime = 3
	.label BeanTime = 5


	CurrentLevel:	.byte 0


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


	NewGame: {

		lda #0
		sta CurrentLevel







		rts
	}




	PlayerSprites: {

		lda PlayerPointers
		sta SPRITE_POINTERS

		lda PlayerPointers + 1
		sta SPRITE_POINTERS + 1

		lda PlayerColours
		sta VIC.SPRITE_COLOR_0

		lda PlayerColours + 1
		sta VIC.SPRITE_COLOR_0 +1

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



	Show: {


		lda #1
		jsr ChangeTracks
		
		jsr MAIN.SetupVIC

		lda #%11111111
		sta VIC.SPRITE_MULTICOLOR

		lda #%11111111
		sta VIC.SPRITE_ENABLE

		lda #%00000000
		sta VIC.SPRITE_PRIORITY


		lda #BLACK
		sta VIC.BACKGROUND_COLOUR

		lda #DARK_GRAY
		sta VIC.BORDER_COLOUR

		lda #WHITE
		sta VIC.EXTENDED_BG_COLOR_1
		lda #GRAY
		sta VIC.EXTENDED_BG_COLOR_2

		lda #LIGHT_RED
		sta VIC.SPRITE_MULTICOLOR_1

		lda #WHITE
		sta VIC.SPRITE_MULTICOLOR_2


		jsr DRAW.TowerScreen

		lda #GAME_MODE_TOWER
		sta IRQ.Mode

		jsr PlayerSprites
		jsr Clouds
		jsr DrawBean



		jmp CampaignLoop

	}



	CampaignLoop: {

		jmp CampaignLoop

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



	FrameUpdate: {

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







}