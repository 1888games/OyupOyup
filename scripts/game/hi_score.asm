HI_SCORE:  {
		
	.label ScreenTime = 250
	.label ColourTime = 5


	ScreenTimer: 		.byte ScreenTime
	Screen:				.byte 0

	Colour:			.byte 1
	ColourTimer:	.byte ColourTime

	StartIndexes:	.byte 0, 5, 10

	Rows:		.byte 8, 11, 14, 17, 20

	NameAddresses:	.word SCREEN_RAM + 335, SCREEN_RAM + 455, SCREEN_RAM + 575, SCREEN_RAM + 695, SCREEN_RAM + 815
	ScoreAddresses:	.word SCREEN_RAM + 344, SCREEN_RAM + 464, SCREEN_RAM + 584, SCREEN_RAM + 704, SCREEN_RAM + 824

	Scores:	.byte 0, 0, 0

	TextIDs:	.byte 49, 50, 51


	* = * "Hi score_Code"
	Show: {

		jsr MAIN.SetupVIC

		lda #0
		sta VIC.SPRITE_ENABLE
		sta Screen

		lda #1
		sta Colour

		lda #ScreenTime
		sta ScreenTimer

		lda #RED
		sta VIC.BORDER_COLOUR

		lda #BLACK
		sta VIC.BACKGROUND_COLOUR

		jsr DRAW.HiScoreScreen
	//	jsr ColourRows


		lda #RED + 8
		sta COLOR_RAM
		sta COLOR_RAM + 39
		sta COLOR_RAM + 960
		sta COLOR_RAM + 999

		jsr PopulateTable

		jmp HiScoreLoop



	}



	PopulateHeader: {

		lda #16
		sta ZP.TextColumn

		lda #5
		sta ZP.TextRow

		ldx Screen
		lda TextIDs, x

		ldx #WHITE

		jsr TEXT.Draw
	


		rts
	}


	PopulateTable: {


		jsr PopulateHeader

		ldx Screen
		lda StartIndexes, x
		sta ZP.StartID

		Names:

		ldx #0

		Loop:

			stx ZP.X

			txa
			asl
			tax
			lda NameAddresses, x
			sta ZP.ScreenAddress

			lda NameAddresses + 1, x
			sta ZP.ScreenAddress + 1

			ldx ZP.StartID
			lda FirstInitials, x

			ldy #0
			sta (ZP.ScreenAddress), y

			lda SecondInitials, x

			iny
			sta (ZP.ScreenAddress), y

			lda ThirdInitials, x

			iny
			sta (ZP.ScreenAddress), y

			inc ZP.StartID

			ldx ZP.X
			inx
			cpx #5
			bcc Loop


		Score:

		ldx Screen
		lda StartIndexes, x
		sta ZP.StartID


		ldx #0

		Loop2:

			stx ZP.X

			txa
			asl
			tax
			lda ScoreAddresses, x
			sta ZP.ScreenAddress

			lda ScoreAddresses + 1, x
			sta ZP.ScreenAddress + 1

			ldx ZP.StartID

			lda HiByte, x
			sta Scores + 2

			lda MedByte, x
			sta Scores + 1

			lda LowByte, x
			sta Scores

			jsr DrawScore

			inc ZP.StartID

			ldx ZP.X
			inx
			cpx #5
			bcc Loop2





		rts
	}


	DrawScore: {

		ldy #5	// screen offset, right most digit
		ldx #ZERO	// score byte index
		
		ScoreLoop:

			lda Scores,x
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


			clc
			adc #48
			sta (ZP.ScreenAddress), y


			dey
			rts

		}


		rts
	}


	HiScoreLoop: {


		WaitForRasterLine:

			lda VIC.RASTER_LINE
			cmp #175
			bne WaitForRasterLine



		ldy #1
		lda INPUT.FIRE_UP_THIS_FRAME, y
		beq Finish

		jmp MENU.Show

		Finish:

		jmp FrameCode
	}




	FrameCode: {

		jsr ColourRows

		lda ScreenTimer
		beq Ready

		dec ScreenTimer
		jmp HiScoreLoop

		Ready:

		lda #ScreenTime
		sta ScreenTimer

		lda ZP.FrameCounter
		and #%00000001
		beq Flip

		jmp HiScoreLoop

		Flip:

		inc Screen
		lda Screen
		cmp #3
		bcc Okay

		jmp MENU.Show

		Okay:

		jsr PopulateTable


		jmp HiScoreLoop


	}


	NextColour: {

		ldy Colour
		iny
		cpy #8
		bcc Okay


		ldy #1

		Okay:

		sty Colour
		tya

		rts



	}

	ColourRows: {

		lda ColourTimer
		beq Ready

		dec ColourTimer
		rts


		Ready:


		lda #ColourTime
		sta ColourTimer

		ldx #0

		Loop:

			jsr NextColour
			sta COLOR_RAM + 331, x

			jsr NextColour
			sta COLOR_RAM + 451, x

			jsr NextColour
			sta COLOR_RAM + 571, x

			jsr NextColour
			sta COLOR_RAM + 691, x

			jsr NextColour
			sta COLOR_RAM + 811, x

			inx
			cpx #19
			bcc Loop


		rts
	}




	* = $0700 "Hi score_Data"

		FirstInitials:		.text "ASNKBMSSHJRPIBT"
		SecondInitials:		.text "RRJEBKPHYAARNMN"
		ThirdInitials:		.text "LPSVYRZAZMDMCHA"

		HiByte:				.byte $10, $07, $04, $02, $01, $10, $07, $04, $02, $01, $10, $07, $05, $02, $01
		MedByte:			.byte $45, $69, $82, $57, $50, $45, $69, $82, $57, $29, $52, $41, $11, $40, $58
		LowByte:			.byte $23, $12, $70, $63, $78, $91, $52, $46, $02, $08, $99, $31, $47, $28, $12


}