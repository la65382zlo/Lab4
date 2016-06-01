.model small
.386
.stack 3000h
.data
	head		db "<<Sort>>", endl, 0
	str_fin		db '1. File input (F/f)', endl, 0
	str_cin		db '2. Console input (C/c)', endl, 0
	str_n		db 'n = ', 0
	str_id		db '   Invalid data!!!', endl, 0
	str_nf		db '   Not found!!!', endl, 0
	exit_tab	db endl, '   Enter ESC for exit', endl, 0
	str_arr_beg	db 'arr[', 0
	str_arr_end	db '] = ', 0
	str_value	db 'value = ', 0
	file_err	db 'not exist!!!', endl, 0
	prompt		db 'file: ', 0
	str_save	db 'Save in file y/n  :  ', 0
	len			dw ?
	n			dw 0
	value		dw 0
	arr			dw ?
	handle		dw ?
	
	file_name	db 80 dup(0)
	arr_out		db 80 dup(0)
	tmp 		db 80 dup(0)
.code

LOCALS

include arr_io.inc

;============================
cmpnum proc c
	arg @a, @b
	uses bx, si
	mov si, @a
	mov ax, word ptr[si]
	mov si, @b
	mov bx, word ptr[si]
	cmp ax, bx
	je @@ecv
	jl @@less
	mov ax, 1
	jmp @@end
@@ecv:
	xor ax, ax
	jmp @@end
@@less:
	mov ax, -1
@@end:
	ret
cmpnum endp
;============================

;============================
exchange proc c
	arg @a, @b, @n
	uses ax, cx, si, di
	mov cx, @n
	mov si, @a
	mov di, @b
@@cycle:
	cmp cx, 0
	je @@end
	mov al, [di]
	mov ah, [si]
	mov [di], ah
	mov [si], al
	inc si
	inc di
	dec cx
	jmp @@cycle
@@end:
	ret
exchange endp
;============================


;============================
; void choice_sort(void *arr, size_t arr_len, size_t size_elem, int (*comparator)(const *void, const *void))
choice_sort proc c
	arg @arr, @arr_len, @size_elem, @comparator
	uses ax, bx, cx, dx, si, di
	mov cx, @arr_len
	dec cx
	mov bx, @arr
@@cycle1:
	cmp cx, 0
	je @@end
	mov dx, cx
	mov di, bx
	mov si, bx
	add si, @size_elem
@@cycle2:
	cmp dx, 0
	je @@ns0
	push di
	push si
	call @comparator
	add sp, 4
	cmp ax, 0
	jnl @@ns1
	mov di, si
@@ns1:
	add si, @size_elem
	dec dx
	jmp @@cycle2
@@ns0:	
	cmp bx, di
	je @@ns2
	push @size_elem
	push bx
	push di
	call exchange
	add sp, 6
@@ns2:
	dec cx
	add bx, @size_elem
	jmp @@cycle1
@@end:
	ret
choice_sort endp
;============================

;============================
file_save proc c
	uses ax
	puts str_save
@@fsave:
	call _getch
	cmp al, 'y'
	je @@save
	cmp al, 'Y'
	je @@save
	cmp al, 'n'
	je @@end
	cmp al, 'N'
	je @@end
	jmp @@fsave
	
@@save:
	putc endl
	putc endl
	puts prompt
	
	push offset file_name
	call gets
	add sp, 2
	
	push WO
    push offset file_name
    call fopen
    add sp, 4
	
	mov handle, ax
	
	push 10
	push offset tmp
	push n
	call itoa
	add sp, 6
	
	push handle
	push offset tmp
	call fputs
	add sp, 4
	
	fputc endl, handle
	
	push handle
	push n
	push arr
	call arr_ifout
	add sp, 6
	
	push handle
	call fclose
	add sp, 2
	
@@end:
	putc endl
	putc endl
	ret
file_save endp
;============================

;============================
main proc
    mov ax, @data
    mov ds, ax

@@beg_app:

; menu
	puts head
	putc endl
	puts str_fin
	puts str_cin
	puts exit_tab
@@check_input:
	call _getch
	cmp al, 31h
	je @@fin
	cmp al, 'f'
	je @@fin
	cmp al, 'F'
	je @@fin
	cmp al, 32h
	je @@cin
	cmp al, 'c'
	je @@cin
	cmp al, 'C'
	je @@cin
	cmp ah, 1
	jne @@check_input
	_exit
	
; file input
@@fin:
	putc endl
	puts prompt
	push offset file_name
	call gets
	add sp, 2
	
	putc endl
	putc endl
	
	push RO
    push offset file_name
    call fopen
    add sp, 4
	
	test ax, ax
    jne @@ns2
	putc ' '
	putc ' '
	putc ' '
	putc '"'
	puts file_name
	putc '"'
	putc ' '
	puts file_err
	putc endl
	jmp @@beg_app
	
@@ns2:
	mov handle, ax
	
	push offset tmp
	push handle
	call ifin
	add sp, 4
	
	cmp bl, 0
	je @@ns3					; file open
	
	; error
	puts str_id
	jmp @@beg_app
	
@@ns3:
	mov n, ax
	
	add ax, ax
	mov len, ax
	sub sp, ax
	mov arr, sp
	
	puts str_n
	puts tmp
	putc endl
	putc endl
	
	push handle
	push n
	push arr
	call arr_ifin
	add sp, 6
	
	push ax
	putc endl
	pop ax
	
	cmp al, 0
	je @@alg
	
	; error
	putc endl
	puts str_id
	
	; memory free
	add sp, len
	
	; goto @@beg_app
	jmp @@beg_app
	
; console input
@@cin:
	putc endl

	push offset str_n
	call icin
	add sp, 2
	mov n, ax
	
	
	; reserved memory
	add ax, ax
	mov len, ax
	sub sp, ax
	mov arr, sp
	
	putc endl
	
	; input arr
	push n
	push arr
	call arr_icin
	add sp, 4
	
	putc endl
	
	push n
	push arr
	call arr_icout
	add sp, 4
	putc endl
	
	call file_save
	
@@alg:
	putc endl

	push offset cmpnum
	push 2
	push n
	push arr
	call choice_sort
	add sp, 8
	
	push n
	push arr
	call arr_icout
	add sp, 4
	putc endl

	call file_save
	
@@end:
	; memory free
	add sp, n
	add sp, n
	
@@end_app:
	_exit
main endp
;============================
end main