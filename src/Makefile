all: add-32.o xor.o stack.o

%.o: %.s
	../assemble/asm-16.pl $< | sed -e 's/;.*//' | xxd -p -r > $@

clean: 
	rm -f *.o 
