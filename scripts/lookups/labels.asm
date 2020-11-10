
MemoryAddresses:

.label PROCESSOR_PORT = $01
.label SCREEN_RAM = $c000
.label SPRITE_POINTERS = SCREEN_RAM + $3f8
.label COLOR_RAM = $d800

.label TITLE_POINTERS = $6000 + $3f8


.label GAME_MODE_PLAY = 0
.label GAME_MODE_PAUSE = 1
.label GAME_MODE_TITLE = 2
.label GAME_MODE_TOWER = 3

.label ZERO = 0
.label ONE = 1


.label GREEN_MULTI = GREEN + 8
.label BLACK_MULTI = BLACK + 8
.label YELLOW_MULTI = YELLOW + 8
.label CYAN_MULTI = CYAN + 8
.label WHITE_MULTI = WHITE+ 8
.label BLUE_MULTI = BLUE + 8
.label RED_MULTI = RED + 8
.label PURPLE_MULTI = PURPLE + 8


.label GRID_MODE_PAUSE = 0
.label GRID_MODE_NORMAL = 1
.label GRID_MODE_CHECK = 2

.label LEFT_SIDE = 0
.label RIGHT_SIDE = 1

.label PLAYER_1 = 0
.label PLAYER_2 = 1


.label RIGHT = 1
.label LEFT= 2
.label DOWN = 4
.label UP = 8

