bits 16

; BIOS drops us here by default
mov ax, 0x7C0       ; segment for our data, since code starts reading from this address
mov ds, ax          ; ds (data segment) now points to 0x7C0

; our code is 512 bytes, so the stack segment starts right after it
mov ax, 0x7E0       ; 0x7C0 + 512 bytes = end of code, start of stack
mov ss, ax          ; marks end of data segment, start of stack segment

; on x86, sp counts down as you push, so you have to pick a size and
; a starting point yourself, nothing does this for you
; stack segment can address 64k, so let's use 8k of it
; physical = segment * 16 + offset
; 0x07E0 (start of stack) * 16 + 0x2000 (the size we want) = 0x9E00 (end of stack)
mov sp, 0x2000      ; sp starts at the top of that 8k and decreases from here

call clear_screen
; call pushes the return address to the stack, then jumps to clear_screen

push 0x0000
call set_cursor
add sp, 2           ; caller cleans up its own argument after the call
; there's no register or language-level way to pass arguments here,
; so we push the value first, the callee reads it off the stack with
; [bp+4], and we pop it back off once the call returns

push hello
call print_string
add sp, 2

cli
hlt

clear_screen:
  push bp             ; save caller's frame pointer
  mov bp, sp
  pusha               ; save all general purpose registers, not flags, so this function doesn't clobber the caller's

  mov ah, 0x07
  mov al, 0x00
  mov bh, 0x07
  mov cx, 0x00
  mov dh, 0x18
  mov dl, 0x4F
  int 0x10
  ; INT 10h, AH=07h, the BIOS video service for scrolling.
  ; AL = 0 tells it to blank the entire window instead of scrolling by
  ; a line count. BH = 0x07 sets the attribute byte for the blanked cells,
  ; light gray on black here, upper nibble is background, lower nibble is
  ; foreground. CX packs the top-left corner as CH:CL = row:col, here
  ; 0x00:0x00. DH:DL packs the bottom-right corner, 0x18:0x4F is row 24,
  ; col 79, the standard 80 by 25 text mode grid since both are
  ; zero-indexed. int 0x10 triggers the interrupt, which jumps into BIOS
  ; code through the interrupt vector table.

  popa
  mov sp, bp
  pop bp              ; restore caller's frame pointer
  ret

set_cursor:
  push bp
  mov bp, sp
  pusha
  mov dx, [bp+4]
  mov ah, 0x02
  mov bh, 0x00
  int 0x10
  ; walk the offset from bp: bp+0 holds the saved caller bp (2 bytes),
  ; bp+2 holds the return address call pushed (2 bytes), bp+4 is where
  ; the argument sits, since the caller pushed it before calling.
  ; mov dx, [bp+4] loads that packed row:col word straight into dx,
  ; since INT 10h, AH=02h expects dh and dl set that way.

  popa
  mov sp, bp
  pop bp              
  ret

print_string:
  push bp
  mov bp, sp
  pusha
  mov si, [bp+4]
  mov bh, 0x00
  mov bl, 0x00
  mov ah, 0x0E
.next_char:
  mov al, [si]
  add si, 1
  or al, al
  je .done
  int 0x10
  jmp .next_char
.done:
  popa
  mov sp, bp
  pop bp
  ret

hello: db "Hello from bootloader, testing by sifat", 0
; the trailing 0 is the null terminator print_string looks for.
; without it, the loop keeps reading past the string into whatever
; bytes come next until it happens to hit a zero somewhere in memory

times 510-($-$$) db 0  ; pad out to 510 bytes
dw 0xAA55               ; boot signature, must be the last 2 bytes of the sector
