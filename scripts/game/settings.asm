SETTINGS: {



	DropSpeed:		.byte 1, 1
	RockLayers:		.byte 0, 0
	BeanColours:	.byte 5, 5
	RoundsToWin:	.byte 2, 2
	Character:		.byte 0, 1

	SelectedOption:	.byte 0
	PreviousOption:	.byte 0
	ControlTimer:	.byte 0

	.label ControlCooldown = 3

	Min:			.byte 1, 0, 3, 1, 0
	Max:			.byte 5, 6, 6, 5, 47

	OptionColours:	.byte YELLOW + 8 ,  GREEN +8, CYAN + 8, PURPLE + 8,BLUE + 8, RED+ 8 

	SelectionRows:	.byte 5, 8, 11, 14, 17, 21

	SelectionColumns:	.byte 9, 29

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

		lda #GREEN
		sta VIC.BORDER_COLOUR

		lda #WHITE
		sta VIC.EXTENDED_BG_COLOR_1
		lda #GRAY
		sta VIC.EXTENDED_BG_COLOR_2

		jsr DRAW.SettingScreen
		jsr SettingsColours

		jsr DrawSelection

		
		jmp SettingsLoop





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
			cmp #6
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

			lda #5
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

	SettingsColours: {


		ldx #0

		Loop:	

			lda OptionColours + 0
			sta COLOR_RAM + 209, x
			sta COLOR_RAM + 249, x

			lda OptionColours + 1
			sta COLOR_RAM + 329, x
			sta COLOR_RAM + 369, x

			lda OptionColours + 2
			sta COLOR_RAM + 449, x
			sta COLOR_RAM + 489, x

			lda OptionColours + 3
			sta COLOR_RAM + 569, x
			sta COLOR_RAM + 609, x

			lda OptionColours + 4
			sta COLOR_RAM + 689, x
			sta COLOR_RAM + 729, x

			lda OptionColours + 5
			sta COLOR_RAM + 849, x
			sta COLOR_RAM + 889, x

			inx
			cpx #22
			bcc Loop


		ldx #0

		Loop2:	

			lda #RED + 8
			sta COLOR_RAM + 84, x
			sta COLOR_RAM + 124, x

			lda #CYAN +8
			sta COLOR_RAM + 108, x
			sta COLOR_RAM + 148, x

			
			inx
			cpx #8
			bcc Loop2

		rts
	}




	SettingsLoop: 
	{


		WaitForRasterLine:

			lda VIC.RASTER_LINE
			cmp #160
			bne WaitForRasterLine

		lda #0
		sta cooldown

		ldy #1
		lda INPUT.FIRE_UP_THIS_FRAME, y
		beq Finish

		jmp MENU.Show

		Finish:

		//jsr SpriteUpdate
		jsr ControlUpdate

		jmp SettingsLoop
	}










}