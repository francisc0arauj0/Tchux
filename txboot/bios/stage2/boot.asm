bits 16
org 0x7E00

stage2_entry:
	cli
	cld
	; Reset segments and stack to a known state
	; Segments
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; Stack
	mov ss, ax 
	mov sp, 0x7C00

	sti

	mov [boot_drive], dl

	; Check if the A20 is already enabled
	call check_a20
	cmp ax, 1
	je a20_ok

	; Fast a20 gate
	in al, 0x92
	or al, 2
	out 0x92, al

	; Verify that A20 was successfully enabled
	call check_a20
	cmp ax, 1
	je a20_ok

	jmp halt

a20_ok:
	call do_e820
	jc halt

; https://wiki.osdev.org/A20_Line#Testing_the_A20_line
check_a20:
	pushf
	push ds
	push es
	push di
	push si

	cli

	xor ax, ax
	mov es, ax

	not ax
	mov ds, ax

	mov di, 0x500 
	mov si, 0x510

	mov al, byte[es:di]
	push ax

	mov al, byte[ds:si]
	push ax

	mov byte[es:di], 0x00
	mov byte[ds:si], 0xFF

	cmp byte[es:di], 0xFF

	pop ax
	mov byte[ds:si], al

	pop ax
	mov byte [es:di], al

	mov ax, 0
	je .check_a20_exit

	mov ax, 1
.check_a20_exit:
	pop si
	pop di
	pop es
	pop ds
	popf
	ret

; https://wiki.osdev.org/Detecting_Memory_(x86)#Getting_an_E820_Memory_Map
do_e820:
    mov di, 0x8004          	; set di to 0x8004
	xor ebx, ebx				; ebx must be 0 to start
	xor bp, bp					; keep an entry count in bp
	mov edx, 0x0534D4150		; place "SMAP" into edx
	mov eax, 0xe820
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24					; ask for 24 bytes
	int 0x15
	jc short .failed			; carry set on first call means "unsupported function"
	mov edx, 0x0534D4150		; some BIOSes apparently trash this register?
	cmp eax, edx				; on success, eax must have been reset to "SMAP"
	jne short .failed
	test ebx, ebx				; ebx = 0 implies list is only 1 entry long (worthless)
	je short .failed
	jmp short .jmpin
.e820lp:
	mov eax, 0xe820				; eax, ecx get trashed on every int 0x15 call
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24					; ask for 24 bytes again
	int 0x15
	jc short .e820f				; carry set means "end of list already reached"
	mov edx, 0x0534D4150		; repair potentially trashed register
.jmpin:
	jcxz .skipent				; skip any 0 length entries
	cmp cl, 20					; got a 24 byte ACPI 3.X response?
	jbe short .notext
	test byte [es:di + 20], 1	; if so: is the "ignore this data" bit clear?
	je short .skipent
.notext:
	mov ecx, [es:di + 8]		; get lower uint32_t of memory region length
	or ecx, [es:di + 12]		; "or" it with upper uint32_t to test for zero
	jz .skipent					; if length uint64_t is 0, skip entry
	inc bp						; got a good entry: ++count, move to next storage spot
	add di, 24
.skipent:
	test ebx, ebx				; if ebx resets to 0, list is complete
	jne short .e820lp
.e820f:
	mov [es:mmap_ent], bp		; store the entry count
	clc							; there is "jc" on end of list to this point, so the carry must be cleared
	ret
.failed:
	stc							; "function unsupported" error exit
	ret

halt:
	cli
	hlt
	jmp halt

boot_drive db 0
mmap_ent equ 0x8000