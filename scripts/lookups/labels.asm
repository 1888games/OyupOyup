
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
.label GAME_MODE_SWITCH_CAMPAIGN = 4
.label GAME_MODE_SWITCH_MENU = 5
.label GAME_MODE_SWITCH_GAME = 6
.label GAME_MODE_SWITCH_SCORE = 7


.label STATE_IDLE= 0  // A
.label STATE_SETUP_NEW_BEANS = 1 // B
.label STATE_NEW_BEANS = 2 // C
.label STATE_CONTROL_BEANS = 3 // D
.label STATE_AWAIT_CHECK_MATCHES = 4 // E
.label STATE_CHECK_MATCHES = 5 // F
.label STATE_POP_BEANS = 6 // G
.label STATE_AWAIT_FALL = 7 // H
.label STATE_DELIVER_ROCKS = 8 // I
.label STATE_CHECK_ROCKS = 9 // J
.label STATE_AWAIT_ROCKS = 10 // K
.label STATE_AWAIT_SETTLE = 11 // L
.label STATE_ROUND_LOST = 12 // M
.label STATE_ROUND_WON = 13 // N
.label STATE_COUNTERING = 14 // O

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
.label GRID_MODE_WAIT_CHECK = 3
.label GRID_MODE_FALL = 4
.label GRID_MODE_END = 5

.label LEFT_SIDE = 0
.label RIGHT_SIDE = 1

.label PLAYER_1 = 0
.label PLAYER_2 = 1

.label PLAY_MODE_SCENARIO = 0
.label PLAY_MODE_2P = 1
.label PLAY_MODE_PRACTICE= 2



.label RIGHT = 1
.label LEFT= 2
.label DOWN = 4
.label UP = 8

