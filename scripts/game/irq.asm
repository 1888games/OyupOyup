IRQ: {


	* = * "IRQ"

	.label INTERRUPT_CONTROL = 				$d01a
	.label INTERRUPT_STATUS = 				$d019
	.label RASTER_INTERRUPT_VECTOR = 		$fffe

	.label MainIRQLine = 220

	TowerSkyLines:	.byte 

	Mode:	.byte 0


	//.label Colours = 5
	//TowerColours:	.byte PURPLE, LIGHT_BLUE, CYAN, LIGHT_RED, BROWN
	//TowerLines:		.byte 30, 70, 105, 160, 218

	.label Colours = 2
	TowerColours:	.byte BLACK, BLACK
	TowerLines:		.byte 30, 218


	TowerStatus:	.byte 0



	DisableCIAInterrupts: {

		// prevent CIA interrupts now the kernal is banked out
		lda #$7f
		sta VIC.IRQ_CONTROL_1
		sta VIC.IRQ_CONTROL_2

		lda VIC.IRQ_CONTROL_1
		lda VIC.IRQ_CONTROL_2

		rts

	}


	Setup: {

		sei 	// disable interrupt flag
		lda INTERRUPT_CONTROL
		ora #%00000001		// turn on raster interrupts
		sta INTERRUPT_CONTROL

		lda #<MainIRQ
		ldx #>MainIRQ
		ldy #MainIRQLine
		jsr SetNextInterrupt

		asl INTERRUPT_STATUS
		cli

		rts


	}



	SetNextInterrupt: {

		sta RASTER_INTERRUPT_VECTOR
		stx RASTER_INTERRUPT_VECTOR + 1
		sty VIC.RASTER_LINE
		lda VIC.SCREEN_CONTROL
		and #%01111111		// don't use 255+
		sta VIC.SCREEN_CONTROL

		rts
	}




	PerformEveryFrame: {

	//	jsr SidFrameUpdate
	
		SetDebugBorder(2)
		
		inc ZP.FrameCounter

   		ldy #2
		jsr INPUT.ReadJoystick

		ldy #1
		jsr INPUT.ReadJoystick

		lda #1
		sta MAIN.PerformFrameCodeFlag


		rts
	}


	MainIRQ: {

		:StoreState()
			
		SetDebugBorder(2)

		jsr PerformEveryFrame
		
		lda MAIN.GameActive
		beq Paused
   
	 	GameActive:
		
			jmp Finish

		Paused:


		 CheckFireButton:

		 	ldy #1
		 	lda INPUT.FIRE_UP_THIS_FRAME, y
		 	beq Finish

		Finish:

		lda Mode
		cmp #GAME_MODE_TOWER
		bne NotTower


		SwitchToTowerMode:

			lda #0
			sta TowerStatus

			lda TowerLines
			tay

			lda #<TowerIRQ
			ldx #>TowerIRQ

			jsr SetNextInterrupt


		NotTower:

		asl INTERRUPT_STATUS

		SetDebugBorder(11)

		:RestoreState()

		rti

	}


	TowerIRQ: {

		:StoreState()

		GetRasterOffScreen:

			ldx #8

			Loop:

				dex
				bne Loop


		SetBackgroundColour:

			ldx TowerStatus
			lda TowerColours, x
			sta VIC.BACKGROUND_COLOUR

		NextColourBand:

			lda TowerStatus
			bne NotTop	

			jsr CAMPAIGN.PlayerSprites
			jsr CAMPAIGN.Clouds
			jsr CAMPAIGN.FrameUpdate


			NotTop:

			inc TowerStatus
			ldx TowerStatus

			cpx #Colours
			bcc SetupNextIRQLine

		DoneAllBands:

			jsr PerformEveryFrame

			ldx #0
			stx TowerStatus

		SetupNextIRQLine:

	

			lda TowerLines, x
			sta VIC.RASTER_LINE
			
			asl INTERRUPT_STATUS

			:RestoreState()

		rti

	}



}