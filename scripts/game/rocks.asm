ROCKS: {



	Slots:	.fill 24, 0



	Count:			.byte 0, 0
	PreviousCount:	.byte 0, 0
	FullCount:		.byte 0
	SingleCount:	.byte 0
	ColumnsDrawn:	.byte 0
	Mode:			.byte 0, 0

	BackgroundCharIDs:	.byte 34, 35, 38, 39

	ColumnAdd:	.byte 2, 26

	Order:		.byte 6, 7, 5, 8, 4, 9, 3, 10, 2, 11, 1, 0
	BackgroundCharOrder:	.byte 34, 35, 39, 38, 34, 35, 39, 38, 34, 35, 39, 38
	BackgroundColourOrder:	.byte PURPLE, YELLOW, CYAN, GREEN, PURPLE, YELLOW, CYAN, GREEN, PURPLE, YELLOW, CYAN, GREEN

	CurrentColumn:	.byte 0


	DropColumns:	.byte 0, 0, 0, 1, 1, 1, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5
	QueueOrder:		.byte 2, 3, 1, 4, 0, 5
	QueueOffset:	.byte 0, 6


	.label FullCharID = 106
	.label SingleCharID = 105


	* = * "Queue"

	Queue:		.byte 0, 0, 0, 0, 0, 0
				.byte 0, 0, 0, 0, 0, 0


	Reset: {

		lda #15
		sta Count + 0
		sta Count + 1
		sta PreviousCount + 0
		sta PreviousCount + 1

		ldy #0

		jsr TransferToQueue

		ldx #0
		jsr Draw
		ldx #1
		jsr Draw

		lda #1
		sta Mode

		rts
	}

	FrameUpdate: {

		ldx #0


		Loop:	

			stx ZP.X


			lda Mode, x
			beq NoDrop

			Drop:	

				ldy ZP.X
				jsr TryQueue
				ldx ZP.X

			NoDrop:

				lda Count, x
				cmp PreviousCount, x
				beq EndLoop

				jsr Draw

				ldx ZP.X

				lda Count, x
				sta PreviousCount, x

			EndLoop:

				inx	
				cpx #2
				bcc Loop


		rts
	}


	TryQueue: {

		lda #0
		sta ZP.Okay

		sty ZP.TempY

		lda QueueOffset, y
		tax

		Loop:

			stx ZP.Y

			ldy ZP.TempY

			lda Queue, x
			beq EndLoop

			txa
			clc
			adc GRID.PlayerLookup, y
			tay

		
			lda GRID.PlayerOne, y
			beq Okay

			inc ZP.Okay
			jmp EndLoop

			Okay:

			dec Queue,x

			lda #CYAN
			sta GRID.PlayerOne, y
		
			lda ZP.Okay
			clc
			adc Queue, x
			sta ZP.Okay

			EndLoop:

				ldx ZP.Y

				inx
				cpx #6
				beq Finish

				cpx #12
				beq Finish

				jmp Loop


		Finish:

		lda ZP.Okay
		bne NotDone

		//.break
		ldy ZP.TempY
		lda #0
		sta Mode, y
		
		lda #1
		sta PANEL.Mode
		//nop



		NotDone:


		rts
	}


	TransferToQueue: {

		sty ZP.TempY

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

				lda QueueOrder, y
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

			ldx ZP.TempY
			lda #0
			sta Count, x

		rts
	}

	DropRocks: {

		stx ZP.TempX

		lda Count, x
		tay

		Loop:

			sty ZP.TempY

			jsr RANDOM.Get
			and #%00001111
			tay
			lda DropColumns, y
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