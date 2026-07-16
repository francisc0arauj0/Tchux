bits 16
org 0x7C00

start:
	jmp short main
	nop
	times 8-($-$$) db 0

main:
	cli
	; Init segments
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; Init stack
	mov ss, ax
	mov sp, 0x7C00
	sti

	mov [boot_drive], dl

	; No support for floppy disks
	cmp dl, 0x80
	jb floppy_error

	; Check edd (https://wiki.osdev.org/Disk_access_using_the_BIOS_(INT_13h))
	mov ah, 0x41
	mov bx, 0x55AA
	int 0x13
	jc edd_error
	cmp bx, 0xAA55
	jne edd_error
	test cx, 1
	jz edd_error

	; Reading 16 sectors from LBA
	mov si, dapack
	mov ah, 0x42
	mov dl, [boot_drive]
	int 0x13
	jc disk_error

	mov dl, [boot_drive]
	jmp 0x0000:0x7E00

; Print
print:
	pusha
	mov ah, 0x0E
.loop:
	lodsb
	test al, al
	jz .done
	int 0x10
	jmp .loop
.done:
	popa
	ret

; Errors
floppy_error:
	mov si, msg_no_floppy
	call print
	jmp halt

edd_error:
	mov si, msg_no_edd
	call print
	jmp halt

disk_error:
	mov si, msg_disk_error
	call print
	jmp halt

halt:
	cli
	hlt
	jmp halt

boot_drive db 0
msg_no_floppy db "[TxBt ERROR] does not support floppy disks", 13, 10, 0
msg_no_edd db "[TxBt ERROR] It does not support EDD", 13, 10, 0
msg_disk_error db "[TxBt ERROR] Disk read failed!", 13, 10, 0

align 4
dapack:
	db 0x10
	db 0
	blkcnt: dw 16       ; int 13 resets this to # of blocks actually read/written
	db_add: dw 0x7E00   ; memory buffer destination address (0x0000:0x7E00)
	dw 0                ; in memory page zero
	d_lba: dd 1         ; put the lba to read in this spot
	dd 0                ; more storage bytes only for big lba's ( > 4 bytes )

times 510-($-$$) db 0
dw 0xAA55