
* = $c400 "Sprites" //Start at frame #16
 	.import binary "../../assets/puyo - Sprites.bin"

 // * = $8000 "Game Map"
 //MAP: .import binary "../assets/blank - Map (20x13).bin"

 * = * "Game Colours"
CHAR_COLORS: .import binary "../../assets/puyo - CharAttribs.bin"


 * = * "Game Map"
GAME_MAP: .import binary "../../assets/puyo - Map (40x26).bin"

		
* = $f000 "Charset"
CHAR_SET:
		.import binary "../../assets/puyo - Chars.bin"   //roll 12!
