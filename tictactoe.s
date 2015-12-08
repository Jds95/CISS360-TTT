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
			move $a1, $v0  		# a0 = board size, will be used for printing


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

			jal printBoard
			jal printBotRow

TicTacToeGameLoop: 
			li $v0, 4
			la $a0, NEWLINE
			syscall

			jal getUserInput 			# Get user input for row/col
			jal printBoard
			jal printBotRow
			jal ComputerAiWinMoveCheck  # Check to see if computer has winning move

			j TicTacToeGameLoop

#--------------------------------------------------------------------------
# Function to check if Ai has Win Move
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
ComputerAiWinMoveCheck:

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
				beq $s1, $a1, ComputerAiColCheck
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
# Functions to perform winning move on Column for Computer Ai
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


ComputerAiColCheck:
				jr 	$ra
#------------------------------------------------------------------------
# Functions to get user input from the user
# Registers used $a2, $a3 for row/col
#------------------------------------------------------------------------

getUserInput:
			li $v0, 4
			la $a0, rowinput
			syscall

			li $v0, 5
			syscall
			move $a2, $v0 		# a2 = row 

			li $v0, 4
			la $a0, NEWLINE
			syscall

			li $v0, 4
			la $a0, colinput
			syscall

			li $v0, 5
			syscall
			move $a3, $v0 		# a3 = col

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

			li  $t2, 1 			# t2 = 2 or 'X'
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

DisplayComputerWin:
			li 	$v0, 4
			la 	$a0, NEWLINE
			syscall

			li 	$v0, 4
			la 	$a0, computerwon
			syscall

			jal printBoard
			jal printBotRow

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