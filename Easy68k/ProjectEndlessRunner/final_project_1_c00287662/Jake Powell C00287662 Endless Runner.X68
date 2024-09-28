*-----------------------------------------------------------
* Title      : Endless Runner Starter Kit Modified
* Written by : Jake Powell Langstaff C00287662
* Date       : 27/02/2023
* Description: Endless Runner Project Starter Kit Modified
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         00          ; Places 0 in D1.L to retrieve Screen width and height in D1.L
                                    ; First 16 bit Word is screen Width and Second 16 bits is screen Height
TC_KEYCODE  EQU         19          ; Check for pressed keys
TC_DBL_BUF  EQU         92          ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11          ; Trap code cursor position

TC_EXIT     EQU         09          ; Exit Trapcode

*-----------------------------------------------------------
* Section       : Character Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_W_INIT EQU         10          ; Players initial Width
PLYR_H_INIT EQU         20          ; Players initial Height

PLYR_DFLT_V EQU         00          ; Default Player Velocity
PLYR_JUMP_V EQU        -20          ; Player Jump Velocity
PLYR_DFLT_G EQU         01          ; Player Default Gravity

GND_TRUE    EQU         01          ; Player on Ground True
GND_FALSE   EQU         00          ; Player on Ground False

RUN_INDEX   EQU         00          ; Player Run Sound Index  
JMP_INDEX   EQU         01          ; Player Jump Sound Index  
OPPS_INDEX  EQU         02          ; Player Opps Sound Index

ENMY_W_INIT EQU         20          ; Enemy initial Width
ENMY_H_INIT EQU         20          ; Enemy initial Height
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*HEALTHBLOCK_W_INIT EQU  20          ; healthblock initial Width
*HEALTHBLOCK_H_INIT EQU  20          ; healthblock initial Height

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*ENMY_2W_INIT EQU         10          ; Enemy initial Width
*ENMY_2H_INIT EQU         10          ; Enemy initial Height
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Section       : Game Stats
* Description   : Points
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
POINTS      EQU         01          ; Points added

*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

* Section       : Keyboard Keys
* Description   : Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode

*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INITIALISE:
    ; Initialise Sounds
    BSR     RUN_LOAD                ; Load Run Sound into Memory
    BSR     JUMP_LOAD               ; Load Jump Sound into Memory
    BSR     OPPS_LOAD               ; Load Opps (Collision) Sound into Memory

    ; Screen Size
    MOVE.B  #TC_SCREEN, D0          ; access screen information
    MOVE.L  #TC_S_SIZE, D1          ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                     ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H    ; place screen height in memory location
    SWAP    D1                      ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W    ; place screen width in memory location

    ; Place the Player at the center of the screen
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X    ; Players X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Players Y Position

    ; Initialise Player Score
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Init Score
    MOVE.L  D1,         PLAYER_SCORE
    
***********************************************************************************************************************************************************************
  * Subroutine    : Initialise
  * Description   : Initialise Health Points
*********************************************************************************************************************************************************************** 
    
  ; Initialise Health Points
  CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
  MOVE.L  #100,       D1          ; Init Points
  MOVE.L  D1,         PLAYER_HEALTH

***********************************************************************************************************************************************************************
  * Subroutine    : Initialise
  * Description   : Initialise players, enemies etc
***********************************************************************************************************************************************************************

    ; Initialise Player Velocity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.B  #PLYR_DFLT_V,D1         ; Init Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY

    ; Initialise Player Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #PLYR_DFLT_G,D1         ; Init Player Gravity
    MOVE.L  D1,         PLYR_GRAVITY

    ; Initialize Player on Ground
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Init Player on Ground

    ; Initial Position for Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y     ; Enemy Y Position

    
*  * ; Initial Position for Health Block
    CLR.L   D1                              ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1                  ; Place Screen width in D1
    ****DIVU    #02,        D1              ; just testing putting centre screen
    **MOVE.L  D1,         HEALTHBLOCK_X     ; health block X Position PROBLEM CODE

    CLR.L   D1                            ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1                ; Place Screen width in D1
    DIVU    #02,        D1                ; divide by 2 for center on Y Axis
    MOVE.L  D1,         HEALTHBLOCK_Y     ; Health Block Y Position
 
 
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   
    ; Initial Position for Enemy
    *CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    *MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    *MOVE.L  D1,         ENEMY_2X     ; Enemy X Position

    *CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    *MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    *DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    *MOVE.L  D1,         ENEMY_2Y     ; Enemy Y Position
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!





***********************************************************************************************************************************************************************
  * Subroutine    : Background
  * Description   : Draw and add color to background
***********************************************************************************************************************************************************************
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Game
* Description   : Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GAME:
    BSR     PLAY_RUN                ; Play Run Wav
GAMELOOP:
    ; Main Gameloop
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
  
    BSR     CHECK_COLLISIONS        ; Check for Collisions
    BSR     DRAW                    ; Draw the Scene
    BRA     GAMELOOP                ; Loop back to GameLoop

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INPUT:
    ; Process Input
    CLR.L   D1                      ; Clear Data Register
    MOVE.B  #TC_KEYCODE,D0          ; Listen for Keys
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  D1,         D2          ; Move last key D1 to D2
    CMP.B   #00,        D2          ; Key is pressed
    BEQ     PROCESS_INPUT           ; Process Key
    TRAP    #15                     ; Trap for Last Key
                                    ; Check if key still pressed
    CMP.B   #$FF,       D1          ; Is it still pressed
    BEQ     PROCESS_INPUT           ; Process Last Key
    RTS                             ; Return to subroutine

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Process Input
* Description   : Branch based on keys pressed
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PROCESS_INPUT:
    MOVE.L  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.L   #ESCAPE,    CURRENT_KEY ; Is Current Key Escape
    BEQ     EXIT                    ; Exit if Escape
    CMP.L   #SPACEBAR,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     JUMP                    ; Jump
    BRA     IDLE                    ; Or Idle
    RTS                             ; Return to subroutine

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE:
    ; Update the Players Positon based on Velocity and Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  PLYR_VELOCITY, D1       ; Fetch Player Velocity
    MOVE.L  PLYR_GRAVITY, D2        ; Fetch Player Gravity
    ADD.L   D2,         D1          ; Add Gravity to Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Update Player Velocity
    ADD.L   PLAYER_Y,   D1          ; Add Velocity to Player
    MOVE.L  D1,         PLAYER_Y    ; Update Players Y Position 

    ; Move the Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D1                      ; Clear the contents of D0
    MOVE.L  ENEMY_X,    D1          ; Move the Enemy X Position to D0
    CMP.L   #00,        D1
    BLE     RESET_ENEMY_POSITION    ; Reset Enemy if off Screen
    BRA     MOVE_ENEMY              ; Move the Enemy
    
    
    
     
    
     ; Move the Health Block
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D1                      ; Clear the contents of D0
    MOVE.L  HEALTHBLOCK_X,    D1          ; Move the Health Block X Position to D0
    CMP.L   #00,        D1
    BLE     RESET_HEALTHBLOCK_POSITION    ; Reset Health Block if off Screen
    BRA     MOVE_HEALTHBLOCK         ; Move the Health Block
    
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ; Move the Enemy
    *CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    *CLR.L   D1                      ; Clear the contents of D0
    *MOVE.L  ENEMY_2X,    D1          ; Move the Enemy X Position to D0
    *CMP.L   #00,        D1
    *BLE     RESET_ENEMY2_POSITION    ; Reset Enemy if off Screen
    *BRA     MOVE_2ENEMY              ; Move the Enemy




*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   
    
    
    
  
    RTS                             ; Return to subroutine  

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
MOVE_ENEMY:
    SUB.L   #01,        ENEMY_X     ; Move enemy by X Value
    RTS

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

*MOVE_2ENEMY:
   * SUB.L   #01,        ENEMY_2X     ; Move enemy by X Value
  *  RTS

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Reset Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RESET_ENEMY_POSITION:
    CLR.L   D1                            ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1                ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X           ; Enemy X Position
    RTS
    
    
    
     
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

*RESET_ENEMY2_POSITION:
*    CLR.L   D1                            ; Clear contents of D1 (XOR is faster)
*    MOVE.W  SCREEN_W,   D1                ; Place Screen width in D1
*    MOVE.L  D1,         ENEMY_2X          ; Enemy X Position
*    RTS
    
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!




MOVE_HEALTHBLOCK:
    SUB.L   #01,        HEALTHBLOCK_X     ; Move Health Bloc by X Value
    RTS


RESET_HEALTHBLOCK_POSITION:
    CLR.L   D1                            ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1                ; Place Screen width in D1
    MOVE.L  D1,         HEALTHBLOCK_X     ; Health Block X Position
    RTS


*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DRAW: 
*    MOVE.L #00ffffFF,D1
*    MOVE.B  #81,D0
*    TRAP    #15
   
    MOVE.B  #94,    D0
    TRAP    #15
    

    ; Clear the screen (see easy 68k help)
    MOVE.B  #TC_CURSR_P, D0         ; Set Cursor Position
    MOVE.W  #$FF00,     D1          ; Fill Screen Clear
    TRAP    #15                      ; Trap (Perform action)

    BSR DRAW_BACKGROUND
    BSR     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_ENEMY              ; Draw Enemy
        
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    *BSR     DRAW_2ENEMY              ; Draw Enemy
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    BSR     DRAW_HEALTHBLOCK        ; dis is the border now
    RTS                             ; Return to subroutine

DRAW_BACKGROUND:
    ; Enable the screen back buffer (see easy 68k help)
    MOVE.B  #TC_DBL_BUF, D0         ; Enable Double Buffer
    MOVE.B  #17,         D1         ; Combine Tasks
    TRAP    #15                      ; Trap (Perform action)
   
    
    ; Set color for second box (

    MOVE.L  #00000000, D1  *all good set to deep purple
    MOVE.B  #81, D0
    TRAP    #15
    
    ; Draw back around screen BOTTOM
    MOVE.L  #0,    D1      ; Left coordinate
    MOVE.L  #245,  D2      ; Top coordinate
    MOVE.L  #639,  D3      ; Right coordinate
    MOVE.L  #479,  D4      ; Bottom coordinate
    MOVE.L  #$00000000,D5      ; Color 
    MOVE.B  #87,   D0      ; Draw rectangle trap
    TRAP    #15
    
    ; Set color for top*** half background*** (BLACK)
   MOVE.L  #00000000, D1       
    MOVE.B  #81, D0        ; Set color trap
    TRAP    #15
    
    ; Draw top half background
    MOVE.L  #PURPLE,  D5      ; Color (PURPLE)
    MOVE.L  #0,    D1      ; Left coordinate
    MOVE.L  #90,    D2      ; Top coordinate
    MOVE.L  #639,  D3      ; Right coordinate
    MOVE.L  #260,  D4      ; Bottom coordinate
    MOVE.L  #PURPLE,  D5
    MOVE.B  #87,   D0      ; Draw rectangle trap
    TRAP    #15
    
    RTS
    

*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Draw Player Data
* Description   : Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
DRAW_PLYR_DATA:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)

    ; Player Score Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0901,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player X Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0202,     D1          ; Col 02, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     X_MSG,      A1          ; X Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player X
    MOVE.B  #TC_CURSR_P, D0          ; Set Cursor Position
    MOVE.W  #$0802,     D1          ; Col 08, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_X,   D1          ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Y Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1002,     D1          ; Col 10, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     Y_MSG,      A1          ; Y Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Y
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1602,     D1          ; Col 16, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_Y,   D1          ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action) 

    ; Player Velocity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0203,     D1          ; Col 02, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     V_MSG,      A1          ; Velocity Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Velocity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0403,     D1          ; Col 04, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_VELOCITY,D1        ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1003,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     G_MSG,      A1          ; G Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1203,     D1          ; Col 12, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_GRAVITY,D1         ; Move Gravity to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Player On Ground Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0204,     D1          ; Col 02, Row 04
    TRAP    #15                     ; Trap (Perform action)
    LEA     GND_MSG,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player On Ground
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0604,     D1          ; Col 06, Row 04
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_ON_GND,D1          ; Move Play on Ground ? to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Show Keys Pressed
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$4101,     D1          ; Col 41, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     KEYCODE_MSG, A1         ; Keycode
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show KeyCode
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$4901,     D1          ; Col 49, Row 01
    TRAP    #15                     ; Trap (Perform action)    
    MOVE.L  CURRENT_KEY,D1          ; Move Key Pressed to D1
    MOVE.B  #03,        D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)
    

 
    ; Player Health Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1001,     D1          ; Col 10, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     HEALTH_MSG,  A1         ;  Displays Health text Msg
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    
    ; Player Health Points
   MOVE.B  #TC_CURSR_P,D0           ; Set Cursor Position
    MOVE.W  #$1701,     D1          ; Col 17, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L, which is current health
    MOVE.L  PLAYER_HEALTH,D1        ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)

    RTS  
    
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Player is on Ground
* Description   : Check if the Player is on or off Ground
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IS_PLAYER_ON_GND:
    ; Check if Player is on Ground
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D2                      ; Clear contents of D2 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  PLAYER_Y,   D2          ; Player Y Position
    CMP     D1,         D2          ; Compare middle of Screen with Players Y Position 
    BGE     SET_ON_GROUND           ; The Player is on the Ground Plane
    BLT     SET_OFF_GROUND          ; The Player is off the Ground
    RTS                             ; Return to subroutine


*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : On Ground
* Description   : Set the Player On Ground
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET_ON_GROUND:
    CLR.L   D1                        ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1            ; Place Screen width in D1
    DIVU    #02,        D1            ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y      ; Reset the Player Y Position
    CLR.L   D1                        ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1            ; Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Set Player Velocity
    MOVE.L  #GND_TRUE,  PLYR_ON_GND   ; Player is on Ground
    RTS

*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Off Ground
* Description   : Set the Player Off Ground
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET_OFF_GROUND:
    MOVE.L  #GND_FALSE, PLYR_ON_GND ; Player if off Ground
    RTS                             ; Return to subroutine
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Jump
* Description   : Perform a Jump
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JUMP:
    CMP.L   #GND_TRUE,PLYR_ON_GND      ; Player is on the Ground ?
    BEQ     PERFORM_JUMP               ; Do Jump
    BRA     JUMP_DONE                  ; Confirms and returns to main game loop
PERFORM_JUMP:
    BSR     PLAY_JUMP                  ; Play jump sound
    MOVE.L  #PLYR_JUMP_V,PLYR_VELOCITY ; Set the players velocity to true
    RTS                                ; Return to subroutine
JUMP_DONE:
    RTS                                ; Return to subroutine

*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Idle
* Description   : Perform a Idle, plays run music
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IDLE:
    BSR     PLAY_RUN                ; Play Run Wav
    RTS                             ; Return to subroutine

*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Initialise game sounds into memory 
* Current Sounds are RUN, JUMP and Opps for Collision
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RUN_LOAD:
    LEA     RUN_WAV,    A1          ; Load Wav File into A1
    MOVE    #RUN_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_RUN:
    MOVE    #RUN_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

JUMP_LOAD:
    LEA     JUMP_WAV,   A1          ; Load Wav File into A1
    MOVE    #JMP_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_JUMP:
    MOVE    #JMP_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

OPPS_LOAD:
    LEA     OPPS_WAV,   A1          ; Load Wav File into A1
    MOVE    #OPPS_INDEX,D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_OPPS:
    MOVE    #OPPS_INDEX,D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #$FFFFFF00,    D1         ; Set Background color dats a extra brigth white
    MOVE.B  #80,        D0         ; Task for Background Color
    TRAP    #15                    ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,       D1     ; X
    MOVE.L  PLAYER_Y,       D2     ; Y
    MOVE.L  PLAYER_X,       D3
    ADD.L   #PLYR_W_INIT,   D3     ; Width
    MOVE.L  PLAYER_Y,       D4 
    ADD.L   #PLYR_H_INIT,   D4     ; Height
    
    ; Draw Player
    MOVE.B  #87,            D0     ; Draw Player
    TRAP    #15                    ; Trap (Perform action)
    RTS                            ; Return to subroutine

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Draw Enemy
* Description   : Draw Enemy Square
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DRAW_ENEMY:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1       ; Set Background color
    MOVE.B  #80,           D0       ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_X,       D1      ; X
    MOVE.L  ENEMY_Y,       D2      ; Y
    MOVE.L  ENEMY_X,       D3
    ADD.L   #ENMY_W_INIT,  D3      ; Width
    MOVE.L  ENEMY_Y,       D4 
    ADD.L   #ENMY_H_INIT,  D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,           D0      ; Draw Enemy
    TRAP    #15                    ; Trap (Perform action)
    RTS                            ; Return to subroutine
    
    

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*DRAW_2ENEMY:
 *   ; Set Pixel Colors
  *  MOVE.L  #RED,       D1          ; Set Background color
  *  MOVE.B  #80,        D0          ; Task for Background Color
  *  TRAP    #15                     ; Trap (Perform action)

 *   ; Set X, Y, Width and Height
 *   MOVE.L  ENEMY_2X,    D1          ; X
 *   MOVE.L  ENEMY_2Y,    D2          ; Y
  *  MOVE.L  ENEMY_2X,    D3
   * ADD.L   #ENMY_2W_INIT,   D3      ; Width
   * MOVE.L  ENEMY_2Y,    D4 
   * ADD.L   #ENMY_2H_INIT,   D4      ; Height
    
   * ; Draw Enemy    
   * MOVE.B  #87,        D0          ; Draw Enemy
   * TRAP    #15                     ; Trap (Perform action)
   * RTS                             ; Return to subroutine
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Draw Health Block
* Description   : Draw Health Square
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DRAW_HEALTHBLOCK:
    ; Set Pixel Colors
    MOVE.L  #$2AD2C90,       D1          ; Set Background color BORDER
    MOVE.B  #80,          D0          ; Task for Background Color
    TRAP    #15                       ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  HEALTHBLOCK_X,         D1     ; X
    MOVE.L  HEALTHBLOCK_Y,         D2     ; Y
    MOVE.L  HEALTHBLOCK_X,         D3
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   * ADD.L   #HEALTHBLOCK_W_INIT,   D3     ; Width
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    MOVE.L  HEALTHBLOCK_Y,         D4 
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  *Code no work properly block was just chillin at end of screen couldnt get spawning to work removed cause was not aesthetic
 * ADD.L   #HEALTHBLOCK_H_INIT,   D4     ; Height
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    ; Draw Health Block    
    MOVE.B  #87,        D0          ; Draw Health Block
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= HEALTHBLOCK_X + HEALTHBLOCK_W &&
* PLAYER_X + PLAYER_W >= HEALTHBLOCK_X &&
* PLAYER_Y <= HEALTHBLOCK_Y + HEALTHBLOCK_H &&
* PLAYER_H + PLAYER_Y >= HEALTHBLOCK_Y
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

HEALTH:
    CLR.L   D1                              ; Clear D1
    CLR.L   D2                              ; Clear D2
    BSR     PLAYER_X_LTE_TO_ENEMY_X_PLUS_W
    BSR     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X
    BSR     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H
    BSR     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y
    BSR     CHECK_COLLISIONS
   
CHECK_COLLISIONS:
    CLR.L   D1                              ; Clear D1
    CLR.L   D2                              ; Clear D2

PLAYER_X_LTE_TO_ENEMY_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1                  ; Move Player X to D1
    MOVE.L  ENEMY_X,    D2                  ; Move Enemy X to D2
    ADD.L   ENMY_W_INIT,D2                  ; Set Enemy width X + Width
    CMP.L   D1,         D2                  ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE            ; If not, no collision

PLAYER_X_PLUS_W_LTE_TO_ENEMY_X:
    ADD.L   PLYR_W_INIT,D1                  ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2                  ; Move Enemy X to D2
    CMP.L   D1,         D2                  ; Do they Overlap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE            ; If not, no collision   

PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1                  ; Move Player Y to D1
    MOVE.L  ENEMY_Y,    D2                  ; Move Enemy Y to D2
    ADD.L   ENMY_H_INIT,D2                  ; Set Enemy Height to D2
    CMP.L   D1,         D2                  ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE            ; If not, no collision 

PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y:     
    ADD.L   PLYR_H_INIT,D1                  ; Add Player Height to D1
    MOVE.L  ENEMY_Y,    D2                  ; Move Enemy Height to D2  
    CMP.L   D1,         D2                  ; Do they Overlap ?
    BGE     COLLISION                       ; Collision !
    BRA     COLLISION_CHECK_DONE            ; If not, no collision

COLLISION_CHECK_DONE:                       ; No Collision Update points
    ADD.L   #POINTS,    PLAYER_SCORE        ; Move points upgrade to player score
    RTS                                     ; Return to subroutine

COLLISION:
    BSR     PLAY_OPPS                       ; Play Opps Wav
    MOVE.L  #0, PLAYER_SCORE                ; Reset Player Score

    ; Subtract 30 from player health
    MOVE.L  PLAYER_HEALTH, D1               ; Load player's health into D1
    SUB.L   #10,           D1               ; Subtract 30 from health

    ; Check if health is negative, if so, set it to 0
    MOVEQ   #0, D2                          ; Load 0 into D2
    CMP.L   #0, D1                          ; Compare health with 0
    BGE     UPDATE_HEALTH                   ; If health is greater than or equal to 0, update it
    MOVEQ   #0, D1                          ; Otherwise, set health to 0
    BRA     CHECK_GAME_OVER                 ; Branch to check game over condition
    
    
    END_COLLISION:
    RTS                             ; Return from subroutine
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : subrouting of collision
* Description   : When collides with block looses health
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE_HEALTH:
    MOVE.L  D1, PLAYER_HEALTH               ; Update player's health
    RTS                                     ; Return to subroutine

CHECK_GAME_OVER:
    CMP.L   #0, D1                          ; Compare health with 0
    BGT     END_COLLISION                   ; If health is greater than 0, continue
    BRA     GAME_OVER                       ; If health is 0 or less, jump to game over logic


*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : Game Over
* Description   : activates BRA EXIT when health reaches zero or below. Also contains additional exit option
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------
GAME_OVER:
    

    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1909,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     GAMEOVER_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    move.l   #100,D1     ; delay in 1/100th of seconds
    moveq    #23,D0
    trap     #15
    



*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
**BSR FINITO    
    
**FINITO:

**BRA EXIT
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CODE NO WORK PROPERLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    
 
 **************************************************************************************************   
    
 
   

 

  
   
                           






*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



**REDUCE_HEALTH:
   *** LEA     MSG_COLLISION, A1 ; Load message "Collision" to A1
   ** BSR     DRAW ; Call subroutine to draw
    
        
   ** MOVE.B  PLAYER_HEALTH, D1     ; Load player health into D1 register
    
    **MOVE.B  D1, PLAYER_HEALTH      ; Store the result back into PLAYER_HEALTH

    
   *** LEA     MSG_DAMAGE,A1 ; Load message "Taking Damage" to A1
  **  BSR     DRAW ; Call subroutine to draw
    
    











*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXIT:
    ; Show if Exiting is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$4004,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     EXIT_MSG,   A1          ; Exit
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #TC_EXIT,   D0          ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    
    SIMHALT

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console, names should be
* self documenting
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SCORE_MSG       DC.B    'Points: ', 0       ; Score Message
KEYCODE_MSG     DC.B    'KeyCode: ', 0     ; Keycode Message
JUMP_MSG        DC.B    'Jump....', 0       ; Jump Message

IDLE_MSG        DC.B    'Idle....', 0       ; Idle Message
UPDATE_MSG      DC.B    'Update....', 0     ; Update Message
DRAW_MSG        DC.B    'Draw....', 0       ; Draw Message

X_MSG           DC.B    'X pos:', 0             ; X Position Message
Y_MSG           DC.B    'Y pos:', 0             ; Y Position Message
V_MSG           DC.B    'V:', 0             ; Velocity Position Message
G_MSG           DC.B    'G:', 0             ; Gravity Position Message
GND_MSG         DC.B    'GND:', 0           ; On Ground Position Message


HEALTH_MSG      DC.B    'Health:', 0        ; Message for Player Health


EXIT_MSG        DC.B    'Exiting....', 0    ; Exit Message

GAMEOVER_MSG    DC.B    'You Met a Tragic End lol', 0  ; Game Over Message

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WHITE           EQU     $00FFFFFF
RED             EQU     $000000FF
PURPLE          EQU     $00B026FF
YELLOW          EQU     $0000FFFF
GREEN           EQU     $0000FF00
BLUE            EQU     $000000FF


*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Section       : Keyboard Input
* Description   : Used for storing Keypresses
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CURRENT_KEY     DS.L    01  ; Reserve Space for Current Key Pressed

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PLAYER_X        DS.L    01  ; Reserve Space for Player X Position
PLAYER_Y        DS.L    01  ; Reserve Space for Player Y Position
PLAYER_SCORE    DS.L    01  ; Reserve Space for Player Score

PLYR_VELOCITY   DS.L    01  ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    01  ; Reserve Space for Player Gravity
PLYR_ON_GND     DS.L    01  ; Reserve Space for Player on Ground

ENEMY_X         DS.L    01  ; Reserve Space for Enemy X Position
ENEMY_Y         DS.L    01  ; Reserve Space for Enemy Y Position

ENEMY_2X         DS.L    01  ; Reserve Space for Enemy X Position
ENEMY_2Y         DS.L    01  ; Reserve Space for Enemy Y Position

HEALTHBLOCK_X   DS.L    01  ; Reserve Space for Health Block X Position
HEALTHBLOCK_Y   DS.L    01  ; Reserve Space for Health Block Y Position
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PLAYER_HEALTH   DS.L    01  ; Player health is 100

*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Section       : Sounds
* Description   : Sound files, which are then loaded and given
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to 
* generate and Audacity to convert MP3 to WAV
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JUMP_WAV        DC.B    'jump.wav',0        ; Jump Sound
RUN_WAV         DC.B    'run.wav',0         ; Run Sound
OPPS_WAV        DC.B    'opps.wav',0        ; Collision Opps
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END    START        ; last line of source
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
