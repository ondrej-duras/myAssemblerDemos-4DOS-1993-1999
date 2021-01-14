
ifndef texty_icp_v_1_0_txt
display "Kniznaca FILENAME.ICP v.1.0.txt musi byt priradena do programu"
display "spolu s kniznicou TEXTY.ICP v.1.0.txt   !!!"
err
endif

display	"Filename verzia 1.0.txt - vyzaduje kniznicu texty.icp v.1.0"
filename proc near		;vstupne meno suboru je na adrese PSP:82h
	mov si,offset filewin	;procedura zadavania mena suboru
	call window		;v ASCIIZ formate
	mov di,14*160+26	;ak nebolo zadane ziadne meno suboru
	mov si,82h		;potom je na adrese 82h kod 0 (byte)
	call zwrite
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
	mov ah,0
	int 22
	cmp al,13
	jne filename1
	cmp par+1,0
	je filename2
	jmp filenamekoniec
filename1:mov cx,ax
	mov ah,5
	int 22
	mov di,14*160+26
	mov cx,55
	mov ax,4f20h
	rep stosw
	mov cl,55
	mov dx,0e0dh
	mov si,82h
	call zinput	
	cmp par+1,0
	je filename2
filenamekoniec:retn
filename2:mov fncount,0	;zaciatok editacnej casti v suborovom menu
	mov fncurh,0
	mov fncurr,0
	mov ah,48h
	mov bx,2048 	
	int 33
	jnc fnamee4
	mov ah,2
	mov dl,7
	int 33
	mov par+1,0
	retn
	;derr 'Malo pamete !'
fnamee4:mov fnbuf,ax
fnamee3:mov es,fnbuf	;vstupny bod pri opetovnom nacitani adresara
	sub di,di
	mov ax,di
	mov cx,16384
	rep stosw
	mov si,9eh
	sub ax,ax
	mov [si],ax
	mov [si+2],ax
	mov [si+4],ax
	mov [si+6],ax
	mov [si+8],ax
	mov [si+10],ax
	mov [si+12],ax
	mov ah,4eh
	mov dx,offset findpath
	mov cx,49
	int 33
	jc fnamee2
	sub di,di
fnamee1:cmp fncount,2048
	je fnamee2
	push di
	mov al,parsize+15h
	stosb
	mov si,9eh
	mov cx,13
	rep movsb
	pop di
	add di,16
	inc fncount
	mov si,9eh
	sub ax,ax
	mov [si],ax
	mov [si+2],ax
	mov [si+4],ax
	mov [si+6],ax
	mov [si+8],ax
	mov [si+10],ax
	mov [si+12],ax
	mov ah,4fh
	int 33
	jnc fnamee1
fnamee2:mov si,offset filemenuwin
	call window
fname3:	mov si,fncurh	;zaciatok vykreslenia obsahu menu
	mov cl,4	;zaciatok hlavneho cyklu v editacii v menu
	shl si,cl
	mov es,vram
	mov ds,fnbuf
	mov di,9*160+66
	mov ah,3fh
	mov dh,10
fname5:	lodsb		;zaciatok vykreslenia jedneho riadku
	test al,16
	mov bh,0
	mov al,20h
	mov bl,al
	jz fname4
	mov al,'['
	mov bl,']'
	mov bh,1
fname4:	stosw
	mov al,bl
	mov [es:di+24],ax
	mov cx,12
fname6:	lodsb
	or al,al
	jne fname7
	mov al,20h
fname7:	or bh,bh
	jne fname11
	cmp al,'Z'
	ja fname11
	cmp al,'A'
	jb fname11
	or al,20h
fname11:stosw
	loop fname6
	add di,160-26
	add si,3
	dec dh
	jnz fname5
	push cs
	pop ds		;koniec vykreslovania obsahu tabulky
	mov ax,fncurr	;zobrazenie kurzora
	mul lins
	add ax,9*160+67
	mov di,ax
	mov al,4fh
	mov cx,14
fname8:	stosb
	inc di
	loop fname8
	mov dh,byte ptr fncurr
	add dh,9
	mov bh,0
	mov dl,33
	mov ah,2
	int 16
	mov ah,0
	int 22
	mov bx,ax
	cld
	mov si,offset fnametab	
fname9:	lodsw
	or ax,ax
	jne fname10
	jmp fname3
fname10:mov dx,ax
	lodsw
	cmp dx,bx
	jne fname9
	jmp ax

fntabkon:mov ah,49h
	mov bx,fnbuf
	int 33
	retn
	
fnkoniec:mov par+1,0
	jmp short fntabkon

fnametab dw 011bh,fnkoniec,1c0dh,fnok ;tabulka obsluznych klaves menu
	dw 5000h,fndole,4800h,fnhore,4900h,fnpgup,5100h,fnpgdn
	dw 8400h,fnupdir
	dw 2000h,fnchdrv,3b00h,fnhelp
	dw 0

fndole:	cmp fncurr,9	;pohyby kurzorom hore a dole
	jnb fndole2
	mov ax,fncount
	or ax,ax
	je fndole1
	dec ax
	cmp fncurr,ax
	jnb fndole1
	inc fncurr
fndole1:jmp fname3
fndole2:mov ax,fncurh
	add ax,10
	cmp ax,fncount
	jnb fndole1
	inc fncurh
	jmp short fndole1
fnhore:	cmp fncurr,0
	je fnhore1
	dec fncurr
	jmp short fndole1
fnhore1:cmp fncurh,0
	je fndole1
	dec fncurh
	jmp short fndole1
fnpgup:	cmp fncurr,0
	je fnpgup1
	mov fncurr,0
	jmp short fndole1
fnpgup1:cmp fncurh,10
	jb fnpgup2
	sub fncurh,10
	jmp short fndole1
fnpgup2:mov fncurh,0
	jmp short fndole1
fnpgdn:	cmp fncurr,9
	je fnpgdn3
	mov ax,fncount
	cmp ax,10
	jb fnpgdn1
	mov ax,10
fnpgdn1:dec ax
	mov fncurr,ax
fnpgdn2:jmp fname3
fnpgdn3:mov bx,fncount
	sub bx,10
	mov ax,fncurh
	cmp ax,bx
	jnb fnpgdn2
	add ax,10
	cmp ax,bx
	jb fnpgdn4
	mov ax,bx
fnpgdn4:mov fncurh,ax
	jmp short fnpgdn2
	
fnok:	mov si,fncurh		;obsluha pri stlaceni Enter
	add si,fncurr		; to je : - vyber suboru
	mov cl,4		;         - zmena adresara
	shl si,cl
	mov ds,fnbuf		;vyhladanie polozky adresara
	test byte ptr [si],16	;a urcenie jej typu
	je fnok1
	mov dx,si		;zmena adresara
	inc dx
	mov ah,3bh
	int 33
	push cs
	pop ds
fnok2:	mov fncount,0
	mov fncurr,0
	mov fncurh,0
	jmp fnamee3
fnok1:	push cs			;vyber suboru a nasledovne
	pop es			;ukoncenie procedury
	mov di,82h
	inc si
	mov cx,13
	rep movsb
	push cs
	pop ds
	retn

fnchdrv:mov si,offset filenamedrv	;zmena aktualneho disku
	call window
	mov ah,0
	int 22
	or al,32
	cmp al,'a'
	jb fnchdrv
	cmp al,'z'
	ja fnchdrv
	sub al,'a'
	mov dl,al
	mov ah,14
	int 33
	jmp short fnok2

fnupdir:mov ah,3bh	;zmena adresara o jednu uroven vyssie
	mov dx,offset finduppath	
	int 33
	jmp short fnok2
	
fnhelp:	mov si,offset filenamehlp
	call window	;help ku procedure
	mov ah,0
	int 22
	jmp fname3
		
findpath db '*.*',0
finduppath db '..',0
fnbuf	dw 0c000h
fncurh	dw 24h	;index prvej v menu zobrazovanej polozky adresara
fncurr	dw 6h	;poloha kurzora v menu
fncount	dw 77h	;pocet najdenych suborov (moze ich byt max 2048)
filewin: twin 10,12,59,2,3fh
	db 13,'  Zadaj meno suboru:',13
	db '  ',1,5eh,'                                                       ' 
	db 0
filemenuwin:twin 32,8,14,10,3fh
	db ' ADRESAR ',0
filenamedrv:twin 34,10,10,4,5fh
	db 13,13,' Vyber si',13,'   disk.',0
filenamehlp:twin 33,9,12,8,5fh
	db ' POMOC ',13
	db ' Specialne',13
	db '  klavesy',13
	db '컴컴컴컴컴컴',13
	db ' Ctrl+PgUp',13
	db '  Alt+D',13
	db '  PgUp',13
	db '  PgDn',13
	db '  Esc',0
	endp
