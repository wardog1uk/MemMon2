; start of screen memory
screenRam = $0400

; kernal function to get input
GETIN = $ffe4

; Number of chars in keyboard buffer 
NDX = $c6

; initial start address to display
startPosition = $c000

; screen size
screenWidth = #40
screenHeight = #25

; number of bytes and rows displayed
bytesInLine = #8
rowsOnScreen = #22
displayedBytes = bytesInLine * rowsOnScreen

; zero page addresses that hold the current column and row numbers
col = $d3
row = $d6

; points to the address for the start of the current line
lineStart = $fb

; points to the address of memory to be loaded
memoryPointer = $fd

; key codes
DOWN_ARROW = $11
UP_ARROW = $91
RIGHT_ARROW = $1d
LEFT_ARROW = $9d
E_KEY = $45
G_KEY = $47
Q_KEY = $51
F1_KEY = $85
PLUS_KEY = $2b
MINUS_KEY = $2d
SPACE_KEY = $20
