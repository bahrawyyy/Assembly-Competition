 EXPORT myApplication
	 
	IMPORT delay
	IMPORT send_command
	IMPORT send_data
	IMPORT init_lcd
		 

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





	ALIGN

    END