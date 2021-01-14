Display "Kniznica zakladnych operacii pre textove aplikacie...  verzia 1.0.txt"
texty_icp_v_1_0_txt=10
twin	macro xx,yy,sir,vys,farba	;makro pre okna
	dw (yy*160)+(xx*2)
	db sir,vys,farba
	endm
derr	macro bb
	local xx
	jnc xx
	call derrp
	db bb,13,10,36
xx:	endm
cursor	macro
	mov bh,0
	mov ah,2
	int 16
	endm
curon	macro xx,yy
	mov ah,2
	mov bh,0
	mov dx,yy*256+xx
	int 16
	endm
key	macro
	mov ah,0
	int 22
	endm

derrp	proc near	;ukoncenie programu
	mov ax,3
	int 16
	pop dx
	mov ah,9
	int 33
	mov ax,4c00h
	int 33
	endp
	
	
vram	dw 0b800h
lins	dw 160
linx	db 160
zwrite	proc near
	cld
	mov es,cs:vram
zwrite1:lodsb
	or al,al
	jne zwrite2
	retn
zwrite2:stosb
	inc di	
	jmp short zwrite1
	endp

pdec	proc near	;procedura premeny dec na ascii
	push ax
	push cs
	pop es
	cld
	mov di,81h
	mov ax,2020h
	stosw
	stosw
	mov ah,0
	stosw
	std
	dec di
	dec di
	mov bx,10
	pop ax
pdec1:	sub dx,dx
	div bx
	xchg ax,dx
	add al,30h
	stosb
	xchg ax,dx
	or ax,ax
	jnz pdec1
	cld
	retn
	endp

decgeto	dw 0	;stara hodnota
decgeta	dw 0	;aktualna hodnota
decgetv	dw 0	;adresa videoram
decgetl	dw 0	;limitna nodnota (najvyssia dovolena)
decgets	dw 81h	;buff

decget	proc near	;vstup v ax	- vstupna hodnota
	push cs		;	 di - adresa videoram
	pop ds		;	 dx - rozsah platnosti
	mov decgeto,ax	;vystpu v ax - vystupna hodnota
	mov decgeta,ax
	mov decgetl,dx
	push di
	mov bl,160	;nastavenie kurzora pod cislo
	mov ax,di
	div bl
	shr ah,1
	mov dh,al
	mov dl,ah
	mov bh,0
	mov ah,2
	int 16
	pop di
	sub di,10	;zistenie poctu cislic
	mov si,81h
	cmp dx,9999	;podla toho nastavenie pozicie vypisu
	ja decget1
	inc di
	inc di
	inc si
	cmp dx,999
	ja decget1
	inc di
	inc di
	inc si
	cmp dx,99
	ja decget1
	inc di
	inc di
	inc si
	cmp dx,9
	ja decget1
	inc di
	inc di
	inc si
decget1:mov decgetv,di	
	mov decgets,si
decget2:mov ax,decgeta	;zaciatok hl.cyklu
	call pdec	;vypis cisla
	mov di,decgetv
	mov si,decgets
	call zwrite
	mov ah,0	;cakanie na stlacenie klavesy
	int 22
	cmp al,13	;Enter
	jne decget3
	mov ax,decgeta
	retn
decget3:cmp al,27	;Esc
	jne decget4
	mov ax,decgeto
	retn
decget4:cmp ax,5300h	;Del
	jne decget5
	mov decgeta,0
	jmp short decget2
decget5:cmp ax,5200h	;Ins
	jne decget6
	mov ax,decgeto
	mov decgeta,ax
	jmp short decget2
decget6:cmp al,8
	jne decget7
	mov bx,10
	mov ax,decgeta
	sub dx,dx
	div bx
	mov decgeta,ax
	jmp short decget2
decget7:cmp al,'0'
	jb decget2
	cmp al,'9'
	ja decget2
	sub al,'0'
	mov ch,0
	mov cl,al
	mov ax,decgeta
	mov bx,10
	mul bx
	add ax,cx
	adc dx,0
	or dx,dx
	jnz decget2
	cmp ax,decgetl
	ja decget2
	mov decgeta,ax
	jmp short decget2
	endp

ziposit	dw 0	;x,y-ova suradnica zacitaku vypisu
zidlzka	db 0	;aktualna dlzka retazca
zimax	db 0	;maximalna dlzka retazca (s nulou)
zinput	proc	near	;vstup asciiz retazca
	mov cs:zimax,cl	;vstupy dx-suradnice,cl-maxdlzka,ds:si-buffer
	mov cs:ziposit,dx
	push ds		;vypocet dlzky retazca,ktory uz v buf. je
	pop es
	mov al,0
	mov di,si
	mov cx,81
	cld
	repne stosb
	neg cx
	add cx,80
	mov cs:zidlzka,cl
	je zinput1
	mov cs:zidlzka,0
	mov byte ptr [si],0
zinput1:mov di,si		;zaciatok cyklu
	mov ah,2
	mov bh,0
	mov dx,cs:ziposit
	int 16
	mov ah,2
zinput2:lodsb
	or al,al
	je zinput3
	mov dl,al
	int 33
	jmp short zinput2
zinput3:mov si,di
	mov ah,8
	int 33
	cmp al,13
	jne zinput4
	retn
zinput4:cmp al,27
	jne zinput5
	mov byte ptr [si],0
	retn
zinput5:cmp al,8
	jne zinput6
	sub bx,bx
	mov bl,cs:zidlzka
	mov byte ptr [si+bx],0
	cmp cs:zidlzka,0
	je zinput1
	dec cs:zidlzka
	dec bx
	mov byte ptr [si+bx],0
	mov ah,2
	mov dl,8
	int 33
	mov dl,' '
	int 33
	jmp short zinput1
zinput6:mov dl,cs:zidlzka
	cmp dl,zimax
	jnb zinput1
	sub bx,bx
	mov bl,cs:zidlzka
	mov [bx+si],al
	inc bx
	mov byte ptr [bx+si],0
	inc cs:zidlzka
	jmp short zinput1
	endp

window	proc near
	mov es,vram
	lodsw
	mov di,ax
	lodsw
	mov bx,ax
	mov dl,bh
	mov bh,0
	mov bp,lins
	sub bp,bx
	sub bp,bx
	sub bp,4
	lodsb
	mov ah,al
	mov al,'É'	;'Ú'=218 'É'=201
	stosw
	push di
	mov al,'Í'	;'Ä'=196 'Í'=205
	mov cx,bx
	rep stosw
	mov al,'»'	;'¿'=191 '»'=187
	stosw
	add di,bp
window1:mov cx,bx
	mov al,'º'	;'³'=179 'º'=186
	stosw
	mov al,' '
	rep stosw
	mov al,'º'
	stosw
	add di,bp
	dec dl
	jnz window1
	mov al,'È'	;'À'=192 'È'=200
	stosw
	mov cx,bx
	mov al,'Í'
	rep stosw
	mov al,'¼'	;'Ù'=217 '¼'=188
	stosw
	pop di
	mov bp,di
window2:lodsb
	or al,al
	jnz window3
	retn
window3:cmp al,13
	jne window4
	add bp,lins
	mov di,bp
	jmp short window2
window4:cmp al,10
	jne window5
	jmp short window2
window5:cmp al,1
	jne window6
	lodsb
	mov ah,al
	jmp window2
window6:stosw
	jmp short window2
	endp

mmenu	dw 0	;offset dat menu
moffs	dw 0	;offset prvej polozky menu
mvide	dw 0	;offset kurzora vo videoram
mpolo	db 0	;index polozky na ktoru prave kurzor ukazuje

;priklad db 74h	;farba kurzora
;	twin x,y,sirka,vyska,farba (okna)
;	db 'meno okna',13
;	db 'text..',13
;	db 'text..',0
;hhx	dw nasledujuca_polozka (ak sa rovna offsetu hhx potom= posledna pol.
;	obsluzna rutina 1. polozky
;	Prva polozka obsahuje obsluhu Esc.

menu	proc near
	mov mpolo,0
	mov mmenu,si
	inc si
	call window
	mov moffs,si
	mov si,mmenu
	mov di,[si+1]
	add di,lins
	inc di
	inc di
	mov mvide,di
	inc mvide
menu1:	mov si,mmenu
	mov di,mvide	;zaciatok cyklu
	mov ch,0
	mov cl,[si+3]
	mov al,[si]
menu2:	stosb
	inc di
	loop menu2
	mov ah,0
	int 22
	push ax
	mov di,mvide
	mov ch,0
	mov cl,[si+3]
	mov al,[si+5]
menu3:	stosb
	inc di
	loop menu3
	pop ax
	cmp al,27	;Esc
	jne menu6
menu4:	mov si,moffs
menu5:	inc si
	inc si
	jmp si
menu6:	cmp al,13	;Enter
	jne menu8
	mov ah,mpolo
	mov al,255
	mov si,moffs
menu7:	cmp al,ah
	je menu5
	cmp si,[si]
	je menu1 ;menu4
	mov si,[si]
	inc al
	jmp short menu7
menu8:	cmp ax,4800h	;hore
	jne menu9
	cmp mpolo,0
	je menu1
	dec mpolo
	mov dx,lins
	sub mvide,dx
	jmp short menu1
menu9:	cmp ax,5000h	;dole
	jne menu1
	mov al,[si+4]
	dec al
	cmp mpolo,al
	jnb menu1
	inc mpolo
	mov dx,lins
	add mvide,dx
	jmp menu1
	endp	
