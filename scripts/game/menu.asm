MENU: {



	.label LogoStartPointer = 39
	.label MaxYOffset = 13
	.label ControlCooldown = 3

	Colours:		.byte LIGHT_BLUE, LIGHT_RED, LIGHT_GREEN, YELLOW, PURPLE
	Pointers:		.byte 39, 40, 41, 42, 43
	XPos:			.byte 124, 149, 174, 199, 224
	YPos:			.byte 74, 74, 74, 74, 74
	XPos_MSB:		.byte 0, 0, 0, 0, 0
	FrameTimer:		.fill 5, 0
	FrameTime:		.byte 1, 1, 2, 1, 1

	* = * "Menu"

	YOffset:		.byte 2, 12, 5, 7, 0
	Direction:		.byte -1, 1, 1, -1, 1


	PreviousOption:	.byte 0
	SelectedOption:	.byte 0
	OptionColours:	.byte RED + 8, PURPLE + 8, GREEN +8, YELLOW + 8
	ControlTimer: .byte 0

	SelectionRows:	.byte 9, 12, 15, 18

	SelectionColumns:	.byte 13, 25
	OptionCharType:	.byte 0, 0




	Show: {

		lda #0
		sta SelectedOption
		sta PreviousOption
		sta ControlTimer

		jsr MAIN.SetupVIC
		jsr DRAW.HideSprites

		lda #BLACK
		sta VIC.BACKGROUND_COLOUR

		lda #CYAN
		sta VIC.BORDER_COLOUR

		lda #WHITE
		sta VIC.EXTENDED_BG_COLOR_1
		lda #GRAY
		sta VIC.EXTENDED_BG_COLOR_2

		jsr DRAW.MenuScreen
		jsr MenuColours
		jsr SetupSprites

		jsr DrawSelection

		
		jmp MenuLoop

	}



	MenuLoop: {


		WaitForRasterLine:

			lda VIC.RASTER_LINE
			cmp #160
			bne WaitForRasterLine

		lda #0
		sta cooldown


		ldy #1
		lda INPUT.FIRE_UP_THIS_FRAME, y
		beq Finish

		jmp DecidePath

		Finish:

		jsr SpriteUpdate
		jsr ControlUpdate

		jmp MenuLoop

	}



	DecidePath: {

		lda SelectedOption
		beq Scenario

		cmp #3
		beq Options

		cmp #PLAY_MODE_2P
		beq TwoPlayer

		Practice:

			lda #0
			sta GRID.Active + 1

			ldx SETTINGS.DropSpeed
			lda SETTINGS.DropSpeeds, x
			sta PLAYER.CurrentAutoDropTime

			lda SETTINGS.BeanColours
			sta PANEL.MaxColours

			jmp MAIN.StartGame


		TwoPlayer:

			lda SETTINGS.BeanColours
			sta PANEL.MaxColours
			lda SETTINGS.BeanColours + 1
			sta PANEL.MaxColours + 1

			lda #0
			sta PLAYER.CPU + 1

			lda SETTINGS.Character + 1
			sta CAMPAIGN.OpponentID

			ldx SETTINGS.DropSpeed
			dex
			lda SETTINGS.DropSpeeds, x
			sta PLAYER.CurrentAutoDropTime

			ldx SETTINGS.DropSpeed + 1
			dex
			lda SETTINGS.DropSpeeds, x
			sta PLAYER.CurrentAutoDropTime + 1

			jmp MAIN.StartGame


		Scenario:

			jmp CAMPAIGN.Show


		Options:

			jmp SETTINGS.Show




	}


	ControlUpdate: {

		lda ControlTimer
		beq Ready

		dec ControlTimer
		jmp Finish

		Ready:

		ldy #1
		lda SelectedOption
		sta PreviousOption

		CheckDown:

			lda SelectedOption

			lda INPUT.JOY_DOWN_NOW, y
			beq CheckUp

			lda INPUT.JOY_DOWN_LAST, y
			bne Finish

			PressingDown:

			lda #ControlCooldown
			sta ControlTimer

			jsr DeleteSelection
			inc SelectedOption

			lda SelectedOption
			cmp #4
			bcc Okay

			lda #0
			sta SelectedOption

			Okay:

			jsr DrawSelection

			sfx(SFX_MOVE)

			jmp Finish



		CheckUp:

			ldy #1
			lda INPUT.JOY_UP_NOW, y
			beq Finish

			lda INPUT.JOY_UP_LAST, y
			bne Finish

			PressingUp:

			lda #ControlCooldown
			sta ControlTimer

			jsr DeleteSelection
			dec SelectedOption

			lda SelectedOption
			cmp #255
			bne Okay2

			lda #3
			sta SelectedOption

			Okay2:

			jsr DrawSelection

			sfx(SFX_BLOOP)




		Finish:



		rts
	}


	DeleteSelection: {

		ldx PreviousOption
		lda SelectionRows, x
		sta ZP.Row

		LeftBean:

			lda SelectionColumns
			tax

			lda #0
			ldy ZP.Row

			jsr DRAW.PlotCharacter

			inx

			jsr DRAW.PlotCharacter

			iny

			jsr DRAW.PlotCharacter

			dex

			jsr DRAW.PlotCharacter

		RightBean:	

			dec ZP.Row


			lda SelectionColumns + 1
			tax

			lda #0
			ldy ZP.Row

			jsr DRAW.PlotCharacter

			inx

			jsr DRAW.PlotCharacter

			iny

			jsr DRAW.PlotCharacter

			dex

			jsr DRAW.PlotCharacter




		rts
	}



	DrawSelection: {

		ldx SelectedOption
		lda SelectionRows, x
		sta ZP.Row

		lda OptionColours, x
		sta ZP.BeanColour


		LeftBean:

			ldy OptionCharType
			lda BEAN.Chars, y
			clc
			adc #3
			sta ZP.CharID

			ldx SelectionColumns

			lda ZP.CharID
			ldy ZP.Row

			jsr DRAW.PlotCharacter
			lda ZP.BeanColour
			jsr DRAW.ColorCharacter

			inx

			dec ZP.CharID
			lda ZP.CharID

			jsr DRAW.PlotCharacter
			lda ZP.BeanColour
			jsr DRAW.ColorCharacter


			dec ZP.CharID
			lda ZP.CharID

			iny

			jsr DRAW.PlotCharacter
			lda ZP.BeanColour
			jsr DRAW.ColorCharacter


			dec ZP.CharID
			lda ZP.CharID

			dex

			jsr DRAW.PlotCharacter

			lda ZP.BeanColour
			jsr DRAW.ColorCharacter

		RightBean:	

			dec ZP.Row
		

			ldy OptionCharType + 1
			lda BEAN.Chars, y
			clc
			adc #3
			sta ZP.CharID

			ldx SelectionColumns + 1

			lda ZP.CharID
			ldy ZP.Row

			jsr DRAW.PlotCharacter
			lda ZP.BeanColour
			jsr DRAW.ColorCharacter

			inx

			dec ZP.CharID
			lda ZP.CharID

			jsr DRAW.PlotCharacter
			lda ZP.BeanColour
			jsr DRAW.ColorCharacter


			dec ZP.CharID
			lda ZP.CharID

			iny

			jsr DRAW.PlotCharacter
			lda ZP.BeanColour
			jsr DRAW.ColorCharacter


			dec ZP.CharID
			lda ZP.CharID

			dex

			jsr DRAW.PlotCharacter

			lda ZP.BeanColour
			jsr DRAW.ColorCharacter



		rts
	}

	MenuColours: {


		ldx #40

		Loop:	

			lda OptionColours + 0
			sta COLOR_RAM + 336, x
			sta COLOR_RAM + 376, x

			lda OptionColours + 1
			sta COLOR_RAM + 456, x
			sta COLOR_RAM + 496, x

			lda OptionColours + 2
			sta COLOR_RAM + 576, x
			sta COLOR_RAM + 616, x

			lda OptionColours + 3
			sta COLOR_RAM + 696, x
			sta COLOR_RAM + 736, x

			inx
			cpx #48
			bcc Loop


		rts
	}



	SetupSprites: {	

		lda #%11111111
		sta VIC.SPRITE_ENABLE
		sta VIC.SPRITE_MULTICOLOR


		lda #DARK_GRAY
		sta VIC.SPRITE_MULTICOLOR_1

		lda #WHITE
		sta VIC.SPRITE_MULTICOLOR_2


		lda #0
		sta VIC.SPRITE_5_Y
		sta VIC.SPRITE_6_Y
		sta VIC.SPRITE_7_Y



		ldx #0

		Loop:	

			txa
			asl
			tay

			lda Pointers, x
			sta SPRITE_POINTERS, x
			
			lda Colours, x
			sta VIC.SPRITE_COLOR_0, x

			lda XPos, x
			sta VIC.SPRITE_0_X, y

			lda YPos, x
			sta VIC.SPRITE_0_Y, y

			lda FrameTime, x
			sta FrameTimer, x

			lda XPos_MSB, x
			bne MSB


			NoMSB:

				lda VIC.SPRITE_MSB
				and DRAW.MSB_Off, x
				sta VIC.SPRITE_MSB
				jmp EndLoop

			MSB:

				lda VIC.SPRITE_MSB
				ora DRAW.MSB_On, x
				sta VIC.SPRITE_MSB

			EndLoop:

				inx
				cpx #5
				bcc Loop



		rts
	}


	SpriteUpdate: {

		ldx #0

		Loop:	


			lda FrameTimer, x
			beq Ready

			dec FrameTimer, x
			jmp EndLoop

			Ready:

			

				lda FrameTime, x
				sta FrameTimer, x

				txa
				asl
				tay

				lda YPos, x
				clc
				adc YOffset, x
				sta VIC.SPRITE_0_Y, y

				lda YOffset, x
				clc
				adc Direction, x
				sta YOffset, x

				cmp #0
				beq MakeOne

				cmp #MaxYOffset
				beq Make255

				jmp EndLoop

			Make255:

				lda #255
				sta Direction, x
				jmp EndLoop


			MakeOne:

				lda #1
				sta Direction, x

			EndLoop:

				inx
				cpx #5
				bcc Loop




		rts
	}


	GameTitle: {








		rts
	}









}