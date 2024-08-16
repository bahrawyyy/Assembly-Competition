 EXPORT myApplication
	 
	IMPORT delay
	IMPORT send_command
	IMPORT send_data
	IMPORT init_lcd
	IMPORT init_adc
	IMPORT read_adc
	IMPORT display_lcd

		 

RCC      EQU 0x40021000
Port_B   EQU 0x40010C00
Port_A    EQU 0x40010800
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
	
	LDR r0, =RCC
    LDR r1, [r0, #0x18]  ; Read RCC_APB2ENR
	ORR r1, r1, #0x04 ; Enable GPIOA and ADC1 clocks
    ORR r1, r1, #0x200 ; Enable GPIOA and ADC1 clocks
    STR r1, [r0, #0x18]  ; Write back RCC_APB2ENR

    ; Configure GPIOB pins for LCD
    ; Set pins 4 to 7 as output (push-pull, 10 MHz)
    LDR r0, =0x11111000   ; Configure PB4-PB7 as output push-pull, 10 MHz
    LDR r1, =Port_B
    STR r0, [r1, #0x00]   ; Write to GPIOB_CRL
	
	; Set pins 8 and 9 for control lines (RS and E)
    LDR r0, =0x00000111   ; Configure PB8 and PB9 as output push-pull, 10 MHz
    STR r0, [r1, #0x04]   ; Write to GPIOB_CRH
	
	
	LDR r0, =(0x0101 << 28)   ; Configure PB4-PB7 as output push-pull, 10 MHz
    LDR r1, =Port_A
    STR r0, [r1, #0x04]   ; Write to GPIOB_CRH
	

    ; Initialize LCD
    BL init_lcd
	BL	init_adc
	
	
	LDR r0, =0x83         ; Command to move the cursor to first row, position 4
	BL send_command

	
	; Write "Temperature" to the LCD
	LDR r0, =0x54         ; ASCII for 'T'
	BL send_data
	LDR r0, =0x65         ; ASCII for 'e'
	BL send_data
	LDR r0, =0x6D         ; ASCII for 'm'
	BL send_data
	LDR r0, =0x70         ; ASCII for 'p'
	BL send_data
	LDR r0, =0x65         ; ASCII for 'e'
	BL send_data
	LDR r0, =0x72         ; ASCII for 'r'
	BL send_data
	LDR r0, =0x61         ; ASCII for 'a'
	BL send_data
	LDR r0, =0x74         ; ASCII for 't'
	BL send_data
	LDR r0, =0x75         ; ASCII for 'u'
	BL send_data
	LDR r0, =0x72         ; ASCII for 'r'
	BL send_data
	LDR r0, =0x65         ; ASCII for 'e'
	BL send_data


    ; Infinite loop
loop

	LDR r0, =0xC8         ; Command to move the cursor to second row, position 5
	BL send_command

	BL read_adc
	BL display_lcd
	
	
	BL delay
	BL delay
	BL delay
	BL delay
    BL delay              ; Delay for LCD processing

    B loop                ; Loop forever


	ALIGN

    END