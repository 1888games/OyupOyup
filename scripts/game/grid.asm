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
	.label CheckTime = 30

	
	* = * "Grid Data"

	PlayerOne:	.fill Rows * Columns, GREEN
	PlayerTwo:	.fill Rows * Columns, BLACK

	PreviousType:	.fill TotalSquaresOnScreen, 99

	PlayerLookup:	.byte 0, Rows * Columns


	RowLookup:	.fill TotalSquaresOnGrid, floor(i / Columns) * 2
				.fill TotalSquaresOnGrid, floor(i / Columns) * 2

	ColumnLookup:	.fill TotalSquaresOnGrid, PlayerOneStartColumn + (i * 2 - ((floor(i / Columns) * Columns) * 2))
					.fill TotalSquaresOnGrid, PlayerTwoStartColumn + (i * 2 - ((floor(i / Columns) * Columns) * 2))

	RowStart:	.fill 12, (i * Columns)
	BottomRightIDs:	.byte 71, 143



	CurrentRow:			.byte LastRowID
	StartRow:			.byte LastRowID

	CurrentSide:		.byte 0
	InitialDrawDone:	.byte 0


	CheckTimer:			.byte 255, 255
	Mode:				.byte 0, 0
	CheckProgress:		.byte 0, 0

	QueueLength:		.byte 0, 0
	QueueColour:		.byte 0, 0
	QueueLeft: 			.fill 32, 0
	QueueRight:			.fill 32, 0


	Clear: {

		ldx BottomRightIDs + 1

		Loop:

			stx ZP.X


			jsr RANDOM.Get
			and #%00000111

			lda #BLACK
			sta PlayerOne, x

			jsr ClearSquare

			lda #99
			sta PreviousType, x

			ldx ZP.X

			dex
			cpx #255
			beq Finish
			jmp Loop


		Finish:

			ldy #0

		Loop2:

			sty ZP.TempY

			jsr RANDOM.Get
			and #%01111111
			tax

			jsr RANDOM.Get
			and #%00000111	

			sta PlayerOne, x

			ldy ZP.TempY

			iny
			cpy #50
			bcc Loop2


		lda #1
		sta MAIN.GameActive

		
		rts


	}





	Reset: {

		jsr Clear

		lda #LastRowID
		sta CurrentRow
		sta StartRow

		lda #0
		sta CurrentSide
		sta ZP.BeanType
		sta InitialDrawDone

		lda #255
		sta CheckTimer
		sta CheckTimer + 1


		rts
	}




	CheckGrid: {

		rts

		CheckIfAlreadyInCheckMode:

			ldx CurrentSide
			lda Mode, x
			cmp #GRID_MODE_CHECK
			beq Checking

		CheckIfNotAboutToCheck:

			lda CheckTimer, x
			bmi Finish

		CheckIfTimerZeroYet:

			beq ReadyToCheck

		DecreaseTimer:

			dec CheckTimer, x
			jmp Finish

		ReadyToCheck:

			lda #GRID_MODE_CHECK
			sta Mode, x

			lda BottomRightIDs, x
			sta CheckProgress, x

			jsr NextSlot


		Checking:

			jsr DoScan


		Finish:

		rts
	}



	NextSlot: {


		lda CheckProgress, x
		bne SlotIsOccupied

		MoveToNextSlot:

			dec CheckProgress, x
			bne NextSlot

			jsr CheckComplete
			jmp Finish

		SlotIsOccupied:

			ldy CurrentSide
			beq Left

		Right:

			sta QueueRight, x
			jmp Done

		Left:

			sta QueueLeft, x

		Done:

		lda #1
		sta QueueLength

		Finish:


		rts
	}



	ProcessSlot: {

		ldy CurrentSide
		lda QueueLength, y
		tax
		dex

		cpy #0
		beq Left

		Right:

			lda QueueRight, x
			jmp GetSlotInfo

		Left:

			lda QueueLeft, x

		GetSlotInfo:	

			sta ZP.SlotID
			tax
			lda RowLookup, x
			sta ZP.Row

			lda ColumnLookup, x
			sta ZP.Column



		rts
	}

	DoScan: {

		lda QueueLength, x
		bne ProcessNextInQueue

		QueueEmpty:

			dec CheckProgress, x
			beq CheckCompleted

			jsr NextSlot

		ProcessNextInQueue:

			jsr ProcessSlot

		jmp Finish

		CheckCompleted:

			jsr CheckComplete

		Finish:


		rts
	}


	CheckComplete: {

		lda #255
		sta CheckTimer, x

		lda #GRID_MODE_NORMAL
		sta Mode, x


		rts
	}



	UpdateSide: {

		jsr CheckGrid

		ldy CurrentSide

		lda Mode, y
		bne Finish

		ldy #3

		lda StartRow
		sta CurrentRow

		Loop:

			sty ZP.Y

			jsr UpdateRow

			ldx CurrentRow
			dex
			stx CurrentRow
			bpl EndLoop

			lda #LastRowID
			sta CurrentRow

			lda #1
			sta InitialDrawDone

			EndLoop:

				ldy ZP.Y
				dey
				bpl Loop


		

		Finish:
	




		rts
	}

	FrameUpdate: {


		lda MAIN.GameActive
		beq Finish

		jsr UpdateSide

		inc CurrentSide
		jsr UpdateSide

		dec CurrentSide

		lda CurrentRow
		sta StartRow


		Finish:

		
	//	dec $d020

		rts
	}




	UpdateRow: {

		lda #0
		sta ZP.BeanType

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
			bne CheckLeft

			jmp EndLoop

			CheckLeft:

				lda InitialDrawDone
				bne Continue

				jmp Draw

				Continue:

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

					lda ZP.BeanColour
					sta PlayerOne, x

					lda #99
					sta PreviousType, x

					jsr DrawBean

					ldx ZP.X
					lda #0
					sta PlayerOne, x

					lda #99
					sta PreviousType, x

					ldy CurrentSide
					lda #CheckTime
					sta CheckTimer, y

					jsr ClearSquare
					jmp ResetForNextBean


			CheckUp:

				ldx ZP.X

				lda CurrentRow
				beq CheckRight

				txa
				sec
				sbc #Columns
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

				ldx ZP.X
				jsr DrawBean

			ResetForNextBean:

				lda #0
				sta ZP.BeanType
		
			EndLoop:

				ldx ZP.X
				inx
				cpx ZP.EndID
				beq Finish

				jmp Loop


		Finish:



		rts
	}


	DrawBean: {

		lda ZP.BeanType
		cmp PreviousType, x
		beq Finish

		lda RowLookup, x
		sta ZP.Row

		lda ColumnLookup, x
		sta ZP.Column

		TopLeft:

			lda ZP.BeanType
			sta PreviousType, x
			tay

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


		Finish:



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