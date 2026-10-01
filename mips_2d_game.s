#***************************************
# Name: Amani Chikh-Touhami
# Email:achikhtouhami@hawk.iit.edu
# Course: Cs350
# Assignment: Project 2
# Summary of Assignment Purpose: to create a 2D user friendly game in MIPS assembly
# Date of Initial Creation: nov/21/2023
#
# Description of Program Purpose: allows user to naviugate through a 2D map using the WASD keys with the objective of reaching the exit.


.data 0x10002000
initialMap: # initial game map data
    .ascii " ##0 ###"
    .ascii "  + @  *"
    .ascii "      @#"
    .ascii "1@###+ 2"
    .ascii "        "
    .ascii "  @#### "
    .ascii "   3  + "
    .ascii "S ## ## "
.data 0x10002040
dynamicMap: .space 64   

.data 0x10002800  
playerX:  .word 0   # player's X coordinate (column)
playerY:  .word 0   # player's Y coordinate (row)
gameOver: .word 0
score:    .word 0
#prompts
.data 0x10000000
userPrompt: .asciiz "How to play: (w: up[↑], a: left[←], s: down[↓], d: right[→]): \n"
.data 0x10000100
gameMessage:.asciiz "Welcome to the game!: \n"
.data 0x10000150
endGameMessage:.asciiz "you reached the exit!: \n"

.text
main:
    jal initializeGame
    or $0, $0, $0 #NOP
    gameLoop:
        # Call the function to flush console
	    addi $a1, $zero, 40
	    jal printNewlines
        or $0, $0, $0 #NOP
	    # render and display the map
        jal displayCurrentMap
        or $0, $0, $0 #NOP
        jal checkGameOver
            lui $t6, 0x1000
            ori $t6, $t6, 0x2808  # Address of 'gameOver' variable
	        lb $t5, 0($t6)
            or $0, $0, $0 #NOP
            addi $t7, $zero, 1
            beq $t5, $t7, endGame
        or $0, $0, $0 #NOP
        # print prompt message
        addi $v0, $zero, 4
	    lui $a0, 0x1000 	
	    ori $a0, $a0, 0		
	    syscall
        or $0, $0, $0 #NOP
        # READ USER INPUT
    	ori $v0, $zero, 12
    	syscall
    	or $a0, $zero, $v0	
        jal applyAction
        or $0, $0, $0 #NOP
        j gameLoop
        or $0, $0, $0 #NOP
    j endGame
    or $0, $0, $0 #NOP
endGame:
# Print a new line
    ori $v0, $zero, 11
    ori $a0, $zero, 10  
    syscall
# print game message
    addi $v0, $zero, 4
	lui $a0, 0x1000 	    
	ori $a0, $a0, 0x0150    
	syscall
    or $0, $0, $0 #NOP
    # Exit
    	ori $v0, $zero, 10
    	syscall
    	or $0, $0, $0 #NOP

# TASK 1 and 4: Represent initial map AND make the map dynamic
displayCurrentMap:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    # Load the address of initialMap
    lui $t0, 0x1000
    ori $t0, $t0, 0x2000
    or $0, $0, $0 #NOP
    # Load the address of dynamicMap
    lui $t1, 0x1000
    ori $t1, $t1, 0x2040
    or $0, $0, $0 #NOP
    addi $t2, $zero, 64     # Number of bytes to copy
    addi $t4, $zero, 1     
    addi $t5, $zero, 35     # '#' - Obstacle
    addi $t6, $zero, 42     # '*' - Exit gate
    initializeDynamicMap:
        # Initialize the dynamic map with empty spaces
        addi $t3, $zero, 32  # ASCII code for ' '
        sb $t3, 0($t1)     # Store empty space to dynamicMap
        sub $t2, $t2, $t4  # Decrement the counter
        beq $t2, $zero, endInitializeDynamicMap  # End loop if counter is zero
        addi $t1, $t1, 1   # Move to the next byte in dynamicMap
        or $0, $0, $0 #NOP
        j initializeDynamicMap
        or $0, $0, $0 #NOP
    endInitializeDynamicMap:
        addi $t2, $zero, 64 # Reset the counter
        # Load the address of dynamicMap
        lui $t1, 0x1000
        ori $t1, $t1, 0x2040
        or $0, $0, $0 #NOP
    copyStaticElementsLoop:
        lb $t3, 0($t0)  # Load a byte from initialMap
        or $0, $0, $0 #NOP
        # Check if it's a static element
        beq $t3, $t5, copyStaticElement  # '#' - Obstacle
        or $0, $0, $0 #NOP
        beq $t3, $t6, copyStaticElement  # '*' - Exit gate
        or $0, $0, $0 #NOP
        j skipDynamicMapUpdate
        or $0, $0, $0 #NOP
    skipDynamicMapUpdate:
        addi $t0, $t0, 1   # Move to the next byte in initialMap
        addi $t1, $t1, 1   # Move to the next byte in dynamicMap
        sub $t2, $t2, $t4  # Decrement the counter
        beq $t2, $zero, populatePosition  # End loop if counter is zero
        or $0, $0, $0 #NOP
        j copyStaticElementsLoop
        or $0, $0, $0 #NOP
    copyStaticElement:
        sb $t3, 0($t1)  # Store the byte to dynamicMap
        or $0, $0, $0 #NOP
        addi $t0, $t0, 1   # Move to the next byte in initialMap
        addi $t1, $t1, 1   # Move to the next byte in dynamicMap
        sub $t2, $t2, $t4  # Decrement the counter
        beq $t2, $zero, populatePosition  # End loop if counter is zero
        or $0, $0, $0 #NOP
        j copyStaticElementsLoop
        or $0, $0, $0 #NOP
    populatePosition:
        # Load the address of dynamicMap
        lui $t1, 0x1000
        ori $t1, $t1, 0x2040
        or $0, $0, $0 #NOP
        addi $t5, $zero, 8  # num of rows
        #load playerX and playerY
        lui $t0, 0x1000
        ori $t0, $t0, 0x2800
        or $0, $0, $0 #NOP
        lw $t7, 0($t0)      # playerX
        or $0, $0, $0 #NOP
        lw $t8, 4($t0)      # playerY
        or $0, $0, $0 #NOP
        # calculate Offset = Row * N + Col
        mult $t8, $t5
        mflo $t9            # $t9 = Row * N
        add $t9, $t9, $t7   # Offset = Row * N + Col
        add $t1, $t1, $t9   # adding the offset to the start of our map to go to the player position
        addi $t6, $zero, 36 # ASCII character '$' for the player
        sb $t6, 0($t1)      # Store the player's character in dynamicMap
        or $0, $0, $0 #NOP
        j endMakeMapDynamic
        or $0, $0, $0 #NOP
    endMakeMapDynamic:
        jal displayMap
        or $0, $0, $0 #NOP
        lw $ra, 0($sp)
        or $0, $0, $0 #NOP
        addi $sp, $sp, 4
        jr $ra
        or $0, $0, $0 #NOP

# Function to display the current map on the console
displayMap:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    # Load the address of dynamicMap - beginning of the current row
    lui $t0, 0x1000
    ori $t0, $t0, 0x2040
    or $0, $0, $0 #NOP
    addi $t1, $zero, 8      # number of columns in each row
    add $t3, $zero, $t0     # copy the beginning of the current row
    addi $t4, $zero, 8      # max number of rows 
    addi $t6, $zero, 1
    displayRowLoop:
        addi $t2, $zero, 0      # Initialize col counter
        #print Map Row
        rowLoop:
            lb $a0, 0($t3)      # load current column
            ori $v0, $zero, 11  # Print the column
            or $0, $0, $0 #NOP
            syscall
            addi $t3, $t3, 1    # Move to the next column
            addi $t2, $t2, 1    # Increment the col counter
            slt $t5, $t2, $t1	# test for col counter < num of columns in each row
            beq $t5, $zero, endRowLoop	# end loop if we reached the end of the row
            or $0, $0, $0 #NOP
            j rowLoop
            or $0, $0, $0 #NOP
        endRowLoop:
            sub $t4, $t4, $t6     # decrement number of rows
            # Print a new line
            ori $v0, $zero, 11
            ori $a0, $zero, 10  
            syscall
            beq $t4, $zero, endDisplayRowLoop	# end loop if we reached the end of the row
            or $0, $0, $0 #NOP
            j displayRowLoop
            or $0, $0, $0 #NOP
    endDisplayRowLoop:
        lw $ra, 0($sp)
        or $0, $0, $0 #NOP
        addi $sp, $sp, 4
        jr $ra
        or $0, $0, $0 #NOP

# TASK 3: initializer function
initializeGame:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal parseMap
    or $0, $0, $0 #NOP
    addi $t6, $zero, 0  #Score = 0
    # Print a new line
    ori $v0, $zero, 11
    ori $a0, $zero, 10  
    syscall
    # print game message
    addi $v0, $zero, 4
	lui $a0, 0x1000 	
	ori $a0, $a0, 0x0100		
	syscall
    or $0, $0, $0 #NOP
    lw $ra, 0($sp)
    or $0, $0, $0 #NOP
    addi $sp, $sp, 4
    jr $ra
    or $0, $0, $0 #NOP
    parseMap:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        # Load the address of initialMap
        lui $t0, 0x1000
        ori $t0, $t0, 0x2000
        or $0, $0, $0 #NOP
        addi $t1, $zero, 0   # Player's initial row position counter
        # Traverse the map to find the player's initial position
        add $t3, $zero, $t0  # Copy the address of map
        addi $t4, $zero, 8   # Number of max rows in the map
        addi $t2, $zero, 7   # Number of max columns in the map
        addi $t9, $zero, 83  # ascii for 'S'
        parseLoop:
            addi $t5, $zero, 0   # Initialize column counter
            parseColumnLoop:
                lb $t7, 0($t3)   # Load the current character from the map
                or $0, $0, $0 #NOP
                # Check if the current character is the player's initial position 'S'
                beq $t7, $t9, setPlayerPosition  
                or $0, $0, $0 #NOP
                addi $t3, $t3, 1   # Move to the next column in map
                addi $t5, $t5, 1   # Increment the column counter
                slt $t8, $t5, $t2  # test for col counter < num of columns in each row
                beq $t8, $zero, newRow	# end loop if we reached the end of the row
                or $0, $0, $0 #NOP
                j parseColumnLoop
                or $0, $0, $0 #NOP
            setPlayerPosition:
                #load playerX and playerY
                lui $t0, 0x1000
                ori $t0, $t0, 0x2800
                or $0, $0, $0 #NOP
                # Set the player's initial position based on the row and column counters
                sw $t5, 0($t0)      # Store the column in PlayerX
                sw $t1, 4($t0)      # Store the row in PlayerY
                j endparseLoop   # Exit the row parsing loop
                or $0, $0, $0 #NOP
            newRow:
                addi $t1, $t1, 1   # increment row counter
                addi $t3, $t3, 1   # Move to the next row in the map
                slt $t8, $t1, $t4  # test if row counter < max number of rows
                beq $t8, $zero, endparseLoop	# end loop if we reached the end of the row
                or $0, $0, $0 #NOP
                j parseLoop
                or $0, $0, $0 #NOP
        endparseLoop:
            lw $ra, 0($sp)
            or $0, $0, $0 #NOP
            addi $sp, $sp, 4
            jr $ra
            or $0, $0, $0 #NOP

# TASK 5: MAKE IT MOVE
applyAction:
	addi $sp, $sp -4 	# save space in stack 
	sw $ra, 0($sp) 		# save return address
	sw $a0, 4($sp)		# save a0
	add $t0, $zero, $a0
    #load playerX and playerY
    lui $s1, 0x1000
    ori $s1, $s1, 0x2800
    or $0, $0, $0 #NOP
    lw $s2, 0($s1)      # playerX
    or $0, $0, $0 #NOP
    lw $s3, 4($s1)      # playerY
    or $0, $0, $0 #NOP
    #w: up[↑], a: left[←], s: down[↓], d: right[→]): \n"
    addi $t1, $zero, 119    # 'w'
    addi $t2, $zero, 97     # 'a'
    addi $t3, $zero, 115    # 's'
    addi $t4, $zero, 100    # 'd'
    addi $t5, $zero, 116    # 't'
	# Check the operation selected by the user
	beq $t0, $t1, up        # 'w'
    or $0, $0, $0 #NOP
	beq $t0, $t2, left      # 'a'
    or $0, $0, $0 #NOP
	beq $t0, $t3, down      # 's'
    or $0, $0, $0 #NOP
	beq $t0, $t4, right     # 'd'
    or $0, $0, $0 #NOP
    beq $t0, $t5, endGame   # 't'
    or $0, $0, $0 #NOP
    up:
        addi $s3, $s3, -1     # Decrement Y coordinate
        j CheckObstaclesAndBoundaries
        or $0, $0, $0 #NOP
    left:
        addi $s2, $s2, -1     # Decrement X coordinate
        j CheckObstaclesAndBoundaries
        or $0, $0, $0 #NOP
    down:
        addi $s3, $s3, 1      # Increment Y coordinate
        j CheckObstaclesAndBoundaries
        or $0, $0, $0 #NOP
    right:
        addi $s2, $s2, 1      # Increment X coordinate
        j CheckObstaclesAndBoundaries
        or $0, $0, $0 #NOP
    endApplyAction:
        sw $s2, 0($s1)
        sw $s3, 4($s1)
        lw $a0, 4($sp)		# restore a0 
        or $0, $0, $0 #NOP
	    lw $ra, 0($sp)		# restore return address
        or $0, $0, $0 #NOP
	    addi $sp, $sp, 4	# restore stack
        jr $ra
        or $0, $0, $0 #NOP

# TASK 7: Check obstacles and boundaries
CheckObstaclesAndBoundaries:
    CheckObstacles:
    # Load the address of original map
        lui $t1, 0x1000
        ori $t1, $t1, 0x2000
        or $0, $0, $0 #NOP
        addi $t5, $zero, 8  # num of rows
        # calculate Offset = Row * N + Col
        mult $s3, $t5
        mflo $t9            # $t9 = Row * N
        add $t9, $t9, $s2   # Offset = Row * N + Col
        add $t1, $t1, $t9   # adding the offset to the start of our dynamicMap to go to the player position
        lb $t2, 0($t1)      #loading char at players current position
        or $0, $0, $0 #NOP
        addi $t5, $zero, 35 # '#' - Obstacle
        beq $t5, $t2, skipUpdate
        or $0, $0, $0 #NOP
    checkBoundaries:
        addi $t1, $zero, 8  # bounds
        # checking if X position is < 0
        slt $t2, $s2, $zero
        bne $t2, $zero, skipUpdate
        or $0, $0, $0 #NOP
        # checking if X position is within bounds
        slt $t2, $s2, $t1	
        beq $t2, $zero, skipUpdate
        or $0, $0, $0 #NOP
        # checking if Y position is < 0
        slt $t4, $s3, $zero
        bne $t4, $zero, skipUpdate
        or $0, $0, $0 #NOP
        # checking if position is within bounds
        slt $t4, $s3, $t1
        beq $t4, $zero, skipUpdate
        or $0, $0, $0 #NOP
    j endApplyAction
    or $0, $0, $0 #NOP
    skipUpdate:
    # load playerX and playerY
        lui $t0, 0x1000
        ori $t0, $t0, 0x2800
        or $0, $0, $0 #NOP
        # If the position is negative, skipUpdate
        # load original playerX
        lw $t1, 0($t0)      # playerX
        or $0, $0, $0 #NOP
        lw $t2, 4($t0)      # playerY
        or $0, $0, $0 #NOP
        add $s2, $zero, $t1  # adding the original position into $s2
        add $s3, $zero, $t2  # adding the original position into $s3
    j endApplyAction
    or $0, $0, $0 #NOP

# TASK 6: End Game
checkGameOver:
	addi $sp, $sp -4 	# save space in stack 
	sw $ra, 0($sp) 		# save return address
	add $t0, $zero, $a0
    # Load the address of original map
    lui $t1, 0x1000
    ori $t1, $t1, 0x2000
    or $0, $0, $0 #NOP
    addi $t5, $zero, 8  # num of rows
    #load playerX and playerY
    lui $t0, 0x1000
    ori $t0, $t0, 0x2800
    or $0, $0, $0 #NOP
    lw $t7, 0($t0)      # playerX
    or $0, $0, $0 #NOP
    lw $t8, 4($t0)      # playerY
    or $0, $0, $0 #NOP
    # calculate Offset = Row * N + Col
    mult $t8, $t5
    mflo $t9    # $t9 = Row * N
    add $t9, $t9, $t7 # Offset = Row * N + Col
    add $t1, $t1, $t9   # adding the offset to the start of our dynamicMap to go to the player position
    lb $t2, 0($t1) #loading char at players current position
    or $0, $0, $0 #NOP
    addi $t5, $zero, 42 #'*'
    beq $t5, $t2, setGameOver
    or $0, $0, $0 #NOP
    j endCheckGameOver
    or $0, $0, $0 #NOP
    setGameOver:
        # Set the 'gameOver' variable to 1
        lui $t6, 0x1000
        ori $t6, $t6, 0x2808  # Address of 'gameOver' variable
        or $0, $0, $0 #NOP
        addi $t7, $zero, 1    # Set 'gameOver' to 1
        sw $t7, 0($t6)
        j endCheckGameOver
        or $0, $0, $0 #NOP
endCheckGameOver:
	lw $ra, 0($sp)		# restore return address
    or $0, $0, $0 #NOP
	addi $sp, $sp, 4	# restore stack
    jr $ra
    or $0, $0, $0 #NOP

# Function to print multiple newline characters
printNewlines:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    # Print newline loop
    printloop:
        # Print a new line
    	ori $v0, $zero, 11
    	ori $a0, $zero, 10  # ASCII code for newline
    	syscall
        # Decrement the newline counter
        addi $a1, $a1, -1
        # Check if more newlines need to be printed	
        beq $a1, $zero, end_printNewlines	
        or $0, $0, $0 #NOP
        j printloop
        or $0, $0, $0 #NOP
end_printNewlines:
    lw $ra, 0($sp)		# restore return address
    or $0, $0, $0 #NOP
	lw $a1, 4($sp)
    or $0, $0, $0 #NOP
	addi $sp, $sp, 4	# restore stack
    jr $ra
    or $0, $0, $0 #NOP