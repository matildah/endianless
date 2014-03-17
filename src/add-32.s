; code here is for adding 32 bit integers 
; 
; by matilda 

JNC add
JNC add

ZERO        DB 0        ; all bits zero
ONES        DB FFFF     ; all bits one
ONE         DB 0001     ; one
TWO         DB 0002     ; two

Alow        DB FEED     ; low part of the first addend
Ahigh       DB FACE     ; high part of first addend

Blow        DB ABAD     ; low part of second addend
Bhigh       DB F00D     ; high part of second addend

ResLow      DB 0000     ; result low part
ResHigh     DB 0000     ; result high part


carryin     DB 0000     ; carry in
carryout    DB 0000     ; carry out

intercarry  DB 0000     ; stores the carry of Alow + Blow

temp        DB 0000     ; temporary storage location

add:
low:
NAND ZERO           ; acc = 0xFFFF
NAND ONES           ; acc = 0x0000
ST intercarry       ; zero the carry     
ADD carryin         ; acc = carryin

ADD Alow            ; acc = carryin + Alow
jnc nextadd1        ; no carry generated, we can continue as normal
jnc nextadd1_carry  ; a carry was generated, so we need to go to the code that
                    ; sets intercarry to 1

nextadd1_carry:
ST temp             ; store Alow + carryin into the temporary
NAND ZERO           ; acc = 0xffff
ADD TWO             ; acc = 1
ST intercarry       ; intercarry = 1 

NAND ZERO
NAND ONES
ADD temp            ; acc = Alow + carryin

nextadd1:
ADD Blow

ST ResLow

jnc nextadd2        ; no carry generated
jnc nextadd2_carry  ; carry generated, need to set intercarry = 1 


nextadd2_carry:
NAND ZERO
ADD TWO
ST intercarry


nextadd2:

