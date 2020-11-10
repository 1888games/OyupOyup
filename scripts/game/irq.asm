IRQ: {


	* = * "IRQ"

	.label INTERRUPT_CONTROL = 				$d01a
	.label INTERRUPT_STATUS = 				$d019
	.label RASTER_INTERRUPT_VECTOR = 		$fffe

	.label MainIRQLine = 220

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



	MainIRQ: {

		:StoreState()

		jsr SidFrameUpdate
	

		SetDebugBorder(2)
		
		inc ZP.FrameCounter

   		ldy #2
		jsr INPUT.ReadJoystick

		ldy #1
		jsr INPUT.ReadJoystick

		lda #1
		sta MAIN.PerformFrameCodeFlag
		
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

		asl INTERRUPT_STATUS

		SetDebugBorder(11)

		:RestoreState()

		rti

	}



}