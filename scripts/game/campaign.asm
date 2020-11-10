CAMPAIGN: {





	Show: {


		lda #1
		jsr ChangeTracks
		
		jsr MAIN.SetupVIC


		lda #BLACK
		sta VIC.BACKGROUND_COLOUR

		lda #DARK_GRAY
		sta VIC.BORDER_COLOUR

		lda #WHITE
		sta VIC.EXTENDED_BG_COLOR_1
		lda #GRAY
		sta VIC.EXTENDED_BG_COLOR_2

		jsr DRAW.TowerScreen

		lda #GAME_MODE_TOWER
		sta IRQ.Mode

		jmp CampaignLoop

	}



	CampaignLoop: {



		jmp CampaignLoop

	}







}