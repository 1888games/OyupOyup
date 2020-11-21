ROCKS: {


	* = * "Rocks"


	.label FullCharID = 106
	.label SingleCharID = 105
	.label ComboTime = 50
	.label Stage1Time = 20
	.label Stage2Time = 40
	.label FrameTime = 6


	.label ComboStartPointer = 44
	.label ComboEndPointer  = 52
	.label BlobStartPointer = 16
	.label BlobEndPointer = 19

	.label Stage2Speed = 8
	.label Stage2Speed_Y = 6
	


	Count:			.byte 0, 0
	PendingCount:	.byte 0, 0
	PreviousCount:	.byte 0, 0
	FullCount:		.byte 0
	SingleCount:	.byte 0
	ColumnsDrawn:	.byte 0
	Mode:			.byte 0, 0

	* = * "Queue"

	Queue:		.byte 0, 0, 0, 0, 0, 0
				.byte 0, 0, 0, 0, 0, 0


	XPos_MSB:		.byte 0, 0
	XPos_LSB:		.byte 0, 0
	YPos:			.byte 0, 0
	Speed:			.byte 0, 0
	Frame:			.byte 0, 0
	Stage:			.byte 0, 0
	StageTimer:		.byte 0, 0
	FrameTimer:		.byte 0, 0
	FrameDirection:	.byte 1, 1

	StageTimes:		.byte 20, 40

	TargetXPos_MSB:	.byte 0, 0
	TargetXPos_LSB:	.byte 0, 0
	TargetYPos:		.byte 0, 0

	ComboTimer:		.byte 0, 0
	ComboFrame:		.byte 0, 0

	GridOffset:		.byte 0, 66

	DropTimeout:	.byte 0

		
	SpriteLookup:	.byte 0, 2, 4, 6, 8, 10, 12, 14
	

	Order:					.byte 6, 7, 5, 8, 4, 9, 3, 10, 2, 11, 1, 0
	BackgroundCharOrder:	.byte 34, 35, 39, 38, 34, 35, 39, 38, 34, 35, 39, 38
	BackgroundColourOrder:	.byte PURPLE, YELLOW, CYAN, GREEN, PURPLE, YELLOW, CYAN, GREEN, PURPLE, YELLOW, CYAN, GREEN
	BackgroundCharIDs:		.byte 34, 35, 38, 39

	DropColumns:	.byte 0, 0, 0, 1, 1, 1, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5
	QueueOrder:		.byte 2, 3, 1, 4, 0, 5

	ColumnAdd:		.byte 2, 26
	QueueOffset:	.byte 0, 6
	Opponent:		.byte 1, 0
	Colours:		.byte RED, BLUE
	Colours2:		.byte LIGHT_RED, LIGHT_BLUE
	TargetColumns:	.byte 7, 32

	BaseLookup:		.byte 1, 2, 4, 5, 7, 10, 14, 19, 25  //4-12
	ChainLookup:	.byte 0, 3, 10, 27, 68, 90		// 1 - 6
	ComboLookup:	.byte 0, 5, 14, 32, 69, 90		// 1 - 6


	BaseScore:		.byte 5, 18, 28, 40, 54, 70, 88, 108, 130   //4-12
	ChainScore:		.byte 24, 48, 96, 192, 255
	ComboScore:		.byte 36, 72, 144, 216, 255

	RockLookupAdd:	.byte 0
	SecondsTimer:	.byte 0
	SecondsCounter:	.byte 0
	GameSeconds:	.byte 0
	FramesPerSecond:	.byte 50
	RampUpTime:		.byte 90



	Reset: {

		lda #0
		sta Count + 0
		sta Count + 1
		sta PreviousCount + 0
		sta PreviousCount + 1
		sta RockLookupAdd
		sta FullCount
		sta PendingCount
		sta PendingCount + 1

		lda FramesPerSecond
		sta SecondsTimer

		lda #0
		sta GameSeconds
		sta SecondsCounter
		sta SecondsTimer
		sta RockLookupAdd
		sta DropTimeout
		sta ComboTimer 
		sta ComboTimer + 1
		sta ComboFrame
		sta ComboFrame + 1
		sta Stage
		sta Stage + 1
		sta Mode
		sta Mode + 1

		ldx #0
		lda #0

		Loop:

			sta Queue, x
			inx 
			cpx #12
			bcc Loop

		rts
	}



	StartTransfer: {

		lda #BlobStartPointer
		sta SPRITE_POINTERS + 2, x
		sta Frame, x

		lda StageTimes
		sta StageTimer, x

		lda #FrameTime
		sta FrameTimer, x

		lda #1
		sta FrameDirection, x

		lda Colours, x
		sta VIC.SPRITE_COLOR_2, x

		lda Count, x
		beq HeadForOpponent

		HeadForOwn:

			ldy #0
			lda EXPLOSIONS.YPos, y
			sta TargetYPos, x

			lda TargetColumns, x
			tay
			lda EXPLOSIONS.XPosLSB, y
			sta TargetXPos_LSB, x

			lda EXPLOSIONS.XPosMSB, y
			sta TargetXPos_MSB, x
			jmp GetInitialPosition

		HeadForOpponent:

			ldy #0
			lda EXPLOSIONS.YPos, y
			sta TargetYPos, x

			lda Opponent, x
			tax

			lda TargetColumns, x
			tay

			lda Opponent, x
			tax

			lda EXPLOSIONS.XPosLSB, y
			sta TargetXPos_LSB, x

			lda EXPLOSIONS.XPosMSB, y
			sta TargetXPos_MSB, x

		GetInitialPosition:


			ldy ZP.Row
			iny
			lda EXPLOSIONS.YPos, y
			sta YPos, x

			ldy ZP.Column
			lda EXPLOSIONS.XPosLSB, y
			sta XPos_LSB, x

		CalcMSB:

			lda EXPLOSIONS.XPosMSB, y
			sta XPos_MSB, x


		rts
	}



	TransferToQueue: {

	

		ldy GRID.CurrentSide

		lda Count, y
		bne AreRocks

		NoRocks:

			lda #1
			sta PANEL.Mode, y
			sta PLAYER.Status, y

			lda #0
			sta Mode
			rts

		AreRocks:

			lda #1
			sta Mode, y

			lda QueueOffset, y
			sta ZP.Offset
			tax

		Loop:

			lda Count, y
			sec
			sbc #6
			bpl FullRow

			lda Count, y
			tay

			PartialLoop:

				jsr RANDOM.Get
				and #%00000111
				cmp #6
				bcs PartialLoop
				clc
				adc ZP.Offset
				tax

				inc Queue, x

				dey
				bne PartialLoop

				jmp Finish


			FullRow:

				sta Count, y

				ldx ZP.Offset

				inc Queue + 0, x
				inc Queue + 1, x
				inc Queue + 2, x
				inc Queue + 3, x
				inc Queue + 4, x
				inc Queue + 5, x

				jmp Loop


		Finish:

			ldx GRID.CurrentSide
			lda #0
			sta Count, x

		rts
	}


	
	Delete: {

		lda #0
		sta Frame, x

		lda #0
		sta VIC.SPRITE_2_Y, x

		rts

	}

	HeadForTop: {

		inc GRID.NumberMoving, x

		MoveX:

			lda TargetXPos_MSB, x
			cmp XPos_MSB, x
			beq CheckLSB

			bcc GoLeft
			jmp GoRight

		CheckLSB:

			lda TargetXPos_LSB, x
			cmp XPos_LSB, x
			bcc GoLeft
			beq MoveY


		GoRight:

			lda XPos_LSB, x
			clc
			adc #Stage2Speed
			sta XPos_LSB, x

			lda XPos_MSB, x
			adc #0
			sta XPos_MSB, x

			cmp TargetXPos_MSB, x
			bne MoveY

			lda XPos_LSB, x
			cmp TargetXPos_LSB, x
			bcc MoveY

			lda TargetXPos_LSB, x
			sta XPos_LSB, x

			lda YPos, x
			cmp TargetYPos, x
			beq Arrived

			jmp MoveY


		GoLeft:

			lda XPos_LSB, x
			sec
			sbc #Stage2Speed
			sta XPos_LSB, x

			lda XPos_MSB, x
			sbc #0
			sta XPos_MSB, x

			cmp TargetXPos_MSB, x
			bne MoveY

			lda TargetXPos_LSB, x
			cmp XPos_LSB, x
			bcc MoveY

			lda YPos, x
			cmp TargetYPos, x
			beq Arrived

			lda TargetXPos_LSB, x
			sta XPos_LSB, x


		MoveY:

			lda YPos, x
			cmp TargetYPos, x
			beq CheckArrived
			bcc SetTarget

			jmp MoveNow

			SetTarget:

				lda TargetYPos, x
				sta YPos, x

				jmp CheckArrived

			MoveNow:

				lda YPos, x
				sec
				sbc #Stage2Speed_Y
				sta YPos, x

			jmp NotArrived

		CheckArrived:

			lda TargetXPos_LSB, x
			cmp XPos_LSB, x
			bne NotArrived

			lda TargetXPos_MSB, x
			cmp XPos_MSB, x
			bne NotArrived

		Arrived:

		
			jsr Delete

			lda Opponent, x
			tax

			lda Count, x
			clc
			adc PendingCount, x
			sta Count, x

			lda #0
			sta PendingCount, x

			lda Opponent, x
			tax

			dec GRID.NumberMoving, x



		NotArrived:



		rts
	}

	UpdateSprite: {


		UpdateFrame:

			lda FrameTimer, x
			beq ReadyToChange

			dec FrameTimer, x
			jmp Position

			ReadyToChange:

				lda #FrameTime
				sta FrameTimer, x

				lda Frame, x
				clc
				adc FrameDirection, x
				sta Frame, x
				cmp #BlobEndPointer
				beq SwitchTo255

				cmp #BlobStartPointer
				beq SwitchToOne

				jmp Position

				SwitchTo255:

				lda #255
				sta FrameDirection, x
				jmp Position

				SwitchToOne:

				lda #1
				sta FrameDirection, x



		Position:

		lda Frame, x
		sta SPRITE_POINTERS + 2, x

		txa
		asl
		tay

		lda XPos_LSB, x
		sta VIC.SPRITE_2_X, y

		lda YPos, x
		sta VIC.SPRITE_2_Y, y



		lda XPos_MSB, x
		beq NoMSB

		MSB:


			inx
			inx

			lda VIC.SPRITE_MSB
			ora DRAW.MSB_On, x
			sta VIC.SPRITE_MSB
			jmp Finish

		NoMSB:

			inx
			inx

			lda VIC.SPRITE_MSB
			and DRAW.MSB_Off, x
			sta VIC.SPRITE_MSB



		Finish:


		dex
		dex



		rts
	}


	UpdateOrb: {


		ldx #0

		Loop:

			stx ZP.X

			lda Frame, x
			beq EndLoop

			jsr UpdateSprite

			lda Frame, x
			beq EndLoop

			lda Stage, x
			beq StageOne

			jsr HeadForTop
			jmp EndLoop

			StageOne:

				lda StageTimer, x
				beq Finished

				dec StageTimer, x

				ldy ZP.X
				lda StageTimer,y
				lsr
				lsr
				lsr
				sta ZP.Amount
				inc ZP.Amount
					
				lda YPos, x
				sec
				sbc ZP.Amount
				sta YPos, x

				cpy #0
				beq Left

				Right:

					lda XPos_LSB, x
					clc
					adc #1
					sta XPos_LSB, x

					lda XPos_MSB
					adc #0
					sta XPos_MSB

					jmp EndLoop

				Left:

					lda XPos_LSB, x
					sec
					sbc #1
					sta XPos_LSB, x

					lda XPos_MSB, x
					sbc #0
					sta XPos_MSB, x


				jmp EndLoop

			Finished:

				lda #1
				sta Stage, x

			EndLoop:	

				ldx ZP.X

				inx
				cpx #2
				bcc Loop



		rts
	}

	UpdateCombo: {

		ldx #0

		Loop:

			stx ZP.X

			lda ComboFrame, x
			beq EndLoop

			lda ComboTimer, x
			beq Finished

			and #%00000011
			beq Dark

			Light:

				lda Colours2, x
				sta VIC.SPRITE_COLOR_0, x
				jmp Done

			Dark:

				lda Colours, x
				sta VIC.SPRITE_COLOR_0, x

			Done:

			
				lda ComboTimer, x
				lsr
				lsr
				lsr
				lsr
				lsr
				sta ZP.Amount
				inc ZP.Amount

				dec ComboTimer, x

				txa
				asl
				tax

				lda VIC.SPRITE_0_Y, x
				sec
				sbc ZP.Amount
				sta VIC.SPRITE_0_Y, x

				jmp EndLoop

			Finished:

				lda #0
				sta ComboFrame, x

				txa
				asl
				tax

				lda #0
				sta VIC.SPRITE_0_Y, x

			EndLoop:	

				ldx ZP.X

				inx
				cpx #2
				bcc Loop




		rts
	}




	StartCombo: {



		lda ComboFrame, x
		sta SPRITE_POINTERS, x

		lda #ComboTime
		sta ComboTimer, x

		lda Colours, x
		sta VIC.SPRITE_COLOR_0, x

		txa
		asl
		tax

		ldy ZP.Row
		dey
		lda EXPLOSIONS.YPos, y
		sta VIC.SPRITE_0_Y, x

		ldy ZP.Column
		lda EXPLOSIONS.XPosLSB, y
		sta VIC.SPRITE_0_X, x

		ldx GRID.CurrentSide

		lda EXPLOSIONS.XPosMSB, y
		beq NoMSB

		MSB:

			lda VIC.SPRITE_MSB
			ora DRAW.MSB_On, x
			sta VIC.SPRITE_MSB
			jmp Finish

		NoMSB:

			lda VIC.SPRITE_MSB
			and DRAW.MSB_Off, x
			sta VIC.SPRITE_MSB

		Finish:



		rts
	}





	CalculateBaseRocks: {


		cmp #9
		bcc Okay

		lda #8

		Okay:

		jsr SCORING.BeansCleared

	    tay

	    lda Opponent, x
		tax	

		lda PendingCount, x
		clc
		adc BaseLookup, y
		sta PendingCount, x

		lda Opponent, x
		tax


		rts
	}


	CalculateChainRocks: {

		clc
		adc RockLookupAdd

		cmp #6
		bcc Okay

		lda #5	

		Okay:

		tay

		lda Opponent, x
		tax	


		lda PendingCount, x
		clc
		adc ChainLookup, y
		sta PendingCount, x

		lda Opponent, x
		tax	

		rts
	}

	CalculateComboRocks: {


		sta SCORING.CurrentChain, x

		cmp #2
		bcc Finish

		pha

		CalculatePointer:

			clc
			adc #ComboStartPointer
			cmp #ComboEndPointer

		CheckInRange:

			bcs PointerOutOfRange
			jmp PointerInRange

		PointerOutOfRange:

			lda #ComboEndPointer

		PointerInRange:

			sta ComboFrame, x

		CalculateTableLookup:

			pla
			clc
			adc RockLookupAdd

			cmp #6
			bcc Okay

			lda #5	

			Okay:

			tay

		GetGarbage:

			lda Opponent, x
			tax	

			lda PendingCount, x
			clc
			adc ComboLookup, y
			sta PendingCount, x

			lda Opponent, x
			tax

		jsr StartCombo

		Finish:


		rts
	}


	UpdateTime: {

		lda SecondsTimer
		beq Ready

		dec SecondsTimer
		jmp Finish

		Ready:

		lda FramesPerSecond
		sta SecondsTimer

		inc SecondsCounter
		inc GameSeconds

		lda SecondsCounter
		cmp RampUpTime
		bcc Finish

		lda #0
		sta SecondsCounter

		inc RockLookupAdd


		Finish:


		rts
	}

	FrameUpdate: {

		jsr UpdateTime
		jsr UpdateCombo
		jsr UpdateOrb

		ldx #0

		Loop:	

			stx ZP.Player

			lda Mode, x
			beq NoDrop

			Drop:	

				cmp #2
				beq EndLoop

				ldy ZP.Player
				jsr TryQueue
				ldx ZP.Player

			NoDrop:

				lda Count, x
				cmp PreviousCount, x
				beq EndLoop

				jsr Draw

				ldx ZP.Player

				lda Count, x
				sta PreviousCount, x

			EndLoop:

				inx	
				cpx #2
				bcc Loop


		rts
	}


	TryQueue: {

		lda DropTimeout
		beq Okay2

		dec DropTimeout
		lda DropTimeout
		bne Okay2

		sty ZP.Player
		jsr PLAYER.LostRound
		rts

		Okay2:

		lda #0
		sta ZP.Okay

		lda QueueOffset, y
		tax

		Loop:

			stx ZP.Column

			ldy ZP.Player

			lda Queue, x
			beq EndLoop

			txa
			clc
			adc GridOffset, y
			tay

			lda GRID.PlayerOne, y
			beq Okay

			inc ZP.Okay
			jmp EndLoop

			Okay:

			dec Queue,x

			lda #WHITE
			sta GRID.PlayerOne, y

			lda #255
			sta GRID.PreviousType, y
		
			lda ZP.Okay
			clc
			adc Queue, x
			sta ZP.Okay

			EndLoop:

				ldx ZP.Column

				inx
				cpx #6
				beq Finish

				cpx #12
				beq Finish

				jmp Loop


		Finish:

			lda ZP.Okay
			beq Done

			lda DropTimeout
			bne NotDone

			lda #90
			sta DropTimeout

			jmp NotDone

		Done:

			lda #0
			sta DropTimeout

			//.break
			ldy ZP.Player
			lda #0
			sta Mode, y

			lda PLAYER.Status, y
			cmp #PLAYER.PLAYER_STATUS_END
			beq NotDone
			
			lda #1
			sta PANEL.Mode, y

		NotDone:

			ldy ZP.Player
			lda #GRID_MODE_NORMAL
			sta GRID.Mode, y

			lda #1
			sta GRID.Active, y



		rts
	}




	DropRocks: {

		stx ZP.TempX

		lda Count, x
		tay

		Loop:

			sty ZP.TempY

			GetRandom:

			jsr RANDOM.Get
			and #%00000111
			cmp #6
			bcs GetRandom
			clc
			adc GRID.PlayerLookup, x
			tay

			lda GRID.PlayerOne, y
			bne Loop


		rts
	}




	Draw: {	

		stx ZP.X

		lda #0
		sta FullCount
		sta ColumnsDrawn

		lda #1
		sta ZP.Colour


		lda Count, x
		sta SingleCount


		DoWhile:

			lda SingleCount
			sec
			sbc #12
			bmi EndWhile

			inc FullCount
			sta SingleCount
			jmp DoWhile


		EndWhile:


		DrawLoop:

			lda ColumnsDrawn
			cmp #12
			beq Finish

			lda FullCount
			beq FullDone

			Full:

				lda #FullCharID
				dec FullCount
				jmp DoIt

			FullDone:

				lda SingleCount
				beq SingleDone

			Single:

				lda #SingleCharID
				dec SingleCount
				jmp DoIt

			SingleDone:

				ldy ColumnsDrawn

				lda BackgroundColourOrder, y
				clc
				adc #8
				sta ZP.Colour
				lda BackgroundCharOrder, y

			DoIt:

				pha

				ldx ColumnsDrawn
				lda Order, x
				ldx ZP.X
				clc
				adc ColumnAdd, x
				tax

				pla

				ldy #0

				jsr DRAW.PlotCharacter

				lda ZP.Colour

				jsr DRAW.ColorCharacter

				inc ColumnsDrawn
				jmp DrawLoop



		Finish:


		rts
	}


}