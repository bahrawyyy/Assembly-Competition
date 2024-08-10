 EXPORT myApplication
       
RCC      EQU 0x40021000
Port_B   EQU 0x40010C00
LCD_RS   EQU 0x0200   ; GPIOB pin 9 for RS
LCD_E    EQU 0x0100   ; GPIOB pin 8 for E
DATA_MASK EQU 0x00F0  ; Mask for data lines (D4-D7), GPIOB pins 4-7
 
       
      AREA mySection3, CODE, READONLY
       
myApplication
       ; Enable the APB2 clock for GPIOB (bit 3 in RCC_APB2ENR)
    MOV r0, #0x08
    LDR r1, =RCC
    LDR r2, [r1, #0x18]   ; Load RCC_APB2ENR
    ORR r2, r2, r0        ; Set IOPBEN bit (bit 3)
    STR r2, [r1, #0x18]   ; Write back to RCC_APB2ENR

    ; Configure GPIOB pins for LCD
    ; Set pins 4 to 7 as output (push-pull, 10 MHz)
    LDR r0, =0x11110000   ; Configure PB4-PB7 as output push-pull, 10 MHz
    LDR r1, =Port_B
    STR r0, [r1, #0x00]   ; Write to GPIOB_CRL

    ; Set pins 8 and 9 for control lines (RS and E)
    LDR r0, =0x00000111   ; Configure PB8 and PB9 as output push-pull, 10 MHz
    STR r0, [r1, #0x04]   ; Write to GPIOB_CRH

    ; Initialize LCD
    BL init_lcd
	
	LDR r0, =0x01         ; Clear display
    BL send_command
    BL delay              ; Delay for LCD processing
	
	LDR r0, =0x41         ; Clear display
    BL send_data
    BL delay              ; Delay for LCD processing


    ; Infinite loop
loop
	LDR r0, =0x01         ; Clear display
    BL send_command
    BL delay              ; Delay for LCD processing
	
	LDR r0, =0x41         ; Clear display
    BL send_data
    BL delay              ; Delay for LCD processing




    B loop                ; Loop forever

; A function to send nibble by nibble
send_nibble
    MOV r9, lr            ; Save the link register
    LDR r5, =Port_B
    LDR r4, [r5, #0x0C]   ; Read GPIOB_ODR
    BIC r4, r4, #DATA_MASK ; Clear the data lines
    ORR r6, r4, r3        ; Set the new data
	LSL r6, r6, #4        ; Shift nibble to the higher 4 bits
    AND r6, r6, #DATA_MASK ; Apply mask to get the correct data
    
	; Preserve the RS bit
    LDR r12, [r5, #0x0C]   ; Read GPIOB_ODR again to get the current RS state
    AND r12, r12, #LCD_RS   ; Isolate the RS bit
    ORR r6, r6, r12        ; Combine the RS bit with the new data
	
	
	STR r6, [r5, #0x0C]   ; Write back to GPIOB_ODR
    ; Pulse the E line
	LDR r4, [r5, #0x0C]   ; Read GPIOB_ODR
    ORR r6, r4, #LCD_E    ; Set E high
    STR r6, [r5, #0x0C]   ; Write back to GPIOB_ODR
    BL delay              ; Delay for LCD processing
    BIC r6, r4, #LCD_E    ; Set E low
    STR r6, [r5, #0x0C]   ; Write back to GPIOB_ODR
    BL delay              ; Delay for LCD processing
    BX r9                 ; Return

; Function to send a command to the LCD
; Function to send a command to the LCD
send_command
    MOV r7, lr            ; Save the link register
    LDR r1, =Port_B
    ; Clear RS (Command mode)
    LDR r2, [r1, #0x0C]   ; Read GPIOB_ODR
    BIC r2, r2, #LCD_RS   ; Clear RS bit (set to command mode)
    STR r2, [r1, #0x0C]   ; Write back to GPIOB_ODR

    ; Send high nibble
    MOV r3, r0
    LSR r3, r3, #4        ; Get high nibble
    BL send_nibble

    ; Send low nibble
    MOV r3, r0
    AND r3, r3, #0x0F     ; Get low nibble
    BL send_nibble

    BL delay              ; Delay for LCD processing
    BX r7                 ; Return

send_data
    MOV r7, lr            ; Save the link register
    LDR r1, =Port_B
    ; Set RS (Data mode)
    LDR r2, [r1, #0x0C]   ; Read GPIOB_ODR
    ORR r2, r2, #LCD_RS   ; Set RS bit (set to data mode)
    STR r2, [r1, #0x0C]   ; Write back to GPIOB_ODR

    ; Send high nibble
    MOV r3, r0
    LSR r3, r3, #4        ; Get high nibble
    BL send_nibble
	
	LDR r1, =Port_B
	LDR r2, [r1, #0x0C]   ; Read GPIOB_ODR
    ORR r2, r2, #LCD_RS   ; Set RS bit (set to data mode)
    STR r2, [r1, #0x0C]   ; Write back to GPIOB_ODR

    ; Send low nibble
    MOV r3, r0
    AND r3, r3, #0x0F     ; Get low nibble
    BL send_nibble

    BL delay              ; Delay for LCD processing
    BX r7                 ; Return

; Function to introduce a delay
delay
    MOV r1, #10000        ; Adjust the delay count as needed
delay_loop
    SUBS r1, r1, #1       ; Decrement the counter
    BNE delay_loop        ; Loop until r1 == 0
    BX lr                 ; Return

; Function to initialize the LCD
init_lcd
    MOV r11, lr

    LDR r0, =0x02         ; Set 4-bit mode
    BL send_command
    BL delay              ; Delay for LCD processing

    LDR r0, =0x28         ; Function set (4-bit mode, 2 lines, 5x7 dots)
    BL send_command
    BL delay              ; Delay for LCD processing
	
	LDR r0, =0x0E         ; Display on, cursor off, blink off
    BL send_command

    LDR r0, =0x06         ; Entry mode set (Increment cursor, No shift)
    BL send_command
    BL delay              ; Delay for LCD processing

    

	LDR r0, =0x01         ; Clear display
    BL send_command
    BL delay              ; Delay for LCD processing
	
	BX r11                ; Return



	ALIGN

    END