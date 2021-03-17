section .data
  filename1           DB  "./Input/W1.wav", 0       	  ; 1B [7]
  filename2           DB  "./Input/W2.wav", 0       	  ; 1B [7]
  filename3           DB  "./Output/ASM-W3.wav", 0       ; 1B [11]
  length              DQ                1       ; 8 B
  w2_sum              DQ                0       ; 8 B
  w2_count            DQ                0       ; 8 B

section .bss
  fileW1:             resd              1       ; 4 B
  fileW2:             resd              1       ; 4 B
  fileW3:             resd              1       ; 4 B
  header:             resb             44       ; 44 B
  data:               resw              1       ; 2 B
  w2_average:         resq              1       ; 8 B
  dataW1:             resw              1       ; 2 B
  dataW2:             resw              1       ; 2 B

section .text
global _start

_start:
  INITIALIZATION:
    mov rax, 2 									                ; open()
    mov rdi, filename1					                ; pathname
    mov rsi, 0									                ; flags
    mov rdx, 0q777							                ; mode
    syscall
    mov [fileW1], eax						                ; file descriptor

    mov rax, 2									                ; open()
    mov rdi, filename2				                	; pathname
    mov rsi, 0								                	; flags
    mov rdx, 0q777                              ; mode
    syscall
    mov [fileW2], eax				                 		; file descriptor

    mov rax, 85								                 	; creat()
    mov rdi, filename3			                 		; pathname
    mov rsi, 0q777				                			; mode
    syscall

    mov rax, 2								                	; open()
    mov rdi, filename3			                 		; pathname
    mov rsi, 2							                 		; flags
    mov rdx, 0q777				                			; mode_t
    syscall
    mov [fileW3], eax			                			; file descriptor

    mov rax, 8					                   			; lseek()
    mov rdi, [fileW1]			                   		; file descriptor
    mov rsi, 0						                  		; offset
    mov rdx, 0						                   		; from where
    syscall

    mov rax, 8							                   	; lseek()
    mov rdi, [fileW2]			                  		; file descriptor
    mov rsi, 0							                   	; offset
    mov rdx, 0								                  ; from where
    syscall

  FIND_SHORTER:
    mov rax, 0 								                  ; read()
    mov rdi, [fileW1]					                  ; file descriptor
    mov rsi, data								                ; destination buffer
    mov rdx, 2								                  ; count
    syscall

    cmp rax, 0                                  ; feof(fileW1)
      je W1_SHORTER

    mov rax, 0								                  ; read()
    mov rdi, [fileW2]					                  ; file descriptor
    mov rsi, data								                ; destination buffer
    mov rdx, 2								                  ; count
    syscall

    cmp rax, 0                                  ; feof(fileW2)
      je W2_SHORTER

    xor rax, rax
    mov rax, [length]					                  ; add [length], 1
    add rax, 1
    mov [length], rax

    jmp FIND_SHORTER

  W1_SHORTER:
    xor r8, r8
    mov r8, [length]

    mov rax, 8								                  ; lseek()
    mov rdi, [fileW1]					                  ; file descriptor
    mov rsi, 0								                  ; offset
    mov rdx, 0								                  ; from where
    syscall

    mov rax, 0									                ; read()
    mov rdi, [fileW1]					                	; file descriptor
    mov rsi, header   			                 		; destination buffer
    mov rdx, 44							                		; count
    syscall

    mov rax, 8						                  		; lseek()
    mov rdi, [fileW3]			                  		; file descriptor
    mov rsi, 0					                   			; offset
    mov rdx, 0					                   			; from where
    syscall

    mov rax, 1								                  ; write()
    mov rdi, [fileW3]					                  ; file descriptor
    mov rsi, header				                     	; source buffer
    mov rdx, 44							                  	; count
    syscall

    mov rax, 8								                  ; lseek()
    mov rdi, [fileW2]			                  		; file descriptor
    mov rsi, 44						                   		; offset
    mov rdx, 0					                   			; from where
    syscall

    mov rax, 8						                  		; lseek()
    mov rdi, [fileW3]			                  		; file descriptor
    mov rsi, 44							                  	; offset
    mov rdx, 0				                   				; from where
    syscall

    jmp FIND_W2_AVERAGE

  W2_SHORTER:
    xor r8, r8
    mov r8, [length]

    mov rax, 8						                  		; lseek()
    mov rdi, [fileW2]				                   	; file descriptor
    mov rsi, 0						                  		; offset
    mov rdx, 0							                   	; from where
    syscall

    mov rax, 0						                			; read()
    mov rdi, [fileW2]				                 		; file descriptor
    mov rsi, header   			                 		; destination buffer
    mov rdx, 44							                 		; count
    syscall

    mov rax, 8							                   	; lseek()
    mov rdi, [fileW3]		                   			; file descriptor
    mov rsi, 0						                  		; offset
    mov rdx, 0						                  		; from where
    syscall

    mov rax, 1						                  		; write()
    mov rdi, [fileW3]			                  		; file descriptor
    mov rsi, header				                     	; source buffer
    mov rdx, 44						                   		; count
    syscall

    mov rax, 8						                  		; lseek()
    mov rdi, [fileW2]				                   	; file descriptor
    mov rsi, 44						                   		; offset
    mov rdx, 0							                   	; from where
    syscall

    mov rax, 8							                   	; lseek()
    mov rdi, [fileW3]			                  		; file descriptor
    mov rsi, 44						                   		; offset
    mov rdx, 0						                  		; from where
    syscall

    jmp FIND_W2_AVERAGE

  FIND_W2_AVERAGE:
    mov rax, 0							                   	; read()
    mov rdi, [fileW2]			                  		; file descriptor
    mov rsi, data					                      ; destination buffer
    mov rdx, 2						                   		; count
    syscall

    cmp rax, 0                                  ; feof(fileW2)
      je PREPARE_LOOP

    xor rax, rax                                ; mov rax, 0
    mov ax, [data]
    cwde                                        ; signed extend ax 2 eax
    cdqe                                        ; signed extend eax 2 rax
    add [w2_sum], rax                           ; w2_sum += rax

    xor rax, rax
    mov rax, 1                                  ; w2_count++
    add [w2_count], rax

    jmp FIND_W2_AVERAGE

  PREPARE_LOOP:
    xor rax, rax
    mov ax, [data]
    cwde                                        ; signed extend ax 2 eax
    cdqe                                        ; signed extend eax 2 rax
    add [w2_sum], rax                           ; w2_sum += rax

    xor rax, rax
    mov rax, 1                                  ; w2_count++
    add [w2_count], rax

    xor rdx, rdx
    xor rax, rax
    mov rax, [w2_sum]
    cqo                                         ; signed extend rax to rdx

    xor rcx, rcx
    mov rcx, [w2_count]

    idiv rcx                                    ; rax = rdx:rax / rcx

    mov [w2_average], rax

    mov rax, 8								                  ; lseek()
		mov rdi, [fileW1]					                  ; file descriptor
		mov rsi, 44								                  ; offset
		mov rdx, 0						                  		; from where
		syscall

		mov rax, 8						                   		; lseek()
		mov rdi, [fileW2]				                   	; file descriptor
		mov rsi, 44						                   		; offset
		mov rdx, 0					                  			; from where
		syscall

    mov rax, 8						                  		; lseek()
    mov rdi, [fileW3]		                   			; file descriptor
    mov rsi, 44						                   		; offset
    mov rdx, 0					                   			; from where
    syscall

    mov [length], r8

  WRITING_LOOP:
    xor rax, rax
    mov rax, [length]
    cmp rax, 0                                  ; length >= 0
      je FINALIZE

    mov rax, 0								                  ; read()
		mov rdi, [fileW1]			                  		; file descriptor
		mov rsi, dataW1				                   		; destination buffer
		mov rdx, 2					                   			; count
		syscall

		mov rax, 0					                   			; read()
		mov rdi, [fileW2]			                  		; file descriptor
		mov rsi, dataW2			                   			; destination buffer
		mov rdx, 2						                  		; count
		syscall

    xor rax, rax
    mov rax, [length]		                   			; length--
		sub rax, 1
		mov [length], rax

    xor rax, rax
		xor rcx, rcx
    mov ax, [dataW1]
    cwde                                        ; signed extend ax 2 eax
    cdqe                                        ; signed extend eax 2 rax
    mov rcx, [w2_average]

    cmp rax, rcx                                ; dataW1 >= w2_average
      jge WRITE_FROM_W1

    jmp WRITE_FROM_W2

  WRITE_FROM_W1:
    mov rax, 1 							                 		; write()
    mov rdi, [fileW3]			                			; file descriptor
    mov rsi, dataW1						                 	; source buffer
    mov rdx, 2							                 		; count
    syscall

    jmp WRITING_LOOP

  WRITE_FROM_W2:
    mov rax, 1 							                		; write()
    mov rdi, [fileW3]				                 		; file descriptor
    mov rsi, dataW2						                  ; source buffer
    mov rdx, 2						                 			; count
    syscall

    jmp WRITING_LOOP

  FINALIZE:
    mov rax, 3                                  ; close()
    mov rdi, [fileW1]                           ; file descriptor
    syscall

    mov rax, 3                                  ; close()
    mov rdi, [fileW2]                           ; file descriptor
    syscall

    mov rax, 3                                  ; close
    mov rdi, [fileW3]                           ; file descriptor
    syscall

    mov rax, 60						                   		; exit()
    mov rdi, 0					                   			; status
    syscall
