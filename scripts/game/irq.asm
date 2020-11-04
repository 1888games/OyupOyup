IRQ: {


	* = * "IRQ"

	DisableCIAInterrupts: {

		// prevent CIA interrupts now the kernal is banked out
		lda #$7f
		sta VIC.IRQ_CONTROL_1
		sta VIC.IRQ_CONTROL_2

		lda VIC.IRQ_CONTROL_1
		lda VIC.IRQ_CONTROL_2

		rts

	}


}