DISK: {


*	=* "---Disk"

  	.label FileNumber = 2
  	.label DefaultDeviceNumber = 8
  	.label SecondaryAddress = 2
	.label ErrorChannel = 15

	.label FileEnd = 		$0755
	.label FileStart = 		$0700
	.label SetName = 		$FFBD
	.label SetLFS = 		$FFBA
	.label OpenFile	=	  	$FFC0
	.label CheckOut = 		$FFC9
	.label FileStartRegister = $AE
	.label ReadStatusByte = $FFB7
	.label WriteByte = 		$FFD2 
	.label CloseFile =      $FFC3
	.label ClearChannel =   $FFCC
	.label CheckIn =  		$FFC6
	.label FileRegister = 	$C1
	.label SaveFile = 		$FFD8
	.label ReadByte = 		$FFE4
	.label PrintChar = 		$FFD2
	.label CheckChar = 		$0C


	Scratch:		.text "S0:"
	Filename:  		.text "SCORES"

	ScratchEnd:		
					.text ",S,"
	ReadOrWrite:	.text "W"
  	FilenameEnd:

  	DeviceNumber:	.byte 8
  	DiskAvailable:	.byte 0
	WriteRead:		.text "W"
					.text "R"

	IsLoading:		.byte 0
	IsError:		.byte 0



  	SetFilename: {

		lda #FilenameEnd - Filename

		ldx #<Filename
		ldy #>Filename
		jsr SetName

		rts

  	}

  	SetDeleteFileName: {

  		lda #ScratchEnd - Scratch

		ldx #<Scratch
		ldy #>Scratch
		jsr SetName

		rts

  	}
  
  	SetFileAndDevice: {

		lda #FileNumber
		ldx DeviceNumber
		ldy #FileNumber
		jsr SetLFS

		rts

  	}

 	

 	PauseGame: {

 		lda #%00000000
		sta IRQ.INTERRUPT_CONTROL

	//	lda #%00000110
		//sta VIC.MEMORY_SETUP

 		WaitForVBlank:

  		lda VIC.RASTER_LINE
  		cmp #210
  		bcs Okay

  		jmp WaitForVBlank

  		Okay:

  		lda #0
		sta MAIN.GameActive
		sta MAIN.PerformFrameCodeFlag


		rts

 	}



 	


  	SetupForDiskOperation: {

  		jsr PauseGame

  		jsr BankInKernal	
  		
  		ldx IsLoading
 		lda WriteRead, x
 		sta ReadOrWrite
		
  		rts
  	}


  	BankInKernal: {

  		lda #0
		sta VIC.SPRITE_ENABLE
		sta IRQ.INTERRUPT_CONTROL

		sei
		jsr MAIN.BankInKernal
		cli


		rts

  	}

  	SetupMemoryAddress: {

		lda #<FileStart
		sta FileStartRegister

		lda #>FileStart
		sta FileStartRegister + 1

		ldy #0

  		rts
  	}

  	CloseFileAndChannel: {


		lda #FileNumber
		jsr CloseFile
		jsr ClearChannel


  		rts
  	}


  	SetupFileRange: {

  		lda #<FileStart
  		sta FileRegister

  		lda #>FileStart
  		sta FileRegister

  		ldx #<FileEnd
  		ldy #>FileEnd


  		rts
  	}

  	 DeleteFile: {

  	 	lda #0
  	 	sta IsError

  	 	lda #0
 		sta $94

  		jsr SetDeleteFileName

  		jsr SetName

  		lda #FileNumber
		ldx $BA
		bne Skip

		ldx DeviceNumber

		Skip:

			ldy #ErrorChannel
			jsr SetLFS

  		jsr OpenFile
  		bcs Error

  		close:


  		jmp Finish

  		Error:	

  			inc IsError

  		Finish:

  		lda #FileNumber
  		jsr CloseFileAndChannel

  		rts
  	}



	Save: {


		jsr SetupForDiskOperation

		TryAgain:

		
		jsr DeleteFile

		.break

		//jmp Finish

		lda #0
 		sta $94
 		sta IsError

		jsr SetFilename
		jsr SetFileAndDevice

		jsr OpenFile
		
		bcs Error

		ldx #FileNumber
		jsr CheckOut

		jsr SetupMemoryAddress

		.break

		ldx #0

		WriteLoop:		

			inc VIC.BORDER_COLOUR

			jsr ReadStatusByte

			beq Okay

			jmp WriteError

			Okay:

				lda #0                  
                sta $02a1 
		
				ldy #0
				lda (FileStartRegister), y

				jsr WriteByte
				inc FileStartRegister
				bne NoWrap

				inc FileStartRegister + 1

				inx
				cpx #40
				bcc NoEnd

				ldx #0

				NoEnd:

			NoWrap:

				lda FileStartRegister
				cmp #<FileEnd
				lda FileStartRegister + 1
				sbc #>FileEnd
				bcc WriteLoop

		jmp Finish

		Error:
	 	WriteError:

	 		lda #1
			sta IsError
			
		Finish:

			lda #FileNumber
			jsr CloseFileAndChannel
			jsr ReturnToGame


		rts
	}


	ReturnToLoad: {

		jsr BankOutKernal
		
		lda #1
		sta MAIN.GameActive

		rts

	}


	ReturnToGame: {

		jsr BankOutKernal
		
		////lda #GAME_MODE_SWITCH_MENU
		//sta MAIN.GameMode

		lda #1
		sta MAIN.GameActive

		rts
	}


	BankOutKernal: {

		jsr MAIN.BankOutKernalandBasic
		jsr IRQ.Setup

		lda #255
		sta VIC.SPRITE_ENABLE

		lda #%00000001
		sta IRQ.INTERRUPT_CONTROL

		rts

	}



	Load: {

		jsr SetupForDiskOperation

		jsr SetFilename
		jsr SetFileAndDevice

		jsr OpenFile
		
		bcs Error

		ldx #FileNumber
		jsr CheckIn

		jsr SetupMemoryAddress

		ldx #0
		stx IsError

		WaitForVBlank:

			lda VIC.RASTER_LINE
			cmp #250
			bne WaitForVBlank


		WriteLoop:		

			lda #0
 			sta $94

 			inc VIC.BORDER_COLOUR

			lda #0                  
            sta $02a1 
		
			jsr ReadStatusByte

			beq Okay

			jmp ReadError

			Okay:

				lda #0                  
           	 	sta $02a1 
				
				jsr ReadByte

				ldy #0
				sta (FileStartRegister), y

				inc FileStartRegister
				bne NoWrap

				inc FileStartRegister + 1

				inx
				cpx #40
				bcc NoEnd

				ldx #0

				NoEnd:

			NoWrap:

				lda FileStartRegister
				cmp #<FileEnd
				lda FileStartRegister + 1
				sbc #>FileEnd
				bcc WriteLoop


		jmp Finish

		Error:
	 	ReadError:

	 		.break

	 		inc IsError
		
		Finish:

			lda #FileNumber
			jsr CloseFileAndChannel
			jsr ReturnToGame
			

	}


}