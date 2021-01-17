;Pre potreby ALG II.ulohy
;vypis znaku(putc),textu(write), vykreslenie ciar(dline) stlacenie klavesy(key)

	mov ah,4ah		;inicializacny predProgram
	mov bx,dlzkaprog
	int 33
	mov ah,48h
	mov bx,1000
	int 33
	jnc strombeg1
	mov dx,offset strombeg0t
strombeg0:mov ah,9
	int 33
	mov ax,4cffh
	int 33
strombeg0t db 'Strom: Malo Pamete !',13,10,36
strombeg1:cli
	mov ss,ax
	mov sp,16000
	sti
	mov ax,18
	int 16
	jmp StromDefEnd

key	macro
	mov ah,0
	int 22
	endm
wend=0		;koniec textu
wco=1		;nova farba
nl=3		;novy riadok
wmarg=4		;nove odsadenie
wlines=5	;dalej budu ciarky
wcls=6		;zmazanie obrazovky
wproc	macro xx	;procedura vramci vypisu
	db 7
	dw offset xx
	endm
wat	macro xx,yy
	db 2
	dw xx,yy
	endm		;nova poloha kurzora
xwrite	macro xx,yy,tt,cc	;vypis textu
	push xx yy cs
	push offset tt
	push cc
	call write_p
	endm

vram	dw 0a000h
lins	dw 80
putc_f	dd 0ffa6000eh
putc	proc near		;vykresli znak
	mov es,cs:vram		;VSTUPY: ah=farba al=znak cx=xx dx=yy
	push ds si
	push ax
	lds si,cs:putc_f
	mov ax,dx
	mul cs:lins
	mov di,ax
	mov dx,cx
	shr dx,3
	add di,dx
	and cl,7
	pop ax
	mov dh,0
	mov dl,al
	shl dx,3
	add si,dx
	mov dx,3ceh
	mov al,0
	out dx,ax
	mov ax,0305h
	out dx,ax
	mov ch,8
	cld
putc1:	lodsb
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	dec ch
	jnz putc1
	pop si ds
	retn
	endp

write_p	proc near
	arg fcolor:word,ffrom:dword,fyy:word,fxx:word
	local newx:word,newy:word,margin:word
	enter 6,0
	mov ax,fxx
	mov newx,ax
	mov ax,fyy
	mov newy,ax
	mov margin,8
	push ds
	lds si,ffrom
write_p1:lodsb
	cmp al,32
	jb write_p2
	mov ah,byte ptr fcolor
	mov cx,fxx
	mov dx,fyy
	call putc
	mov dx,margin
	add fxx,dx
	jmp write_p1
write_p2:cmp al,0
	jne write_p3
	pop ds
	leave
	retn 10
write_p3:cmp al,1
	jne write_p4
	lodsb
	mov byte ptr fcolor,al
	jmp write_p1
write_p4:cmp al,2
	jne write_p5
	lodsw
	mov fxx,ax
	mov newx,ax
	lodsw
	mov fyy,ax
	mov newy,ax
	jmp write_p1
write_p5:cmp al,3
	jne write_p6
	mov ax,newx
	mov fxx,ax
	mov ax,newy
	add ax,margin
	mov fyy,ax
	mov newy,ax
	jmp write_p1
write_p6:cmp al,4
	jne write_p7
	lodsb
	mov ah,0
	mov margin,ax
	jmp write_p1
write_p7:cmp al,5
	jne write_p8
	push bp
	call dline
	pop bp
	add si,2
	jmp write_p1
write_p8:cmp al,6
	jne write_p9
	lodsb
	mov ah,al
	call cls
write_pa:jmp write_p1
write_p9:cmp al,7
	jne write_pa
	lodsw
	pusha
	push ds es
	call ax
	pop es ds
	popa
	jmp write_p1	
	endp

;ahoj	db 'ahoj',wco,14,wmarg,16,' cau',nl,wco,4,' by by'
;	wat 200,400
;	db wmarg,12,wco,11,'ha ha ha...'
;	db wend	;zakoncovak
	
;DLINE procedura pre kreslenie ciar, 11.9.1997 Ondrej Duras
;nasledujuce makro a 1.riadok procedury predpisuju format parametra...
;Toto vyzera byt velmi dobra verzia...
line	macro x1,y1,x2,y2,farba	;struktura prvku ciara
	dw x1,y1,x2,y2
	db farba
	endm
;kresli postupnost ciar zakoncenu zakoncovacim znakom >64000
;vstup [ds:si] na struktoru viz ^makro...
dline	proc near	;pre FAR staci prepisat na far
	mov es,cs:vram	;priprava pre kreslenie
	cld
	cmp word ptr [si],64000	;test konca retazca ciar
	jb dline0
	ret		;jediny RET
dline0:	mov dx,3ceh
	mov ax,0305h
	out dx,ax
	mov al,0
	mov ah,[si+8]
	out dx,ax
	
	mov bp,cs:lins	;vypocet suradnic poc. bodu
	mov di,[si]
	mov ax,[si+2]
	mul bp
	mov cx,7
	and cx,di
	shr di,3
	add di,ax
	mov al,128
	ror al,cl
	push ax
	xor ax,ax	;priprava diferencialov II.
	mov dx,[si+6]
	sub dx,[si+2]
	jnc dline1
	neg bp
	neg dx
dline1:	mov cx,[si+4]
	sub cx,[si]
	jnc dline2
	neg cx
	jmp dline21	;pre do_lava
dline2:	push es
	pop ds
	cmp dx,cx	;pre do_prava
	jb dline5	;k<1
	ja dline9	;k>1
	inc cx		;k=1
	pop ax
dline3:	mov ah,[di]
	stosb
	dec di
	ror al,1
	jnc dline4
	inc di
dline4:	add di,bp
	loop dline3
	jmp dline30	;na koniec

dline5:	div cx		;k<1
	mov bx,ax
	inc cx
	pop ax
dline6:	mov ah,[di]
	stosb
	dec di
	ror al,1
	jnc dline7
	inc di
dline7:	add dx,bx
	jnc dline8
	add di,bp
dline8:	loop dline6
	jmp dline30	;na koniec
	
dline9:	xchg cx,dx	;k>1
	div cx
	inc cx
	mov bx,ax
	pop ax
dline10:mov ah,[di]
	stosb
	dec di
	add di,bp
	add dx,bx
	jnc dline11
	ror al,1
	jnc dline11
	inc di
dline11:loop dline10
	jmp dline30



dline21:push es
	pop ds
	cmp dx,cx	;pre do_lava
	jb dline25	;k<1
	ja dline29	;k>1
	inc cx		;k=1
	pop ax
dline23:mov ah,[di]
	stosb
	dec di
	rol al,1
	jnc dline24
	dec di
dline24:add di,bp
	loop dline23
	jmp dline30	;na koniec

dline25:div cx		;k<1
	mov bx,ax
	inc cx
	pop ax
dline26:mov ah,[di]
	stosb
	dec di
	rol al,1
	jnc dline27
	dec di
dline27:add dx,bx
	jnc dline28
	add di,bp
dline28:loop dline26
	jmp dline30	;na koniec
	
dline29:xchg cx,dx	;k>1
	div cx
	inc cx
	mov bx,ax
	pop ax
dline210:mov ah,[di]
	stosb
	dec di
	add di,bp
	add dx,bx
	jnc dline211
	rol al,1
	jnc dline211
	dec di
dline211:loop dline210
	
dline30:push cs	;zakoncenie cyklu procedury
	pop ds
	add si,9
	jmp dline
	endp

cls	proc near		;vstup v ah=farba
	mov es,cs:vram
	mov al,0
	mov dx,3ceh
	out dx,ax
	mov ax,0305h
	out dx,ax
	xor di,di
	mov cx,40*480
	mov ax,0ffffh
	rep stosw
	retn
	endp

biostime dd 0040006ch
delay	proc near		;synchronizacne cakanie max. 55ms
	push es di
	les di,cs:biostime
	mov al,es:[di]
delay1:	cmp es:[di],al
	je delay1
	pop di es
	retn
	endp

StromDefEnd:
; Koniec suboru --------------------------------------------------------
