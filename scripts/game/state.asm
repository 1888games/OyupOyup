STATE: {


	* = * "State Machine"



	Current: 	.byte 0, 0
	Previous:	.byte 0, 0

	DebugFlag:		.byte 1


	Reset: {

		lda #STATE_IDLE
		sta Current
		sta Current + 1

		rts
	}


	FrameUpdate: {

		lda DebugFlag
		beq Skip	

		lda Current
		clc
		adc #1
		sta SCREEN_RAM + 0

		lda Current + 1
		clc
		adc #1
		sta SCREEN_RAM + 40

		lda #WHITE
		sta COLOR_RAM + 40

		lda #CYAN
		sta COLOR_RAM + 0

		Skip:

		rts
	}

	StartGame: {

		lda #STATE_SETUP_NEW_BEANS
		sta Current, x

		jsr DeactivateGrid

		rts
	}


	DeactivateGrid: {

		lda #0
		sta GRID.Active, x

		rts
	}

	ActivateGrid: {

		lda GRID.IsPlaying, x
		beq Finish

		jsr GRID.ResetCycle

		lda #1
		sta GRID.Active, x
		
		Finish:

		rts
	}


	ReadyForNewBeans: {

		lda #STATE_NEW_BEANS
		sta Current, x

		cpx #0
		beq NotCPU

		lda PLAYER.CPU, x
		beq NotCPU

		CPU:

			jsr OPPONENTS.SetActive

		NotCPU:

			lda #1
			sta PANEL.FirstKickOff, x
			sta GRID.GridClearAllowed, x

			//jsr DeactivateGrid

		rts


	}


	AllowControl: {


		lda #STATE_CONTROL_BEANS
		sta Current, x

		jsr DeactivateGrid

		rts
	}



	BeansPlaced: {

		lda #STATE_AWAIT_FALL
		sta Current, x

		jsr ActivateGrid

		rts

	}

	BeansAllSettled: {

		lda #STATE_AWAIT_CHECK_MATCHES
		sta Current, x

		jsr DeactivateGrid
		jsr GRID.StartCheck

		rts
	}


	ReadyToCheck: {

		lda #STATE_CHECK_MATCHES
		sta Current, x

		jsr DeactivateGrid

		jmp GRID.Scan

	
	}	


	BeansPopping: {  

		lda #STATE_AWAIT_FALL
		sta Current, x

		jsr ActivateGrid


		rts
	}

	AllPoppingCompleted: {

//		.break
//
		lda #STATE_DELIVER_ROCKS
		sta Current, x

		jsr ActivateGrid

		rts
	}



	NoBeansLeftToPop: {

		jsr DeactivateGrid
		jsr ROCKS.TransferCountToQueue

		rts
	}




	NoRocksLeftToDrop: {

		lda #STATE_SETUP_NEW_BEANS
		sta Current, x

		jsr DeactivateGrid

		Finish:


		rts	

	}

	FinishedCountering: {

		jsr NoBeansLeftToPop

		rts
	}

	Countering: {

		lda #STATE_COUNTERING
		sta Current, x

		jsr DeactivateGrid


		rts
	}

	StillDroppingRocks: {

		lda #STATE_AWAIT_ROCKS
		sta Current, x

		rts
	}

	WillBeRocksToDrop: {

		lda #STATE_AWAIT_ROCKS
		sta Current, x

		jsr ActivateGrid


		rts
	}


	RoundOver: {

		lda #GRID_MODE_END
		sta GRID.Mode
		sta GRID.Mode + 1

		lda #0
		sta GRID.Active
		sta GRID.Active + 1

		ldy ZP.Player
		lda #GRID_MODE_FALL
		sta GRID.Mode, y

		lda #1
		sta GRID.NumberMoving, y
		sta GRID.Active, y

		lda #GRID.LastRowID
		sta GRID.StartRow
		sta GRID.CurrentRow

		lda #STATE_ROUND_LOST
		sta Current, y

		lda ROCKS.Opponent, y
		tax

		lda #STATE_ROUND_WON
		sta Current, x

		lda #3
		jsr sid.init

		jsr ROUND_OVER.Show
		
		rts
	}


	RocksToPop: {






		rts
	}












}