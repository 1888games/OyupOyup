MAIN: {

	#import "/scripts/lookups/zeropage.asm"

	* = $0800 "Upstart"

	PerformFrameCodeFlag:	.byte 0

	BasicUpstart2(Entry)
	* = $080d "End Of Basic"

	#import "/scripts/lookups/vic.asm"
	#import "/scripts/game/irq.asm"
	

	* = * "Main"

	GameActive: 			.byte 0
	GameMode:				.byte 0



	//exomizer sfx sys -t 64 -x "inc $d020" -o oyup.prg main.prg
	Entry: {


		jsr IRQ.DisableCIAInterrupts
		
	

		Finish:
		
		jmp StartGame

	}





	StartGame: {




		jmp Loop


	}



	Loop: {



		jmp Loop
	}

}