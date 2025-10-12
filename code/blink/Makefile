# Adjust the run address to match the .org in the source code
all: hd64180_blink.bin hd64180_blink.hex

hd64180_blink.bin: hd64180_blink.hex
	objcopy --input-target=ihex --output-target=binary hd64180_blink.hex hd64180_blink.bin

hd64180_blink.hex: hd64180_blink.asm
	a85 hd64180_blink.asm -l hd64180_blink.lst -o hd64180_blink.hex 

clean:
	$(RM) *.lst *.hex *.bin

distclean: clean
