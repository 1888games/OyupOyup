GRID: {

	.label Rows = 12
	.label Columns = 6
	.label RowsPerFrame = 3

	.label TotalSquaresOnGrid = 72
	.label TotalSquaresOnScreen = 144
	.label PlayerOneStartColumn = 2
	.label PlayerTwoStartColumn = 26
	.label LastRowID = 11
	.label LastColumnID = 5
	.label CheckTime = 6
	.label SquashedBean = 233
	.label FirstAnimationFrame = 17

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

	RowsPerFrameUse:	.byte RowsPerFrame



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
	Active:				.byte 1, 1


	// Matching

	Queue:				.fill 32, 0
	Matched:			.fill 32, 0
	QueueLength:		.byte 0
	MatchCount:			.byte 0
	NumberPopped:		.byte 0
	Combo:				.byte 0, 0



	Reset: {

		jsr ClearGrid

		lda #LastRowID
		sta CurrentRow
		sta StartRow

		lda #0
		sta CurrentSide
		sta ZP.BeanType
		sta InitialDrawDone
		sta CheckTimer
		sta CheckTimer + 1
		sta QueueLength
		sta NumberPopped
		sta MatchCount
		sta Combo
		sta Combo + 1

		
		lda #1
		sta NumberMoving
		sta NumberMoving + 1
		sta Mode
		sta Mode + 1
		sta MAIN.GameActive

		lda #RowsPerFrame
		sta RowsPerFrameUse



		rts
	}



	FrameUpdate: {

		lda ZP.FrameCounter
		and #%00001111
		sta ZP.RowRefresh


		CheckIfGameActive:

			lda MAIN.GameActive
			beq Finish

		UpdateLeftSide:

			ldx CurrentSide
			lda Active, x
			beq UpdateRightSide

			jsr UpdateSide

		UpdateRightSide:

			inc CurrentSide
			ldx CurrentSide
			lda Active, x
			beq PrepareForNextFrame

			jsr UpdateSide

		PrepareForNextFrame:

			dec CurrentSide
			lda CurrentRow
			sta StartRow

		Finish:

		rts
	}



	ClearGrid: {

		ldx BottomRightIDs + 1

		Loop:

			stx ZP.X

			EmptyCell:

				lda #BLACK
				sta PlayerOne, x

				jsr GRID_VISUALS.ClearSquare

				lda #255
				sta PreviousType, x

			EndLoop:

				ldx ZP.X
				dex
				cpx #255
				beq Finish

				jmp Loop


		Finish:

		jsr DummyBeans
	
		rts

	}



	DummyBeans: {

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




	StartCheck: {

		lda #GRID_MODE_WAIT_CHECK
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

		cpy #1
		bne NoExplosion

		lda GRID_VISUALS.RowLookup, x
		sta ZP.Row

		lda GRID_VISUALS.ColumnLookup, x
		sta ZP.Column

		lda PlayerOne, x
		sta ZP.BeanColour

		jsr RANDOM.Get
		and #%00000001
		clc
		adc #1
		tax

		ldy ZP.BeanColour

		jsr EXPLOSIONS.StartExplosion

		sfx(SFX_EXPLODE)

		NoExplosion:

		ldx CurrentSide
		lda #1
		sta NumberMoving, x

		rts
	}

	


	Scan: {

		lda #0
		sta QueueLength
		sta MatchCount
		sta NumberPopped

		ldx CurrentSide
		// bne NoStop

		// lda NumberMoving, x
		// .break
		// nop


		// NoStop:
			
		lda PlayerLookup, x
		sta ZP.EndID

		lda CheckProgress, x
		tax
			
		CellLoop:

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
				bne NotEmpty

				jmp Empty

				NotEmpty:

				cmp #16
				beq Empty

				bcc Increase

				Error:

					.break
					nop

				Increase:

				ldy MatchCount
				txa
				sta Matched, y

				inc MatchCount
				

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

				lda #0
				sta MatchCount

				ldx ZP.SlotID
				dex
				cpx ZP.EndID
				beq CompleteScan

				jmp CellLoop


		CompleteScan:
		
			ldx CurrentSide

			lda NumberPopped
			beq NextBeans

			WaitForDrop:

				inc Combo, x		

				lda NumberPopped
				sec
				sbc #2
				bmi NoGarbage

				jsr ROCKS.CalculateChainRocks

				NoGarbage:

				lda Combo, x
				sec
				sbc #2
				bmi NoGarbage2

				jsr ROCKS.CalculateComboRocks

				NoGarbage2: 

				ldx CurrentSide

				lda #PLAYER.PLAYER_STATUS_WAIT
				sta PLAYER.Status, x

				lda #GRID_MODE_NORMAL
				sta Mode, x

				// jsr StartCheck

				// lda #CheckTime
				// asl
				// asl
				// asl
				// sta CheckTimer, x

				jsr ROCKS.StartTransfer

				jmp Finish

			NextBeans:

				ldy CurrentSide

				jsr ROCKS.TransferToQueue

				ldx CurrentSide

				lda #0
				sta Combo, x
				sta Active, x


				
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

		CalculateGarbage:

			ldx CurrentSide
			lda MatchCount
			sec
			sbc #4
			bmi NoGarbage

			jsr ROCKS.CalculateBaseRocks

		NoGarbage:

			ldy MatchCount
			dey

		Loop:
			sty ZP.TempY

			lda Matched, y
			tax
			stx ZP.TempX

			jsr PopBean

			ldx ZP.TempX
			jsr GRID_VISUALS.DrawBean

			ldy ZP.TempY
			dey
			bpl Loop


		NoPop:



		lda #0
		sta MatchCount



		rts
	}




	UpdateReadyToCheck: {

		lda Mode, x
		cmp #GRID_MODE_WAIT_CHECK
		bne Finish

		WaitingForCheck:

			lda CheckTimer, x
			beq ReadyToCheck

			dec CheckTimer, x
			jmp Finish

		ReadyToCheck:

			lda #GRID_MODE_CHECK
			sta Mode, x


		Finish:

			cmp #GRID_MODE_CHECK
			bne NotChecking

			jmp Scan

		NotChecking:


		rts
	}


	EndOfRound: {

		lda #0
		sta Active
		sta Active + 1

		lda #GRID_MODE_PAUSE
		sta Mode
		sta Mode + 1

		inc $d020


		rts
	}



	EndOfCycle: {

		lda #LastRowID
		sta CurrentRow

		lda #1
		sta InitialDrawDone

		ldx CurrentSide

		lda Mode, x
		cmp #GRID_MODE_WAIT_CHECK
		beq StillMoving

		cmp #GRID_MODE_CHECK
		beq StillMoving

		lda NumberMoving, x
		bne StillMoving

		Check:

			lda Mode, x
			cmp #GRID_MODE_FALL
			bne NotGameOver

			EndRound:	


				jsr EndOfRound
				rts

			NotGameOver:

				lda #PLAYER.PLAYER_STATUS_WAIT
				sta PLAYER.Status, x

				jsr StartCheck

		StillMoving:

			lda #0
			sta NumberMoving, x
			sta NumberLanded, x


		rts
	}

	UpdateSide: {

		ldx CurrentSide

		jsr UpdateReadyToCheck

		NormalMode:

			lda StartRow
			sta CurrentRow

			ldy RowsPerFrameUse
			dey

		Loop:

			sty ZP.FrameRow

			lda #0
			sta ZP.BeanType

			jsr UpdateRow

			NextRow:

				dec CurrentRow
				ldx CurrentRow
				bpl EndLoop

			StartAgain:	

				jsr EndOfCycle

			EndLoop:

				ldy ZP.FrameRow
				dey
				bpl Loop

		Finish:
	

		rts
	}

	





	GetStartAndEnd: {

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


		rts
	}



	CheckIfAnimating: {

		DefaultSingleBean:

			lda #0
			sta CurrentType, x

		IfMinusCantBe:

			lda PreviousType, x
			sta ZP.PreviousType
			bmi Finish

		CheckPopAnimation:

			cmp #LastPoppedFrame
			bcc Finish

		AnimatePop:

			tay
			jsr GRID_VISUALS.UpdateAnimation

			ldx ZP.CurrentSlot

		Finish:


		rts
	}





	CheckLeftBean: {

		cpx ZP.StartID
		beq Finish

		NotFarLeft:

			dex
			lda PlayerOne, x
			inx
			cmp ZP.BeanColour
			bne Finish

			MatchToLeft:

				lda ZP.BeanType
				ora #LEFT
				sta ZP.BeanType

		Finish:


		rts
	}

	CheckAboveBean: {

		ldx ZP.CurrentSlot
		lda CurrentRow
		beq Finish

		txa
		sec
		sbc #Columns
		tax

		lda PlayerOne, x
		cmp ZP.BeanColour
		bne Finish

		MatchUp:

			lda ZP.BeanType
			ora #UP
			sta ZP.BeanType

		Finish:


		rts
	}

	CheckRightBean: {

		CheckFarRight:

			ldx ZP.CurrentSlot
			inx
			cpx ZP.EndID
			beq Finish

		NotFarRight:

			lda PlayerOne, x
			dex
			cmp ZP.BeanColour
			bne Finish

		MatchToRight:

			lda ZP.BeanType
			ora #RIGHT
			sta ZP.BeanType

		Finish:

		rts
	}


	FallDown: {

		CheckIfBottomRow:

			lda CurrentRow
			cmp #LastRowID
			beq DeleteOldGridSpace

		NotBottomRow:

			txa
			clc
			adc #Columns
			tax

		CheckBeanBelow:

			lda PlayerOne, x
			beq TransferDataBelow

			ldx CurrentSide
			inc NumberMoving, x

			jmp Finish

		TransferDataBelow:

			lda ZP.BeanColour
			sta PlayerOne, x

			lda #BeanFallingType
			sta CurrentType, x
			sta ZP.BeanType

			lda #255
			sta PreviousType, x

			jsr GRID_VISUALS.DrawBean

		PreventCheckFiring:

			ldx CurrentSide
			inc NumberMoving, x

		DeleteOldGridSpace:

			ldx ZP.CurrentSlot
			lda #0
			sta PlayerOne, x

			lda #255
			sta PreviousType, x

			jsr GRID_VISUALS.ClearSquare

		Finish:
		

		rts

	}

	UpdateRow: {

		jsr GetStartAndEnd

		Loop:

			stx ZP.CurrentSlot

			jsr CheckIfAnimating
			
			CheckIfEmpty:

				lda PlayerOne, x
				sta ZP.BeanColour
				bne CheckLeft

				jmp EndLoop

			CheckInitialDraw:

				lda InitialDrawDone
				bne CheckLeft
				jmp Draw

			CheckLeft:

				jsr CheckLeftBean

			CheckDown:

					lda CurrentRow
					cmp #LastRowID
					beq BottomRow

				NotBottomRow:

					txa
					clc
					adc #Columns
					tax

				CheckBeanBelow:

					lda PlayerOne, x
					beq MoveBeanDown

					jmp SolidBelow

				BottomRow:

					ldy CurrentSide
					lda Mode, y
					cmp #GRID_MODE_FALL
					bne SolidBelow

					tya
					tax
					inc NumberMoving, x

					jmp DeleteOldGridSpace

				SolidBelow:
				
					ldy ZP.PreviousType
					bmi NotAnimating

					cpy #BeanFallingType
					beq FinishedFalling

					cpy #FirstAnimationFrame
					bcc NotAnimating

				Animating:

					jsr GRID_VISUALS.UpdateAnimation
					jmp Draw

				FinishedFalling:

					ldx ZP.CurrentSlot
					lda #BeanLandedType
					sta ZP.BeanType

				PreventCheckFiring:

					ldx CurrentSide	
					inc NumberMoving, x

				CheckSoundToPlay:


					lda ZP.BeanColour
					cmp #CYAN
					beq IsRock

					IsBean:

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

				MatchBelow:

					lda ZP.BeanType
					ora #DOWN
					sta ZP.BeanType
					jmp CheckUp

				MoveBeanDown:

					lda ZP.BeanColour
					sta PlayerOne, x

					lda #BeanFallingType
					sta CurrentType, x
					sta ZP.BeanType

					lda #255
					sta PreviousType, x

					jsr GRID_VISUALS.DrawBean

				PreventCheckFiring2:

					ldx CurrentSide
					inc NumberMoving, x

				DeleteOldGridSpace:

					ldx ZP.CurrentSlot
					lda #0
					sta PlayerOne, x

					lda #255
					sta PreviousType, x

					jsr GRID_VISUALS.ClearSquare
					jmp ResetForNextBean

			CheckUp:

				jsr CheckAboveBean
				jsr CheckRightBean
			
			Draw:

				ldx ZP.CurrentSlot
				lda ZP.BeanType
				sta CurrentType, x
				jsr GRID_VISUALS.DrawBean

			ResetForNextBean:

			EndLoop:

				lda #0
				sta ZP.BeanType

				ldx ZP.CurrentSlot
				inx
				cpx ZP.EndID
				beq Finish

				jmp Loop


		Finish:

		

		rts
	}


	


}