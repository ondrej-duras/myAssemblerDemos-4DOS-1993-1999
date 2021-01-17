buffsize=1024
	p286n
prog	segment
	assume cs:prog,ds:prog,es:prog,ss:prog
prvyb:	org 2ch
dosenv	dw ?	;prostredie dosu
	org 80h
parsize	db ?
par	db 127 dup(?)
zac:	;ZACIATOK PROGRAMU
	include VSTROM_A.INC

	call treeclr
	xwrite 100,100,uvod,15
	key
	mov ax,3d00h	;otvorenie .CFG suboru
	lds dx,homepath
	int 33
	push cs
	pop ds
	jnc zac5
	mov dx,offset nocfgf
	mov ah,9
	int 33
	call manual
	jmp quit
zac5:	push ax
	;call bodka
	mov bx,ax	;zacitanie za suboru
	mov ah,3fh
	mov dx,offset buff
	mov cx,buffsize	;maximalny objem citanych dat
	int 33
	;call bodka
	pop bx		;uzavretie .CFG
	mov ah,3eh
	int 33
	;call bodka
docmd1:	push cs			;citanie a vyhodnocovanie prikazov
	pop es		;vyhladanie 1. pismena prikazu
	mov di,cmdat
	mov cx,buffsize+10
	mov al,32
docmd2:	repe scasb
	cmp byte ptr es:[di-1],8
	je docmd2
	cmp byte ptr es:[di-1],13
	je docmd2
	cmp byte ptr es:[di-1],10
	je docmd2
	dec di
	mov cmdc,di
	mov si,offset cmdtab	;zistenie adresy obsluhy prikazu
docmd3:	mov di,cmdc
	lodsw
	or ax,ax
	jne docmd4
	mov ah,9
	mov dx,offset unknowcmd
	int 33
	call check
	mov ax,4cfeh
	int 33
docmd4:	mov dx,ax
	mov ah,0
	lodsb
	mov bx,si
	add bx,ax
	mov cx,ax
	repe cmpsb
	mov si,bx
	jne docmd3
	mov cmdn,di
	call dx		;volanie obsluhy prikazu
	push cs		;hladanie zaciatku noveho prikazovaho riadku
	pop ds
	push cs
	pop es
	mov al,10
	mov di,cmdc
	mov cx,buffsize
	repne scasb
	mov cmdat,di
	cmp debugm,0
	je docmd5
	call check
	call keyproc
	mov ah,2
	mov dl,13
	int 33
	mov ah,2
	mov dl,10
	int 33
docmd5:	jmp docmd1
	
debugm	db 0	;debugm=0 plinuly mod, debugm!=0 trasovaci
cmdc	dw buff	;prvy neprazdny znak
cmdat	dw buff	;zaciatok prave vyhodnocovaneho riadku
cmdpar	dw buff	;parameter prave vyhodnocovaneho riadku
cmdn	dw buff	;prvy znak za identifikatorom prikazu
cmdtab	dw quit		;tabulka identifikatorov a obsluh prikazov
	db 4,'quit'	;ukoncenie programov
	dw check	;kontrolny bod   ;vypis premennych
	db 5,'check'
	dw warning	;(varovanie) vypis paranetra
	db 7,'warning'
	dw bodka	;nakreslenie bodky
	db 5,'point'
	dw helpline	;komentar
	db 1,';'
	dw keyproc	;cakanie na stlacenie klavesy bez vypisu
	db 3,'key'
	dw pauseproc
	db 5,'pause'	;cakanie na stlacenie klavesy s vypisom "<stlac...>"
	dw comspec
	db 7,'comspec'	;specifikacia kde je command.com
	dw command
	db 7,'command'	;vykonanie prikazu
	dw init
	db 4,'init'	;inicializacia grafiky
	dw close
	db 5,'close'	;zrusenie grafickeho modu
	dw label_p
	db 5,'label'	;meno "strazeneho virtualneho suboru"
	dw debug
	db 5,'debug'	;trasovaci mod
	dw nodebug
	db 7,'nodebug'	;plinuly mod
	dw manual
	db 4,'edit'
	dw 0 ;zakoncovak

init	proc near
	mov ax,18
	int 16
	xwrite 100,100,uvod,15
	retn
	endp
close	proc near
	mov ax,3
	int 16
	retn
	endp

pauseproc proc near
	mov ah,9
	mov dx,offset pauseproc_t
	int 33
keyproc:mov ah,0
	int 22
helpline:retn
	
pauseproc_t db '<< Stlac lubovolnu klavesu >>',13,10,36
	endp
debug	proc near
	mov debugm,255
	retn
	endp
nodebug	proc near
	mov debugm,0
	retn
	endp

checkw	macro xx
	mov ah,9
	mov dx,offset xx
	int 33
	endm
checkcc	db 'Kompilacia........ datum-',??date,' cas-',??time,13,10
	db 'Aktualny riadok... $'
checkhp	db 'Konfig. subor..... $'
checkcs	db 'Interpreter....... $'
checkcm db 'Prikaz DOSu....... $'
checkvn	db 'Virtualne meno ... $'
checksr	db 'Aplik.zdroj ...... $'
checkpa	db 'Procedura ........ AKTIVNA',13,10,36
checkpp	db 'Procedura ........ PASIVNA',13,10,36
check	proc near
	checkw checkcc
	mov si,cmdc
	call twrite
	checkw checkhp
	lds si,homepath
	call twrite
	push cs
	pop ds
	checkw checkcs
	mov si,offset comsp
	call twrite
	checkw checkcm
	mov si,offset cmdline
	call twrite
	checkw checkvn
	mov si,offset vlabel
	call twrite
	checkw checksr
	mov si,offset source
	call twrite
	key
	retn
	endp
bodka	proc near
	pusha
	mov ah,2
	mov dl,'.'
	int 33
	popa
	retn
	endp	
	
buff	db 13,buffsize dup(32)
	db 13,10,'quit',13,10,'quit',13,10
ahoj	db 'Citam konfiguracny subor $'
nocfgf	db 13,'VSTROM: Chyba pri citani konfiguracneho suboru !'
	db 7,13,10,36
unknowcmd db 13,'VSTROM: Neznamy prikaz !'
	db 7,13,10,36

getparm	proc near	;vrati es:[di] - na zaciatok prikazu
	push cs
	pop es
	cld
	mov di,cmdn
	mov cx,buffsize
	mov al,32
getparm1:repe scasb
	cmp byte ptr es:[di-1],8
	je getparm1
	dec di
	retn
	endp

warning	proc near
	mov si,cmdn
	call twrite
	retn
	endp

twrite	proc near
	lodsb
	cmp al,13
	je twrite1
	cmp al,0
	je twrite1
	mov dl,al
	mov ah,2
	int 33
	jmp twrite
twrite1:mov ah,2
	mov dl,13
	int 33
	mov dl,10
	mov ah,2
	int 33
	retn
	endp

comsp	db 'C:\COMMAND.COM',0,80 dup(32);specifikacia (cesta+meno) command.com-u
comspec	proc near
	call getparm
	mov si,di
	mov di,offset comsp
	mov cx,90
comspec1:lodsb
	cmp al,13
	je comspec2
	cmp al,10
	je comspec2
	cmp al,8
	je comspec2
	cmp al,32
	je comspec2
	stosb
	loop comspec1
comspec2:mov al,0
	stosb
	retn
	endp

xepb	dw 0	;Exec Parameter Blok  ;0-prostredie Dos-u sa bude dedit
	dw offset xepbl,0c000h	;prikazovy riadok
	dw 5ch,0c000h	;FCB1	;toto sa dalej pouzivat nebude
	dw 6ch,0c000h	;FCB2
oldstack dw 0,0
xepbl	db 22,' /c '	;pocet znakov prikaz riadku
cmdline	db '<NEPOUZITE>',13,106 dup(32),13 ;buffer pre prikazovy riadok
command	proc near
	mov xepb+4,cs	;priprava bloku epb
	mov xepb+8,cs
	mov xepb+12,cs
	mov xepbl,4
	call getparm	;priprava prikaz riadku
	mov si,di
	mov cx,120
	mov di,offset cmdline
	cld
command1:lodsb		;vlastne kopirovanie riadku do jeho buffra
	cmp al,13
	je command2
	stosb
	inc xepbl
	loop command1
command2:mov al,13
	stosb
	cli
	mov oldstack,sp
	mov oldstack+2,ss
	sti
	mov dx,offset comsp
	mov bx,offset xepb
	mov ax,4b00h
	int 33
	cli
	mov ss,cs:oldstack+2
	mov sp,cs:oldstack
	sti
	push cs
	pop ds
	push cs
	pop es
	retn
	retn
	endp

source	db '<NEPOUZITE>',0,80 dup(32),0	;meno zdrojoveho suboru
label_p	proc near	;procedura na zistenie mena strazeneho suboru
	call getparm
	mov si,di
	mov di,offset vlabel
	lodsb
	cmp al,'"'
	jne label_p2
	mov cx,30
label_p1:lodsb
	cmp al,'"'
	je label_p2
	cmp al,8
	je label_p2
	cmp al,13
	je label_p2
	cmp al,10
	je label_p2
	stosb
	loop label_p1
label_p2:mov al,0
	stosb
	retn
	endp

quit:	mov ax,3	;ukoncenie programu
	int 16
	mov ah,9
	mov dx,offset koniec_t
	int 33
	mov ax,4c00h
	int 33
koniec_t db 'Koniec programu...',13,10,36


tbeep	macro		;piskacie makro pre ladenie
	pusha
	mov ah,2
	mov dl,7
	int 33
	popa
	endm

;----------------------------------------------------------------------	
;----------------------------------------------------------------------	
;----------------------------------------------------------------------	
mscrref	proc near	;vykreslenie celej obrazovky so stromom
	call zaklad_p	;(manualne pouzivanej)
	call tree
	xwrite 50,430,mscrref_1,7
	cmp treebeg,0
	jne mscrref1
	xwrite 150,240,mscrref_2,14
mscrref1:retn
	endp
mscrref_1 db wco,11,'Esc',wco,7,' Ukoncenie programu, '
	  db wco,11,'+',wco,7,' Pridat vrchol, '
	  db wco,11,'-',wco,7,' Odobrat vrchol, '
	  db wco,11,'BkSp',wco,7,' Zrus'
	  wat 95,50
	  db wco,15,wmarg,15
vlabel  db '   DOKONALE VYVAZENY STROM    ',wend ;maximalne 30 znakov !!
	db 10 dup(32),0
	dw 0,0,0,0,0
mscrref_2 db wmarg,20,'STROM JE PRAZDNY.',0

treebeg	dw 0	;odkaz na koren stromu
treeatx	dw 16	;horizontalne posunutie stromu	;char.KONSTANTY stromu
treeaty	dw 82	;vertikalne posunutie stromu
treeydi	db 45	;sirka leveloveho pasu (vertikalna sirka jednej urovne stromu)
treexdi	db 19	;horizontalna vzdialenost opornych bodov dvoch susedov
		;najpocetnejsej urovne
tree	proc near	;Vykreslenie iba stromu
	cmp treebeg,0
	je tree1
	push 4040h	;deleno bin.index
	push treebeg	;vrchol
	call treex
tree1:	retn
	endp
treex	proc near	;rekurzia procedury tree
	arg vrch:word,bind:word
	enter 0,0
	mov bx,vrch		;lave potomstvo
	cmp word ptr [bx+2],0
	je treex1
	mov ax,bind
	shr al,1
	sub ah,al
	push ax
	push word ptr [bx+2]
	call treex
treex1:	mov ax,bind	;zobrazenie vrcholu
	mov binM,ah
	shr al,1
	sub ah,al
	mov binL,ah
	add ah,al
	add ah,al
	mov binR,ah
	mov dx,vrch
	mov stpp,dx
	call stp
	mov bx,vrch		;prave potomstvo
	cmp word ptr [bx+4],0
	je treex2
	mov ax,bind
	shr al,1
	add ah,al
	push ax
	push word ptr [bx+4]
	call treex
treex2:	leave
	retn 4
	endp

;parametre STP (Show Tree Point)
binM	db 64	;Binarny INdex Vrcholu (Master)
binL	db 32	;Binarny INdex Laveho Potomka (Left)
binR	db 96	;Binarny INdex Praveho Potomka (Right)
stpp	dw vrch08	;offset vrcholu
stpx	dw 0	;suradnice oporneho bodu
stpy	dw 0
stpstc	db 7	;farba poctu vrcholov
stpstat	db 1	;0-zakazuje vypist poctu vrcholov ,!0 povoluje
stpbuf	db 6*9 dup(0)	;buffer pre 6 ciar po 9 B.
	dw 65535,65535,65535,65535
stp	proc near	;ZOBRAZENIE JEDNEHO VRCHOLU
	push bp
	mov al,binM	;vypocet oporneho bodu
	call bindex
	mov stpx,cx
	mov stpy,dx
	inc dx		;vypis hodnoty vrcholu
	inc dx
	sub cx,5
	mov bx,stpp
	mov ah,[bx+6]
	push bx cx dx
	mov al,[bx+1]
	call dcislo
	pop dx cx bx
	cmp stpstat,0	;pripadny vypis stavu
	je stp3
	mov al,[bx]
	add dx,15
	mov ah,stpstc
	call dcislo
stp3:	push cs		;zaciatok vytvorenia fronty ciar
	pop es
	mov di,offset stpbuf
	cld
	cmp word ptr [bx+2],0	;existuje LAVY potomok?
	je stp1
	mov ax,stpx	;ak ano => vytvor vo fronte spojnicu
	sub ax,7
	stosw
	mov ax,stpy
	add ax,14
	stosw
	mov al,binL
	call bindex
	mov ax,cx
	stosw
	mov ax,dx
	dec ax
	stosw
	mov bx,[bx+2]
	mov al,[bx+8]
	stosb
	mov bx,stpp
stp1:	cmp word ptr [bx+4],0	;existuje PRAVY potomok?
	je stp2
	mov ax,stpx	;ak ano => vytvor vo fronte spojnicu
	add ax,8
	stosw
	mov ax,stpy
	add ax,14
	stosw
	mov al,binR
	call bindex
	mov ax,cx
	stosw
	mov ax,dx
	dec ax
	stosw
	mov bx,[bx+4]
	mov al,[bx+8]
	stosb
stp2:	mov cx,stpx	;priprava zakladneho stvorca
	mov dx,stpy
	sub cx,7	;horna c.
	mov ax,cx
	stosw
	mov ax,dx
	stosw
	add cx,15
	mov ax,cx
	stosw
	mov ax,dx
	stosw
	mov al,[bx+7]
	stosb
	mov ax,cx	;prava c.
	stosw
	mov ax,dx
	stosw
	mov ax,cx
	stosw
	add dx,14
	mov ax,dx
	stosw
	mov al,[bx+7]
	stosb
	mov ax,cx	;dolna c.
	stosw
	mov ax,dx
	stosw
	sub cx,15
	mov ax,cx
	stosw
	mov ax,dx
	stosw
	mov al,[bx+7]
	stosb
	mov ax,cx	;lava c.
	stosw
	mov ax,dx
	stosw
	mov ax,cx
	stosw
	sub dx,14
	mov ax,dx
	stosw
	mov al,[bx+7]
	stosb
	mov ax,65535	;zakoncenie fronty ciar
	stosw
	mov si,offset stpbuf
	call dline
	pop bp
	retn
	endp

bindex	proc near	;vypocet x,y z binarneho indexu	<al=bin => cx=x dx=y
	push bx
	mov bl,al
	shr al,2
	mul treexdi	;vypocet X-ovej suradnice (uz posunutej)
	add ax,treeatx
	mov cx,ax
	mov al,0
	mov bh,6
	mov al,treeydi
	mov ah,6
	mul ah
	add ax,treeaty
	mov dx,ax
	test bl,2
	jz bindex1
	add cx,10;;
bindex1:test bl,1
	jnz bindex2
	shr bl,1
	sub dl,treeydi
	sbb dh,0
	dec bh
	jnz bindex1
bindex2:pop bx
	retn
	endp
	
;struktura pouzivaneho vrcholu
pkvrchol macro pocet,hodnota,lavy,pravy,fcislo,fram,fciara
	db pocet,hodnota		;9B/vrchol
	dw offset lavy,offset pravy
	db fcislo,fram,fciara
	endm
	
;struktura volneho vrcholu zv zasobniku
;	dw 0,0,offset dalsi	;dalsi=0 =>posledny
;	db 0,0,0

treeclr	proc near	;inicializovanie (zmazanie) stromu
	mov treebeg,0	;zmazanie stromu
	mov treefree,offset treebuf	;nastavenie pociatku zasobnika
	push cs			;volnych vrcholov
	pop es
	cld
	mov di,offset treebuf
	mov cx,63
treeclr1:xor ax,ax	;cyklus gemerovania volnych vrcholov vo zasobniku
	stosw
	stosw
	mov ax,di
	add ax,5
	stosw
	xor ax,ax
	stosw
	stosb
	loop treeclr1	;koniec cyklu
	mov word ptr [di-5],0	;zapisanie zakoncovacieho znaku zoznamu
	retn
	endp

gettp	proc near	;prideli volny vrchol z fronty vrchol=bx
	cmp treefree,0	;je mozno pridelit vrchol ?
	jne gettp1
	stc		;ak nie nastav priznak a ukonc.
	retn
gettp1:	mov bx,treefree
	mov ax,[bx+4]
	mov treefree,ax
	retn
	endp
freetp	proc near ;uvolnenie vrcholu do zasobnika volnych vrcholov bx=vrchol
	mov ax,treefree
	mov [bx+4],ax
	mov word ptr [bx],0
	mov word ptr [bx+2],0
	mov word ptr [bx+6],0
	mov word ptr [bx+8],0
	mov treefree,bx
	retn
	endp

treefree dw 0	;ak obsahuje nulu tak je prazdna inak smernik na zac. zasob.
treecnum db 15	;implicitna farba cisla vrcholu			;! nemenit
treecbox db 3	;implicitna farba ramceka vrcholu		;! poradie !
treeclin db 11	;implicitna farba ciary k rodicovskemu vrcholu	;! 
treebuf	db 9*80 dup(0)	;buffer dat pre strom

findtp	proc near	;vyhladanie vrcholu v strome al=vrchol
	mov bx,treebeg  ;ak nenajdene ZF=1, najdene ZF=0 bx=offset najdeneho
	xor di,di	;di=offset predchodcu, ak di=0 => vrchol nema predchodcu
findtp1:or bx,bx
	jnz findtp2
	sub ah,ah	;ak nieje najdeny nastav priznak ZF
	retn		;a skonc
findtp2:cmp al,[bx+1]	;porovnanie hladanej s vrcholom	;zaciatok hl.cyklu
	jb findtp3
	ja findtp4
	mov ah,0	;ak je rovno vynuluj priznak ZF
	inc ah
	retn		;a skonc
findtp3:mov di,bx	;pokracuj lavym
	mov bx,[bx+2]
	jmp findtp1
findtp4:mov di,bx	;pokracuj pravym
	mov bx,[bx+4]
	jmp findtp1
	endp

sizst	proc near	;nastavi velkost podstromu kazdeho vrcholu
	cmp treebeg,0
	je sizst1
	push treebeg
	call sizstr
sizst1:	retn
	endp
sizstr	proc near	;rekurzivna cast procedury ,velkost=al
	arg vrch:word	;offset vrcholu
	enter 0,0
	xor ax,ax
	mov bx,vrch		;je to vlastne prehladavanie PostInOrder
	cmp word ptr [bx+2],0
	je sizstr1
	push [bx+2]
	call sizstr
sizstr1:push ax
	xor ax,ax
	mov bx,vrch
	cmp word ptr [bx+4],0
	je sizstr2
	push [bx+4]
	call sizstr
sizstr2:pop dx
	add ax,dx
	inc ax
	mov bx,vrch
	mov [bx],al
	leave
	retn 2
	endp
	
	
pushtp	proc near	;vlozenie vrcholu do stromu al=hodnota
	call findtp
	jnz pushtp0
	push ax
	call gettp	;pridel volny vrchol 
	jnc pushtp1
	pop ax
pushtp0:retn		;ak nieje mozne pridelit vrchol, akonc
pushtp1:mov si,treebeg	
	pop ax
	or si,si	;obsahuje strom nejaky vrchol ?
	jnz pushtp3
	mov treebeg,bx	;ak je strom prazdny => prirad 1. vrchol
pushtp2:mov ah,al	;vypln strukturu vrcholu
	mov al,1
	mov [bx],ax
	mov ax,word ptr treecnum
	mov word ptr [bx+6],ax
	mov al,treeclin
	mov [bx+8],al
	mov word ptr [bx+4],0
	call sizst
	;call tree
	retn
pushtp3:mov dx,[si+2]
	mov di,2
	cmp [si+1],al
	jnb pushtp4
	mov dx,[si+4]
	mov di,4
pushtp4:or dx,dx
	jz pushtp5
	mov si,dx
	jmp pushtp3
pushtp5:xchg bx,di
	mov [si+bx],di
	mov bx,di
	jmp pushtp2
	endp

popltp	proc near	;rusenie NAJPRAVEJSIEHO V LAVOM podstrome vrcholu(BX)
	mov di,bx	;pre proc. musi byt zaruceny min. jeden lavy potomok
	mov si,[bx+2]	;zruseny prvok je vrateny v AH !
	cmp word ptr [si+4],0	;priamy lavy potrebuje extra osetrit
	jne popltp1
	mov ax,[si+2]	
	mov [bx+2],ax
	mov bx,si
	push [si]
	call freetp
	call sizst
	pop ax
	retn
popltp1:mov di,si	;vyhladanie
	mov si,[si+4]
	cmp word ptr [si+4],0
	jne popltp1
	mov ax,[si+2]	;vymazanie
	mov [di+4],ax
	push [si]
	mov bx,si
	call freetp
	call sizst
	pop ax
	retn
	endp

poprtp	proc near	;rusenie NAJLAVEJSIEHO V PRAVOM podstrome vrcholu(BX)
	mov di,bx	;pre proc. musi byt zaruceny min. jeden lavy potomok
	mov si,[bx+4]	;zruseny prvok je vrateny v AH !
	cmp word ptr [si+2],0	;priamy lavy potrebuje extra osetrit
	jne poprtp1
	mov ax,[si+4]	
	mov [bx+4],ax
	mov bx,si
	push [si]
	call freetp
	call sizst
	pop ax
	retn
poprtp1:mov di,si	;vyhladanie
	mov si,[si+2]
	cmp word ptr [si+2],0
	jne poprtp1
	mov ax,[si+4]	;vymazanie
	mov [di+2],ax
	push [si]
	mov bx,si
	call freetp
	call sizst
	pop ax
	retn
	endp

poptp	proc near	;zrusenie korena(AL)
	call findtp	;hladanie korena
	jnz poptp1	;ak neexistuje => koniec
	retn
poptp1:	mov si,[bx+2]	;zistenie velkosti laveho i praveho podstromu
	mov dl,0
	or si,si
	jz poptp2
	mov dl,[si+1]
poptp2:	mov si,[bx+4]
	mov dh,0
	or si,si
	jz poptp3
	mov dh,[si+1]
poptp3:	or dx,dx	;je ruseny vrchol listom ?
	jne poptp7
	or di,di	;je list zaroven korenom ?
	jne poptp5
	mov treebeg,0	;ak je list korenom => zrus strom
poptp4:	call freetp
	call sizst
	;call comps
	retn
poptp5:	mov si,bx	;ak list nieje korenom => ? je lavy|pravy
	mov bx,2
	cmp [di+2],si
	je poptp6
	mov bx,4
poptp6:	mov word ptr [di+bx],0	;zrusenie korena
	mov bx,si
	jmp poptp4
poptp7:	sub dl,dh	;ak vrchol nieje listom
	push bx
	jb poptp9
	call popltp
poptp8:	pop bx
	mov [bx+1],ah
	call sizst
	;call comps
	retn
poptp9:	call poprtp
	jmp poptp8
	endp

comps	proc near	;Vyrovnavanie stromu
	mov bx,treebeg	;zistenie nerovnosti velkosti podstromov
	or bx,bx
	jne comps0
	retn
comps0:	mov cl,0
	mov si,[bx+2]
	or si,si
	jz comps1
	mov cl,[si]
comps1:	mov ch,0
	mov si,[bx+4]
	or si,si
	jz comps2
	mov ch,[si]
comps2:	mov dx,offset comps4	;off.zlava doprava
	sub cl,ch
	jnc comps3
	neg cl
	mov dx,offset comps5	;off.zprava dolava
comps3:	mov ch,0
	cmp cx,1
	pushf		;rozdelenie nerovnosti
	shr cx,1
	popf
	jna comps6
	jmp dx
comps4:	push cx			;vyrovnavanie zlava doprava
	mov bx,treebeg
	call popltp
	mov bx,treebeg
	xchg [bx+1],ah
	mov al,ah
	call pushtp
	pop cx
	loop comps4
	jmp comps6
comps5:	push cx			;vyrovnavanie zprava dolava
	mov bx,treebeg
	call poprtp
	mov bx,treebeg
	xchg [bx+1],ah
	mov al,ah
	call pushtp
	pop cx
	loop comps5
comps6:	push treebeg	;rekurzia
	mov bx,treebeg
	mov ax,[bx+2]
	mov treebeg,ax
	call comps
	pop bx
	push bx
	mov ax,[bx+4]
	mov treebeg,ax
	call comps
	pop treebeg
	call sizst
	retn
	endp

box	proc near	;do ax farby ah=ramcek al=vypln
	push ax
	mov es,vram
	mov dx,3ceh
	mov ax,0305h
	out dx,ax
	pop ax
	push ax
	mov ah,al
	mov al,0
	out dx,ax
	mov byte ptr es:[65535],255
	mov al,byte ptr es:[65535]
	pop ax
	mov al,0
	out dx,ax
	mov di,388*80+3
	mov ax,65535
	mov cx,37
	rep stosw
	add di,6
	mov cx,37
	rep stosw
	mov di,390*80+3
	mov cx,25
	mov al,192
box1:	stosb
	add di,79
	loop box1		
	mov di,390*80+76
	mov cx,25	
	mov al,3
box2:	stosb
	add di,79
	loop box2
	sub di,73
	mov ax,65535
	mov cx,37
	rep stosw
	add di,6
	mov cx,37
	rep stosw
	mov di,390*80+4
	mov dx,25
	xor ax,ax
box3:	mov cx,36
	rep stosw
	add di,8
	dec dx
	jnz box3
	retn
	endp

cukeyatx dw 32
cukeyaty dw 397
cukey	proc near	;blika s kurzorom + caka na stlacenie klavesy
	mov cx,cukeyatx	;vracia ah=2*cislo_funkcie al=cislica
	mov dx,cukeyaty	;Cislica=0,+=1,-=2,Enter=3,BkSp=4,Esc=5
	mov ax,0c0fh
	call cislica
	mov ah,1
	int 22
	jnz cukey9
	call delay
	call delay
	call delay
	call delay
cukey9:	mov cx,cukeyatx
	mov dx,cukeyaty
	mov ax,070fh
	call cislica
	mov ah,1
	int 22
	jnz cukey8
	call delay
	call delay
	call delay
	call delay
	mov ah,1
	int 22
	jz cukey
cukey8:	key
	cmp al,27	;Esc kod5
	jne cukey1
	mov ax,0a00h
	retn
cukey1:	cmp al,'+'	;+ kod1
	je cukey2
	cmp al,'='
	jne cukey3
cukey2:	mov ax,0200h
	retn
cukey3:	cmp al,'-'	;- kod2
	je cukey4
	cmp al,'_'
	jne cukey5
cukey4:	mov ax,0400h
	retn
cukey5:	cmp al,13	;Enter kod3
	jne cukey6
	mov ax,0600h
	retn
cukey6:	cmp al,8	;BkSp
	jne cukey7
	mov ax,0800h
	retn
cukey7:	cmp al,'0'	;cislica kod0
	jb cukey
	cmp al,'9'
	jna cukey10
	jmp cukey
cukey10:sub al,'0'
	mov ah,0
	retn
	endp
;Box vykreslit ax=0f07h, zmazat ax=0808h	
manual_tab dw manualx,manualu,manualo,manualx,manualx,manuale

manual	proc near	;manualna obsluha stromu
	call mscrref
manualx:mov cukeyaty,481	;pri stlaceni rusiacej klavesy
	mov ax,0808h
	call box
	call cukey
manualn:mov bh,0	;bola stlacena NEcislica - hned osetrit
	mov bl,ah
	jmp word ptr [bx+manual_tab]
manuale:retn

manualv	db 0	;hodnota pridavaneho / vyberaneho vrcholu
manualu_1 db wmarg,10,'Pridaj do stromu vrchol s cislom',wend
manualu_2 db wmarg,10,'Pridane. Mozno este treba strom vyvazit. Stlac klaves.'
	db wend
manualu:mov ax,0f07h	;pridavanie vrcholov do stromu
	call box
	xwrite 40,400,manualu_1,15
	mov cukeyatx,330+40	;cakanie na prvu cislicu
	mov cukeyaty,397
	call cukey
	cmp ah,0
	je manualu1
	jmp manualn
manualu1:mov manualv,al	;vypis prvej cislice
	mov ah,15
	mov cx,370
	mov dx,397
	call cislica
	mov cukeyatx,377
manualu2:call cukey	;cakanie na druhu cislicu
	cmp ah,6	;bol stlaceny enter ?
	je manualu4
	cmp ah,0
	je manualu3
	jmp manualn
manualu3:mov cukeyatx,384
	mov bl,al
	mov al,manualv
	mov ah,10
	mul ah
	add al,bl
	mov bl,100
	div bl
	mov manualv,ah
	mov al,ah
	mov ah,15
	mov cx,370
	mov dx,397
	push word ptr dcislob
	mov dcislob,7
	call dcislo
	pop word ptr dcislob
	jmp manualu2	;opakuj cakanie na 2. cislicu
manualu4:cmp treebeg,0	;fyzicke pridanie vrcholu do stromu
	jne manualu5
	mov al,manualv
	call pushtp
	call mscrref
	jmp manualu6
manualu5:mov al,manualv
	call pushtp
	call tree
manualu6:mov ax,0f07h	;vypis spravy "stlac klaves"
	call box
	xwrite 40,400,manualu_2,15
	key
	mov cx,ax
	mov ah,5
	int 22
	call comps
	jmp manual
	endp

manualo_1 db wmarg,10,'Odober zo stromu vrchol s cislom',wend
manualo_2 db wmarg,10,'Odobrane. Mozno este treba strom vyvazit. Stlac klaves.'
	db wend
manualo:mov ax,0f07h	;pridavanie vrcholov do stromu
	call box
	xwrite 40,400,manualo_1,15
	mov cukeyatx,330+40	;cakanie na prvu cislicu
	mov cukeyaty,397
	call cukey
	cmp ah,0
	je manualo1
	jmp manualn
manualo1:mov manualv,al	;vypis prvej cislice
	mov ah,15
	mov cx,370
	mov dx,397
	call cislica
	mov cukeyatx,377
manualo2:call cukey	;cakanie na druhu cislicu
	cmp ah,6	;bol stlaceny enter ?
	je manualo4
	cmp ah,0
	je manualo3
	jmp manualn
manualo3:mov cukeyatx,384
	mov bl,al
	mov al,manualv
	mov ah,10
	mul ah
	add al,bl
	mov bl,100
	div bl
	mov manualv,ah
	mov al,ah
	mov ah,15
	mov cx,370
	mov dx,397
	push word ptr dcislob
	mov dcislob,7
	call dcislo
	pop word ptr dcislob
	jmp manualo2	;opakuj cakanie na 2. cislicu
manualo4:mov al,manualv	;fyzicke pridanie vrcholu do stromu
	call poptp
	call mscrref
	mov ax,0f07h	;vypis spravy "stlac klaves"
	call box
	xwrite 40,400,manualo_2,15
	key
	mov cx,ax
	mov ah,5
	int 22
	call comps
	jmp manual
	endp

	include VSTROM_B.INC
poslednyb:
dlzkaprog=(offset poslednyb-offset prvyb)/16+1
prog	ends
end	zac


