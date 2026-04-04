mov ax, 0x7C0  ; for data segment, since it will start reading from this address
mov ds, ax

mov ax, 0x7E0 ; 0x7C0 + 512, after the code segment-> stack segment
mov ss, ax

;on x64 architecture, the stack pointer decreases. so need to fix the
; size of the stack, then declare the start of the stack.
;Since the stack segment can address 64k of memory,
; let's make an 8k stack, by setting SP to 0x2000.

mov sp, 0x2000

