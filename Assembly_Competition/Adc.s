	EXPORT init_adc
	EXPORT read_adc
	EXPORT display_lcd
		
	IMPORT send_data

RCC       EQU 0x40021000
ADC1      EQU 0x40012400
Port_A    EQU 0x40010800
ADC_CH1   EQU 0x00000001 ; Channel 1

	AREA adcSection, CODE, READONLY

; Function to initialize the ADC
init_adc
	MOV r7, lr            ; Save the link register

    ; Enable clock for GPIOA and ADC1
    LDR r0, =RCC
    LDR r1, [r0, #0x18]  ; Read RCC_APB2ENR
	ORR r1, r1, #0x04 ; Enable GPIOA and ADC1 clocks
    ORR r1, r1, #0x200 ; Enable GPIOA and ADC1 clocks
    STR r1, [r0, #0x18]  ; Write back RCC_APB2ENR

    ; Set PA1 as analog input (for ADC Channel 1)
    LDR r0, =Port_A
    LDR r1, [r0, #0x04]  ; Read GPIOA_CRL
    BIC r1, r1, #(0xF << 4) ; Clear PA1 settings (bits 7:4)
    STR r1, [r0, #0x04]  ; Write back GPIOA_CRL

    ; Configure ADC1
    LDR r0, =ADC1
    LDR r1, [r0, #0x08]  ; Read ADC1_CR2
    ORR r1, r1, #0x00000001 ; Enable ADC1 (ADON bit)
    STR r1, [r0, #0x08]  ; Write back ADC1_CR2

    ; Configure the sampling time for channel 1
    LDR r1, [r0, #0x10]  ; Read ADC1_SMPR2
    ORR r1, r1, #(0x7 << 3) ; Set sampling time to 239.5 cycles (bits 5:3)
    STR r1, [r0, #0x10]  ; Write back ADC1_SMPR2

    ; Perform ADC calibration
   ; LDR r5, [r0, #0x08]  ; Read ADC1_CR2
    ;ORR r5, r5, #0x04 ; Start calibration (CAL bit)
    ;STR r5, [r0, #0x08]  ; Write back ADC1_CR2

;adc_calibration_loop
    ;LDR r1, [r0, #0x04]  ; Read ADC1_CR2
    ;TST r1, #0x00000008  ; Check if calibration is complete
    ;BNE adc_calibration_loop ; Loop until calibration is done

    ; Set ADC1 to continuous conversion mode
    ;LDR r1, [r0, #0x04]  ; Read ADC1_CR2
    ;ORR r1, r1, #0x00000002 ; Set continuous mode (CONT bit)
    ;STR r1, [r0, #0x04]  ; Write back ADC1_CR2

    BX r7                ; Return

; Function to read ADC value
read_adc
    ; Start conversion on channel 1
    LDR r0, =ADC1
    LDR r1, [r0, #0x08]  ; Read ADC1_CR2
    ORR r1, r1, #0x00000001 ; Enable ADC1 (ADON bit)
    STR r1, [r0, #0x08]  ; Write back ADC1_CR2

adc_conversion_loop
    LDR r1, [r0, #0x00]  ; Read ADC1_SR
    TST r1, #0x00000002  ; Check if conversion is complete (EOC bit)
    BEQ adc_conversion_loop ; Loop until conversion is complete

    ; Read the result
    LDR r0, [r0, #0x4C]  ; Read ADC1_DR (data register)
    BX lr                ; Return with the ADC result in r0
	

display_lcd
	MOV r10, lr            ; Save the link register

	MOV r8, r0

	LDR r4, =1137        ; Load the offset value 1137 into r1
    SUB r8, r8, r4       ; Subtract 1137 from ADC.DR (r0 = r0 - 1137)
	
	LDR r2, =2560        ; Load the inverse of the slope * 10000 (1/0.3533 ˜ 2831) into r2
    MUL r8, r8, r2       ; Multiply r0 by 2831 (r0 = r0 * 2831)

    ; r0 now contains (ADC.DR - 1137) * 2831

    MOV r1, #1000       ; Load 10000 into r1 (for division)
    UDIV r8, r8, r1      ; Divide r0 by 10000 to get the temperature
	
	

	MOV r1, #1000
    UDIV r0, r8, r1      ; Divide r8 by 1000 to get the hundreds place
    ADD r0, r0, #0x30    ; Convert the digit to ASCII
    BL send_data         ; Send hundreds place to LCD
	
	SUB r0, r0, #0x30    ; Convert the digit to ASCII

    MOV r1, #1000
	MUL r4, r1, r0
	SUB r8, r8, r4
	MOV r1, #100
    UDIV r0, r8, r1      ; Divide by 100 to get the tens place
    ADD r0, r0, #0x30    ; Convert the digit to ASCII
    BL send_data         ; Send tens place to LCD
	
	SUB r0, r0, #0x30    ; Convert the digit to ASCII

    MOV r1, #100
	MUL r4, r1, r0
	SUB r8, r8, r4
	MOV r1, #10
    UDIV r0, r8, r1      ; Divide by 100 to get the tens place
    ADD r0, r0, #0x30    ; Convert the digit to ASCII
    BL send_data         ; Send tens place to LCD
	
	
	SUB r0, r0, #0x30    ; Convert the digit to ASCII

    MOV r1, #10
	MUL r4, r1, r0
	SUB r8, r8, r4
	MOV r1, #1
    UDIV r0, r8, r1      ; Divide by 100 to get the tens place
    ADD r0, r0, #0x30    ; Convert the digit to ASCII
    BL send_data         ; Send tens place to LCD
	
	BX r10
	
	END