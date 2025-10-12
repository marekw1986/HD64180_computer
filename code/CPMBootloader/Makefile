# Adjust the run address to match the .org in the source code
all: bootloader_hd64180.bin
	
bootloader_hd64180.p: bootloader_hd64180.asm
	asl -o bootloader_hd64180.p -L -OLIST bootloader_hd64180.lst bootloader_hd64180.asm -cpu z180
	
bootloader_hd64180.bin: bootloader_hd64180.p
	p2bin -l '$$00' bootloader_hd64180.p bootloader_hd64180.bin

clean:
	$(RM) *.lst *.hex labels.asm *.bin *.p

distclean: clean
