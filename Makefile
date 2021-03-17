Run: C-WaveManipulation
	@- rm ASM-WaveManipulation.o 2> /dev/null ||:
	mkdir ./Output
	cp ./Input/W1.wav ./Output/W1.wav
	cp ./Input/W2.wav ./Output/W2.wav
	./C-WaveManipulation
	./ASM-WaveManipulation
	cmp ./Output/C-W3.wav ./Output/ASM-W3.wav
	./Optimizations/Measure
	
C-WaveManipulation: ASM-WaveManipulation
	gcc -o C-WaveManipulation C-WaveManipulation.c

ASM-WaveManipulation: ASM-WaveManipulation.o
	ld -o ASM-WaveManipulation ASM-WaveManipulation.o

ASM-WaveManipulation.o: Del
	nasm -f elf64 -g -F dwarf ASM-WaveManipulation.asm
	
Del: ASM-WaveManipulation.asm C-WaveManipulation.c
	@- rm -r ./Output 2> /dev/null ||: 
	@- rm ASM-WaveManipulation 2> /dev/null ||: 
	@- rm ASM-WaveManipulation.o 2> /dev/null ||: 
	@- rm C-WaveManipulation 2> /dev/null ||:
	
