;SOCIOM.ASM - Sociometria malych pracovnych skupin
;19960101, rtm. Ondrej DURAS (dury)
prog	segment
	assume cs:prog,ds:prog,es:prog,ss:prog
prvyb:
	org 80h
parsize	db ?
par	db 127 dup(?)
	org 100h

; Makra  a kniznice -----------------------------------------------------
kanerr	macro www	;osetrenie klasickych chyb
	local aa,bb
	jnc aa
	call kanerrp
bb	db www,0
aa:	endm
kanerz	macro www
	call kanerrp
	db www,0
	endm

zac:	jmp zac1

	include texty.icp    ;a:\inc\texty.icp
	include filename.icp ;a:\inc\filename.icp
	
zac1:	jmp short beg0	;preskok lic..
	mov al,8	;licencia
	out 70h,al
	in al,71h
	cmp al,10h
	jb zac3
zac2:	mov ax,3
	int 16
	mov si,offset zacsor
	call window
	mov ah,0
	int 22
	mov ax,4c00h
	int 33
zacsor:	twin 10,8,60,7,4fh
	db 13,13,13,13,'            KONTAKTUJTE SA S AUTOROM PROGRAMU...',0
zac3:	mov al,9
	out 70h,al
	in al,71h
	cmp al,96h
	ja zac2


; Uvod ------------------------------------------------------	
beg0:	mov ah,4ah		;pametove allokacie
	mov bx,dlzkaprog	;novy zasobnik
	int 33
	mov ah,48h
	mov bx,1000
	int 33
	derr 'Malo miesta pre zasobnik !'
	mov stacks,ax
	cli
	mov ss,ax
	mov sp,16000
	sti
	
	mov cx,4		;buffre pre matice
	mov di,offset buf1
beg1:	push cx di
	mov bx,dlzkamatic
	mov ah,48h
	int 33
	derr 'Malo Pamete !'
	pop di
	push cs
	pop es
	stosw
	mov buf,ax
	push di
	call clearm
	pop di
	push cs
	pop es
	inc default+15
	inc default+23
	pop cx
	loop beg1

	mov ax,buf1
	mov buf,ax
	
;--- testovacia vypln
;	mov di,offset rows
;	mov es,buf
;	mov cx,128*5
;	mov al,0
;beg2:	stosb
;	inc al
;	loop beg2
;	push ds
;	mov ax,0f000h
;	mov ds,ax
;	mov cx,128*128
;	mov ax,1
;	sub di,di
;	sub si,si
;beg3:	lodsw
;	and ax,1
;	stosw
;	loop beg3
;	pop ds
;--- koniec testovacej vyplne

; testovacia vypln pre +/-
;	mov es,buf
;	mov cx,128*128
;	mov ax,0fffh
;	sub di,di
;beg2:	stosw
;	add ah,10h
;	or ax,0fffh
;	loop beg2
;	jmp asbeg4
;koniec testovacej vyplne pre +/-
beg4:	mov si,offset kansaveh	;  .TS
	mov al,1
beg5:	sub [si],al
	inc si
	inc al
	cmp al,36
	jb beg5
	mov si,offset ahoj+1
	mov al,1
beg6:	sub [si],al
	inc si
	inc al
	cmp al,27
	jb beg6
	jmp asbeg4	;preskok na iny zac

kanbeg4:mov begin,offset kanbeg
	mov draw,offset drawkan
	mov fill,offset fillkan
	call word ptr draw ;obsluha klavesnice pri editacii matice v kanonickom
	call word ptr fill	;tvare
	sub ax,ax
	int 51
kanbeg:	call cursoron	;zaciatok obsluzneho cyklu
	mov ax,1
	int 51
	mov help,offset kanhelp
	
kanbeg3:sub bx,bx
	mov ax,3	;obsluha klavesnice
	int 51		;pri editacii dat v matici
	or bx,bx
	je kanbeg2
	jmp mouse
kanbeg2:mov ah,1
	int 22
	jz kanbeg3
	mov ah,0
	int 22
	
	push ax
	mov ax,2
	int 51
	call cursoroff
	pop ax
	mov dx,ax
	mov si,offset kantab
kanbeg1:lodsw
	or ax,ax
	jz kanbeg
	mov bx,ax
	lodsw
	cmp bx,dx
	jne kanbeg1
	jmp ax

kantab	dw 4d00h,vpravo ,4b00h,vlavo,4800h,hore,5000h,dole,0e08h,vlavo ;right,left,up,down,backspace
	dw 3920h,odznac,1c0dh,oznac,4700h,home,4900h,pguphome ;space,enter,home,pgup
	dw 4300h,rmark,4400h,rmark3,5300h,rmark4 ;f9,f10,del
	dw 1519h,delrow,1615h,delcolum,4200h,change ;ctrl+y,ctrl+u,f8
	dw 7800h,kantaba,7900h,kantabb,7a00h,kantabc,7b00h,kantabd ;alt+1 az 4
	dw 5100h,pgdown,7400h,pgright,7300h,pgleft ;pgdn,ctrl+right,ctrl+left
	dw 0f09h,edn,3b00h,kanhelp,011bh,koniec	;tab,f1,esc
	dw 3c00h,kansave,3d00h,kanload,3e00h,kanexp ;f2,f3,f4
	dw 7100h,kanclear	;alt+f10 zmaz tabulku
	dw 1900h,asgen	;generovanie tabulky (+/-) spolupatricnosti alt+p
	dw 0	;zakoncovak
	
koniec:	mov ax,3	;ukoncenie programu
	int 16
	push cs
	pop ds
	mov ah,9
	mov dx,offset koniect
	int 33
	mov ax,4c00h
	int 33
koniect	db 'Sociom v.2.0',13,10
	db 'Original ',??date,' ',??time,' Normal shutdown',13,10,36
	
vpravo:	cmp xr,11	;posuny kurzora -univerzalne
	je vpravo1
	inc xr
vpravo2:jmp word ptr begin
vpravo1:cmp xh,128-12
	jnb vpravo2
	inc xh
	call word ptr fill
	jmp short vpravo2
	
vlavo:	cmp xr,0
	je vlavo1
	dec xr
vlavo2:	jmp short vpravo2
vlavo1:	cmp xh,0
	je vlavo2
	dec xh
	call word ptr fill
	jmp short vlavo2

hore:	cmp yr,0
	je hore1
	dec yr
hore2:	jmp short vlavo2
hore1:	cmp yh,0
	je hore2
	dec yh
	call word ptr fill
	jmp short hore2
	
dole:	cmp yr,18
	je dole1
	inc yr
dole2:	jmp short vlavo2
dole1:	cmp yh,128-19
	jnb dole2
	inc yh
	call word ptr fill
	jmp short dole2
	
pgdown:	cmp yr,18
	je pgdown1
	mov yr,18
	jmp word ptr begin
pgdown1:add yh,19
	cmp yh,128-19
	jb pgdown2
	mov yh,128-19
pgdown2:call word ptr fill
	jmp word ptr begin
	

pgright:cmp xr,11	;posunutie o stranku vpravo
	je pgright1
	mov xr,11
	jmp word ptr begin
pgright1:add xh,12
	cmp xh,128-12
	jb pgright2
	mov xh,128-12
pgright2:call word ptr fill
	jmp word ptr begin

odznac:	mov bx,0	;medzera-mazanie X
	jmp short oznac1
oznac:	mov bx,1	;enter-zapis X
oznac1:	sub ax,ax	;editacia buniek v kanonickom tvare
	mov status,1
	mov al,xh
	add al,xr
	shl ax,1
	add ah,yh
	add ah,yr
	mov es,buf
	mov si,ax
	mov [es:si],bx
	call word ptr fill
	jmp vpravo
	
pguphome:cmp yr,0
	je pguphome1
	mov yr,0
	jmp short pguphome3
pguphome1:sub yh,19
	jnb pguphome2
	mov yh,0
pguphome2:call word ptr fill
pguphome3:jmp word ptr begin
home:	mov xr,0
	mov xh,0
	jmp short pguphome2

pgleft:cmp xr,0		;posun o stranku do lava
	je pgleft1
	mov xr,0
	jmp short pgleft3
pgleft1:sub xh,12
	jnb pgleft2
	mov xh,0
pgleft2:call word ptr fill
pgleft3:jmp word ptr begin
	
rmark:	mov al,yh	;oznacenie riadku a stlpca podla riadku F9
	add al,yr
rmark1:	mov si,mrst
	mov [si],al
	mov mrst,offset mr1
	cmp si,offset mr1
	jne rmark2
	mov mrst,offset mr2
rmark2:	call word ptr fill
	jmp word ptr begin
rmark3:	mov al,xh	;nastavenie riadku a stlpca podla stlpca F10
	add al,xr
	jmp short rmark1
rmark4:	mov mr1,7fh
	mov mr2,7fh
	jmp short rmark2
	
delrow:sub ax,ax	;zmazanie jedneho riadku
	mov ah,yh
	add ah,yr
	mov di,ax
	mov cx,128
	mov es,buf
	sub ax,ax
	rep stosw
	call word ptr fill
	jmp dole

delcolum:sub ax,ax
	mov al,xh
	add al,xr
	shl ax,1
	mov di,ax
	mov cx,128
	sub ax,ax
	mov es,buf
delcolum1:stosw
	add di,254
	loop delcolum1
	call word ptr fill
	jmp vpravo
		
	
change:	mov es,buf	;vymena oznacenych riadkov a stlpocov medzi sebou
	sub bx,bx	;vymena riadkov
	mov bh,mr1
	sub ax,ax
	mov ah,mr2
	mov si,ax
	mov di,bx	;je to urobene na klavesu Z, alebo z
	mov cx,128
change1:mov ax,[es:si]
	mov bx,[es:di]
	mov [es:si],bx
	mov [es:di],ax
	inc si
	inc si
	inc di
	inc di
	loop change1
	sub ax,ax	;vymena stlpcov
	mov al,mr1
	shl ax,1
	sub bx,bx
	mov bl,mr2
	shl bx,1
	mov si,ax
	mov di,bx
	mov cx,128
change2:mov ax,[es:si]
	mov bx,[es:di]
	mov [es:si],bx
	mov [es:di],ax
	add si,256
	add di,256
	loop change2
	mov al,mr1	;vymena mien riadkov a stlpcov
	mov bl,5
	mul bl
	add ax,offset rows
	mov si,ax
	mov al,mr2
	mul bl
	add ax,offset rows
	mov di,ax
	mov cx,5
change3:mov al,[es:si]
	mov bl,[es:di]
	mov [es:si],bl	
	mov [es:di],al
	inc si
	inc di
	loop change3
	call word ptr fill
	jmp word ptr begin
	

kantaba:mov ax,buf1	;vymena tabuliek na obrazovke (podporna procedura)
kantaba1:jmp short kantabd1
kantabb:mov ax,buf2
	jmp short kantabd1
kantabc:mov ax,buf3
	jmp short kantabd1
kantabd:mov ax,buf4
kantabd1:call changetab
	jmp word ptr begin
	
kanerrp	proc near	;Osetrenie chyb v programe...
	mov si,offset kanerrt
	call window
	pop si
	mov di,12*160+22
	call zwrite
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
	mov ah,0
	int 22
	call word ptr draw
	jmp word ptr begin
kanerrt:twin 5,9,68,5,4fh
	db ' CHYBOVE HLASENIE ',0
	endp

kansave:mov si,offset kansavet
	call window
	call getfname		;obsluha zapisu tabulky na disk
	jne kansave1
	jmp word ptr begin
kansave1:mov ah,3ch
	mov cx,32
	mov dx,82h
	int 33
	kanerr 'Neda sa otvorit subor !'
	mov handle,ax
	mov bx,ax
	mov ah,40h
	mov cx,offset nr-offset kansaveh+3
	mov dx,offset kansaveh
	int 33
	kanerr 'Neda sa do suboru zapisovat !'
	mov bx,handle
	mov ds,buf
	mov ah,40h
	sub dx,dx
	mov cx,offset zbegin
	int 33
	push cs
	pop ds
	kanerr 'Disk je plny !'
	mov ah,3fh
	mov bx,handle
	int 33
	mov status,0
	mov si,offset kansaveok
	call window
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
	mov ah,0
	int 22
	call word ptr draw
	jmp word ptr begin

kansaveok:twin 22,11,34,3,3fh
	db 13,13,'   Tabulka je ulozena na disku.',0

kansaveh db 'S'+1,'o'+2,'c'+3,'i'+4,'o'+5,'m'+6,' '+7,'v'+8,'.'+9,'2'+10
	db '.'+11,'0'+12,','+13,' '+14,'O'+15,'n'+16,'d'+17,'r'+18,'e'+19
	db 'j'+20,' '+21,'D'+22,'u'+23,'r'+24,'a'+25,'s'+26,' '+27,'('+28
	db 'C'+29,')'+30,' '+31,'1'+32,'9'+33,'9'+34,'6'+35
	db 13,10
	 db 'Tento subor obsahuje tabulku.',13,10
nr	 db 36,13,10
kansavet:twin 5,8,58,3,5fh
	db 13,'            ',1,4fh,'  Zapisanie tabulky do suboru. '
	db 1,5fh,'         ',1,7h,' ->',254,32,1,5fh,13
	db '      Doporucujem pouzivat rozsirenie suboru .TAB .',13
	db '        Ak chces ukoncit tuto opraciu stlac Esc.',0

kanload:mov si,offset kanloadt	;nacitanie tabulky z disku
	call window
	call getfname
	jne kanload1
	jmp word ptr begin
kanload1:mov ax,3d00h
	mov dx,82h
	int 33
	kanerr 'Nemozem otvorit subor !'
	mov handle,ax
	mov bx,ax
	mov ah,3fh
	mov dx,81h
	mov cx,offset nr-offset kansaveh+3
	int 33
	kanerr 'Chyba pri citani zo suboru !'
	push cs
	pop es
	mov si,81h
	mov di,offset kansaveh
	mov cx,offset nr-offset kansaveh+3
	repe cmpsb
	je kanload3
	kanerz 'Tento subor neobsahuje tabulku v pozadovanom tvare !'
kanload2:mov ah,3eh
	mov bx,handle
	int 33
	jmp word ptr begin
kanload3:mov bx,handle
	mov ds,buf
	mov ah,3fh
	mov cx,offset zbegin
	sub dx,dx
	int 33
	push cs
	pop ds
	kanerr 'Chyba pri citani dat zo suboru !'
	cmp ax,offset zbegin
	je kanload4
	kanerz 'Obsah tabulky je poskodeny !'
	jmp short kanload2
kanload4:push cs
	pop es
	mov ds,buf
	mov si,offset zxh
	mov di,offset xh
	mov cx,15
	rep movsb
	push cs
	pop ds
	call word ptr draw
	jmp kanload2
	
kanloadt:twin 5,8,58,3,5fh
	db 13,'            ',1,4fh,'  Nacitanie tabulky zo suboru. '
	db 1,5fh,'         ',1,7h,32,254,'-> ',1,5fh,13
	db '      Doporucujem pouzivat rozsirenie suboru .TAB .',13
	db '        Ak chces ukoncit tuto opraciu stlac Esc.',0
	
kanexp:	mov expprb,offset kanprb	;exportovanie zakladnej matice
	jmp txtexp
kanprb	proc near	;Exportna procedura bunky
	mov ax,'  '	;Tvar zakladnej matice ( X a medzery )
	stosw
	lodsw
	or ax,ax
	mov al,' '
	je kanprb1
	mov al,'X'
kanprb1:stosb
	mov ax,'  '
	stosw
	retn
	endp

kanclear:mov si,offset kancleart	;zmazanie matice klavesou alt+f10
	call window
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
	mov ah,0
	int 22
	cmp ax,2e03h	;ctrl+c
	jne kanclear1
	jmp clearx
kanclear1:call word ptr draw
	jmp word ptr begin
kancleart:twin 14,10,52,3,4fh
	db ' POZOR ! ',13,13
	db '   Ak chces tabulku skutocne zmazat stlac Ctrl+C.',0

;Hlavne premenne ==========================================================
stacks	dw 0c000h	;segment zasobnika
handle	dw 0	;handle suboru
expprb	dw 0c000h	;adresa procedury exportu jednej bunky
buf	dw 0c000h	;ukazuje na jednu z matic
buf1	dw 0c000h	;buffer 1. matice
buf2	dw 0c000h	;buffer 2. matice
buf3	dw 0c000h	;buffer 3. matice
buf4	dw 0c000h	;buffer 4. matice
xh	db 0	;pozicia laveho horneho bodu obrazovky v tabulke
yh	db 10
xr	db 6	;posunutie kurzora voci lavemu hornemu rohu
yr	db 5
mr1	db 10	;riadky a stlpce s danym indexom, ktore maju byt
mr2	db 1	;vymeneme navzajom mediz sebou
begin	dw kanbeg		;adresa zaciatku obsluhy stlacenia klavesu
fill	dw fillkan		;adresa vyplnovacej rutiny
draw	dw drawkan		;adresa rutiny vykreslujucej podklad
help	dw kanhelp		;adresa rutiny helpu
status	db 0	;stav modifikacie tabulky ;0 a 1 -stavy modifikacie
mrst	dw offset mr1	;ukazatel na nasledovne menenu premennu
ednpos	db 0	;x-ova fyz.suradnica pri editacii mien stlpcov a riadkov
default	db  0,0,0,0,127,127
	dw asbeg,asfill,drawkan,ashelp
	db 0,'A','NONAME_A.TAB',0
;standardne vyplnenie
;Pracovne procedury --------------------------------------------------
kanhelp:mov si,offset kanhelpt
	call helpp
	jmp kanbeg
kanhelpt:twin 0,1,78,21,1fh
	db ' MANUAL ',13,13
	db '    ',1,4fh,' Esc ',1,1fh,'  Ukoncenie programu',0
	db 0

helpp	proc near
	call window
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
helpp1:	sub bx,bx
	mov ax,3
	int 51
	or bx,bx
	jne helpp2
	mov ah,1
	int 22
	jz helpp1
	mov ah,0
	int 22
helpp2:	sub bx,bx
	mov ax,3
	int 51
	or bx,bx
	jne helpp2
	call word ptr draw
	retn
	endp


txtexp:	mov si,offset kanexpst	;export tabulky do textoveho suboru
	call window		;procedura
	mov ah,2
	mov bh,0
	mov dx,0c3dh
	int 16
	mov al,yh
	add al,yr
	inc al
	mov kanexps,al
kanexp4:sub  ax,ax
	mov al,kanexps
	call pdec
	mov si,offset 83h
	mov di,12*160+118
	call zwrite
	mov ah,0
	int 22
	cmp al,8
	jne kanexp5
	sub ax,ax
	mov al,kanexps
	mov bl,10
	div bl
	mov kanexps,al
	jmp short kanexp4
kanexp5:cmp al,13
	je kanexp8
	cmp al,27
	jne kanexp7
kanexp6:call word ptr draw
	jmp word ptr begin
kanexp7:cmp al,'0'
	jb kanexp4
	cmp al,'9'
	ja kanexp4
	sub al,'0'
	mov dl,al
	mov bl,10
	mov ah,0
	mov al,kanexps
	mul bl
	add al,dl
	cmp ax,128
	ja kanexp4
	mov kanexps,al
	jmp short kanexp4
kanexp8:call word ptr draw
	mov word ptr par+1,'rp'
	mov word ptr par+3,'n'
	mov si,offset kanexpt
	call window
	call filename
	call word ptr draw
	cmp par+1,0
	jne kanexp0
	jmp word ptr begin
kanexp0:cmp word ptr par+1,'rp'
	jne kanexp3
	cmp word ptr par+3,'n'
	jne kanexp3
	mov ah,2
	sub dx,dx
	int 17h
	test al,64
	jne kanexp1
	kanerz 'Tlaciaren nieje pripojena !'
kanexp1:test ah,1
	je kanexp2
	kanerz 'Tlaciaren sa neozyva !'
kanexp2:test ah,32
	je kanexp3
	kanerz 'V tlaciarni nieje papier !'
	
kanexp3:cmp kanexps,2
	jnb kanexp9
	mov kanexps,2
kanexp9:mov ah,0
	mov al,kanexps
	shl ax,1
	add ax,41
	mov kanexpw,ax
	
	mov si,offset kanexpt1
	call window
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
	mov ah,48h
	mov bx,66
	int 33
	kanerr 'Malo pamete !'
	mov kanexpb,ax
	mov ah,3ch
	mov cx,0
	mov dx,82h
	int 33
	kanerr 'Subor nieje mozne vytvorit !'
	mov handle,ax
	mov es,kanexpb		;zapis prveho riadku tabulky
	cld
	sub di,di	
	mov al,'É'
	stosb
	mov cx,5
	mov al,'Í'
	rep stosb
	mov al,'Ë'
	stosb
	mov ax,'ÑÍ'
	mov cx,word ptr kanexps
	rep stosw
	dec di
	mov al,'Ë'
	stosb
	mov cx,31
	mov al,'Í'
	rep stosb
	mov al,'»'
	stosb
	mov ax,0a0dh
	stosw
	call kanexpz
	mov si,offset kanexptr0	;1. az 5. riadok s menom +bocne sumacie
	mov cx,7
	rep movsb
	mov si,offset rows
	mov bx,offset kanexptr2
	call kanexpprh	
	mov si,offset kanexptr0
	mov cx,7
	rep movsb
	mov si,offset rows+1
	mov bx,offset kanexptr3
	call kanexpprh	
	mov si,offset kanexptr1
	mov cx,7
	rep movsb
	mov si,offset rows+2
	mov bx,offset kanexptr4
	call kanexpprh	
	mov si,offset kanexptr0
	mov cx,7
	rep movsb
	mov si,offset rows+3
	mov bx,offset kanexptr5
	call kanexpprh	
	mov si,offset kanexptr0
	mov cx,7
	rep movsb
	mov si,offset rows+4
	mov bx,offset kanexptr6
	call kanexpprh	
	mov al,'Ì'		; 7. (posledny horny) riadok
	stosb
	mov al,'Í'
	mov cx,5
	rep stosb
	mov al,'Î'
	stosb
	mov cx,word ptr kanexps
	mov ax,'ØÍ'
	rep stosw
	dec di
	mov al,'Î'
	stosb
	mov cx,8
kanexp10:mov ax,'ÍÍ'
	stosw
	mov ax,'ØÍ'
	stosw
	loop kanexp10
	dec di
	mov al,'¹'
	stosb
	mov ax,0a0dh
	stosw
	call kanexpz

	mov cx,word ptr kanexps		;zaciatok vonkajsieho cyklu hl.casti
	mov si,offset rows
	sub bx,bx
	mov dl,0
kanexp11:push cx bx si dx
	mov ds,buf
	mov al,'º'
	stosb
	mov cx,5
	rep movsb
	mov al,'º'
	stosb
	mov si,bx
	mov cx,word ptr cs:kanexps
kanexp12:call word ptr cs:[expprb]
	mov al,'³'
	stosb
	loop kanexp12
	dec di
	mov al,'º'
	stosb
	mov ah,dl
	push di		;vypis sumacii   ;mxcdk
	push cs
	pop ds
	push buf
	push ax
	mov ax,expseg
	mov buf,ax
	pop ax
	call mccount
	pop buf
	pop di
	mov cx,8
	mov si,offset mcxdk
kanexp13:sub ax,ax
	lodsb
	push si di
	call pdec
	pop di
	mov es,kanexpb
	mov si,83h
	movsw
	movsb
	pop si
	mov al,'³'
	stosb
	loop kanexp13
	dec di
	mov al,'º'
	stosb
	call kanexpz
	pop dx si bx cx		;push cx bx si dx
	add si,5
	add bx,256
	inc dl
	loop kanexp11
	mov al,'È'		;posledny (zaverecny) riadok
	stosb
	mov al,'Í'
	mov cx,5
	rep stosb
	mov al,'Ê'
	stosb
	mov cx,word ptr kanexps
	mov ax,'ÏÍ'
	rep stosw
	dec di
	mov al,'Ê'
	stosb
	mov cx,8
kanexp14:mov ax,'ÍÍ'
	stosw
	mov ah,'Ï'
	stosw
	loop kanexp14
	dec di
	mov al,'¼'
	stosb
	call kanexpz

kanexpkon:mov ah,3eh	;ukoncenie exportu 
	mov bx,handle	;( uzatvorenie pridelenej pamete,suboru, zmazanie obr...)
	int 33
	mov ah,49h
	mov es,kanexpb
	int 33
	call word ptr draw
	mov si,offset kanexpt2
	call window
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
	mov ah,0
	int 22
	call word ptr draw
	jmp word ptr begin
	
kanexpz	proc near		;zapis dat z buffera
	mov ah,40h
	mov bx,handle
	sub dx,dx
	mov cx,kanexpw
	mov ds,kanexpb
	int 33
	push cs
	pop ds
	mov es,kanexpb
	sub di,di
	kanerr 'Chyba pri zapise na disk !'
	retn
	endp
kanexpprh proc near	;procedura vypisu  jedneho z piatich hornych riadkov
	mov ah,'³'	;procedura riadku
	mov cx,word ptr kanexps
	mov ds,buf
kanexpprh1:lodsb	;vstup SI=offset ROWS+index znaku
	add si,4
	stosw
	loop kanexpprh1
	push cs
	pop ds
	dec di
	mov si,bx
	mov cx,33
	rep movsb
	call kanexpz
	retn
	endp
expseg	dw 0c000h	;segment odkial budu do exportu brane sumacie
kanexpw	dw 0	;sirka zapisovanych dat v buffry exportu
kanexpb	dw 0c000h	;buffer pre pre export
kanexps	db 12	;sirka a vyska exportovanej tabulky
	db 0
kanexptr0 db 'º     º' ;7B
kanexptr1 db 'ºMENO º' ;7B
kanexptr2 db 'º            SUMACIA            º'
kanexptr3 db 'ÇÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ¶'
kanexptr4 db 'º    DAL    ³  DOSTAL   ³VZAJOMNº'
kanexptr5 db 'ÇÄÄÄÂÄÄÄÂÄÄÄÅÄÄÄÂÄÄÄÂÄÄÄÅÄÄÄÂÄÄÄ¶'
kanexptr6 db 'º + ³ - ³ ä ³ + ³ - ³ ä ³ + ³ - º'
kanexpst:twin 17,10,49,3,3fh
	db 13,13,'    Sirka a vyska exportovanej tabulky: ',1,4fh,'     ',0
kanexpt1:twin 25,10,27,3,5fh
	db 13,13,'   Exportujem tabulku...',0
kanexpt2:twin 24,10,29,3,3fh
	db 13,13,'   Tabulka je exportovana.',0
kanexpt:twin 5,7,58,4,5fh
	db 13,'          ',1,4fh,'  Export tabulky do textoveho suboru. '
	db 1,5fh,13
	db '    Ak chces tabulku vytlacit stlac iba ENTER, inak',13
	db '      doporucujem pouzivat rozsirenie suboru .TXT .',13
	db '        Ak chces ukoncit tuto opraciu stlac Esc.',0




getfname proc near	;ziskanie mena suboru
	push cs		;jeho pripadne nastavenie v tabulke
	pop es
	mov ds,buf
	mov si,offset meno
	mov di,82h
	mov cx,100
	rep movsb
	push cs
	pop ds
	call filename
	cmp par+1,0
	pushf
	je getfname1
	mov es,buf
	mov si,82h
	mov di,offset meno
	mov cx,100
	rep movsb
getfname1:mov ax,buf
	call changetab
	popf
	retn
	endp
		
changetab proc near	;vymeni aktivnu tabulku
	push ax		;vstup ax=seg adresa novej tabulky
	mov es,buf
	mov buf,ax
	assume ds:buffer
	mov di,offset zxh
	mov si,offset xh
	assume ds:prog
	mov cx,15
	rep movsb
	push cs
	pop es
	pop ds
	assume ds:buffer
	mov si,offset zxh
	mov di,offset xh
	assume ds:prog
	mov cx,15
	rep movsb
	push cs
	pop ds
	call word ptr draw
	retn
	endp

clearm	proc near	;zmazanie buffera matice
	mov mr1,127
	mov mr2,127
	mov xh,0
	mov yh,0
	mov xr,0
	mov yr,0
	mov es,buf
	sub di,di
	mov cx,128*128+64*5
	sub ax,ax
	rep stosw
	mov si,offset default
	mov cx,29
	rep movsb
	retn
	endp

clearx:	mov mr1,127	;zmazanie buffera matice pri stlaceni klavesy
	mov mr2,127
	mov xh,0
	mov yh,0
	mov xr,0
	mov yr,0
	mov es,buf
	sub di,di
	mov cx,128*128+64*5
	sub ax,ax
	rep stosw
	mov si,offset default
	mov cx,15
	rep movsb
	push cs
	pop es
	mov si,offset default
	mov di,offset xh 
	mov cx,15
	rep movsb
	call word ptr draw
	jmp word ptr begin

fillname proc near	;vypis horneho a dolneho riadku
	mov es,vram	;horny fialovy riadok
	sub di,di
	mov cx,80
	mov ax,5f20h
	rep stosw
	mov ds,buf	;meno suboru
	mov di,2
	assume ds:buffer
	mov si,offset meno
	call zwrite
	mov al,char	;znak matice
	assume ds:prog
	push cs
	pop ds
	mov es,vram
	assume es:nothing
	mov byte ptr [es:156],al
	assume es:prog
	mov di,24*160
	push di
	mov cx,80
	mov ax,5f20h
	rep stosw
	pop di
	mov si,offset ahoj
	call zwrite
	retn
ahoj	db ' ','S'+1,'o'+2,'c'+3,'i'+4,'o'+5,'m'+6,' '+7,'v'+8,'.'+9
	db '2'+10,'.'+11,'0'+12,','+13,' '+14,'O'+15,'n'+16,'d'+17
	db 'r'+18,'e'+19,'j'+20,' '+21,'D'+22,'u'+23,'r'+24,'a'+25,'s'+26
	db '                            < Manual-F1,Koniec-Esc >',0
	endp
	
chrs	proc near
	mov es,vram
chrs1:	lodsb
	or al,al
	jne chrs2
	retn
chrs2:	cmp al,255	;zaciatok cykly "for"
	jne chrs3
	lodsb
	sub cx,cx
	mov cl,al
	push si cx
	jmp short chrs1
chrs3:	cmp al,254	;koniec cyklu "next"
	jne chrs5
	mov bx,si
	pop cx si
	loop chrs4
	mov si,bx
	jmp short chrs1
chrs4:	push si cx
	jmp short chrs1
chrs5:	sub cx,cx
	mov cl,al
	lodsw
	rep stosw
	jmp short chrs1
	endp
	

fillrc	proc near	;vyplnenie mien riadkov a stlpcov
	mov es,vram
	mov si,offset rows
	sub ax,ax
	mov al,xh
	mov bl,5
	mul bl
	add si,ax
	mov ds,buf
	mov dl,12
	mov di,336
	mov ah,1eh
fillrc1:mov cx,5
fillrc2:lodsb
	stosw
	loop fillrc2
	inc di
	inc di
	dec dl
	jnz fillrc1
	mov si,offset rows
	sub ax,ax
	mov al,cs:yh
	mov bl,5
	mul bl
	add si,ax
	mov di,642
	mov dl,19
	mov ah,1eh
fillrc3:mov cx,5
	mov al,' '
	stosw
fillrc4:lodsb
	stosw
	loop fillrc4
	add di,148
	dec dl
	jnz fillrc3
	push cs
	pop ds
	retn
	endp
	
fillkan	proc near
	call fillrc
	mov es,vram
	mov di,656
	sub ax,ax	;vypocet adresy zdorja
	mov al,xh
	shl ax,1
	add ah,yh
	mov si,ax
	mov ds,buf
	mov dl,19
fillkan2:mov cx,12
fillkan3:lodsw
	cmp ax,1
	mov ax,1f20h
	stosw
	stosw
	jne fillkan4
	mov ax,1f58h
fillkan4:stosw
	mov ax,1f20h
	stosw
	stosw
	inc di
	inc di
	loop fillkan3
	add di,16
	add si,232
	dec dl
	jnz fillkan2
	push cs
	pop ds
	call fillin
	retn
	endp
	
fillin	proc near	;vyznacenie diagonaly a oznacenych riadkov na obr.
	mov es,vram
	mov si,offset mr1
	call fillinn
	mov si,offset mr2
	call fillinn
	
	mov al,yh
	cmp al,xh
	ja filli3
	add al,18
	cmp al,xh
	jb filli3	;ak diagonala nepretina lavy roh potom preskoc
	mov al,xh
	sub al,yh
	sub dx,dx
	mov dl,12
	cmp al,7
	jb filli6
	mov dl,19
	sub dl,al
filli6:	mov bl,160
	mul bl
filli5:	add ax,657
	mov di,ax
	mov al,2fh	;farba diagonaly
filli1:	mov cx,5
filli2:	stosb
	inc di
	loop filli2
	add di,162
	dec dl
	jnz filli1
filli4:	retn
filli3: mov al,xh
	cmp al,yh
	ja filli4
	add al,11
	cmp al,yh
	jb filli4
	mov al,yh
	sub al,xh
	sub dx,dx
	mov dx,12
	sub dl,al
	mov bl,12
	mul bl
	jmp short filli5
	

fillinn proc near
	mov al,[si]
	mov ah,xh
	cmp al,ah
	jb fillin4	;preskok
	sub al,ah
	cmp al,11
	ja fillin4
	mov ah,0
	mov bl,12
	mul bl
	
	add ax,657
	mov di,ax
	mov al,6eh
	mov dl,19
	inc al
fillin2:mov cx,5
fillin3:stosb
	inc di
	loop fillin3
	add di,150
	dec dl
	jnz fillin2
fillin4:mov al,[si]
	mov ah,yh
	cmp al,ah
	jb fillin8
	sub al,ah
	cmp al,18
	ja fillin8
	mov bl,160
	mul bl
	add ax,655
	mov di,ax
	mov al,6fh
	mov dl,12
fillin6:mov cx,5
	inc di
	inc di
fillin7:stosb
	inc di
	loop fillin7
	dec dl
	jnz fillin6	 	
fillin8:retn
	endp
	endp

cursorf	proc near	;vyplni kurzor pozadovanou farbou
	mov es,vram	;vtup dl=farba kurzora...
	cld
	mov al,xr
	mov bl,12
	mul bl
	add ax,337
	mov di,ax		
	mov al,dh
	dec al
	mov cx,5
cursorf1:stosb
	inc di
	loop cursorf1
	mov al,yr
	mov bl,160
	mul bl
	add ax,643
	mov di,ax
	mov cx,6
	mov al,dh
	dec al
cursorf2:stosb
	inc di
	loop cursorf2
	mov al,yr
	mul bl
	mov di,ax
	mov al,xr
	mov bl,12
	mul bl
	add di,ax
	add di,657
	mov al,dl
	mov cx,5
cursorf3:stosb
	inc di
	loop cursorf3
	retn
	endp
cursorp	db 2	;posunutie bikacieho kurzora v bunke kurzora

cursoron proc near	;zobrazi kurzor
	sub ax,ax	;vypis pozicie kurzora
	mov al,xh
	add al,xr
	call pdec
	mov di,138
	mov si,83h
	call zwrite
	sub ax,ax
	mov al,yh
	add al,yr
	call pdec
	mov si,83h
	mov di,146
	call zwrite

	mov dx,4f4fh	;samotne vykreslenie kurzora
	call cursorf
	mov al,xr
	mov bl,6
	mul bl
	add al,8
	add al,cursorp
	mov dl,al
	mov dh,yr
	add dh,4
	mov bh,0
	mov ah,2
	int 16
	retn
	endp
	
cursoroff proc near
	mov dx,1f1fh
	mov al,xh
	add al,xr
	mov ah,yh
	add ah,yr
	cmp al,mr1
	je cursoroff1
	cmp ah,mr1
	je cursoroff1
	cmp al,mr2
	je cursoroff1
	cmp ah,mr2
	jne cursoroff2
cursoroff1:mov dx,1f6fh
cursoroff2:cmp al,ah
	jne cursoroff3
	mov dl,2fh
cursoroff3:call cursorf
	retn
	endp
	
drawkan	proc near
	call fillname
	mov si,offset drawkant
	mov di,160
	call chrs
	call word ptr fill
	retn
	endp

drawkant db 1,'É',1eh, 6,205,1eh, 1,203,1eh	;prvy riadok
	db  255,11, 5,205,1eh, 1,209,1eh, 254
	db 5,205,1eh, 1,'»',1eh
	
	db 1,'º',1eh, 6,' ',1eh, 1,'º',1eh	;druhy riadok
	db 255,11, 5,' ',1eh, 1,'³',1eh, 254, 5,' ',1eh, 1,'º',1eh
	
	db 1,204,1eh, 6,205,1eh, 1,206,1eh	;treti riadok
	db 255,11, 5,205,1eh, 1,216,1eh, 254, 5,205,1eh, 1,185,1eh

	db 255,19	;dalsich 19 riadkov
	db 1,'º',1eh, 6,' ',1eh, 1,'º',1eh
	db 255,11, 5,' ',1fh, 1,'³',1eh, 254, 5,' ',1fh, 1,'º',1eh
	db 254	
	db 1,'È',1eh, 6,205,1eh, 1,'Ê',1eh
	db 255,11, 5,205,1eh, 1,'Ï',1eh, 254, 5,205,1eh, 1,'¼',1eh	
	db 0
	
edn:	mov ednpos,0
edn1:	call cursoron	;editacia mien riadkkov a stlpcov
	mov help,offset ednhelp
	mov ax,1
	int 51
	mov ah,2
	mov bh,0
	mov dh,yr
	add dh,4
	mov dl,ednpos
	add dl,2
	int 16

edn5:	sub bx,bx
	mov ax,3
	int 51
	or bx,bx
	je edn4
	jmp mouse	
edn4:	mov ah,1
	int 22
	jz edn5
	mov ah,0
	int 22

	push ax
	mov ax,2
	int 51
	call cursoroff
	pop ax
	mov si,offset edntab
	mov bx,ax
edn2:	lodsw
	or ax,ax
	je edn3
	mov dx,ax
	lodsw
	cmp dx,bx
	jne edn2
	jmp ax
edn3:	mov es,buf
	mov cl,5
	sub ax,ax
	mov al,yh
	add al,yr
	mul cl
	add al,ednpos
	adc ah,0
	add ax,offset rows
	mov di,ax
	mov al,bl
	mov status,1
	stosb
	call fillrc
	cmp ednpos,4
	jnb edn6
	inc ednpos
edn6:	jmp edn1
	
edntab	dw 4d00h,ednrc ,4b00h,ednlc,4800h,ednuc,5000h,edndc,0e08h,ednbak
	dw 4700h,ednhome,1519h,ednclr,1c0dh,ednnewl
	dw 7800h,edntaba,7900h,edntabb,7a00h,edntabc,7b00h,edntabd
	dw 4900h,ednpup,5100h,ednpdn
	dw 0f09h,ednbegin,3b00h,ednhelp,011bh,koniec
	dw 3c00h,ednsave,3d00h,ednload,3e00h,ednexp
	dw 0	;zakoncovak
ednbegin:jmp word ptr begin	;navrat do editacie tabulky
ednrc:	cmp ednpos,4	;posuny kurzora vlavo a vpravo
	jnb ednrc1
	inc ednpos
ednrc1:	jmp edn1
ednlc:	cmp ednpos,0
	je ednrc1
	dec ednpos
	jmp short ednrc1
ednhome:mov ednpos,0
	jmp short ednrc1
ednsave:mov ax,offset kansave	;praca s diskom
	jmp short edndc1
ednload:mov ax,offset kanload
	jmp short edndc1
ednexp:	mov ax,offset kanexp
	jmp short edndc1
ednuc:	mov ax,offset hore	;posuvy kurzora hore a dole
	jmp short edndc1
ednpup:	mov ax,offset pguphome
	jmp short edndc1
ednpdn:	mov ax,offset pgdown
	jmp short edndc1
edndc:	mov ax,offset dole
edndc1:	push begin
	mov begin,offset edndc2
	jmp ax
edndc2:	pop begin
	jmp short ednrc1
ednnewl:mov ednpos,0	;precod na novy riadok
	jmp short edndc
ednclr:	mov ednpos,0	;zmazanie mena riadku a stlpca
	mov es,buf
	mov al,yh
	add al,yr
	mov bl,5
	mul bl
	add ax,offset rows
	mov di,ax
	sub ax,ax
	stosw
	stosw
	stosb
	call fillrc
	jmp short edndc
	
edntaba:mov ax,buf1	;vymeny tabuliek na obrazovke
	jmp short edntabd1
edntabb:mov ax,buf2
	jmp short edntabd1
edntabc:mov ax,buf3
	jmp short edntabd1
edntabd:mov ax,buf4
edntabd1:mov ednpos,0
	call changetab
	jmp edn1

ednbak:	mov al,yh
	add al,yr
	mov bl,5
	mul bl
	add ax,offset rows
	add al,ednpos
	adc ah,0
	mov di,ax
	mov es,buf
	mov al,0
	stosb
	cmp ednpos,0
	jne ednbak2
ednbak1:call fillrc
	jmp edn1
ednbak2:dec ednpos
	dec di
	dec di
	stosb
	jmp short ednbak1
	
ednhelp:mov si,offset ednhelpt
	call helpp
	jmp edn1	;help pre editaciu mien riadkov a stlpcov

ednhelpt:twin 0,1,78,21,1fh
	db ' MANUAL ',13,13
	db '        ',1,4fh,' TAB ',1,1fh,'  Prepnutie do vyplne tabulky'
	db 0


mouse:	mov ax,3	;obsluha mysi pri stlaceni tlacitka
	int 51		;Moze byt pouzivana pri vsetkych obsluhach
	or bx,bx	;stlacenia klavesy, ktorych zaciatok sa uvadza
	jne mouse	;v premennej begin.
	push cx dx
	mov ax,2
	int 51
	call cursoroff
	pop dx cx
	mov bx,cx
	mov cl,3
	shr bx,cl
	shr dx,cl
	mov bh,dl
	mov si,offset mousetab
mouse1:	lodsw
	or ax,ax
	jne mouse2
	jmp word ptr begin	
mouse2:	mov cx,ax
	lodsw
	mov dx,ax
	lodsw
	add ax,dx
	cmp bl,dl
	jnb mouse3
	jmp short mouse1
mouse3:	cmp bh,dh
	jb mouse1
	cmp bl,al
	ja mouse1
	cmp bh,ah
	ja mouse1
	jmp cx
	
mousetab  dw moubeep,184eh,00001h ;sirka a vyska su vzdy o jedno mensie
	dw koniec,1843h,0009h	;67 23 5 0
 	dw mougoto,0408h,1246h	;tabulka funkcii obsluhovanych mysou
 	dw mednon,0402h,1204h
 	dw mhelp,183ah,0007h	;Pozor !!! Tieto funkcie su spolocne pre
 	dw pgdown,1808h,71	; pre vsetky rezimy editacie
 	dw pguphome,0108h,71
 	dw pgright,0249h,0005h
 	dw pgleft,0208h,0005h
 	dw dole,1708h,71
 	dw hore,0308h,71
	dw vpravo,044fh,1300h
	dw vlavo,0407h,1300h
	dw home,0400h,1300h
 	dw mchanget,0,65
	dw 0
moubeep:mov ah,2
	mov dl,7
	int 33
	jmp word ptr begin

mougoto:sub bh,04	;presun kurzora mysou
	sub bl,08
	mov yr,bh
	sub ax,ax
	mov al,bl
	mov bl,6
	div bl
	mov xr,al
	jmp word ptr begin
	
mednon:	sub bl,2
	mov ednpos,bl
	sub bh,4
	mov yr,bh
	jmp edn1
mhelp:	jmp word ptr help

mchanget:mov bx,buf		;vymena tabuliek mysou
	mov si,offset buf1
	mov cx,4
mchanget1:lodsw
	cmp ax,bx
	loopne mchanget1
	cmp si,offset buf4+2
	jne mchanget2
	mov si,offset buf1
mchanget2:lodsw
	call changetab
	jmp word ptr begin
	
;------------------------------------------------------------------------
; pezeranie a usporiaddanie matice v +/- tvare
;------------------------------------------------------------------------
asgent1:twin 20,10,40,3,5fh
	db 13,13,'   Generujem tabulku vstahov (+/-)...',0
asgen:	mov es,buf3	;generovanie +/- tabulky
	sub ax,ax	;tab.C=fn(tab.A,tab.B)
	mov di,ax	;tab.A pozitivne vstahy,B negativne,C +/- tab.
	mov cx,128*128+64*5
	repe scasw
	je asgen2
	kanerz 'Tabulka C musi byt pred generovanim prazdna ! (Alt+F10)'	
asgen2:	mov es,buf1	;su v tabulkach rovnake mena ?
	mov ds,buf2
	mov si,offset rows
	mov di,si
	mov cx,64*5
	repe cmpsw
	je asgen9
	push cs
	pop ds
	kanerz 'Tabulky A a B sa nevstahuju k jednej socialnej skupine !'
asgen9:	mov es,cs:buf3	;Kopirovanie mien do tab.C
	mov si,offset rows
	mov di,si
	mov cx,64*5
	rep movsw
	push cs
	pop ds
	
	mov si,offset asgent1
	call window
	mov si,2		;zaciatok samotneho zlucovania
	mov cx,127
asgen3:	push cx si	;zaciatok vonkajsieho cyklu
	mov di,si
	add di,254
asgen4:	mov ax,0fffh	;zaciatok vnutorneho cyklu
	mov bx,0fffh
	mov es,buf1	;test >+ ?
	cmp word ptr es:[si],0
	je asgen5
	or ax,1fffh
	or bx,4fffh
asgen5:	cmp word ptr es:[di],0	;test +> ?
	je asgen6
	or ax,4fffh
	or bx,1fffh
asgen6:	mov es,buf2	;test >- ?
	cmp word ptr es:[si],0
	je asgen7
	or ax,2fffh
	or bx,8fffh
asgen7:	cmp word ptr es:[di],0	;test -> ?
	je asgen8
	or ax,8fffh
	or bx,2fffh
asgen8:	mov es,buf3
	mov es:[si],ax
	mov es:[di],bx
	inc si
	inc si
	add di,256
	loop asgen4	;koniec vnutorneho (riadkoveho) cyklu
	pop si cx
	add si,258
	loop asgen3	;koniec vonkajsieho (stlpcoveho) cyklu
	
	mov ax,buf3
	call changetab
	mov begin,offset asbeg	;prepnutie do tabulky C a jej rezimu +/-
	mov draw,offset drawkan
	mov fill,offset asfill	;a pokracujeme dalej asbeg4
	

asbeg4:	mov begin,offset asbeg		;vstupny bod pri prepinani
	mov draw,offset drawkan		;tabulky do rezimu (+/-)
	mov fill,offset asfill		;napriklad z rezimu kan.
	call word ptr draw ;obsluha klavesnice pri editacii matice v kanonickom
	call word ptr fill	;tvare
	sub ax,ax
	int 51
asbeg:	mov cursorp,2
	call cursoron	;zaciatok obsluzneho cyklu
	mov ax,1
	int 51
	mov help,offset ashelp
	
asbeg3:sub bx,bx
	mov ax,3	;obsluha klavesnice
	int 51		;pri editacii dat v matici
	or bx,bx
	je asbeg2
	jmp mouse
asbeg2:mov ah,1
	int 22
	jz asbeg3
	mov ah,0
	int 22
	
	push ax
	mov ax,2
	int 51
	call cursoroff
	pop ax
	mov dx,ax
	mov si,offset astab
asbeg1:lodsw
	or ax,ax
	jz asbeg
	mov bx,ax
	lodsw
	cmp bx,dx
	jne asbeg1
	jmp ax

astab	dw 4d00h,vpravo ,4b00h,vlavo,4800h,hore,5000h,dole,0e08h,vlavo ;right,left,up,down,backspace
	dw 4700h,home,4900h,pguphome ;home,pgup
	dw 4300h,rmark,4400h,rmark3,5300h,rmark4 ;f9,f10,del
	dw 1519h,delrow,1615h,delcolum,4200h,change ;ctrl+y,ctrl+u,f8
	dw 7800h,kantaba,7900h,kantabb,7a00h,kantabc,7b00h,kantabd ;alt+1 az 4
	dw 5100h,pgdown,7400h,pgright,7300h,pgleft ;pgdn,ctrl+right,ctrl+left
	dw 0f09h,edn,3b00h,ashelp,011bh,koniec	;tab,f1,esc
	dw 3c00h,kansave,3d00h,kanload,3e00h,asexp ;f2,f3,f4
	dw 3f00h,ctbeg4		;f5 prepnutie rezimu editacie
	dw 7100h,kanclear	;alt+f10 zmaz tabulku
	dw 4e2bh,asadd,4a2dh,assub,3920h,asdel	;+ - space
	dw 0c2dh,assub,0d2bh,asadd,0d3dh,asadd	;- + +
	dw 1c0dh,asnl,372ah,asmc ;enter *
	dw 0938h,asmc,092ah,asmc ;* *
	dw 1900h,ctgen	;generovanie spolupatricnosti alt+p
	dw 0	;zakoncovak

;treba tieto casti asexp,asfill,ashelp
ashelp:mov si,offset ashelpt	;help ku +/- prezeracej casti programu
	call helpp
	jmp asbeg
ashelpt:twin 0,1,78,21,1fh
	db ' MANUAL ',13,13
	db '  ',1,4fh,' Esc ',1,1fh,' Ukoncenie programu        '
	db 1,5fh,' F2 ',1,1fh,'  Zapis tabulky na disk',13
	db '  ',1,4fh,' F1  ',1,1fh,' Tato pomocna obrazovka    '
	db 1,5fh,' F3 ',1,1fh,'  Citanie tabulky na disk',13
	db '                                  '
	db 1,5fh,' F4 ',1,1fh,'  Export do textoveho suboru',13
	db '  ',1,3fh,' + ',1,1fh,'   Zapis kladneho vyberu',13
	db '  ',1,3fh,' - ',1,1fh,'   Zapis zaporneho vyberu  '
	db '  ',1,2fh,' F8  ',1,1fh,' Vymena oznacenych riadkov a stlpcov',13
	db '  ',1,3fh,' # ',1,1fh,'   Vzajomny kladny (auto.) '
	db '  ',1,2fh,' F9  ',1,1fh,' Oznacenie riadku ( a stlpca )',13
	db '  ',1,3fh,' ! ',1,1fh,'   Vzajomny zaporny (auto.)'
	db '  ',1,2fh,' F10 ',1,1fh,' Oznacenie stlpca ( a riadku )',13
	db '  ',1,3fh,' TAB ',1,1fh,' Stlpec nahradnych mien  '
	db '  ',1,2fh,' DEL ',1,1fh,' Zmazanie oznacenia',13
	db '  ',1,3fh,' MEDZERA ',1,1fh,' Zmazanie vyberu',13
	db '  ',1,3fh,' * ',1,1fh,'   Zistenie suctov      '
	db 1,4fh,' Alt+1 az Alt+4 ',1,1fh,' Prepinanie aktualnej tabulky',13,13
	db '  ',1,6fh,' Ctrl+Y ',1,1fh,'  Zmazanie riadku',13
	db '  ',1,6fh,' Ctrl+U ',1,1fh,'  Zmazanie stlpca',13
	db '  ',1,6fh,' Alt+F10 ',1,1fh,' Zmazanie tabukly',13
	db '  ',1,6fh,' Alt+P ',1,1fh,'  Znazornenie sprostredkovanych vazieb'
	db 0

asexp:	mov expprb,offset asprb	;exportovanie +/- matice
	jmp txtexp
asprb	proc near	;Exportna procedura bunky v +/- tvare
	push bx cx
	mov ax,cs:buf
	mov cs:expseg,ax
	lodsw
	mov cl,12
	shr ax,cl
	mov bx,ax
	mov al,cs:[bx+astzns]
	stosb
	pop cx bx
	retn
	endp
	
;	mov ax,'  '	;Tvar zakladnej matice ( X a medzery )
;	stosw
;	lodsw
;	or ax,ax
;	mov al,' '
;	je kanprb1
;	mov al,'X'
;kanprb1:stosb
;	mov ax,'  '
;	stosw
;	retn
;	endp

astzns	db ' ' ;0	0fffh  ;0>0	0=pasivny vstah
	db '+' ;1	1fffh  ;+>0	+=pozitivny vstah
	db '-' ;2	2fffh  ;->0	-=negativny vstah
	db ' ' ;3	3fffh  ;+->0
	db ' ' ;4	4fffh  ;0>+	bity: (ak sa rovnaju 1)
	db '#' ;5	5fffh  ;+>+	0 (1)- pozitivny vyberajuci +>
	db '-' ;6	6fffh  ;->+	1 (2)- negativny vyberajuci ->
	db ' ' ;7	7fffh  ;+->+	2 (4)- pozitivny vyberany   >+
	db ' ' ;8	8fffh  ;0>-	3 (8)- negativny vyberany   >-
	db '+' ;9	9fffh  ;+>-
	db '!' ;10	afffh  ;->-
	db ' ' ;11	bfffh  ;+->-
	db ' ' ;12	cfffh  ;0>+-
	db ' ' ;13	dfffh  ;+>+-
	db ' ' ;14	efffh  ;->+-
	db ' ' ;15	ffffh  ;+->+-
	
astzn	db '     ' ;0	0fffh  ;0>0	0=pasivny vstah
	db '  +  ' ;1	1fffh  ;+>0	+=pozitivny vstah
	db '  -  ' ;2	2fffh  ;->0	-=negativny vstah
	db '     ' ;3	3fffh  ;+->0
	db '     ' ;4	4fffh  ;0>+	bity: (ak sa rovnaju 1)
	db '  #  ' ;5	5fffh  ;+>+	0 (1)- pozitivny vyberajuci +>
	db '  -  ' ;6	6fffh  ;->+	1 (2)- negativny vyberajuci ->
	db '     ' ;7	7fffh  ;+->+	2 (4)- pozitivny vyberany   >+
	db '     ' ;8	8fffh  ;0>-	3 (8)- negativny vyberany   >-
	db '  +  ' ;9	9fffh  ;+>-
	db '  !  ' ;10	afffh  ;->-
	db '     ' ;11	bfffh  ;+->-
	db '     ' ;12	cfffh  ;0>+-
	db '     ' ;13	dfffh  ;+>+-
	db '     ' ;14	efffh  ;->+-
	db '     ' ;15	ffffh  ;+->+-
astzne	db 'CHYBA' ;lubovolna ina hodnota - detekcia chyboveho stavu
	
asfill	proc near
	call fillrc
	mov es,vram
	mov di,656
	sub ax,ax	;vypocet adresy zdorja
	mov al,xh
	shl ax,1
	add ah,yh
	mov si,ax
	mov ds,buf
	mov dl,19
asfill2:mov cx,12

asfill3:lodsw		;samotne vykreslovanie
	or ax,ax
	je asfill4
	cmp ax,0fffh
	jnb asfill5
	mov bx,offset astzne
	jmp short asfill6
asfill5:rol ax,1
	rol ax,1
	rol ax,1
	rol ax,1
	and ax,0fh
	mov bl,5
	mul bl
asfill4:add ax,offset astzn
	mov bx,ax
asfill6:mov ah,1fh
	mov al,cs:[bx]	;1
	stosw
	inc bx		
	mov al,cs:[bx] ;2
	stosw
	inc bx		
	mov al,cs:[bx] ;3
	stosw
	inc bx		
	mov al,cs:[bx] ;4
	stosw
	inc bx		
	mov al,cs:[bx] ;5
	stosw

	inc di
	inc di
	loop asfill3
	add di,16
	add si,232
	dec dl
	jnz asfill2
	push cs
	pop ds
	call fillin
	retn
	endp

asrcap	proc near ;vypocty adries
	sub ax,ax	;vypocet adresy prvej bunky
	mov al,xh	;na nej je curzor
	add al,xr
	shl ax,1
	add ah,yr
	add ah,yh
	mov si,ax
	sub ax,ax
	mov al,yh	;vypocet adresy druhej bunky
	add al,yr	;podla diagonaly symetricka ku kursoru
	shl ax,1
	add ah,xh
	add ah,xr
	mov di,ax
	mov es,buf
	retn
	endp
	
asadd:	call asrcap	;pridanie plusu
	mov ax,es:[si]
	and ax,0cfffh
	or ax,1fffh
	mov es:[si],ax
	mov ax,es:[di]
	and ax,3fffh
	or ax,4fffh
	stosw
	call word ptr fill
	jmp vpravo
assub:	call asrcap	;pridanie plusu
	mov ax,es:[si]
	and ax,0cfffh
	or ax,2fffh
	mov es:[si],ax
	mov ax,es:[di]
	and ax,3fffh
	or ax,8fffh
	stosw
	call word ptr fill
	jmp vpravo
asdel:	call asrcap	;pridanie plusu
	mov ax,es:[si]
	and ax,0cfffh
	mov es:[si],ax
	mov ax,es:[di]
	and ax,3fffh
	stosw
	call word ptr fill
	jmp vpravo
asnl:	mov xh,0	;presun na zaciatok noveho riadku
	mov xr,0
	call word ptr fill
	jmp dole
	
asmc:	mov si,offset asmct	;vypis parametrov
	call window
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
	mov al,xh		;vypis nahradnynch mien
	add al,xr
	mov bh,yh
	add bh,yr
	mov es,vram
	mov di,7*160+84
	mov bl,5
	mul bl
	add ax,offset rows
	mov si,ax
	mov ds,buf
	mov ah,5fh
	lodsb
	stosw	
	lodsb
	stosw	
	lodsb
	stosw	
	lodsb
	stosw	
	lodsb
	stosw	
	add di,6
	mov al,bh
	mul bl
	add ax,offset rows
	mov si,ax
	mov ah,5fh
	lodsb
	stosw	
	lodsb
	stosw	
	lodsb
	stosw	
	lodsb
	stosw	
	lodsb
	stosw	
	push cs
	pop ds
	mov di,9*160+86
	mov ah,xh
	add ah,xr
	call asmcw
	mov di,9*160+102
	mov ah,yh
	add ah,yr
	call asmcw

	mov ah,0
	int 22
	call word ptr draw
	jmp word ptr begin
	
asmcw	proc near	;vypis jedneho stlpca udajov v tabulke suctov
	push di		;teda podla x-ovej, alebo y-ovej sur.
	call mccount
	pop di
	mov si,offset mcxdk
	call asmcw1
	call asmcw1
	call asmcw1
	add di,160
	call asmcw1
	call asmcw1
	call asmcw1
	add di,160
	call asmcw1
	call asmcw1
	retn
asmcw1:	lodsb
	push si cx di
	mov ah,0
	call pdec
	mov si,83h
	pop di
	push di
	call zwrite
	pop di cx si
	add di,160
	retn
	endp
	
asmct:	twin 22,6,35,12,5fh
	db ' SUCTY ',13
	db '   Nahradne meno ³ XXXXX ³ YYYYY',13
	db ' Ä DAL ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ',13
	db '   Kladne        ³  999  ³  999',13
	db '   Zaporne       ³  999  ³  999',13
	db '   Suma          ³  999  ³  999',13
	db ' Ä DOSTAL ÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ',13
	db '   Kladne        ³  999  ³  999',13
	db '   Zaporne       ³  999  ³  999',13
	db '   Suma          ³  999  ³  999',13
	db ' Ä VZAJOMNE ÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ',13
	db '   Kladne        ³  999  ³  999',13
	db '   Zaporne       ³  999  ³  999',0
;dal ;musia byt takto za sebou ako su tu uvedene - nemenit !
mcxdk	db 0	;sucet vsetkych kladnych hlasov danych
mcxdz	db 0	;sucet vsetkych zapornych hlasov danych
mcxds	db 0	;suma vsetkych danych hlasov kladnych i zapornych
;dostal
mcydk	db 0	;sucet vsetkych kladnych hlasov dostanych
mcydz	db 0	;sucet vsetkych zapornych hlasov dostanych
mcyds	db 0	;sucet vsetkych hlasov dostanych
;vzajomne
mcxvk	db 0	;sucet vsetkych kladnych vzajomnych hlasov
mcxvz	db 0	;sucet vsetkych vzajomnych zapornych hlasov
mccount	proc near	;suctovannie hlasov ;vstup AH=cislo ziaka
	mov al,0
	push cs	;zmazanie suctovych premennych
	pop es
	mov cx,8
	mov di,offset mcxdk
	rep stosb
	mov es,buf
	mov si,ax
	mov cx,128
mccount1:seges lodsw	;suctovanie danych hlasov (riadku)
	test ax,1000h
	je mccount2
	inc mcxdk
	inc mcxds
	test ax,4000h
	je mccount2
	inc mcxvk
mccount2:test ax,2000h
	je mccount3
	inc mcxdz
	inc mcxds
	test ax,8000h
	je mccount3
	inc mcxvz
mccount3:test ax,4000h
	je mccount4
	inc mcyds
	inc mcydk
mccount4:test ax,8000h
	je mccount5
	inc mcyds
	inc mcydz
mccount5:loop mccount1
	retn
	endp

;---------------------------------------------------------------------
;vytvorenie a prezeranie tabulky VPLYVOV
;---------------------------------------------------------------------
ctbeg4:	mov begin,offset ctbeg		;vstupny bod pri prepinani
	mov draw,offset drawkan		;tabulky do rezimu (+/-)
	mov fill,offset ctfill		;napriklad z rezimu kan.
	call word ptr draw ;obsluha klavesnice pri editacii matice v kanonickom
	call word ptr fill	;tvare
	sub ax,ax
	int 51
ctbeg:	mov cursorp,4
	call cursoron	;zaciatok obsluzneho cyklu
	mov ax,1
	int 51
	mov help,offset cthelp
	
ctbeg3:sub bx,bx
	mov ax,3	;obsluha klavesnice
	int 51		;pri editacii dat v matici
	or bx,bx
	je ctbeg2
	jmp mouse
ctbeg2:mov ah,1
	int 22
	jz ctbeg3
	mov ah,0
	int 22
	
	push ax
	mov ax,2
	int 51
	call cursoroff
	pop ax
	mov dx,ax
	mov si,offset cttab
ctbeg1:lodsw
	or ax,ax
	jz ctbeg
	mov bx,ax
	lodsw
	cmp bx,dx
	jne ctbeg1
	jmp ax

cttab	dw 4d00h,vpravo ,4b00h,vlavo,4800h,hore,5000h,dole;right,left,up,down
	dw 4700h,home,4900h,pguphome ;home,pgup
	dw 4300h,rmark,4400h,rmark3,5300h,rmark4 ;f9,f10,del
	dw 1519h,delrow,1615h,delcolum,4200h,change ;ctrl+y,ctrl+u,f8
	dw 7800h,kantaba,7900h,kantabb,7a00h,kantabc,7b00h,kantabd ;alt+1 az 4
	dw 5100h,pgdown,7400h,pgright,7300h,pgleft ;pgdn,ctrl+right,ctrl+left
	dw 0f09h,edn,3b00h,cthelp,011bh,koniec	;tab,f1,esc
	dw 3c00h,kansave,3d00h,kanload,3e00h,ctexp ;f2,f3,f4
	dw 3f00h,asbeg4	;f5 prepnutie rezimu editacie
	dw 7100h,kanclear	;alt+f10 zmaz tabulku
	dw 1c0dh,asnl ;enter
	dw 0e08h,ctdelnum	;backspace
	dw 0231h,ctnumb,0332h,ctnumb,0433h,ctnumb,0534h,ctnumb
	dw 0635h,ctnumb,0736h,ctnumb,0837h,ctnumb,0938h,ctnumb
	dw 0a39h,ctnumb,0b30h,ctnumb,1100h,ctwritee
	;dw 1900h	;generovanie spolupatricnosti alt+p
	dw 0	;zakoncovak
ctstatus db 0	;pokial sa tento byte nerovna 1 nieje povoleny zapis do tabulky

ctwritee: mov al,ctstatus	;povoluje|zakazuje zapis do tabulky 
	xor al,1
	mov ctstatus,al
	cmp al,1
	pushf
	mov ah,2
	mov dl,7
	int 33
	popf
	jne ctwritee1
	int 33
ctwritee1:jmp word ptr begin

ctdelnum:cmp ctstatus,1
	je ctdelnum1
	jmp vlavo
 ctdelnum1:sub ax,ax	;zmaz jedny cislicu zprava
	mov al,xh
	add al,xr
	shl ax,1
	add ah,yh
	add ah,yr
	mov di,ax
	mov es,buf
	mov ax,es:[di]
	mov bx,10
	sub dx,dx
	div bx
	stosw
	call word ptr fill
	jmp word ptr begin
	
ctnumb:	cmp ctstatus,1
	jne ctnumb1
	sub bl,30h	;cislice 0-9
	sub ax,ax
	mov al,xh
	add al,xr
	shl ax,1
	add ah,yh
	add ah,yr
	mov di,ax
	mov es,buf
	mov ax,es:[di]
	mov dx,10
	mul dx
	or dx,dx
	jne ctnumb1
	mov bh,0
	add ax,bx
	jc ctnumb1
	stosw
	call word ptr fill
ctnumb1:jmp word ptr begin
	
	
;treba tieto casti ctexp,ctfill,cthelp
cthelp:mov si,offset cthelpt	;help ku +/- prezeracej casti programu
	call helpp
	jmp ctbeg
cthelpt:twin 0,1,78,21,1fh
	db ' MANUAL ',13,13
	db '  ',1,4fh,' Esc ',1,1fh,' Ukoncenie programu        '
	db 1,5fh,' F2 ',1,1fh,'  Zapis tabulky na disk',13
	db '  ',1,4fh,' F1  ',1,1fh,' Tato pomocna obrazovka    '
	db 1,5fh,' F3 ',1,1fh,'  Citanie tabulky na disk',13
	db '                                  '
	db 1,5fh,' F4 ',1,1fh,'  Export do textoveho suboru',13
	db 13 ;Je mozne vlozit text
	db '  ',1,2fh,' F8  ',1,1fh,' Vymena oznacenych riadkov a stlpcov',13
	db '  ',1,2fh,' F9  ',1,1fh,' Oznacenie riadku ( a stlpca )',13
	db '  ',1,2fh,' F10 ',1,1fh,' Oznacenie stlpca ( a riadku )',13
	db '  ',1,2fh,' DEL ',1,1fh,' Zmazanie oznacenia'
	db '    '
	db 1,4fh,' Alt+1 az Alt+4 ',1,1fh,' Prepinanie aktualnej tabulky',13,13
	db '  ',1,6fh,' Ctrl+Y  ',1,1fh,' Zmazanie riadku',13
	db '  ',1,6fh,' Ctrl+U  ',1,1fh,' Zmazanie stlpca',13
	db '  ',1,6fh,' Alt+F10 ',1,1fh,' Zmazanie tabukly',13,13
	db '  ',1,3fh,' Alt+W ',1,1fh,' Povolenie zapisu do tabulky',13
	db '  ',1,3fh,'  TAB  ',1,1fh,' Stlpec nahradnych mien  ',13
	db 0
ctfillbuf db 20 dup(0)
ctfill	proc near
	push cs
	pop es
	mov si,81h
	mov di,offset ctfillbuf
	movsw
	movsw
	movsw
	call fillrc
	mov di,656
	sub ax,ax	;vypocet adresy zdroja
	mov al,xh
	shl ax,1
	add ah,yh
	mov si,ax
	mov dl,19	;zaciatok vertikalneho cyklu
ctfill2:mov cx,12

ctfill3:push cx dx
	mov ds,buf
	lodsw
	push cs
	pop ds
	or ax,ax
	jne ctfill4
	mov es,vram
	mov ax,1f20h
	mov cx,5
	rep stosw
	inc di
	inc di
	jmp short ctfill5
ctfill4:push di
	call pdec
	pop di
	mov bx,si
	mov si,81h
	mov ah,1fh
	mov es,vram
	lodsb
	stosw
	lodsb
	stosw
	lodsb
	stosw
	lodsb
	stosw
	lodsb
	stosw
	inc di
	inc di
	mov si,bx
ctfill5:pop dx cx
	loop ctfill3
	add di,16
	add si,232
	dec dl
	jnz ctfill2
	call fillin
	push cs
	pop es
	mov si,offset ctfillbuf
	mov di,81h
	movsw
	movsw
	movsw
	retn
	endp

ctexpt	db ' 123456789X'	
ctexpseg dw 0c000h	;segmentova adresa povodnej tabulky 
			;pre sumaciu v exporte
ctexpt1:twin 15,9,49,4,4fh
	db ' POZOR ! ',13,13
	db '   Tabulka pravdepodobne nieje exportovatelna.',13
	db '     Ak nechces dalej pokracovat stlac Esc.',0
ctexp:	cmp ctgenct,8
	jna ctexp1
	mov si,offset ctexpt1
	call window
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
	mov ah,0
	int 22
	cmp al,27
	pushf
	call word ptr draw
	popf
	jne ctexp1
	jmp word ptr begin	
ctexp1:	mov expprb,offset ctexpp	;export tabulky
	jmp txtexp
ctexpp	proc near	;exportna procedura bunky
	push bx
	mov ax,cs:ctexpseg
	mov cs:expseg,ax
	lodsw
	cmp ax,10
	jna ctexpp1
	mov ax,10
ctexpp1:mov bx,ax
	mov al,cs:[bx+ctexpt]
	pop bx
	stosb
	retn
	endp
	
ctgent1:twin 22,10,36,3,3fh
	db 13,13
	db '   Zadaj maximalnu hodnotu: ',1,4fh,' XXX ',0
ctgent2:twin 18,10,44,3,4fh
	db ' POZOR ! ',13,13
	db '   Tuto tabulku nebude mozne exportovat !',0
ctgent3:twin 27,10,26,3,5fh
	db 13,13
	db '   Generujem Tabulku...',0
ctgen:	mov si,offset ctgent1
	call window
	mov ah,2
	mov bh,0
	mov dx,0c36h
	int 16
	inc ctgenct
ctgenv0:sub ax,ax
	mov al,ctgenct
	call pdec
	mov si,83h
	mov di,104+12*160
	call zwrite
	mov ah,0
	int 22
	cmp al,27
	jne ctgenv1
	jmp word ptr begin
ctgenv1:cmp al,8	;backspace
	jne ctgenv2
	sub ax,ax
	mov al,ctgenct
	mov bl,10
	div bl
	mov ctgenct,al
	jmp ctgenv0
ctgenv2:cmp al,'0'	;cislice
	jb ctgenv4
	cmp al,'9'
	ja ctgenv4
	sub al,30h
	mov bh,al
	mov bl,10
	mov al,ctgenct
	mul bl
	add al,bh
	adc ah,0
	cmp ax,256
	jnb ctgenv5
	mov ctgenct,al
ctgenv5:jmp short ctgenv0
ctgenv4:cmp al,13	;Enter
	jne ctgenv0
	mov ah,2
	mov bh,0
	mov dx,1900h
	int 16
	cmp ctgenct,2
	jnb ctgenv3
	mov ctgenct,2
ctgenv3:cmp ctgenct,10
	jb ctgen0
	mov si,offset ctgent2
	call window
	mov ah,0
	int 22
ctgen0:	call word ptr draw
	mov si,offset ctgent3
	call window
	dec ctgenct
	mov es,buf4	;Generovanie tabulky "naklonnosti" (ciselny format)
	sub ax,ax	;testovanie, ci je cielova (D) tabulka prazdna
	mov di,ax
	mov cx,128*128
	repe scasw
	je ctgen1
	kanerz 'Tabulka D musi byt prazdna ! ( Alt+4,Alt+F10 )'
ctgen1: mov ctstatus,0
	mov ax,buf
	mov ctexpseg,ax
	mov ds,ax
	mov si,offset rows
	mov di,si
	mov cx,64*5
	rep movsw
	sub di,di	;nastavenie 1 pri "+>"
	mov si,di
	mov cx,128*128
ctgen2:	lodsw
	test ax,1000h
	mov ax,0
	je ctgen3
	inc ax
ctgen3:	stosw
	loop ctgen2
	sub cx,cx
	mov cl,cs:ctgenct
	push es
	pop ds
ctgen9:	push cx
	call ctgensp	
	pop cx
	loop ctgen9
	sub si,si		;omedzovac cisel v tabulke
	mov cx,128*128
	sub bx,bx
	mov bl,cs:ctgenct
	inc bx
ctgen11:lodsw
	cmp ax,bx
	jna ctgen12
	dec si
	dec si
	mov word ptr [si],0
	inc si
	inc si
ctgen12:loop ctgen11
	mov ax,999		;zmazanie diagonaly
	sub di,di
	mov cx,128
ctgen13:stosw
	add di,256
	loop ctgen13
	push cs
	pop ds
	mov ax,buf4	;nastavenie tabulky D do ciselneho rezimu
	call changetab	;a zaroven koniec procedury
	jmp ctbeg4	

ctgenct	db 2 ;najvissie cislo v tabulke -1 ( urcuje pocet priatelskych precodov)
ctgensp	proc near
	sub bx,bx	;zac.verikal.cyklu
	cld
ctgen4:	mov di,bx
	sub si,si	;zaciatok cyklu prehladavania jedniciek
	mov dh,128
ctgen5:	mov ax,1
	scasw
	jne ctgen8
	mov bp,di	;zaciatok cylku kopirovania riadku
	mov di,bx
	mov cx,128
ctgen6:	lodsw
	or ax,ax
	je ctgen7
	inc ax	;mov ax,2
	cmp word ptr [di],0
	je ctgen10
	cmp [di],ax
	jna ctgen7
ctgen10:stosw
	dec di
	dec di
ctgen7:	inc di
	inc di
	loop ctgen6
	mov di,bp
	sub si,256
ctgen8:	add si,256
	dec dh
	jnz ctgen5
	inc bh		;koniec vertikalneho cyklu
	cmp bh,128
	jb ctgen4
	retn
	endp
	
; Koniec programu --------------------------------------------------------
poslednyb:
dlzkaprog=(offset poslednyb-offset prvyb)/16+1
prog	ends
buffer	segment
tabulka	dw 128*128 dup(?)
rows	db 128*5 dup(?)
zxh	db ?	;zaloha pozicie kurzora
zyh	db ?
zxr	db ?
zyr	db ?
zmr1	db ?
zmr2	db ?
;potialto zapisovat na disk
zbegin	dw ?
zfill	dw ?
zdraw	dw ?
zhelp	dw ?
zstatus	db ?
char	db ?
meno	db 127 dup(?)
assume cs:buffer
matickon:
dlzkamatic=(offset matickon-offset tabulka)/16+1
buffer	ends
end	zac
