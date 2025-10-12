# Adjust the run address to match the .org in the source code
all: hd64180_blink.bin
	
hd64180_blink.p: hd64180_blink.asm
	asl -o hd64180_blink.p -L -OLIST hd64180_blink.lst hd64180_blink.asm -cpu z180
	
hd64180_blink.bin: hd64180_blink.p
	p2bin -l '$$00' hd64180_blink.p hd64180_blink.bin

clean:
	$(RM) *.lst *.hex *.bin *.p

distclean: clean
