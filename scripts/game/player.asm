PLAYER: {

	.label AutoDropTime = 20
	.label FlashTime = 10

	.label PLAYER_STATUS_NORMAL = 0
	.label PLAYER_STATUS_WAIT = 1


	Beans: 			.byte 0, 0, 0, 0
	GridPosition:	.byte 2, 2, 74, 74
	Offset:			.byte 255, 255, 255, 255

	
	Status:				.byte 1, 1
	DropTimer:			.byte AutoDropTime, AutoDropTime
	FlashTimer:			.byte 0, 0, 0, 0
	Flashing:			.byte 0, 0, 0, 0
	Rotation:			.byte 0, 0, 0, 0
	ClearUp:			.byte 1, 0, 1, 0

	RotationAdd:		.byte 

	CharIDs:			.byte 129, 200
	StartGridPositions:	.byte 2, 2, 74, 74
	StartOffsets:		.byte 253, 255, 253, 255

	BackgroundColours: 	.byte 0, 0, 0, 0

	CurrentAutoDropTime:	.byte AutoDropTime

	TableOffset:		.byte 0, 2



	Reset: {


		lda #1
		sta Status
		sta Status + 1

		rts
	}

	DrawBean: {


		// y = 0-3


		GetPosition:

			lda GridPosition, y
			tax

			lda GRID.RowLookup, x
			sta ZP.Row

			lda Offset, y
			clc
			adc ZP.Row
			sta ZP.Row

			lda GRID.ColumnLookup, x
			sta ZP.Column

		GetColour:

			lda Beans, y
			clc
			adc #8
			sta ZP.BeanColour

		GetChars:

			lda Flashing, y
			tax
			lda CharIDs, x
			sta ZP.CharID

		TopLeft:
		
			ldx ZP.Column
			ldy ZP.Row
			jsr DrawCharacter
				
		TopRight:

			inx
			dec ZP.CharID		
			jsr DrawCharacter

		BottomRight:

			iny
			dec ZP.CharID
			jsr DrawCharacter
	

		BottomLeft:

			dex
			dec ZP.CharID		
			jsr DrawCharacter


		Finish:


		rts
	}


	DrawCharacter: {

		lda ZP.CharID

		cpy #1
		bcc NoDraw

		cpy #25
		bcs NoDraw

		jsr DRAW.PlotCharacter

		lda ZP.BeanColour
		jsr DRAW.ColorCharacter


		NoDraw:

		rts
	}

	FrameUpdate: {

		ldx #0

		Loop:

			stx ZP.X

			CheckActive:

				lda Status, x
				bne EndLoop

			CheckDrop:

				lda DropTimer, x
				beq ReadyToDrop

			NoDrop:

				dec DropTimer, x
				jmp CheckFlash

			ReadyToDrop:	

				lda #AutoDropTime
				sta DropTimer, x

				jsr DeleteBeans

				ldx ZP.X

				jsr DropBeans

			CheckFlash:


			EndLoop:

			ldx ZP.X
			inx
			cpx #2
			bcc Loop




		rts
	}	



	DeleteBeans: {

		lda TableOffset, x
		tay
		iny
		iny
		sty ZP.EndID
		dey
		dey

		Loop:

			sty ZP.Y

			ldx #0

			lda Offset, y
			beq NoChange

			ldx #2

			NoChange:
				
			jsr DeleteBean

			EndLoop:

				ldy ZP.Y
				iny 
				cpy ZP.EndID
				bcc Loop



		rts

	}


	DeleteBean: {


		// y = 0-3


		GetChars:

			lda GRID.BackgroundCharIDs, x
			sta ZP.CharID


		GetColours:

			lda GRID.BackgroundColours, x
			sta BackgroundColours

			lda GRID.BackgroundColours + 1, x
			sta BackgroundColours + 1

			lda GRID.BackgroundColours + 1, x
			sta BackgroundColours + 2

			lda GRID.BackgroundColours+ 1, x
			sta BackgroundColours + 3




		GetPosition:

			lda GridPosition, y
			tax

			lda GRID.RowLookup, x
			sta ZP.Row

			lda Offset, y
			clc
			adc ZP.Row
			sta ZP.Row

			lda GRID.ColumnLookup, x
			sta ZP.Column

		TopLeft:
		
			ldx ZP.Column
			ldy ZP.Row
			lda BackgroundColours
			sta ZP.BeanColour
			jsr DrawCharacter
				
		TopRight:

			inx
			inc ZP.CharID	
			lda BackgroundColours + 1
			sta ZP.BeanColour	
			jsr DrawCharacter

		BottomRight:

			iny
			inc ZP.CharID
			lda BackgroundColours + 2
			sta ZP.BeanColour	
			jsr DrawCharacter
	

		BottomLeft:

			dex
			inc ZP.CharID	
			lda BackgroundColours + 3
			sta ZP.BeanColour		
			jsr DrawCharacter


		Finish:


		rts
	}

	DropBeans: {


		lda TableOffset, x
		tay

		Loop:

			sty ZP.Y

			lda Offset, y
			beq MoveDownGrid

			clc
			adc #1
			sta Offset, y

			jmp Draw

			MoveDownGrid:

				lda #255
				sta Offset, y

				lda GridPosition, y
				clc
				adc #GRID.Columns
				sta GridPosition, y

			Draw:

				jsr DrawBean

			EndLoop:

				ldy ZP.Y
				iny 
				cpy ZP.EndID
				bcc Loop



		rts




	}


	SetupBeans: {

		// y = 0 or 1 

		lda #0
		sta Status, y

		lda #FlashTime
		sta FlashTimer, y

		lda #AutoDropTime
		sta DropTimer, y


		lda PANEL.Offsets, y
		tax

		lda TableOffset, y
		tay

		// x = 0 or 4
		// y = 0 or 2 

		sty ZP.TempY

		lda PANEL.Queue, x
		sta Beans + 0, y

		lda PANEL.Queue + 1, x
		sta Beans + 1, y


		lda StartGridPositions, y
		sta GridPosition, y

		lda StartGridPositions + 1, y
		sta GridPosition + 1, y

		lda #255
		sta FlashTimer, y

		lda #FlashTime
		sta FlashTimer + 1, y

		lda StartOffsets, y
		sta Offset, y

		lda StartOffsets + 1, y
		sta Offset + 1, y

		jsr DrawBean

		ldy ZP.TempY
		iny

		jsr DrawBean


		rts
	}







}