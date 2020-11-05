GRID: {



	.label Rows = 12
	.label Columns = 6
	.label BackgroundCharID = 202
	.label TotalSquaresOnGrid = 72
	.label TotalSquaresOnScreen = 144
	.label PlayerOneStartColumn = 2
	.label PlayerTwoStartColumn = 26
	.label LastRowID = 11
	.label LastColumnID = 5
	

	PlayerOne:	.fill Rows * Columns, GREEN
	PlayerTwo:	.fill Rows * Columns, BLACK

	PlayerLookup:	.byte 0, Rows * Columns


	RowLookup:	.fill TotalSquaresOnGrid, floor(i / Columns) * 2
				.fill TotalSquaresOnGrid, floor(i / Columns) * 2

	ColumnLookup:	.fill TotalSquaresOnGrid, PlayerOneStartColumn + (i * 2 - ((floor(i / Columns) * Columns) * 2))
					.fill TotalSquaresOnGrid, PlayerTwoStartColumn + (i * 2 - ((floor(i / Columns) * Columns) * 2))

	RowStart:	.fill 12, (i * Columns)


	Mode:			.byte 0
	CurrentRow:		.byte LastRowID
	CurrentSide:	.byte 0


	Clear: {

		ldx #143

		Loop:

			stx ZP.X

			lda #BLACK

			jsr RANDOM.Get
			and #%00000111
			sta PlayerOne, x

			jsr ClearSquare

			ldx ZP.X

			dex
			cpx #255
			beq Finish
			jmp Loop


		Finish:

		lda #RED
		sta PlayerOne


		rts


	}



	Reset: {

		jsr Clear

		lda #LastRowID
		sta CurrentRow

		lda #0
		sta CurrentSide
		sta ZP.BeanType




		rts
	}


	FrameUpdate: {

		inc $d020

		jsr UpdateRow

		inc CurrentSide
		jsr UpdateRow

		ldx CurrentRow
		dex
		stx CurrentRow
		bpl Finish

		lda #LastRowID
		sta CurrentRow

		Finish:

		dec CurrentSide
		dec $d020


		rts
	}


	UpdateRow: {

		GetFirstGridID:

			ldx CurrentRow
			lda RowStart, x
			sta ZP.StartID

		AddIfRightSide:

			ldy CurrentSide
			lda PlayerLookup, y
			clc
			adc ZP.StartID
			sta ZP.StartID

		CalculateEndID:

			clc
			adc #Columns
			sta ZP.EndID


		ldx ZP.StartID

		Loop:

			stx ZP.X

			lda PlayerOne, x
			sta ZP.BeanColour
			beq EndLoop

			CheckLeft:

				cpx ZP.StartID
				beq CheckDown

				dex
				lda PlayerOne, x
				inx
				cmp ZP.BeanColour
				bne CheckDown

				MatchToLeft:

					lda ZP.BeanType
					ora #LEFT
					sta ZP.BeanType


			CheckDown:

				lda CurrentRow
				cmp #LastRowID
				beq CheckUp

				txa
				clc
				adc #Columns
				tax

				lda PlayerOne, x
				beq EmptyBelow

				cmp ZP.BeanColour
				bne CheckUp

				MatchAbove:

					lda ZP.BeanType
					ora #DOWN
					sta ZP.BeanType
					jmp CheckUp


				EmptyBelow:

					//.break
					nop


			CheckUp:

				ldx ZP.X

				lda CurrentRow
				beq CheckRight

				txa
				sec
				sbc #6
				tax

				lda PlayerOne, x
				cmp ZP.BeanColour
				bne CheckRight

				MatchUp:

					lda ZP.BeanType
					ora #UP
					sta ZP.BeanType


			CheckRight:

				ldx ZP.X
				inx
				cpx ZP.EndID
				beq Draw

				lda PlayerOne, x
				dex
				cmp ZP.BeanColour
				bne Draw

				MatchToRight:

					lda ZP.BeanType
					ora #RIGHT
					sta ZP.BeanType


			Draw:

				jsr DrawBean


			ResetForNextBean:

				lda #0
				sta ZP.BeanType
		
			EndLoop:

				ldx ZP.X
				inx
				cpx ZP.EndID
				bcc Loop



		rts
	}


	DrawBean: {

		ldx ZP.X

		lda RowLookup, x
		sta ZP.Row

		lda ColumnLookup, x
		sta ZP.Column

		TopLeft:

			ldy ZP.BeanType
			lda BEAN.Chars, y
			clc
			adc #3
			sta ZP.CharID

			ldx ZP.Column
			ldy ZP.Row

			jsr DRAW.PlotCharacter

			lda ZP.BeanColour
			clc
			adc #8

			jsr DRAW.ColorCharacter

		TopRight:

			ldy #1

			dec ZP.CharID
			lda ZP.CharID

			sta (ZP.ScreenAddress), y

			lda ZP.BeanColour
			clc
			adc #8
			sta (ZP.ColourAddress), y


		BottomRight:

			ldy #41

			dec ZP.CharID
			lda ZP.CharID

			sta (ZP.ScreenAddress), y

			lda ZP.BeanColour
			clc
			adc #8
			sta (ZP.ColourAddress), y


		BottomLeft:

			ldy #40

			dec ZP.CharID
			lda ZP.CharID

			sta (ZP.ScreenAddress), y

			lda ZP.BeanColour
			clc
			adc #8
			sta (ZP.ColourAddress), y






		rts
	}


	ClearSquare: {

		lda RowLookup, x
		sta ZP.Row

		lda ColumnLookup, x
		sta ZP.Column

		TopLeft:

			lda #BackgroundCharID
			sta ZP.CharID

			ldx ZP.Column
			ldy ZP.Row

			jsr DRAW.PlotCharacter

			lda #GREEN

			jsr DRAW.ColorCharacter


		TopRight:

			ldy #1

			inc ZP.CharID
			lda ZP.CharID

			sta (ZP.ScreenAddress), y

			lda #PURPLE
			sta (ZP.ColourAddress), y

		BottomLeft:

			ldy #40

			inc ZP.CharID
			lda ZP.CharID

			sta (ZP.ScreenAddress), y

			lda #YELLOW
			sta (ZP.ColourAddress), y


		BottomRight:


			ldy #41

			inc ZP.CharID
			lda ZP.CharID

			sta (ZP.ScreenAddress), y

			lda #CYAN
			sta (ZP.ColourAddress), y






		rts
	}

	
}