; lcd_constants.s
AREA Constants, DATA, READONLY

EXPORT RCC
EXPORT Port_B
EXPORT LCD_RS
EXPORT LCD_E
EXPORT DATA_MASK

RCC      EQU 0x40021000
Port_B   EQU 0x40010C00
LCD_RS   EQU 0x0200   ; GPIOB pin 9 for RS
LCD_E    EQU 0x0100   ; GPIOB pin 8 for E
DATA_MASK EQU 0x00F0  ; Mask for data lines (D4-D7), GPIOB pins 4-7

END
