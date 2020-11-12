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
	.label CheckTime = 10
	.label SquashedBean = 233

	.label BeanFallingType = 22
	.label BeanLandedType = BeanFallingType - 1
	.label BeanPoppedType = 25

	.label LastPoppedFrame = 23

	
	* = * "Grid Data"

	PlayerOne:	.fill Rows * Columns, GREEN
	PlayerTwo:	.fill Rows * Columns, BLACK

	Checked:	.fill TotalSquaresOnScreen, 0

	CurrentType:	.fill TotalSquaresOnScreen, 255
	PreviousType:	.fill TotalSquaresOnScreen, 255

	PlayerLookup:	.byte 0, Rows * Columns


	RowLookup:	.fill TotalSquaresOnGrid, 1 + (floor(i / Columns) * 2)
				.fill TotalSquaresOnGrid, 1 + (floor(i / Columns) * 2)

	ColumnLookup:	.fill TotalSquaresOnGrid, PlayerOneStartColumn + (i * 2 - ((floor(i / Columns) * Columns) * 2))
					.fill TotalSquaresOnGrid, PlayerTwoStartColumn + (i * 2 - ((floor(i / Columns) * Columns) * 2))

	RelativeColumn:	.fill TotalSquaresOnScreen, [0,1,2,3,4,5]


	RowStart:	.fill 12, (i * Columns)
	BottomRightIDs:	.byte 71, 143

	BackgroundCharIDs:	.byte 202, 203, 204, 205, 202, 203
	BackgroundColours:	.byte GREEN, PURPLE, YELLOW, CYAN, GREEN, PURPLE


	CurrentRow:			.byte LastRowID
	StartRow:			.byte LastRowID

	CurrentSide:		.byte 0
	InitialDrawDone:	.byte 0


	CheckTimer:			.byte 0, 0
	Mode:				.byte 1, 1
	CheckProgress:		.byte 0, 0
	NumberMoving:		.byte 1, 1
	NumberLanded:		.byte 0, 0

	QueueLength:		.byte 0
	QueueColour:		.byte 0
	Queue:				.fill 32, 0
	MatchCount:			.byte 0
	Matched:			.fill 32, 0
	NumberPopped:		.byte 0
	Combo:				.byte 0, 0




	Clear: {

		ldx BottomRightIDs + 1

		Loop:

			stx ZP.X


			jsr RANDOM.Get
			and #%00000111

			lda #BLACK
			sta PlayerOne, x

			jsr ClearSquare

			lda #255
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
			and #%00111111
			tax

			jsr RANDOM.Get
			and #%00000001
			sta PlayerOne, x

			jsr RANDOM.Get
			and #%00000011	
			clc
			adc PlayerOne, x
			tay
			lda PANEL.Colours, y
			sta PlayerOne, x

			ldy ZP.TempY

			iny
			cpy #40
			bcc Loop2

		lda #CYAN
		sta PlayerOne


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

		lda #0
		sta CheckTimer
		sta CheckTimer + 1

		lda #1
		sta NumberMoving
		sta NumberMoving + 1
		sta Mode
		sta Mode + 1


		lda #1
		sta MAIN.GameActive

		


		rts
	}



	StartCheck: {

		lda #GRID_MODE_CHECK
		sta Mode, x

		lda BottomRightIDs, x
		sta CheckProgress, x
		tay
		sec
		sbc #72
		sta ZP.EndID

		lda #CheckTime
		sta CheckTimer, x

		lda #0

		Loop:

			sta Checked, y

			dey
			cpy ZP.EndID
			bne Loop


	

		rts
	}





	PopBean: {


		lda #BeanPoppedType
		sta CurrentType, x

		lda RowLookup, x
		sta ZP.Row

		lda ColumnLookup, x
		sta ZP.Column


		jsr RANDOM.Get
		and #%00000001
		clc
		adc #1
		tax

		ldy ZP.BeanColour

		jsr EXPLOSIONS.StartExplosion


		rts
	}

	


	CheckComplete: {

		lda #255
		sta CheckTimer, x

		lda #GRID_MODE_NORMAL
		sta Mode, x


		rts
	}



	CheckGrid: {



		CheckIfTimerZeroYet:

			lda CheckTimer, x
			beq ReadyToCheck

		DecreaseTimer:

			dec CheckTimer, x
			jmp Finish

		ReadyToCheck:	

			jsr Scan


		Finish:

		rts
	}


	Scan: {

		lda #0
		sta QueueLength
		sta MatchCount
		sta NumberPopped

	
			
		lda PlayerLookup, x
		sta ZP.EndID

		lda CheckProgress, x
		tax
			
		CellLoop:

			stx ZP.X
			stx ZP.SlotID

			CheckWhichCellToLookAt:

				ldy QueueLength
				beq UseNextCell

			UseQueue:

				dey
				sty QueueLength
				lda Queue, y
				tax
				sta ZP.SlotID

			UseNextCell:

				lda Checked, x
				beq CheckIfCellEmpty

			AlreadyChecked:

				jmp EndCellLoop

			CheckIfCellEmpty:

				lda PlayerOne, x
				bne CheckIfRockOrSingle

				jmp Empty

			CheckIfRockOrSingle:

				lda CurrentType, x
				sta ZP.BeanType
				beq Empty

				cmp #16
				beq Empty

				ldy MatchCount
				txa
				sta Matched, y

				inc MatchCount
				//lda MatchCount

			CheckRight:

					lda ZP.BeanType
					and #RIGHT
					beq CheckLeft

				MatchToRight:

					ldx ZP.SlotID
					inx
					lda Checked, x
					bne CheckLeft

				AddToQueueRight:

					ldy QueueLength
					txa
					sta Queue, y
					inc QueueLength

			CheckLeft:

					lda ZP.BeanType
					and #LEFT
					beq CheckDown

				MatchToLeft:

					ldx ZP.SlotID
					dex
					lda Checked, x
					bne CheckDown

				AddToQueueLeft:

					ldy QueueLength
					txa
					sta Queue, y
					inc QueueLength

			CheckDown:

					lda ZP.BeanType
					and #DOWN
					beq CheckUp

				MatchToDown:

					lda ZP.SlotID
					clc
					adc #6
					tax
					lda Checked, x
					bne CheckUp

				AddToQueueDown:

					ldy QueueLength
					txa
					sta Queue, y
					inc QueueLength

			CheckUp:

					lda ZP.BeanType
					and #UP
					beq EndCellLoop

				MatchToUp:

					lda ZP.SlotID
					sec
					sbc #6
					tax
					lda Checked, x
					bne EndCellLoop

				AddToQueueUp:

					ldy QueueLength
					txa
					sta Queue, y
					inc QueueLength

					jmp EndCellLoop

			Empty:

			EndCellLoop:

				ldx ZP.SlotID
				lda #1	
				sta Checked, x

			CheckItemsInQueue:

				lda QueueLength
				bne ItemsInQueue

				jsr CheckHowManyMatched

				jmp NextCell

			ItemsInQueue:

				jmp CellLoop

			NextCell:

				ldx ZP.X
				dex
				cpx ZP.EndID
				beq CompleteScan

				jmp CellLoop


		CompleteScan:

		
			ldx CurrentSide

			lda NumberPopped
			beq NextBeans

			//WaitForDrop:

					lda #PLAYER.PLAYER_STATUS_WAIT
					sta PLAYER.Status, x

					lda #GRID_MODE_NORMAL
					sta Mode, x

					jmp Finish

			NextBeans:

				lda #GRID_MODE_PAUSE
				sta Mode, x

				lda #1
				sta PANEL.Mode, x

				lda #0
				sta PANEL.Mode + 1

		Finish:



		rts
	}


	CheckHowManyMatched: {


		lda MatchCount
		cmp #4
		bcc NoPop

		inc NumberPopped

		lda NumberPopped
		cmp #2
		bcs NoSfx

		sfx(SFX_BLOOP)


		NoSfx:


		ldy MatchCount
		dey

		
		Loop:
			sty ZP.TempY

			lda Matched, y
			tax
			stx ZP.TempX

			jsr PopBean

			ldx ZP.TempX
			jsr DrawBean

			ldy ZP.TempY
			dey
			bpl Loop


		NoPop:

		lda #0
		sta MatchCount


		rts
	}

	UpdateSide: {

		ldx CurrentSide

		lda Mode, x
		cmp #GRID_MODE_CHECK
		bne NotChecking

		jsr CheckGrid
		jmp Finish
			

		NotChecking:


			cmp #GRID_MODE_PAUSE
			beq Finish

		NormalMode:

			ldy #2

			lda StartRow
			sta CurrentRow

		Loop:

			sty ZP.Y

			jsr UpdateRow

			ldx CurrentRow
			dex
			stx CurrentRow
			bpl EndLoop


			StartAgain:

				ldy ZP.Y

				lda #LastRowID
				sta CurrentRow

				lda #1
				sta InitialDrawDone

				ldx CurrentSide

				lda NumberMoving, x
				bne StillMoving

				Check:

				lda #1
				sta PLAYER.Status, x

				jsr StartCheck

			StillMoving:

				lda #0
				sta NumberMoving, x
				sta NumberLanded, x

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






	UpdateAnimation: {

		ldx CurrentSide
		inc NumberMoving, x

		dey
		sty ZP.BeanType

		cpy #16
		beq Reset

		cpy #BeanFallingType
		beq Remove

		
		rts

		Remove:

			ldx ZP.X
			lda #0
			sta PlayerOne, x

			lda #255
			//sta CurrentType, x
			sta PreviousType, x

			jsr ClearSquare
			sfx(SFX_EXPLODE)



		Reset:	

			ldx ZP.X
			lda #0
			sta ZP.BeanType

			ldy CurrentSide
			lda PLAYER.Status, y
			cmp #PLAYER.PLAYER_STATUS_PLACED
			bne Okay

			lda #PLAYER.PLAYER_STATUS_WAIT
			sta PLAYER.Status, y


		Okay:



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

			lda #0
			sta CurrentType, x

			lda PreviousType, x
			sta ZP.PreviousType
			bmi CheckIfEmpty

			cmp #LastPoppedFrame
			bcc CheckIfEmpty

			AnimatePop:

				tay
				jsr UpdateAnimation
				ldx ZP.X

			CheckIfEmpty:

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
				beq SolidBelow

				txa
				clc
				adc #Columns
				tax

				lda PlayerOne, x
				beq EmptyBelow

				SolidBelow:


					jsr RANDOM.Get
					cmp #1
					bcs NoPop

				//	jsr PopBean
				//	jmp Draw

				NoPop:

					ldy ZP.PreviousType
					bmi NotAnimating

					cpy #BeanFallingType
					beq FinishedFalling

					cpy #17
					bcc NotAnimating

					jsr UpdateAnimation
					jmp Draw

				FinishedFalling:

					ldx ZP.X
					lda #BeanLandedType
					sta ZP.BeanType

					ldx CurrentSide	
					inc NumberLanded, x


					lda ZP.BeanColour
					cmp #CYAN
					beq IsRock

					sfx(SFX_EXPLODE)
					jmp Draw


					IsRock:

					sfx(SFX_LAND)

					jmp Draw

				NotAnimating:

					lda CurrentRow
					cmp #LastRowID
					beq CheckUp

					lda PlayerOne, x
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

					lda #BeanFallingType
					sta CurrentType, x

					lda #255
					sta PreviousType, x

					jsr DrawBean

					ldx CurrentSide
					inc NumberMoving, x

					ldx ZP.X
					lda #0
					sta PlayerOne, x

					lda #255
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
				lda ZP.BeanType
				sta CurrentType, x
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

		lda ZP.BeanColour
		cmp #CYAN
		bne NotRock

		lda #16
		sta CurrentType, x

		NotRock:

		lda CurrentType, x
		cmp PreviousType, x
		beq Finish

		lda RowLookup, x
		sta ZP.Row

		lda ColumnLookup, x
		sta ZP.Column

		TopLeft:

				lda CurrentType, x
				sta PreviousType, x
				tay

				lda BEAN.Chars, y
				clc
				adc #3
				sta ZP.CharID

			TimeToDraw:

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