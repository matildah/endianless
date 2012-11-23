; This program computes the gcd of two 8-bit values using Euclid's algorithm.
; the two values are stored in memory locations a and b, and after execution,
; the result will be stored in location res.

; Revision history
; 16 Nov 2009 [scrubbed] : Began implementation
; 16 Nov 2009 [scrubbed] : Finished and tested implementation

;Code

;Main loop entry point
loop:
;If a>b
;To do so, we calculate  b - a, and examine its sign
NAND ZERO
NAND a
ADD  ONE
ADD  b

; now, acc = b - a, which we store for later use
ST   TMP

; we now test the MSB. if it is high, acc < 0, and a > b.
NAND HM; nand acc with 0x10
NAND ONES; now, acc contains (b - a) ^ 0x10

; we now test acc == 0. If so, we go to the b => a condition
ADD  ONES
JNC  dpz

; Now, we have b - a < 0, or a > b
; We must store a - b into a, but we have b - a stored in tmp.

;load  -tmp into acc
NAND ZERO   ; acc = FF
NAND TMP; acc = FF nand tmp = 0xFF ^ tmp
ADD  ONE    ; acc = -tmp

;store a -b into a
ST   a

; jump past dpz condition, to loop test
JNC  ltest ; if carry isn't set, jump. else, reset the carry
JNC  ltest   ; since carry must be low, we jump

; b less than or equal to a. 
dpz:
; we load tmp = b - a into acc, and store it into b
NAND ZERO   ; acc = FF
NAND TMP; acc = 0xFF ^ tmp
NAND ONES   ; acc = tmp

ST   b

ltest:
; here we test if b == 0. If so, we exit the loop. Else, we re-enter the loop.
NAND ZERO
NAND b
NAND ONES

ADD ONES
JNC lexit

JNC loop
JNC loop



lexit:
; we exit the loop
NAND ZERO
NAND a
NAND ONES

ST res 
ST res ; we set the breakpoint here, so the result has already been stored in
; the memory location res

;Constants
ZERO    DB  0  ; all bits zero
ONES    DB  FF ; all bits one
ONE     DB  1  ; one
HM      DB  80 ; the 8-bit number with only the MSB high

;Variables
TMP     DB  00 ; temporary variable

; Inputs/outputs
a       DB C3 ; 35 in hex
b       DB 9C ; 49 in hex
res     DB 00 ; result goes here.
