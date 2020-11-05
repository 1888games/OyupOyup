MAIN: {

	#import "/scripts/lookups/zeropage.asm"

	* = $0800 "Upstart"

	PerformFrameCodeFlag:	.byte 0

	BasicUpstart2(Entry)
	* = $080d "End Of Basic"

	#import "/scripts/common/macros.asm"
	#import "/scripts/lookups/labels.asm"
	#import "/scripts/lookups/vic.asm"
	#import "/scripts/game/irq.asm"
	#import "/scripts/game/draw.asm"
	#import "/scripts/common/input.asm"
	#import "/scripts/game/grid.asm"
	#import "/scripts/game/bean.asm"
	#import "/scripts/common/rnd.asm"

	* = * "Main"

	GameActive: 			.byte 0
	GameMode:				.byte 0



	//exomizer sfx sys -t 64 -x "inc $d020" -o oyup.prg main.prg
	Entry: {

		jsr IRQ.DisableCIAInterrupts
		jsr BankOutKernalandBasic
		jsr IRQ.Setup

		jmp StartGame

	}



	

	StartGame: {


		jsr SetupGameColours
		jsr SetupVIC
		jsr SetupSprites

		jsr DRAW.GameScreen
		
		jsr GRID.Clear

		jmp Loop


	}



	SetupVIC: {

		//Set VIC BANK 3, last two bits = 00
		lda VIC.BANK_SELECT
		
		and #%11111100
		sta VIC.BANK_SELECT

		// multicolour mode on
		lda VIC.SCREEN_CONTROL_2
		and #%11101111
		ora #%00010000
		sta VIC.SCREEN_CONTROL_2

		lda #%00001100
		sta VIC.MEMORY_SETUP	

		rts


	}


	SetupSprites: {

		lda #%11111111
		sta VIC.SPRITE_ENABLE

		lda #%00000000
		sta VIC.SPRITE_PRIORITY


		lda #%11111111
		sta VIC.SPRITE_MULTICOLOR


		lda #BLACK
		sta VIC.SPRITE_MULTICOLOR_1

		lda #RED
		sta VIC.SPRITE_MULTICOLOR_2


		rts
	}

	SetupGameColours: {


		lda #BLACK
		sta VIC.BACKGROUND_COLOUR

		lda #RED
		sta VIC.BORDER_COLOUR

		lda #WHITE
		sta VIC.EXTENDED_BG_COLOR_1
		lda #BROWN
		sta VIC.EXTENDED_BG_COLOR_2



		rts

	
	}


	Loop: {

		lda PerformFrameCodeFlag
		beq Loop

		jsr FrameCode

		jmp Loop
	}



	FrameCode: {

		dec PerformFrameCodeFlag

		jsr GRID.FrameUpdate
		
		rts

	}


	BankOutKernalandBasic:{

		lda PROCESSOR_PORT
		and #%11111000
		ora #%00000101
		sta PROCESSOR_PORT
		rts
	}

	#import "/scripts/game/assets.asm"



}