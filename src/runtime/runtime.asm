use32

[global _GLOBAL_OFFSET_TABLE_]
[global __morestack]
[global abort]
[global malloc]
[global free]
[global start]

[extern main]

[section .mbhdr]
[extern _loadStart]
[extern _loadEnd]
[extern _bssEnd]

align 8
MbHdr:
	dd 0x1BADB002
	dd 0000000000000001b
	dd -(0x1BADB002 + 0000000000000001b)
	
	dd MbHdr
	dd _loadStart
	dd _loadEnd
	dd _bssEnd
	dd start
HdrEnd:

[section .boot]
[extern Stack]
start:
	mov eax, Gdtr1
	lgdt [eax]

	push 0x08
	push .GdtReady
	retf

.GdtReady:
	mov eax, 0x10
	mov ds, ax
	mov ss, ax
	mov esp, Stack

	call setup_paging_and_long_mode

	mov eax, Gdtr2
	lgdt [Gdtr2]

	push 0x08
	push .Gdt2Ready
	retf

use64

.Gdt2Ready:
	mov eax, 0x10
	mov ds, ax
	mov es, ax
	mov ss, ax

	mov rsp, Stack + 0xFFFFFFFF80000000

	mov rax, Gdtr3
	lgdt [rax]

	mov [gs:0x30], dword 0

	mov rax, main
	call rax

	cli
	jmp $

use32
[extern Pml4]
[extern Pdpt]
[extern Pd]

setup_paging_and_long_mode:
	mov eax, Pdpt
	or eax, 1
	mov [Pml4], eax
	mov [Pml4 + 0xFF8], eax

	mov eax, Pd
	or eax, 1
	mov [Pdpt], eax
	mov [Pdpt + 0xFF0], eax

	mov dword [Pd], 0x000083
	mov dword [Pd + 8], 0x200083
	mov dword [Pd + 16], 0x400083
	mov dword [Pd + 24], 0x600083

	mov eax, Pml4
	mov cr3, eax

	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	ret

TmpGdt:
	dq 0x0000000000000000
	dq 0x00CF9A000000FFFF
	dq 0x00CF92000000FFFF
	dq 0x0000000000000000
	dq 0x00A09A0000000000
	dq 0x00A0920000000000

Gdtr1:
	dw 23
	dd TmpGdt

Gdtr2:
	dw 23
	dd TmpGdt + 24
	dd 0

Gdtr3:
	dw 23
	dq TmpGdt + 24 + 0xFFFFFFFF80000000 

use64

[section .text]

_GLOBAL_OFFSET_TABLE_:

__morestack:

abort:
	jmp $

malloc:
	jmp $

free:
	jmp $

