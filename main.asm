.var sid = LoadSid("assets/ppidea.sid")

MAIN: {

	

	#import "/scripts/lookups/zeropage.asm"

	* = $0800 "Upstart"

	PerformFrameCodeFlag:	.byte 0

	BasicUpstart2(Entry)
	* = $080d "End Of Basic"


	#import "/scripts/common/macros.asm"
	#import "/scripts/common/sfx.asm"
	#import "/scripts/lookups/labels.asm"
	#import "/scripts/lookups/vic.asm"
	#import "/scripts/game/irq.asm"
	#import "/scripts/game/draw.asm"
	#import "/scripts/common/input.asm"
	#import "/scripts/game/grid.asm"
	#import "/scripts/game/bean.asm"
	#import "/scripts/common/rnd.asm"
	#import "/scripts/game/explosions.asm"
	#import "/scripts/game/rocks.asm"
	#import "/scripts/game/panel.asm"
	#import "/scripts/game/player.asm"
	#import "/scripts/game/title.asm"
	#import "/scripts/game/campaign.asm"
	#import "/scripts/game/menu.asm"

	* = * "Main"

	GameActive: 			.byte 0
	GameMode:				.byte 0



	//exomizer sfx sys -t 64 -x "inc $d020" -o oyup.prg main.prg
	Entry: {

		jsr IRQ.DisableCIAInterrupts
		jsr BankOutKernalandBasic
		jsr set_sfx_routine
		jsr IRQ.Setup
			

	//	jmp MENU.Show
		//jmp CAMPAIGN.Show
		//jmp TITLE.Show

		jmp StartGame

	}




	

	StartGame: {

		lda #0
		jsr ChangeTracks

		jsr SetupGameColours
		jsr SetupVIC
		jsr SetupSprites

		jsr DRAW.GameScreen
		 
		jsr GRID.Reset
		jsr PANEL.Reset
		jsr PLAYER.Reset
		jsr ROCKS.Reset

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


		lda #GRAY
		sta VIC.SPRITE_MULTICOLOR_1

		lda #WHITE
		sta VIC.SPRITE_MULTICOLOR_2

		lda #0
		sta VIC.SPRITE_0_Y
		sta VIC.SPRITE_1_Y
		sta VIC.SPRITE_2_Y
		sta VIC.SPRITE_3_Y
		sta VIC.SPRITE_4_Y
		sta VIC.SPRITE_5_Y
		sta VIC.SPRITE_6_Y
		sta VIC.SPRITE_7_Y








		rts
	}

	SetupGameColours: {


		lda #BLACK
		sta VIC.BACKGROUND_COLOUR

		lda #DARK_GRAY
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

		jsr sfx_cooldown

		lda MAIN.GameActive
		beq Paused

		jsr PLAYER.FrameUpdate
		jsr GRID.FrameUpdate
		jsr EXPLOSIONS.FrameUpdate
		jsr PANEL.FrameUpdate
		jsr ROCKS.FrameUpdate


		Paused:

		
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