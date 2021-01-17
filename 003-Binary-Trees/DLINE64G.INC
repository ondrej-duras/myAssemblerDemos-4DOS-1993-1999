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

