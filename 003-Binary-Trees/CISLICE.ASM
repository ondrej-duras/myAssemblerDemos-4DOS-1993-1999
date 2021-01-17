;CISLICE.ASM / CISLICE.COM - Len draftovy programcek
;19980107, rtm. Ondrej DURAS (dury)
;
;HISTORICKA POZNAMKA:
; :-) asi niekedy 7.1.1998 som pisal programcek VSTROM.COM
; Pre pre splnenie zadania som potreboval funkciu pre
; vykreslovanie cislic. Nuze vtomto programceku sa diala priprava.
; Po napisani kniznice pre vykreslovanie sa programcek stal nepotrebny.
; ... navyse ... uz sa nedal bez upravy zkompilovat, pretoze vyuzival
; kniznicu vstrom.icp do ktorej bola funkcia vykreslovania prekopirovana.
; Pri dalsom kompilovani sa v kode totizto objavila duplicita prekopirovaneho kodu.
; ... a tak programcek ostal od 7.1.1998 az do 17.1.2021 ladom.
; Dnes bol po 23 rokoch upraveny tak, aby sa opat dal zkompilovat.
; Po 23 rokoch z CISLICE.ASM je opat CISLICE.COM .
; --- 

	p286n
prog	segment
	assume cs:prog,ds:prog,es:prog,ss:prog
prvyb:	org 2ch
dosenv	dw ?
	org 80h
parsize	db ?
par	db 127 dup(?)
zac:	;ZACIATOK PROGRAMU
	;include vstrom.icp
	;xwrite 100,100,uvod,15
	mov ax,18
	int 16

	mov ax,040fh
	mov cx,127
	mov dx,100
	call cislica
	mov ax,0f51h
	mov cx,120
	mov dx,100
	call dcislo
	

	mov ah,0
	int 22	
	
	
koniec:	mov ax,3
	int 16
	mov ah,9
	mov dx,offset koniec_t
	int 33
	mov ax,4c00h
	int 33
koniec_t db 'Koniec programu...',13,10,36




dcislo	proc near	;ah=farba cx=x, dx=y al=cislo
	pusha
	mov bh,ah
	mov ah,0
	mov bl,10
	div bl
	mov ah,bh
	call cislica
	popa
	pusha
	mov bh,ah
	mov ah,0
	mov bl,10
	div bl
	mov al,ah
	mov ah,bh
	add cx,7
	call cislica
	popa
	retn
	endp

cislica	proc near	;al=cislica ah=farba cx=x dx=y ds=cs ;vypis dec cislice
	mov es,vram
	mov bx,dx
	mov si,ax
	mov dx,3ceh
	mov al,0
	out dx,ax
	mov ax,0305h
	out dx,ax
	mov ax,11
	and si,15
	mul si
	add ax,offset cislice
	mov si,ax
	mov ax,lins
	mul bx
	mov di,ax
	mov al,7
	and al,cl
	shr cx,3
	add di,cx
	mov cl,al		
	cld
	
	lodsb		;1.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;2.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;3.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;4.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;5.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;6.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;7.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;8.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;9.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;10.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	add di,78
	lodsb		;11.riadok
	mov ah,0
	ror ax,cl
	mov bh,es:[di]
	stosb
	mov bh,es:[di]
	mov al,ah
	stosb
	retn
	endp
	

cislice:
	db 01110000b ;cislica0
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 01110000b

	db 00110000b ;cislica1
	db 01010000b
	db 10010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	 
	db 01110000b ;cislica2
	db 10001000b
	db 00001000b
	db 00001000b
	db 00001000b
	db 01110000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 10001000b
	db 11111000b
	 
	db 01110000b ;cislica3
	db 10001000b
	db 00001000b
	db 00001000b
	db 01110000b
	db 00001000b
	db 00001000b
	db 00001000b
	db 10001000b
	db 01110000b
	db 00000000b
	 
	db 00011000b ;cislica4
	db 00110000b
	db 01100000b
	db 11000000b
	db 11010000b
	db 11111000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	 
	db 11111000b ;cislica5
	db 10000000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 11110000b
	db 00001000b
	db 00001000b
	db 00001000b
	db 10001000b
	db 01110000b
	 
	db 01110000b ;cislica6
	db 10001000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 11110000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 01110000b
	 
	db 11111000b ;cislica7
	db 10001000b
	db 00001000b
	db 00010000b
	db 00010000b
	db 01111000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	 
	db 01110000b ;cislica8
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 01110000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 01110000b
	 
	db 01110000b ;cislica9 
	db 10001000b
	db 10001000b
	db 10001000b
	db 10001000b
	db 01111000b
	db 00001000b
	db 00001000b
	db 10001000b
	db 01110000b
	db 00000000b

	db 00000000b ;znak +    10
	db 00100000b
	db 00100000b
	db 00100000b
	db 00100000b
	db 11111000b
	db 00100000b
	db 00100000b
	db 00100000b
	db 00100000b
	db 00000000b

	db 00000000b ;znak -    11
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 11111000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b

	db 01110000b ;znak  CHYBA   12
	db 10001000b
	db 10001000b
	db 00001000b
	db 00001000b
	db 11110000b
	db 10000000b
	db 01000000b
	db 01000000b
	db 00000000b
	db 01000000b

	db 00000000b ;znak CIARKA    13
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00110000b
	db 00110000b
	db 00010000b
	db 00100000b

	db 00000000b ;znak PODCIARNIK    14
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 11111000b

	db 11111000b ;znak MAZAC/KURZOR    15
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b

	;include vstrom.ida
VRAM	dw 0a000h
LINS	dw 80
poslednyb:
dlzkaprog=(offset poslednyb-offset prvyb)/16+1
prog	ends
end	zac

