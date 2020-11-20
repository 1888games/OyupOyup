.var sid = LoadSid("assets/ppidea2.sid")

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
	#import "/scripts/game/grid_visuals.asm"
	#import "/scripts/game/scoring.asm"
	#import "/scripts/game/text.asm"
	#import "/scripts/game/opponents.asm"

	* = $6900

	#import "/scripts/game/roundOver.asm"
	#import "/scripts/game/settings.asm"


	* = * "Main"

	GameActive: 			.byte 0
	GameMode:				.byte 0
	MachineType:			.byte 0



	//exomizer sfx sys -t 64 -x "inc $d020" -o oyup.prg main.prg
	Entry: {

		jsr IRQ.DisableCIAInterrupts
		jsr BankOutKernalandBasic
		jsr set_sfx_routine
		jsr IRQ.Setup
		jsr DetectMachine
			


		//jmp TITLE.Show
		 jmp SETTINGS.Show	
		//jmp MENU.Show
		//jmp CAMPAIGN.Show

		jmp StartGame


	}
   
	DetectMachine: {

		w0:  lda $D012
		w1:  cmp $D012
	    beq w1
	    bmi w0
	    and #$03
	    sta MAIN.MachineType

	    cmp #2
	    bne PAL

	    NTSC:

	    lda #60
	    sta ROCKS.FramesPerSecond

	    jmp Finish
	  
	    PAL:


	    Finish:

	    rts

	}




	

	StartGame: {

		lda #0
		jsr ChangeTracks

		lda #0
		sta IRQ.Mode

		jsr SetupGameColours
		jsr SetupVIC
		jsr SetupSprites

		jsr DRAW.GameScreen
		 	
		jsr EXPLOSIONS.Reset
		jsr GRID.Reset
		jsr PANEL.Reset
		jsr PLAYER.Reset
		jsr ROCKS.Reset
		jsr SCORING.Reset
		jsr ROUND_OVER.Reset


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


		lda #LIGHT_RED
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

		lda #LIGHT_BLUE
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

		dec PerformFrameCodeFlag

		jmp CheckSwitchMode
	}


	CheckSwitchMode: {

		lda GameMode
		cmp #GAME_MODE_SWITCH_CAMPAIGN
		bne NotCampaign

		SwitchCampaign:

			lda #0
			sta GameMode

			jmp CAMPAIGN.Show

		NotCampaign:

			cmp #GAME_MODE_SWITCH_MENU
			bne NotMenu

		SwitchMenu:

			lda #0
			sta GameMode

			lda #2
			jsr ChangeTracks

			jmp MENU.Show

		NotMenu:


		jmp FrameCode



	}

	FrameCode: {


		jsr sfx_cooldown

		lda MAIN.GameActive
		beq Paused

		jsr PLAYER.FrameUpdate
		jsr GRID.FrameUpdate
		jsr EXPLOSIONS.FrameUpdate
		jsr PANEL.FrameUpdate
		jsr ROCKS.FrameUpdate
		jsr SCORING.FrameUpdate
		jsr ROUND_OVER.FrameUpdate
		//jsr DRAW.CycleChars


		Paused:

		jmp Loop

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