#--------------------------------------------------------------------
# Tic Tac Toe Project: Jesse and Seth
# Date: 11-15-30
# Game Description: N by N tic tac toe game versus a computer ai
# -------------------------------------------------------------------
		.text
		.globl main


main:		li $v0, 4
			la $a0, WELCOME 	# Display Welcome Message
			syscall

			li $v0, 4
			la $a0, NEWLINE
			syscall				

			li $v0, 4
			la $a0, ENTERN
			syscall

			li $v0, 5
			syscall
			move $a1, $v0  		# a1 = board size, will be used for printing


			jal setupboard

Computerfirstmove:

			li $v0, 4
			la $a0, NEWLINE
			syscall

			li $v0, 4
			la $a0, first	# Display Welcome Message
			syscall

			li $v0, 4
			la $a0, NEWLINE
			syscall

			li 	$t0, 0
			li  $t1, 2 		# Divide by 2
			li 	$t2, 0
			li 	$t3, 4 		# Mult by 4
			la 	$t7, BOARD
			div $t0, $a1, $t1 	# n / 2 for row spot
			addi $t0, 1
			div $t2, $a1, $t1   # n / 2 for col spot
			addi $t2, 1

			addi $t0, $t0, -1 	# t0 = r-1
			mul  $t0, $t0, $a1 	# t0 = (r-1) * column total
			addi $t2, $t2, -1   # t1 = c-1
			add  $t0, $t0, $t2  # t0 = (r-1)*col + (c-1)
			mul  $t0, $t0, $t3  # t0 = 4(t0)

			add $t7, $t7, $t0   # t7 = offset position for board spot for move
			li 	$t1, 1

			sw 	$t1, 0($t7)


TicTacToeGameLoop: 
			li $v0, 4
			la $a0, NEWLINE
			syscall

			jal printBoard
			jal printBotRow
			jal GameDrawCheck
			jal getUserInput 			# Get user input for row/col
			jal GameDrawCheck 			# Check if game tied
			jal PlayerWinRowCheck 		# Check if player won on any rows
			jal PlayerWinColCheck 		# Check if player won on any cols
			jal PlayerWinCheckLeftDiag 	# Check if player won on L Diag
			jal PlayerWinCheckRightDiag # Check if player won on R Diag
			jal ComputerAiWinMoveCheckRow  # Check to see if computer has winning move row
			jal ComputerAiWinMoveCheckCol  # Check to see if computer has winning move col
			jal ComputerAiWinMoveCheckLeftDiag # Check to see if right diag win
			jal ComputerAiWinMoveCheckRightDiag # Check to see if left diag win
			jal PlayerWinMoveCheckRow 		# Check to see if Ai needs to block player win move on row
			jal PlayerWinMoveCheckCol  		# Check to see if Ai needs to block player win move on col
			jal PlayerWinMoveCheckLeftDiag  # Check to see if Ai needs to block player win move on left diag
			jal PlayerWinMoveCheckRightDiag # Check to see if Ai needs to block player win move on right diag
			jal MakeAiMove 					# If Ai didn't block a move, play at first int openning

			j TicTacToeGameLoop

#--------------------------------------------------------------------------
# Function to check if Ai has Win Move on Row
# Registers used
# t0 = O
# t1 = X
# t2 = 4 for mult by 4 for moving around memory
# t3 = counter for O's
# t4 = counter for X's
# t5 = Board for Ai win
# s0 = Board for moving through Loop checking for win rows
# s1 = outer loop i
# s2 = inner loop j 
# s3 = loading words
# s4 = n - 1, amount of O's needed for win row
#--------------------------------------------------------------------------
ComputerAiWinMoveCheckRow:

ComputerAiRowCheck:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t3, 0 			# t3 = counter of O's
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = Outer loop i for for-loop
				li 	$s2, 0 			# s2 = Inner loop j for for-loop
				li 	$s4, 0
				addi $s4, $a1, -1 	# s4 = n - 1

ComputerAiRowCheckOuterLoop:
				beq $s1, $a1, loopreturn
ComputerAiRowCheckInnerLoop:
				beq $s2, $a1, CheckAiRowWin 	# if s2/j = n, check if it's possible to win
				lw 	$s3, 0($s0) 	# s3 = first element of the row/cycle through
				beq $s3, $t0, updateOcounter
				beq $s3, $t1, updateXCounter

				addi $s0, 4 		# If spot is space, update to next spot
				addi $s2, 1 		# update j 
				j ComputerAiRowCheckInnerLoop


updateOcounter:
				addi $t3, 1 		# update O counter 
				addi $s0, 4 		# Update memory to next int
				addi $s2, 1 		# update j 
				j ComputerAiRowCheckInnerLoop

updateXCounter: 
				addi $t4, 1 		# update X counter
				addi $s0, 4 		# update mememory to next int
				addi $s2, 1 		# update j 
				j ComputerAiRowCheckInnerLoop

#------------------------------------------------------------------------
# Functions to perform winning move on Row for Computer Ai
#------------------------------------------------------------------------
CheckAiRowWin:
				bgt $t4, $0, UpdateComputerAiRowCheckOuterLoop 		# If x counter > 0, not a win on that row
				bne $t3, $s4, UpdateComputerAiRowCheckOuterLoop 	# if O counter != n - 1 then not a win

ComputerAiWinMove:
				la 	$t5, BOARD 		# load board to t5
				li 	$t3, 0 			# reset t3 to 0 for computation of offset position

				add $t3, $t3, $s1   # t3 = outer loop i (Row where win is)
				mul $t3, $t3, $a1   # t3 * n or Col number
				mul $t3, $t3, $t2   # t3 * 4 for offset in memory of row

				add $t5, $t5, $t3 	# t5 = first element of winning row
				
ComputerAiWinLoop:
				lw 	$t3, 0($t5)
				bne $t3, $0, updateAiWinLoop

				sw 	$t0, 0($t5)

				j DisplayComputerWin


updateAiWinLoop:
				addi $t5, 4
				j ComputerAiWinLoop

UpdateComputerAiRowCheckOuterLoop:
				li 	$t3, 0 			# Counter for O reset
				li 	$t4, 0  		# Counter for X reset
				addi $s1, 1 		# Update i by 1
				li 	$s2, 0 			# reset j (inner loop) to 0
				j ComputerAiRowCheckOuterLoop


loopreturn:
				jr 	$ra

#------------------------------------------------------------------------
# Function to check if Ai has winning move in a column
# Registers used
# t0 = O
# t1 = X
# t2 = 4 for mult by 4 for moving around memory
# t3 = counter for O's
# t4 = counter for X's
# t5 = Board for Ai win
# s0 = Board for moving through Loop checking for win rows
# s1 = outer loop i
# s2 = inner loop j 
# s3 = loading words
# s4 = n - 1, amount of O's needed for win row
# s7 = variable offset for i'th row in winning loop 
#------------------------------------------------------------------------
ComputerAiWinMoveCheckCol:

ComputerAiColCheck:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t3, 0 			# t3 = counter of O's
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = Outer loop i for for-loop
				li 	$s2, 0 			# s2 = Inner loop j for for-loop
				li 	$s4, 0
				addi $s4, $a1, -1 	# s4 = n - 1

ComputerAiColCheckOuterLoop:
				beq $s1, $a1, loopreturn
ComputerAiColCheckInnerLoop:
				beq $s2, $a1, CheckAiColWin 	# if s2/j = n, check if it's possible to win
				lw 	$s3, 0($s0) 	# s3 = first element of the col/cycle through
				beq $s3, $t0, updateOcounterCol
				beq $s3, $t1, updateXCounterCol

				li 	$t5, 0			# t5 = 0 for offset for column
				move $t5, $a1 		# t5 = n columns
				mul $t5, $t5, $t2 	# t5 = 4 * n to get to next column 
				add $s0, $s0, $t5 	# If spot is space, update to next spot

				addi $s2, 1 		# update j 
				j ComputerAiColCheckInnerLoop


updateOcounterCol:
				addi $t3, 1 		# update O counter 
				li 	 $t5, 0			# t5 = 0 for offset for column
				move $t5, $a1 	    # t5 = n Columns
				mul $t5, $t5, $t2 	# t5 = 4 * n to get to next column 
				add $s0, $s0, $t5 	# If spot is space, update to next spot
		
				addi $s2, 1 		# update j 
				j ComputerAiColCheckInnerLoop

updateXCounterCol: 
				addi $t4, 1 		# update X counter
				li 	 $t5, 0			# t5 = 0 for offset for column
				move $t5, $a1 		# t5 = n Colum
				mul $t5, $t5, $t2 	# t5 = 4 * n to get to next column 
				add $s0, $s0, $t5 	# If spot is space, update to next spot
			
				addi $s2, 1 		# update j 
				j ComputerAiColCheckInnerLoop

#------------------------------------------------------------------------
# Functions to perform winning move on Column for Computer Ai
#------------------------------------------------------------------------
CheckAiColWin:
				bgt $t4, $0, UpdateComputerAiColCheckOuterLoop 		# If x counter > 0, not a win on that row
				bne $t3, $s4, UpdateComputerAiColCheckOuterLoop 	# if O counter != n - 1 then not a win

ComputerAiWinMoveCol:
				la 	$t5, BOARD 		# load board to t5
				li 	$t3, 0 			# reset t3 to 0 for computation of offset position

				mul $s1, $s1, $t2 	# s1 = i * 4 for memory of first column win memory location

				add $t5, $t5, $s1 	# t5 = first element of winning col
				
ComputerAiWinLoopCol:
				lw 	$t3, 0($t5)
				bne $t3, $0, updateAiWinLoopCol

				sw 	$t0, 0($t5)

				j DisplayComputerWin


updateAiWinLoopCol:
				li 	$t6, 0 			# t6 = offset to next column member
				mul $t6, $a1, $t2 	# t6 = Column * 4
				add $t5, $t5, $t6 	# t5 = offset by t6 to next column member
				j ComputerAiWinLoopCol

UpdateComputerAiColCheckOuterLoop:
				li 	$t3, 0 			# Counter for O reset
				li 	$t4, 0  		# Counter for X reset
				addi $s1, 1 		# Update i by 1
				li 	$s2, 0 			# reset j (inner loop) to 0

				la 	$s0, BOARD 		# reset board to first object
				li 	$s7, 0 			# s7 = variable offset
				mul $s7, $s1, $t2 	# s7 = i'th row * 4

				add $s0, $s0, $s7 	# Set s0 to point to first object in column

				j ComputerAiColCheckOuterLoop
#------------------------------------------------------------------------
# Functions to check if Computer Ai has winning Left Diag Move
# t0 = O
# t1 = X
# t2 = 4 for mult by 4 for moving around memory
# t3 = counter for O's
# t4 = counter for X's
# t5 = Board for Ai win
# s0 = Board for moving through Loop checking for win rows
# s3 = offset to next diag int
# s4 = n - 1
#------------------------------------------------------------------------

ComputerAiWinMoveCheckLeftDiag:

ComputerAiDiagLeftCheck:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t3, 0 			# t3 = counter of O's
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = Outer loop i for for-loop
				li 	$s2, 0 			# s2 = offset to next diagonal int
				li 	$s4, 0
				addi $s4, $a1, -1 	# s4 = n - 1

ComputerAiDiagLeftLoop:
				beq $s1, $a1, CheckAiDiagLeftWin
				lw 	$s3, 0($s0) 	# s3 = first element of the diag/cycle through
				beq $s3, $t0, updateOcounterDiagLeft
				beq $s3, $t1, updateXCounterDiagLeft

				move $s3, $a1 		# s3 = column size
				addi $s3, 1 		# s3 = column size + 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag

				add $s0, $s0, $s3 	# s3 offset to next diag int 

				addi $s1, 1 		# Update i for for-loop
				j ComputerAiDiagLeftLoop


updateXCounterDiagLeft:
				addi $t4, 1 		# update O counter 
				move $s3, $a1 		# s3 = column size
				addi $s3, 1 		# s3 = column size + 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag

				add $s0, $s0, $s3 	# s3 offset to next diag int 
				addi $s1, 1 		# Update i for for-loop

				j ComputerAiDiagLeftLoop
updateOcounterDiagLeft:
				addi $t3, 1 		# update O counter 	
			 	move $s3, $a1 		# s3 = column size
				addi $s3, 1 		# s3 = column size + 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag

				add $s0, $s0, $s3 	# s3 offset to next diag int 
				addi $s1, 1 		# Update i for for-loop

				j ComputerAiDiagLeftLoop

CheckAiDiagLeftWin:
				bgt $t4, $0, loopreturn 		# If x counter > 0, not a win on that row
				bne $t3, $s4, loopreturn		# if O counter != n - 1 then not a win

ComputerAiWinMoveDiagLeft:
				la 	$t5, BOARD 		# load board to t5

ComputerAiWinMoveDiagLeftLoop:
				lw 	$t3, 0($t5)  	# Load int in diagonal
				bne $t3, $0, updateAiWinLoopDiagLeft

				sw 	$t0, 0($t5) 	# Store winning move

				j DisplayComputerWin # Display win

updateAiWinLoopDiagLeft:
				move $s3, $a1 		# s3 = column size
				addi $s3, 1 		# s3 = column size + 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag

				add $t5, $t5, $s3 	# t5 moves memory to next int in diag

				j ComputerAiWinMoveDiagLeftLoop

#------------------------------------------------------------------------
# Functions to check if Computer Ai has winning Right Diag Move
# t0 = O
# t1 = X
# t2 = 4 for mult by 4 for moving around memory
# t3 = counter for O's
# t4 = counter for X's
# t5 = Board for Ai win
# s0 = Board for moving through Loop checking for win rows
# s3 = offset to next diag int
# s4 = n - 1
#------------------------------------------------------------------------

ComputerAiWinMoveCheckRightDiag:

ComputerAiDiagRightCheck:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t3, 0 			# t3 = counter of O's
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = i for loop
				li 	$s4, 0
				addi $s4, $a1, -1 	# s4 = n - 1
ComputerAiDiagRightLoop:
				beq $s1, $a1, CheckAiDiagRightWin
				move $s3, $a1 		# s3 = column size / n
				addi $s3, -1 		# s3 = column size - 1/n - 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag
				add $s0, $s0, $s3 	# s3 offset to next diag int 

				lw 	$s3, 0($s0) 	# s3 = first element of the diag/cycle through
				beq $s3, $t0, updateOcounterDiagRight
				beq $s3, $t1, updateXCounterDiagRight

				addi $s1, 1 		# Update i for for-loop
				j ComputerAiDiagRightLoop


updateXCounterDiagRight:
				addi $t4, 1 		# update O counter 	
				j ComputerAiDiagRightLoop
updateOcounterDiagRight:
				addi $t3, 1 		# update O counter 	
				j ComputerAiDiagRightLoop

CheckAiDiagRightWin:
				bgt $t4, $0, loopreturn 		# If x counter > 0, not a win on that row
				bne $t3, $s4, loopreturn		# if O counter != n - 1 then not a win

ComputerAiWinMoveDiagRight:
				la 	$t5, BOARD 		# load board to t5

ComputerAiWinMoveDiagRightLoop:
				move $s3, $a1 		# s3 = column size / n
				addi $s3, -1 		# s3 = column size - 1/n - 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag
				add $t5, $t5, $s3 	# s3 offset to next diag int 

				lw 	$t3, 0($t5)  	# Load int in diagonal
				bne $t3, $0, ComputerAiWinMoveDiagRightLoop

				sw 	$t0, 0($t5) 	# Store winning move

				j DisplayComputerWin # Display win
#--------------------------------------------------------------------------
# Function to check if Player has a winning move in a row, block it
# Registers used
# t0 = O
# t1 = X
# t2 = 4 for mult by 4 for moving around memory
# t3 = counter for O's
# t4 = counter for X's
# t5 = Board for Ai win
# s0 = Board for moving through Loop checking for win rows
# s1 = outer loop i
# s2 = inner loop j 
# s3 = loading words
# s4 = n - 1, amount of O's needed for win row
#--------------------------------------------------------------------------
PlayerWinMoveCheckRow:

PlayerRowCheck:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t3, 0 			# t3 = counter of O's
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = Outer loop i for for-loop
				li 	$s2, 0 			# s2 = Inner loop j for for-loop
				li 	$s4, 0
				addi $s4, $a1, -1 	# s4 = n - 1

PlayerRowCheckOuterLoop:
				beq $s1, $a1, loopreturn
PlayerRowCheckInnerLoop:
				beq $s2, $a1, CheckPlayerRowWin # if s2/j = n, check if it's possible to win
				lw 	$s3, 0($s0) 	# s3 = first element of the row/cycle through
				beq $s3, $t0, updateOcounterPlayer
				beq $s3, $t1, updateXCounterPlayer

				addi $s0, 4 		# If spot is space, update to next spot
				addi $s2, 1 		# update j 
				j PlayerRowCheckInnerLoop


updateOcounterPlayer:
				addi $t3, 1 		# update O counter 
				addi $s0, 4 		# Update memory to next int
				addi $s2, 1 		# update j 
				j PlayerRowCheckInnerLoop

updateXCounterPlayer: 
				addi $t4, 1 		# update X counter
				addi $s0, 4 		# update mememory to next int
				addi $s2, 1 		# update j 
				j PlayerRowCheckInnerLoop

#------------------------------------------------------------------------
# Functions to Check if player has any winning rows, block it
#------------------------------------------------------------------------
CheckPlayerRowWin:
				bgt $t3, $0, UpdatePlayerRowCheckOuterLoop 		# If o counter > 0, not a win on that row
				bne $t4, $s4, UpdatePlayerRowCheckOuterLoop 	# if x counter != n - 1 then not a win

PlayerWinMoveBlock:
				la 	$t5, BOARD 		# load board to t5
				li 	$t3, 0 			# reset t3 to 0 for computation of offset position

				add $t3, $t3, $s1   # t3 = outer loop i (Row where win is)
				mul $t3, $t3, $a1   # t3 * n or Col number
				mul $t3, $t3, $t2   # t3 * 4 for offset in memory of row

				add $t5, $t5, $t3 	# t5 = first element of winning row
				
PlayerWinBlockLoop:
				lw 	$t3, 0($t5)
				bne $t3, $0, updatePlayerWinBlockLoop

				sw 	$t0, 0($t5) 	# Block Move

				j TicTacToeGameLoop # return to game loop


updatePlayerWinBlockLoop:
				addi $t5, 4
				j PlayerWinBlockLoop

UpdatePlayerRowCheckOuterLoop:
				li 	$t3, 0 			# Counter for O reset
				li 	$t4, 0  		# Counter for X reset
				addi $s1, 1 		# Update i by 1
				li 	$s2, 0 			# reset j (inner loop) to 0
				j PlayerRowCheckOuterLoop

#------------------------------------------------------------------------
# Function to check if Player has winning column, then block
# Registers used
# t0 = O
# t1 = X
# t2 = 4 for mult by 4 for moving around memory
# t3 = counter for O's
# t4 = counter for X's
# t5 = Board for Ai win
# s0 = Board for moving through Loop checking for win rows
# s1 = outer loop i
# s2 = inner loop j 
# s3 = loading words
# s4 = n - 1, amount of O's needed for win row
# s7 = variable offset for i'th row in winning loop 
#------------------------------------------------------------------------
PlayerWinMoveCheckCol:

PlayerColCheck:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t3, 0 			# t3 = counter of O's
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = Outer loop i for for-loop
				li 	$s2, 0 			# s2 = Inner loop j for for-loop
				li 	$s4, 0
				addi $s4, $a1, -1 	# s4 = n - 1

PlayerColCheckOuterLoop:
				beq $s1, $a1, loopreturn
PlayerColCheckInnerLoop:
				beq $s2, $a1, CheckPlayerColWin 	# if s2/j = n, check if it's possible to win
				lw 	$s3, 0($s0) 	# s3 = first element of the col/cycle through
				beq $s3, $t0, updateOcounterColPlayer
				beq $s3, $t1, updateXCounterColPlayer

				li 	$t5, 0			# t5 = 0 for offset for column
				move $t5, $a1 		# t5 = n columns
				mul $t5, $t5, $t2 	# t5 = 4 * n to get to next column 
				add $s0, $s0, $t5 	# If spot is space, update to next spot

				addi $s2, 1 		# update j 
				j PlayerColCheckInnerLoop


updateOcounterColPlayer:
				addi $t3, 1 		# update O counter 
				li 	 $t5, 0			# t5 = 0 for offset for column
				move $t5, $a1 	    # t5 = n Columns
				mul $t5, $t5, $t2 	# t5 = 4 * n to get to next column 
				add $s0, $s0, $t5 	# If spot is space, update to next spot
		
				addi $s2, 1 		# update j 
				j PlayerColCheckInnerLoop

updateXCounterColPlayer: 
				addi $t4, 1 		# update X counter
				li 	 $t5, 0			# t5 = 0 for offset for column
				move $t5, $a1 		# t5 = n Colum
				mul $t5, $t5, $t2 	# t5 = 4 * n to get to next column 
				add $s0, $s0, $t5 	# If spot is space, update to next spot
			
				addi $s2, 1 		# update j 
				j PlayerColCheckInnerLoop

#------------------------------------------------------------------------
# Functions to perform Player Col block check
#------------------------------------------------------------------------
CheckPlayerColWin:
				bgt $t3, $0, UpdatePlayerColCheckOuterLoop 		# If o counter > 0, not a win on that row
				bne $t4, $s4, UpdatePlayerColCheckOuterLoop 	# if x counter != n - 1 then not a win

PlayerWinMoveColBlock:
				la 	$t5, BOARD 		# load board to t5
				li 	$t3, 0 			# reset t3 to 0 for computation of offset position

				mul $s1, $s1, $t2 	# s1 = i * 4 for memory of first column win memory location

				add $t5, $t5, $s1 	# t5 = first element of winning col
				
PlayerWinLoopColBlock:
				lw 	$t3, 0($t5)
				bne $t3, $0, updatePlayerWinLoopColBlock

				sw 	$t0, 0($t5) 	# Block Move

				j TicTacToeGameLoop # return to game loop


updatePlayerWinLoopColBlock:
				li 	$t6, 0 			# t6 = offset to next column member
				mul $t6, $a1, $t2 	# t6 = Column * 4
				add $t5, $t5, $t6 	# t5 = offset by t6 to next column member
				j PlayerWinLoopColBlock

UpdatePlayerColCheckOuterLoop:
				li 	$t3, 0 			# Counter for O reset
				li 	$t4, 0  		# Counter for X reset
				addi $s1, 1 		# Update i by 1
				li 	$s2, 0 			# reset j (inner loop) to 0

				la 	$s0, BOARD 		# reset board to first object
				li 	$s7, 0 			# s7 = variable offset
				mul $s7, $s1, $t2 	# s7 = i'th row * 4

				add $s0, $s0, $s7 	# Set s0 to point to first object in column

				j PlayerColCheckOuterLoop

#------------------------------------------------------------------------
# Functions to check if Player has winning move left diag, then block
# t0 = O
# t1 = X
# t2 = 4 for mult by 4 for moving around memory
# t3 = counter for O's
# t4 = counter for X's
# t5 = Board for Ai win
# s0 = Board for moving through Loop checking for win rows
# s3 = offset to next diag int
# s4 = n - 1
#------------------------------------------------------------------------

PlayerWinMoveCheckLeftDiag:

PlayerDiagLeftCheck:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t3, 0 			# t3 = counter of O's
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = Outer loop i for for-loop
				li 	$s2, 0 			# s2 = offset to next diagonal int
				li 	$s4, 0
				addi $s4, $a1, -1 	# s4 = n - 1

PlayerDiagLeftLoop:
				beq $s1, $a1, CheckPlayerDiagLeftWin
				lw 	$s3, 0($s0) 	# s3 = first element of the diag/cycle through
				beq $s3, $t0, updateOcounterDiagLeftPlayer
				beq $s3, $t1, updateXCounterDiagLeftPlayer

				move $s3, $a1 		# s3 = column size
				addi $s3, 1 		# s3 = column size + 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag

				add $s0, $s0, $s3 	# s3 offset to next diag int 

				addi $s1, 1 		# Update i for for-loop
				j PlayerDiagLeftLoop


updateXCounterDiagLeftPlayer:
				addi $t4, 1 		# update O counter 
				move $s3, $a1 		# s3 = column size
				addi $s3, 1 		# s3 = column size + 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag

				add $s0, $s0, $s3 	# s3 offset to next diag int 
				addi $s1, 1 		# Update i for for-loop

				j PlayerDiagLeftLoop
updateOcounterDiagLeftPlayer:
				addi $t3, 1 		# update O counter 	
			 	move $s3, $a1 		# s3 = column size
				addi $s3, 1 		# s3 = column size + 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag

				add $s0, $s0, $s3 	# s3 offset to next diag int 
				addi $s1, 1 		# Update i for for-loop

				j PlayerDiagLeftLoop

CheckPlayerDiagLeftWin:
				bgt $t3, $0, loopreturn 		# If o counter > 0, not a win on that row
				bne $t4, $s4, loopreturn		# if x counter != n - 1 then not a win

PlayerWinMoveDiagLeftBlock:
				la 	$t5, BOARD 		# load board to t5

PlayerWinMoveDiagLeftLoopBlock:
				lw 	$t3, 0($t5)  	# Load int in diagonal
				bne $t3, $0, updatePlayerWinLoopDiagLeftBlock

				sw 	$t0, 0($t5) 	# Block Move

				j TicTacToeGameLoop # return to game loop

updatePlayerWinLoopDiagLeftBlock:
				move $s3, $a1 		# s3 = column size
				addi $s3, 1 		# s3 = column size + 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag

				add $t5, $t5, $s3 	# t5 moves memory to next int in diag

				j PlayerWinMoveDiagLeftLoopBlock

#------------------------------------------------------------------------
# Functions to check if Player has winning Right Diag move, block it
# t0 = O
# t1 = X
# t2 = 4 for mult by 4 for moving around memory
# t3 = counter for O's
# t4 = counter for X's
# t5 = Board for Ai win
# s0 = Board for moving through Loop checking for win rows
# s3 = offset to next diag int
# s4 = n - 1
#------------------------------------------------------------------------

PlayerWinMoveCheckRightDiag:

PlayerDiagRightCheck:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t3, 0 			# t3 = counter of O's
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = i for loop
				li 	$s4, 0
				addi $s4, $a1, -1 	# s4 = n - 1
PlayerDiagRightLoop:
				beq $s1, $a1, CheckPlayerDiagRightWin
				move $s3, $a1 		# s3 = column size / n
				addi $s3, -1 		# s3 = column size - 1/n - 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag
				add $s0, $s0, $s3 	# s3 offset to next diag int 

				lw 	$s3, 0($s0) 	# s3 = first element of the diag/cycle through
				beq $s3, $t0, updateOcounterDiagRightPlayer
				beq $s3, $t1, updateXCounterDiagRightPlayer

				addi $s1, 1 		# Update i for for-loop
				j PlayerDiagRightLoop


updateXCounterDiagRightPlayer:
				addi $t4, 1 		# update O counter 	
				j PlayerDiagRightLoop
updateOcounterDiagRightPlayer:
				addi $t3, 1 		# update O counter 	
				j PlayerDiagRightLoop

CheckPlayerDiagRightWin:
				bgt $t3, $0, loopreturn 		# If o counter > 0, not a win on that row
				bne $t4, $s4, loopreturn		# if x counter != n - 1 then not a win

PlayerWinMoveDiagRightBlock:
				la 	$t5, BOARD 		# load board to t5

PlayerWinMoveDiagRightLoopBlock:
				move $s3, $a1 		# s3 = column size / n
				addi $s3, -1 		# s3 = column size - 1/n - 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag
				add $t5, $t5, $s3 	# s3 offset to next diag int 

				lw 	$t3, 0($t5)  	# Load int in diagonal
				bne $t3, $0, PlayerWinMoveDiagRightLoopBlock

				sw 	$t0, 0($t5) 	# Block move 

				j TicTacToeGameLoop # return back to game

#------------------------------------------------------------------------
# Function to make the computer make a move
#------------------------------------------------------------------------
MakeAiMove:
				la $s0, BOARD 		# Board address put into s0
				li $t0, 0  			# t0 counter to go through all items
				move $t1, $a1  		# t1 = n
				mul  $t1, $t1, $t1  # t1 = total number of cells for ttt board
				li 	$t2, 1

MakeAiMoveLoop:
				beq $t0, $t1, TicTacToeGameLoop

				lw 	$s1, 0($s0) 	# Load first int of board
				bne $s1, $0, updateMakeAiMoveLoop 	# If it isn't space, update to next int

				sw 	$t2, 0($s0)  	# Load O into board

				j TicTacToeGameLoop 


updateMakeAiMoveLoop:
				addi $t0, 1
				addi $s0, 4

				j MakeAiMoveLoop

#------------------------------------------------------------------------
# Function to check if game ended in a draw
# Registers used
# s0 = board
# s1 = load words
# t0 = counter to go through entire board
# t1 = number of cells 
#------------------------------------------------------------------------
GameDrawCheck:			
				la $s0, BOARD 		# Board address put into s0
				li $t0, 0  			# t0 counter to go through all items
				move $t1, $a1  		# t1 = n
				mul  $t1, $t1, $t1  # t1 = total number of cells for ttt board
				li $t2, 0 			# t2 = number of spaces
DrawCheckLoop:
				beq $t0, $t1, DrawCheckResults
				lw 	$s1, 0($s0) 	# s1 = int in storage
				beq $s1, $0, returnToGame
				
				addi $t0, 1
				addi $s0, 4
				j DrawCheckLoop				

DrawCheckResults:
				j DisplayGameDraw

returnToGame:
				jr $ra

#--------------------------------------------------------------------------
# Function to check if Player won on any of the rows
#--------------------------------------------------------------------------
PlayerWinRowCheck:

PlayerWinRowCheckVariables:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = Outer loop i for for-loop
				li 	$s2, 0 			# s2 = Inner loop j for for-loop
				move $s4, $a1

PlayerWinRowCheckOuterLoop:
				beq $s1, $a1, loopreturn
PlayerWinRowCheckInnerLoop:
				beq $s2, $a1, CheckifPlayerRowWin # if s2/j = n, check if it's possible to win
				lw 	$s3, 0($s0) 	# s3 = first element of the row/cycle through
				beq $s3, $t1, updateXCounterPlayerWin

				j UpdatePlayerWinRowCheckOuterLoop


updateXCounterPlayerWin: 
				addi $t4, 1 		# update X counter
				addi $s0, 4 		# update mememory to next int
				addi $s2, 1 		# update j 
				j PlayerWinRowCheckInnerLoop

#------------------------------------------------------------------------
# Functions to check if player won on any rowss
#------------------------------------------------------------------------
CheckifPlayerRowWin:
				bne $t4, $s4, UpdatePlayerWinRowCheckOuterLoop 	# if x counter != n then not a win

				j 	DisplayPlayerWin

UpdatePlayerWinRowCheckOuterLoop:
				li 	$t4, 0  		# Counter for X reset
				addi $s1, 1 		# Update i by 1
				li 	$s2, 0 			# reset j (inner loop) to 0

				la 	 $s0, BOARD 	# Load board to start
				move $t5, $a1  		# t5 = n
				mul  $t5, $t5, $s1  # t5 = n * i offset for row
				mul  $t5, $t5, $t2  # t5 = 4(n * i)

				add $s0, $s0, $t5
				j PlayerWinRowCheckOuterLoop

#------------------------------------------------------------------------
# Function to check if Player won in a column
#------------------------------------------------s------------------------
PlayerWinCheckCol:

PlayerWinColCheck:
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = Outer loop i for for-loop
				li 	$s2, 0 			# s2 = Inner loop j for for-loop
				move $s4, $a1

PlayerWinColCheckOuterLoop:
				beq $s1, $a1, loopreturn
PlayerWinColCheckInnerLoop:
				beq $s2, $a1, CheckPlayerWinColWin 	# if s2/j = n, check if it's possible to win
				lw 	$s3, 0($s0) 	# s3 = first element of the col/cycle through
				beq $s3, $t1, updateXCounterColPlayerWin

				j UpdatePlayerWinColCheckOuterLoop

updateXCounterColPlayerWin: 
				addi $t4, 1 		# update X counter
				li 	 $t5, 0			# t5 = 0 for offset for column
				move $t5, $a1 		# t5 = n Colum
				mul $t5, $t5, $t2 	# t5 = 4 * n to get to next column 
				add $s0, $s0, $t5 	# If spot is space, update to next spot
			
				addi $s2, 1 		# update j 
				j PlayerWinColCheckInnerLoop

#------------------------------------------------------------------------
# Functions to check if player won any columns
#------------------------------------------------------------------------
CheckPlayerWinColWin:			
				bne $t4, $s4, UpdatePlayerWinColCheckOuterLoop 	# if x counter != n  then not a win, check next col

				j DisplayPlayerWin

UpdatePlayerWinColCheckOuterLoop:
				li 	$t4, 0  		# Counter for X reset
				addi $s1, 1 		# Update i by 1
				li 	$s2, 0 			# reset j (inner loop) to 0

				la 	$s0, BOARD 		# reset board to first object
				li 	$s7, 0 			# s7 = variable offset
				mul $s7, $s1, $t2 	# s7 = i'th row * 4

				add $s0, $s0, $s7 	# Set s0 to point to first object in column

				j PlayerWinColCheckOuterLoop

#------------------------------------------------------------------------
# Functions to check if Player won on left Diag
#------------------------------------------------------------------------

PlayerWinCheckLeftDiag:

PlayerWinDiagLeftCheck:
				li 	$t0, 1 			# t0 = 1 or "O"
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = Outer loop i for for-loop
				li 	$s2, 0 			# s2 = offset to next diagonal int
				move $s4, $a1

PlayerWinDiagLeftLoop:
				beq $s1, $a1, CheckPlayerWinDiagLeft
				lw 	$s3, 0($s0) 	# s3 = first element of the diag/cycle through
				beq $s3, $t1, updateXCounterDiagLeftPlayerWin
			
				j loopreturn


updateXCounterDiagLeftPlayerWin:
				addi $t4, 1 		# update O counter 
				move $s3, $a1 		# s3 = column size
				addi $s3, 1 		# s3 = column size + 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag

				add $s0, $s0, $s3 	# s3 offset to next diag int 
				addi $s1, 1 		# Update i for for-loop

				j PlayerWinDiagLeftLoop


CheckPlayerWinDiagLeft:
				bne $t4, $s4, loopreturn # # x's != n, no left diag win

				j DisplayPlayerWin

#------------------------------------------------------------------------
# Functions to check if Player has won on Right Diag
#------------------------------------------------------------------------

PlayerWinCheckRightDiag:

PlayerWinDiagRightCheck:
				li 	$t1, 2  		# t1 = 2 or "X"
				li 	$t2, 4 			# t2 = 4 for multiply
				li 	$t4, 0			# t4 = counter of X's
				la 	$s0, BOARD 		# s0 = Board for main loop through each row
				li 	$s1, 0 			# s1 = i for loop
				move $s4, $a1 
PlayerWinDiagRightLoop:
				beq $s1, $a1, CheckPlayerWinDiagRightWin
				move $s3, $a1 		# s3 = column size / n
				addi $s3, -1 		# s3 = column size - 1/n - 1 for next int for diag
				mul $s3, $s3, $t2 	# s3 = offset for next memory address in diag
				add $s0, $s0, $s3 	# s3 offset to next diag int 

				lw 	$s3, 0($s0) 	# s3 = first element of the diag/cycle through
				addi $s1, 1
				beq $s3, $t1, updateXCounterDiagRightPlayerWin

				j loopreturn

updateXCounterDiagRightPlayerWin:
				addi $t4, 1 		# update O counter

				j PlayerWinDiagRightLoop

CheckPlayerWinDiagRightWin:
				bne $t4, $s4, loopreturn		# if x counter != n  then not a win

				j DisplayPlayerWin

#------------------------------------------------------------------------
# Functions to get user input from the user
# Registers used $a2, $a3 for row/col
#------------------------------------------------------------------------

getUserInput:
			li $v0, 4
			la $a0, NEWLINE
			syscall

			li $v0, 4
			la $a0, rowinput
			syscall

			li $v0, 5
			syscall
			move $a2, $v0 		# a2 = row

			li $v0, 1
			move $a0, $a2 		# Print row 
			syscall 

			li $v0, 4
			la $a0, NEWLINE
			syscall

			li $v0, 4
			la $a0, colinput
			syscall

			li $v0, 5
			syscall
			move $a3, $v0 		# a3 = col

			li $v0, 1
			move $a0, $a3 		# Print col
			syscall 

			blt $a2, $0, getUserInput 	# No negative Row
			blt $a3, $0, getUserInput 	# No negative col
			move $t0, $a1 				# t0 = n
			bgt $a2, $t0, getUserInput 	# No row > row size
			bgt $a3, $t0, getUserInput  # No col > col size

			li $v0, 4
			la $a0, NEWLINE
			syscall
#------------------------------------------------------------------------
# Functions to check if user's input was a valid move or not
# Registers used 
# $a2/$a3 = for row/col
# $t0 = off set varible 
# $t1 = temp variable for c-1
# $t2 = load 0/1/2 from board, and store 2("X") into board space
# $t3 = 4, to multiply by 4
# $t7 = board address
#------------------------------------------------------------------------
validmove:
			li $t0, 0 		# Load offset set to 0
			li $t3, 4
			la $t7,BOARD      # Load board to t7

			addi $t0, $a2, -1 	# t0 = r-1
			mul  $t0, $t0, $a1 	# t0 = (r-1) * column total
			addi $t1, $a3, -1   # t1 = c-1
			add  $t0, $t0, $t1  # t0 = (r-1)*col + (c-1)
			mul  $t0, $t0, $t3  # t0 = 4(t0)

			add $t7, $t7, $t0   # t7 = offset position for board spot for move

			lw  $t2, 0($t7)     # t2 = 0/1/2 from offset position

			seq $v1, $t2, $0
			beq $v1, $0, getUserInput

			li  $t2, 2 			# t2 = 2 or 'X'
			sw  $t2, 0($t7)

			jr 	$ra


#------------------------------------------------------------------------
# Functions to set the board array to all 0's(spaces)
# Registers sued t0-t1, $sp, $ra
#------------------------------------------------------------------------
setupboard: la $t0, BOARD 	# t0 loads the address of board
			li $t1, 0 		# t1 used to offset by 4 to go through board bits
			addi $sp, $sp, -4 	# Allocate 1 int on stack to store ra
			
			sw $ra, 0($sp) 	# Store return address into the stack


setuploop:  beq $t1, 400, setupdone
			sw 	$0, 0($t0)

			addi $t1, $t1, 4 	# t1 +=4 for beq when hit end of board data storage
			addi $t0, $t0, 4     # t0 updated by 4 bits to next spot in memory for next board storage
			j setuploop


setupdone:
			lw $ra, 0($sp)  	# Reload jump return address into ra
			addi $sp, $sp, 4  		# De-allocate memory on the stack
			jr $ra


#-------------------------------------------------------------------------
# Functions to print the board
# Registers used t0-t6, $sp, $ra
#-------------------------------------------------------------------------

printBotRow:
			li $t1, 0		# t1 = i for loop set to 0

			li $v0, 4
			la $a0, plus    
			syscall

printrowcheck2:
			bge $t1, $a1, gameLoopreturn # if t1 >= a1(n) print col next
printrowLoop2: 
			li $v0, 4
			la $a0, row	# print row
			syscall

			addi $t1, $t1, 1
			j printrowcheck2

printBoard: 
			li $v0, 4
			la $a0, NEWLINE
			syscall

			li $t0, 0  		# t0 = i in for loop set to 0
			la $t3, BOARD   # load board into t3 for printing
			addi $sp, $sp, -4 	# Allocate 1 int on stack
			sw $ra, 0($sp) 	# Store return address into the stack

printBoardCheck:
			bge $t0, $a1, funcReturn  # if t0 = n, done with board 

printrow: 	li $t1, 0		# t1 = i for loop set to 0

			li $v0, 4
			la $a0, plus    # print intial row plus
			syscall

printrowcheck:	
			bge $t1, $a1, printcol  # if t1 >= a1(n) print col next
printrowLoop: 
			li $v0, 4
			la $a0, row	# print row
			syscall

			addi $t1, $t1, 1
			j printrowcheck


printcol: 	li $t2, 0 		# t2/i = 0 for for-loop
			
			li $v0, 4
			la $a0, NEWLINE
			syscall

			li $v0, 4
			la $a0, col
			syscall

printcolcheck:	
			beq $t2, $a1, incrementi
printcolLoop:
			
printspacecheck:
			lw 	$t6, 0($t3)		# t6 stores 0, 1, 2 from board
			seq $t4, $t6, 0
			beq $t4, $0, printOcheck

			li $v0, 4
			la $a0, space
			syscall	

			j printwall
printOcheck:
			li $t5, 1  		#t5 to represent 1 in board stream or 'O'
			seq $t4, $t6, $t5 
			beq $t4, $0, printX

			li $v0, 4
			la $a0, charO
			syscall	

			j printwall

printX:
			li $v0, 4
			la $a0, charX
			syscall

			j printwall	

printwall:  li $v0, 4
			la $a0, col
			syscall

			addi $t3, $t3, 4
			addi $t2, $t2, 1
			j printcolcheck

incrementi:
			addi $t0, 1

			li $v0, 4
			la $a0, NEWLINE
			syscall
			
			j printBoardCheck
funcReturn:
			lw $ra, 0($sp)  	# Reload jump return address into ra
			addi $sp, 4  		# De-allocate memory on the stack
			jr $ra

# Function to return from bottom row print
gameLoopreturn:
			jr $ra

DisplayPlayerWin:
			jal printBoard
			jal printBotRow

			li 	$v0, 4
			la 	$a0, NEWLINE
			syscall

			li 	$v0, 4
			la 	$a0, playerwon
			syscall

			li $v0, 10
			syscall


DisplayComputerWin:
			jal printBoard
			jal printBotRow

			li 	$v0, 4
			la 	$a0, NEWLINE
			syscall

			li 	$v0, 4
			la 	$a0, computerwon
			syscall

			li $v0, 10
			syscall

DisplayGameDraw:

			li 	$v0, 4
			la 	$a0, NEWLINE
			syscall

			li 	$v0, 4
			la 	$a0, gamedraw
			syscall

			li $v0, 10
			syscall
#-------------------------------------------------------------------------
# Exit the game
#-------------------------------------------------------------------------
exit:
			li $v0, 10
			syscall

		.data
BOARD:   .space 400
WELCOME: .asciiz "Let's play a game of tic-tac-toe."
ENTERN:  .asciiz "Enter n: "
NEWLINE: .asciiz "\n"
plus:    .asciiz "+"
row: 	 .asciiz "-+"
rowinput: .asciiz "Enter row: "
col:     .asciiz "|"
colinput: .asciiz "Enter col: "
space:   .asciiz " "
charX:   .asciiz "X"
charO:   .asciiz "O"
first:   .asciiz "I'll go first."
computerwon: .asciiz "The Computer has won!"
gamedraw: .asciiz "You Tied the Computer!"
playerwon: .asciiz "You Beat the Computer!"