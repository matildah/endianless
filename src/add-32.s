; code here is for adding 32 bit integers 
; 
; by matilda 

JNC add
JNC add

ZERO        DB 0        ; all bits zero
ONES        DB FFFF     ; all bits one
ONE         DB 0001     ; one

Alow        DB FEED     ; low part of the first addend
Ahigh       DB FACE     ; high part of first addend

Blow        DB ABAD     ; low part of second addend
Bhigh       DB F00D     ; high part of second addend

ResLow      DB 0000     ; result low part
ResHigh     DB 0000     ; result high part


carryin     DB 0000     ; carry in
carryout    DB 0000     ; carry out

intercarry  DB 0000     ; stores the carry of Alow + Blow

add:
low:
NAND ZERO
NAND ONES

ADD carryin

ADD Alow
ADD Blow

ST  ResLow

JNC nocarrylow
JNC carrylow


nocarrylow:
NAND ZERO
NAND ONES
ST intercarry
JNC high
JNC high

carrylow:
NAND ZERO
NAND ONES
ADD ONE
ST intercarry
JNC high
JNC high

high:
NAND ZERO
NAND ONES
ADD intercarry
ADD Ahigh
ADD Bhigh

ST ResHigh

JNC
