; code here is for adding 32 bit integers 
; 
; by matilda 

JNC add
JNC add

ZERO        DB 0        ; all bits zero
ONES        DB FFFF     ; all bits one
ONE         DB 0001     ; one
TWO         DB 0002     ; two

Ahigh       DB FEED     ; high part of first addend
Alow        DB FACE     ; low part of the first addend

Bhigh       DB ABAD     ; high part of second addend
Blow        DB F00D     ; low part of second addend

ResHigh     DB 0000     ; result high part
ResLow      DB 0000     ; result low part


carryin     DB 0000     ; carry in
carryout    DB 0000     ; carry out

intercarry  DB 0000     ; stores the carry of carryin + Alow + Blow

temp        DB 0000     ; temporary storage location

add:
low:
NAND ZERO           ; acc = 0xFFFF
NAND ONES           ; acc = 0x0000
ST intercarry       ; zero the carry     
ADD carryin         ; acc = carryin

ADD Alow            ; acc = carryin + Alow
JNC nextadd1        ; no carry generated, we can continue as normal
JNC nextadd1_carry  ; a carry was generated, so we need to go to the code that
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

JNC nextadd2        ; no carry generated
JNC nextadd2_carry  ; carry generated, need to set intercarry = 1 


nextadd2_carry:
NAND ZERO
ADD TWO
ST intercarry


nextadd2:
high:

NAND ZERO           ; acc = 0xFFFF
NAND ONES           ; acc = 0x0000
ST carryout         ; zero the carry     
ADD intercarry      ; acc = intercarry

ADD Ahigh           ; acc = intercarry + Ahigh
JNC nextadd3        ; no carry generated, we can continue as normal
JNC nextadd3_carry  ; a carry was generated, so we need to go to the code that
                    ; sets carryout to 1

nextadd3_carry:
ST temp             ; store Ahigh + intercarry into the temporary
NAND ZERO           ; acc = 0xffff
ADD TWO             ; acc = 1
ST carryout         ; carryout = 1 

NAND ZERO
NAND ONES
ADD temp            ; acc = Ahigh + intercarry

nextadd3:
ADD Bhigh

ST ResHigh

JNC nextadd4        ; no carry generated
JNC nextadd4_carry  ; carry generated, need to set carryout = 1 


nextadd4_carry:
NAND ZERO
ADD TWO
ST carryout

nextadd4:
