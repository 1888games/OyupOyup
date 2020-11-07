.macro sfx(sfx_id)
{		
		:StoreState()

		ldx #sfx_id
		jsr sfx_play

		:RestoreState()
}

.macro sfxFromX() {

		:StoreState()

		jsr sfx_play

		:RestoreState()

}

music_on: .byte 1

set_sfx_routine:
{
			lda music_on
			bne !on+
			
			lda #<play_no_music
			sta sfx_play.sfx_routine + 1
			
			lda #>play_no_music
			sta sfx_play.sfx_routine + 2
			rts
			
		!on:
			lda #<play_with_music
			sta sfx_play.sfx_routine + 1
			
			lda #>play_with_music
			sta sfx_play.sfx_routine + 2
			rts	
}

sfx_play:
{			
	sfx_routine:
			jmp play_with_music
}


//when sid is not playing, we can use any of the channels to play effects
play_no_music:
{
			lda channels, x
			sta channel
			lda wavetable_l,x
			ldy wavetable_h,x
			ldx channel
			pha
			lda times7,x
			tax
			pla
			//jmp sid.init + 6			
			
channel:
.byte 2
times7:
.fill 3, 7 * i			
}


play_with_music:
{
			lda wavetable_l,x
			ldy wavetable_h,x
			ldx #7 * 2
			jmp sid.init + 6
			rts
}


StopChannel0: {

	lda #0
	sta $d404

	rts


}




//effects must appear in order of priority, lowest priority first.

.label SFX_EXPLODE = 0
.label SFX_LAND = 1


channels:	.byte 2, 0, 1, 1, 0, 0, 0, 0, 0, 0

sfx_land:
.import binary "../../Assets/sfx/low_bang_up.sfx"

sfx_bloop:
.import binary "../../Assets/sfx/click_bloop.sfx"


whoosh:
.import binary "../../Assets/sfx/whoosh.sfx"


wavetable_l:
.byte  <whoosh, <sfx_land

wavetable_h:
.byte  >whoosh, >sfx_land



