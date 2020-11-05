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
	

	PlayerOne:	.fill Rows * Columns, BLACK
	PlayerTwo:	.fill Rows * Columns, BLACK

	PlayerLookup:	.byte 0, Rows * Columns


	RowLookup:	.fill TotalSquaresOnGrid, floor(i / Columns) * 2
				.fill TotalSquaresOnGrid, floor(i / Columns) * 2

	ColumnLookup:	.fill TotalSquaresOnGrid, PlayerOneStartColumn + (i * 2 - ((floor(i / Columns) * Columns) * 2))
					.fill TotalSquaresOnGrid, PlayerTwoStartColumn + (i * 2 - ((floor(i / Columns) * Columns) * 2))



	RowStart:	.fill 12, i * Columns


	Mode:			.byte 0
	CurrentRow:		.byte LastRowID
	CurrentSide:	.byte 0


	Clear: {

		ldx #143

		Loop:

			stx ZP.X

			lda #BLACK
			sta PlayerOne, x

			jsr ClearSquare

			ldx ZP.X

			dex
			cpx #255
			beq Finish
			jmp Loop


		Finish:


		rts


	}



	Reset: {

		jsr Clear

		lda #LastRowID
		sta CurrentRow

		lda #0
		sta CurrentSide




		rts
	}


	FrameUpdate: {









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