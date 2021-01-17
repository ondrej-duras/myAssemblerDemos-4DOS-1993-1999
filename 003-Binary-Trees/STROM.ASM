; STROM.ASM / STROM.COM - Ukazky prechadzania binarnych stromov
; 19971205, rtm. Ondrej DURAS (dury)
;
;POPIS:
; Ide iba o laboratorne cvicenie z predmetu algoritmizacia.
; Cielom je ukazat princip prechadzania binarnych stromov
; troma sposobmi: preorder, inorder, postorder.
; Binarny strom je struktura podobna zoznamu.
; Narozdiel od zoznamu vsak kazdy rodicovsky uzol ma dvoch potomkov.
; Samotny prvy z uzlov, ten ktory nema ziadneho rodica, nazyvame koren.
; Naopak posledne uzly, majuce kazdy iba jedneho 
; rodica ale ziadneho potomka, nazyvame listami.
;
; Pre-order prehladavanie:
; Najprv vykona pozadovanu akciu s hodnodou uzla.
; Potom rekurzivne nasleduje uzol - laveho potomka, a nakoniec
; vykona rekurziu s pravym potomkom.
;
; In-order prehladavanie:
; Najprv vykona rekurziu u laveho potomka,
; naslednevykona pozadovanu akciu s hodnotou uzla
; a nakoniec vykona rekurziu u praveho potomka.
;
; Post-order:
; Najprv vykona rekurziu u laveho potomka,
; potom vykona rekurziu u praveho potomka
; a az na koniec vykona akciu s hodnotou uzla.
;
; Tento priklad - strom.com vizualne demonstruje
; ako vsetky tri prehladavaniu funguju.
;
;POUZITIE:
; Program mozno odstartovat bez argumentov, pricom
; sa strom naplni hodnotami z predvoleneho retazca
; maximalnej dlzky.
; 

	p286n
prog	segment
	assume cs:prog,ds:prog,es:prog,ss:prog
prvyb:	org 80h
parsize	db ?
par	db 127 dup(?)
key	macro
	mov ah,0
	int 22
	endm
zac:	include STROM.INC	;ZACIATOK PROGRAMU
	mov bh,0	;zistenie ci a aky velky je definovany strom
	mov bl,parsize
	cmp bl,1
	jna zac1
	cmp bl,63
	ja zac1
	dec bx
	mov stree,bx
zac1:	mov si,offset uvod
	xwrite 100,100,uvod,15
	key
	call zaklad_p
	mov ah,48h
	mov bx,63
	int 33
	jnc zac2
	mov ax,4c01h
	int 33
zac2:	mov tree,ax
	jmp uziv
	
koniec:	mov ax,3
	int 16
	mov ah,9
	mov dx,offset koniec_t
	int 33
	mov ax,4c00h
	int 33
koniec_t db 'Koniec programu...',13,10,36

tree	dw 0c000h	;seg adresa stromu
stree	dw 63		;velkost stromu v pocte poloziek
tree_a	dw 0	;pocitadlo cyklu
tree_b	dw 0	;pocitadlo smernikov na synov
tree_c	dw 0	;pocitadlo cisla poschodia
tree_d	dw 0	;pocitadlo poctu susedov (na poschodi)
tree_e	dw 0	;pocitadlo suseda
tree_f	dw 0	;vzdialenost susedov
tree_g	dw 0	;poloha dalsieho suseda
tree_h	db 0	;aktualny znak
MkTree	proc near
	mov es,tree	;INICIALIZACIE
	mov tree_a,63	;inicializujeme 63 poloziek - nie vsetky budu v strome
	mov tree_b,16	;lavy syn korena bude mat offset [16]
	mov tree_c,1	;koren je na 1. poschodi
	mov tree_d,1	;koren suseda nema
	mov tree_e,1	;cyklus na prvom poschodi prebehne len raz
	mov tree_h,'A'	;koren sa vola "A" ak nieje pomenovany inak
	xor di,di	;ukazatel na polozku stromu
	
mktree1:mov bx,tree_d	;zaciatok cyklu poschodia
	inc bx
	mov ax,640
	cwd
	div bx
	mov tree_f,ax	;vzdialenost medzi susedmi
	mov tree_g,0	;poloha vrcholu z lava

mktree2:mov ax,tree_b	;zaciatok cyklu zapisov
	mov es:[di],ax	;zapis smernikov
	add ax,16
	mov es:[di+2],ax
	add ax,16
	mov tree_b,ax
	mov ax,tree_g	;x-ova poloha vrcholu
	add ax,tree_f
	mov tree_g,ax
	mov es:[di+4],ax
	mov ax,tree_c		;y-ova poloha vrcholu
	mov bx,40
	mul bx
	add ax,20
	mov es:[di+6],ax
	mov al,tree_h		;standardny znak vo vrchole stromu
	mov es:[di+8],al
	inc al
	mov tree_h,al
	mov ax,0e0fh		;standardne (farby,priznak,"nepouzite")
	mov es:[di+9],ax
	mov ax,0ff03h
	mov es:[di+11],ax
	xor ax,ax
	mov es:[di+13],al
	mov es:[di+14],ax
	add di,16		;posun na dalsi prvok
	dec tree_a
	jz mktree3	;na pokracovanie
	dec tree_e	;treba prejst na nove poschodie ?
	jnz mktree2
	inc tree_c	;ak ano modifikuj: cislo poschodia
	mov ax,tree_d	;pocet susedov
	shl ax,1
	mov tree_d,ax
	mov tree_e,ax	;pocitadlo susedov
	jmp mktree1	;pokracuj modifikaciou pripoctu x-polohy suseda...

mktree3:xor di,di	;tu budeme pokracovat standardizaciou vrcholov
	mov bx,stree	;nulovanie smernikov listov + oznacenie
	mov dx,bx	;nepouzitych vrcholov
	shl dx,4
	mov cx,63
mktree4:cmp di,dx	;zaciatok standardizacneho cyklu
	jb mktree5
	mov byte ptr es:[di+12],0	;ozn. "nepouzity"
mktree5:cmp es:[di],dx
	jb mktree6
	mov word ptr es:[di],0		;lavy NIL
mktree6:cmp es:[di+2],dx
	jb mktree7
	mov word ptr es:[di+2],0	;pravy NIL
mktree7:add di,16
	loop mktree4
	cmp parsize,1
	ja mktree8
	retn
mktree8:xor di,di	;zapisanie standardnych znakov z cmd do stromu
	mov si,offset par+1
	mov ch,0
	mov cl,parsize
	dec cl
	cmp cl,63
	jna mktree9
	mov cl,63
mktree9:cld
mktree10:lodsb
	mov es:[di+8],al
	add di,16
	loop mktree10
	retn
	endp

dtreeb	db 6*9+2 dup(255)
	db 10 dup(255)
dtree	proc near
	push cs
	pop es
	xor si,si
	mov cx,stree
	mov ds,tree
dtree1:	pusha			;zaciatok cyklu vykreslenia stromu
	push ds es
	cmp byte ptr [si+12],0
	jne dtree5
	jmp dtree6
dtree5:	mov di,offset dtreeb
	mov cx,[si+4]
	mov dx,[si+6]
	mov ax,cx	;vrchna ciarka
	sub ax,8
	stosw
	mov ax,dx
	stosw
	mov ax,cx
	add ax,8
	stosw
	mov ax,dx
	stosw
	mov al,[si+10]
	stosb
	mov ax,cx	;lava ciarka
	sub ax,8
	stosw
	mov ax,dx
	stosw
	mov ax,cx
	sub ax,8
	stosw
	mov ax,dx
	add ax,16
	stosw
	mov al,[si+10]
	stosb
	mov ax,cx	;prava ciarka
	add ax,8
	stosw
	mov ax,dx
	stosw
	mov ax,cx
	add ax,8
	stosw
	mov ax,dx
	add ax,16
	stosw
	mov al,[si+10]
	stosb
	mov ax,cx	;spodna ciarka
	sub ax,8
	stosw
	mov ax,dx
	add ax,16
	stosw
	mov ax,cx
	add ax,8
	stosw
	mov ax,dx
	add ax,16
	stosw
	mov al,[si+10]
	stosb
	pusha		;vypis pismenka
	push ds es
	mov ax,[si+8]
	sub cx,4
	add dx,4
	push ax cx dx
	inc cx
	inc cx
	inc dx
	inc dx
	mov ah,0
	call putc
	pop dx cx ax
	call putc
	pop es ds
	popa
	cmp word ptr [si],0	;ciara k lavemu synovi
	je dtree2
	mov bx,[si]
	mov ax,cx
	sub ax,8
	stosw
	mov ax,dx
	add ax,16
	stosw
	mov ax,[bx+4]
	stosw
	mov ax,[bx+6]
	stosw
	mov al,[bx+11]
	stosb
dtree2:	cmp word ptr [si+2],0	;ciara k pravemu synovi
	je dtree3
	mov bx,[si+2]
	mov ax,cx
	add ax,8
	stosw
	mov ax,dx
	add ax,16
	stosw
	mov ax,[bx+4]
	stosw
	mov ax,[bx+6]
	stosw
	mov al,[bx+11]
	stosb
dtree3:	mov ax,65535	;zapisanie zakoncovaku
	stosw
	push cs		;vykreslenie ciarociek vrcholu
	pop ds
	mov si,offset dtreeb
	call dline
	;key		;vykresovanie vrcholov - puaza pri kazdom vrchole
dtree6:	pop es ds	;zakoncenie cyklu
	popa
	add si,16
	;loop dtree1
	dec cx
	jz dtree4
	jmp dtree1
dtree4:	push cs
	pop ds
	retn
	endp
	
	
vrchol	macro ll,pp,xx,yy,zn,cc,bc,lc
	dw ll,pp,xx,yy
	db zn,cc,bc,lc,255,0,0,0
	endm
vrch1:	vrchol vrch2,vrch3,320,150,'A',15,14,00
vrch2:	vrchol vrch4,vrch5,220,200,'B',15,14,11
vrch3:	vrchol vrch6,vrch7,420,200,'C',15,14,11
vrch4:	vrchol 0,vrch8,190,250,'D',15,14,11
vrch5:	vrchol vrch8,vrch9,250,250,'E',15,14,11
vrch6:	vrchol 0,0,390,250,'F',15,14,11
vrch7:	vrchol 0,0,450,250,'G',15,14,11
vrch8:	vrchol 0,0,220,300,'?',07,07,07
vrch9:	vrchol 0,0,280,300,'?',07,07,07
vrcholy	proc near
	mov si,offset vrch1
	mov cx,9
	push cs
	pop es
	jmp dtree1
	endp


xkeymod	db 0	;0=prehliadaci rezim !0=krokovaci rezim
xkey	proc near
	mov ah,1
	int 22
	jnz xkey2	;na ?Esc
	cmp cs:xkeymod,0
	jnz xkey2
xkey1:	retn
xkey2:	mov ah,0
	int 22
	cmp al,27
	jne xkey1	
	jmp koniec
	endp
		
preord_x dw 0
preord_y=300
preord_a db 'PREORDER:',wend
preord_l:line 530,415,550,435,12
	line 550,435,590,375,12
	dw 64000
	preord	proc near		;Prehladavanie typu preorder
	call mktree
	mov preord_x,100	;[50,400] nech zacne vypis...
	xwrite 20,preord_y,preord_a,15
	push 0
	call preordr
	call mktree
	call dtree
	mov si,offset preord_l
	call dline
	retn
	endp
preordr	proc near	;rekurzivna cast procedury preorder
	arg smer:word
	enter 0,0
	mov es,cs:tree
	mov di,smer
	leave
	push es di
	mov byte ptr es:[di+11],12
	mov byte ptr es:[di+10],12
	call dtree
	pop di es
	push es di
	add preord_x,8
	mov cx,preord_x
	mov dx,preord_y
	mov ax,es:[di+8]
	call putc
	call dtree
	call delay
	call delay
	call delay
	pop di es
	push es di
	mov byte ptr es:[di+10],14
	call xkey
	call dtree
	pop di es
	push es di
	cmp word ptr es:[di],0
	je preordr1
	push word ptr es:[di]
	call preordr
	pop di es
	push es di
preordr1:cmp word ptr es:[di+2],0
	je preordr2
	push word ptr es:[di+2]
	call preordr
preordr2:pop di es
	mov byte ptr es:[di+11],13
	call dtree
	retn 2
	endp
	
  inord_x dw 0
  inord_y=320
  inord_a db 'INORDER:',wend
inorder_l:line 540,415,560,435,12
	line 560,435,600,375,12
	dw 64000
  inord	proc near		;Prehladavanie typu   inorder
	call mktree
	mov   inord_x,100	;[50,400] nech zacne vypis...
	xwrite 20,  inord_y,  inord_a,15
	push 0
	call   inordr
	call mktree
	call dtree
	mov si,offset inorder_l
	call dline
	retn
	endp
inordr	proc near	;rekurzivna cast procedury   inorder
	arg smer:word
	enter 0,0
	mov es,cs:tree
	mov di,smer
	leave
	push es di
	mov byte ptr es:[di+11],12
	call dtree
	pop di es
	push es di
	cmp word ptr es:[di],0
	je   inordr1
	push word ptr es:[di]
	call   inordr
	pop di es
	push es di
inordr1:mov byte ptr es:[di+10],12
	call dtree
	pop di es
	push es di
	add   inord_x,8
	mov cx,  inord_x
	mov dx,  inord_y
	mov ax,es:[di+8]
	call putc
	call dtree
	call delay
	call delay
	call delay
	pop di es
	push es di
	mov byte ptr es:[di+10],14
	call xkey
	call dtree
	pop di es
	push es di
  	cmp word ptr es:[di+2],0
	je   inordr2
	push word ptr es:[di+2]
	call   inordr
  inordr2:pop di es
	mov byte ptr es:[di+11],13
	call dtree
	retn 2
	endp



postord_x dw 0
postord_y=340
postord_a db 'POSTORDER:',wend
postorder_l:line 550,415,570,435,12
	line 570,435,610,375,12
	dw 64000
postord	proc near		;Prehladavanie typu postorder
	call mktree
	mov postord_x,100	;[50,400] nech zacne vypis...
	xwrite 20,postord_y,postord_a,15
	push 0
	call postordr
	call mktree
	call dtree
	mov si,offset postorder_l
	call dline
	retn
	endp

postordr proc near	;rekurzivna cast procedury postorder
	arg smer:word
	enter 0,0
	mov es,cs:tree
	mov di,smer
	leave
	push es di
	mov byte ptr es:[di+11],12
	call dtree
	pop di es
	push es di
	cmp word ptr es:[di],0
	je postordr1
	push word ptr es:[di]
	call postordr
	pop di es
	push es di
postordr1:cmp word ptr es:[di+2],0
	je postordr2
	push word ptr es:[di+2]
	call postordr
postordr2:pop di es
	push es di
	mov byte ptr es:[di+10],12
	call dtree
	pop di es
	push es di
	add postord_x,8
	mov cx,postord_x
	mov dx,postord_y
	mov ax,es:[di+8]
	call putc
	call dtree
	call delay
	call delay
	call delay
	pop di es
	push es di
	mov byte ptr es:[di+10],14
	call xkey
	call dtree
	pop di es
	mov byte ptr es:[di+11],13
	call dtree
	retn 2
	endp

uziv_t:	wproc mktree
	wproc zaklad_p
	wproc dtree
	wat 257,33
	db wco,0,wmarg,30,'STROM'
	wat 254,30
	db wco,15,wmarg,30,'STROM',wmarg,12
	wat 22,402
	db wco,0,'1',nl,'2',nl,'3',nl,'4',nl,'Esc'
	wat 20,400
	db wco,11,'1  ',wco,7,' PreOrder',nl
	db wco,11,'2  ',wco,7,' InOrder',nl
	db wco,11,'3  ',wco,7,' PostOrder',nl
	db wco,11,'4  ',wco,7,' Cele divadlo',nl
	db wco,11,'Esc',wco,7,' Koniec programu',nl,wmarg,8
	wat 200,400
	db 'Iny strom si mozno navrhnut zadanim',nl
	db 'niekolkych zakov do prikazoveho riadku',nl
	db 'nasledovnym sposobom:',nl,nl,wco,11
	db '        strom.com ABCDEFGHIJKL'
	db wend
uziv:	xwrite 10,10,uziv_t,8
uziv1:	key
	mov si,offset fnkeys
	mov dl,al
uziv2:	lodsb
	cmp al,0
	je uziv1
	mov bl,al
	lodsw
	cmp dl,bl
	jne uziv2
	push ax
	xwrite 10,10,uziv_t,8
	pop ax
	jmp ax
	
fnkeys	db '1'
	dw preorder
	db '2'
	dw inorder
	db '3'
	dw postorder
	db '4'
	dw divadlo
	db 27
	dw koniec
	db 0	;zakoncovak
preorder:mov xkeymod,1
	call preord
	jmp uziv1
inorder:mov xkeymod,1
	call inord
	jmp uziv1
postorder:mov xkeymod,1
	call postord
	jmp uziv1
divadlo:mov xkeymod,0
	call preord
	call inord
	call postord
	jmp uziv1

;include strom.ida	;obsahuje UVOD
; strom.ida - zaciatok
uvod:	wproc zaklad_p
	wat 153,38
	db wmarg,20,wco,0,'VOJENSKA AKADEMIA',wmarg,15,nl
	db '   Liptovsky Mikulas'
	wat 150,35
	db wmarg,20,wco,15,'VOJENSKA AKADEMIA',wmarg,15,nl
	db '   Liptovsky Mikulas',wmarg,30
	wat 47,373
	db wco,0,'LOZENIE PO STROMOCH',nl,wmarg,15
	db '            ucebna pomocka',wmarg,30
	wat 45,370
	db wco,15,'LOZENIE PO STROMOCH',nl,wmarg,15
	db '            ucebna pomocka'
	wproc vrcholy
	db wlines
	line 220,270,200,290,12
	line 220,280,200,300,12
	line 250,300,300,340,12
	line 300,340,365,240,12
	line 255,320,360,290,12
	dw 64000
	db wend

zaklad_p:xwrite 10,10,zaklad,9
	retn
zaklad	db wcls,8,wlines
	line 0,0,639,0,7
	line 0,0,0,479,7
	line 639,479,639,0,7
	line 639,479,0,479,7
	line 4,4,635,4,7
	line 4,4,4,475,7
	line 635,475,635,4,7
	line 635,475,4,475,7
	dw 64000	;zakoncovak ciar
	wat 420,450
	db wco,7,wmarg,10,'Ondrej DURAS (DURY)'
	db wend
; strom.ida - koniec
poslednyb:
dlzkaprog=(offset poslednyb-offset prvyb)/16+1
prog	ends
end	zac



