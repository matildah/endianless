JNC push
JNC push

; code here is for managing a stack
; 
; by matilda 


ZERO        DB 0        ; all bits zero
ONES        DB FFFF     ; all bits one
ONE         DB 0001     ; one
TWO         DB 0002     ; two
STORE       DB 8000     ; opcode for store instruction

SP          DB 1000     ; stack pointer, stack grows upwards

TEMP        DB 0000     ; temporary storage place

push:

ST TEMP

NAND ZERO
NAND ONES

ADD STORE
ADD SP

ST pushinst
NAND ZERO
NAND ONES
ADD TEMP

pushinst    DB FFFF     ; nominally a JNC to the reset vector, but it'll get overwritten :)

NAND ZERO
NAND ONES
ADD SP
ADD ONE
ST SP

