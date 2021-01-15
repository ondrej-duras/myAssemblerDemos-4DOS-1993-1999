;SPACE v.2.37, Kniznica pre premietanie 3D objektov...
;Postavene na baze konvexnych stvoruholnikov.
;19991001, rtm. Ondrej DURAS (dury)

;HISTORICKA POZNAMKA O POUZITI KNIZNICE:
; Vzdy som si chcel naprogramovat nieco 3D.
; Naprogramovat od podlahy na urovni strojoveho kodu.
; Toto je kniznica, napisanim ktorej som si ciastocne splnil
; svoj jednoduchy clapcensky sen ... napisat nieco 3D.
;
; Program vyuzivajuci tuto kniznicu by mal zacinat
; riadkom "include SPACE.INC , resp v tomto pripade include SPACEFUL.INC
; poslednym riadkom by malo byt makro "spacend" .
; Cielom napisania tejto kniznice bolo co najjednoduchsim sposobom
; umoznit cloveku si napisat vlastne 3D demo.
; Kniznica je usposobena vyslovene na demo. Nieje usposobena velmi
; na pisanie interaktivnych veci ako napr. hier,
; pretoze pouziva staticke retazce so zakoncovanim znakom.
; 
; Ku API sa rozpisem asi neskor, ked sa trosku rozpamatam.
; Predsa len ... kniznica coskoro oslavi stvrtstorocnicu :-)
; Pointa je ale jednoducha:
; 1. kniznica pozkytuje volanie, ktorym mozno vykreslit "scenu".
; 2. "scena" je definovana retazcom objektov.
; 3. kazdy objekt v retazci je definovany troma informaciami
;     - smernikom na zoznam polygonov objektu v jeho zakladej polohe
;     - vychodzou polohou objektu X1,Y1,Z1,alfa1,beta1,gama1
;     - koncovou polohou objektu X2,Y2,Z2,alfa2,beta2,gama2
; 4. medzi vychodou a koncovou polohou vo vsetkych 6 parametroch 
;    je akoby jednoducha usecka.
; 5. scena sa vola, dokial nieje od pociatocnej polohy dokreslena
;    do polohy koncovej. potom volanie vrati priznak.
; 6. Dokial volanie priznak nevrati, tak je mozno pred/po zavolani
;    mozno cinit este ine subezne aktivity ... napriklad snezit,
;    ako v deme mountain.com .
; 7. Pri vykreslovani scen sa vyuzivaju 4-voxelove polygony, o ktorych
;    sa predpoklada, ze budu vzdy konvexne. ....niesu, ale to uz
;    je starost rezisera kazdeho dema, aby tuto nedokonalost kniznice nebolo vidno.
; 8. Zaroven sa tu vyuziva maliarov algoritmus, co znamena kreslenie
;    jednotlivych polygonov od najzadnejsich po najprednejsie do pripravneho buffra.
; 9. pre vypocet vzdialenosti polygonu sa vyuziva banalna priemerna
;    hodnota vzdialenosti jednotlivych voxelov polygona.
;10. Podla tejto hodnoty sa polygony sceny najprv zoradia v buffri vagon-sortom.
;11. Po zoradeni sa polygony vykreslia do pripravneho buffru a odtial sa kopiruju do videoram
;
; ... aspon tak nejako si to pamatam. Viem. Nieje to efektivne, ale funguje to
; a da sa to cele naprogramovat za dva dni.
; Ano ... tato kniznica bola od dokoncenia konceptu po dokoncenie implementacie
; napisana za 48 hodin.
; ---

display "SPACE v.2.37"
ifdef checkit
display "Program include 'checkit' functions"
endif
prog	segment
	.386p
	assume cs:prog,ds:prog,es:prog,ss:prog,fs:prog,gs:prog
prvyb:	org 80h
parsize	db ?
par	db 127 dup(?)
zac:	mov ah,4ah		;pociatocne pamatove alokacie
	mov bx,dlzkaprog
	int 33
	mov ah,48h	;priprava zasobnika
	mov bx,1000
	int 33
	jnc zac2
zac1:	mov ax,4cfeh
	int 33
zac2:	cli
	mov ss,ax
	mov sp,16000
	sti
	mov ah,48h	;bufer pre pripravu polygonov
	mov bx,4096
	int 33
	jc zac1
	mov pbuf,ax
	mov ah,48h	;bufer pre pripravu sceny
	mov bx,4096
	int 33
	jc zac1
	mov vbuf,ax
	mov drawto,ax	;nasmerovanie kreslenia do bufru pre pripravu sceny
	mov es,ax	;inicializacia bufru pre pripravu sceny
	xor di,di
	mov cx,16000
	mov eax,background
	rep stosd
	xor bx,bx	;nastavenie vekrora "divide by zero" na lokalnu proc
	mov es,bx
	mov eax,es:[bx]
	mov dbzvekt,eax
	cli
	mov word ptr es:[bx],offset dbzrout
	mov es:[bx+2],cs
	sti
	mov ax,19	;inicializacia grafickeho rezimu
	int 16
	ifdef checkit
	les bx,int8it;nastavenie kontrolneho prerusenia detekujuceho miesto
	mov eax,es:[bx]
	mov int8v,eax
	cli
	mov word ptr es:[bx],offset int8r	;zamrznutia
	mov es:[bx+2],cs
	sti
	endif
	push cs	;nastavenie segmentovych adries na lokal
	pop fs
	push cs
	pop gs
	push cs
	pop es
	mov moviesg,cs	;nastavenie segmentu zdroja dat na aktualny segment
	call waveini	;inicializacia vlny
	mov cx,256
zac3:	push cx
	call wave
	pop cx
	loop zac3

	jmp space_koniec_zdrojaku

quit:	ifdef checkit
	les bx,int8it
	mov eax,int8v
	mov es:[bx],eax
	endif
	mov ax,3	;ukoncenie programu
	int 16		;inicializacia povodneho textoveho rezimu
	xor bx,bx	;nastavenie vektora "divide by zero" na povodnu hodnotu
	mov es,bx
	mov eax,dbzvekt
	mov es:[bx],eax
	mov ax,4c00h	;ukoncenie programu
	int 33

	ifdef checkit
	align 4
int8it	dd 8*4
int8v	dd 0
int8r:	sub cs:ckrout,2
	and cs:ckrout,15
	or cs:ckrout,16
	call check
int8rq:	jmp dword ptr cs:int8v
ckrout	db 0;farba <16..31> checku modifikovana pri kazdom volani check
ckvoxel	db 0;{1,9}faba voxelu
cktran	db 0;{5,13}farba zatriedovania
ckssort	db 0;{2,10}farba sortu
ckpoly	db 0;farba indikujuca pouzitie poly {1,9}
ckdraw	db 0;{4,12}
ckdbz	db 0;	indikator, ze doslo ku preruseniu
check:	pushad
	push ds
	push es
	push cs
	pop ds
	inc ckrout
	and ckrout,15
	or ckrout,16
	mov es,vram
	call check1
	pop es
	pop ds
	popad
	retn
check1:	mov di,320-7*4
	mov si,offset ckrout
check2:	lodsb
	mov ah,al
	mov dx,4
	push di
check3:	stosw
	stosw
	add di,316
	dec dx
	jnz check3
	pop di
	add di,4
	cmp di,320
	jb check2
	retn	
	endif
dbzrout:xor eax,eax	;obsluha "divide by zero"
	mov edx,eax	;ignorovanie javu delenia nulou...
	ifdef checkit
	or cs:ckdbz,4
	xor cs:ckdbz,8
	endif
	iret

video:	push es ds		;procedura presuvajuca hotovu scenu
	xor si,si		;z bufra pre pripravu sceny na obrazovku
	mov di,si		;a inicializujuca bufer pre pripravu sceny
	mov cx,16000    	;Inicializacia spociva v prekresleni
	mov es,vram		;bufru farbou pozadia (premenna background)
	mov ds,drawto
	rep movsd
	pop ds
	mov es,drawto
	mov eax,background
	xor di,di
	mov cx,16000
	rep stosd
	pop es
	ifndef fastvideo
	call delay
	endif
videoq:	ifdef checkit
	call check
	endif
	retn

delay:	cmp delaytwi,0
	jne delay2
	push es bx eax
	mov bl,delayspd
	mov delaytwi,bl
	les bx,biostime
	mov eax,delayvar
delay1:	cmp eax,es:[bx]	
	je delay1
	mov eax,es:[bx]
	mov delayvar,eax
	pop eax bx es
	retn
delay2:	dec delaytwi
	retn

;rotacia v rovine (16-bit suradnice)
rotacia	macro xx,yy,aa			;makro realizujuce otocenie
	mov bx,aa			;bodu [xx,yy] od osi suradnic xx
	shl bx,1                        ;smerom k osi sur. yy o uhol aa,
	movsx eax,[bx+sintab]		;vyjadreny v uhlovej jednotke
	movsx ebx,[bx+costab]		;1/64 kvadrantu, co je 1/256 kruhu.
	movsx ecx,xx
	movsx edx,yy
	mov esi,ecx
	imul esi,ebx
	mov edi,edx
	imul edi,eax
	sub esi,edi
	mov edi,ecx
	imul edi,eax
	imul edx,ebx
	add edi,edx
	sar esi,8
	sar edi,8 
	mov xx,si
	mov yy,di
	endm

;SINUS/COSINUS tabulka
;y=256*sin(x*pi/128); y=256*cos(x*pi/128); pre kazde x=<0,255>;
	align 4
sintab	dw    0,   6,  13,  19,  25,  31,  38,  44	;  0 -   7 I.kvad SIN
	dw   50,  56,  62,  68,  74,  80,  86,  92	;  8 -  15 
	dw   98, 104, 109, 115, 121, 126, 132, 137	; 16 -  23
	dw  142, 147, 152, 157, 162, 167, 172, 177	; 24 -  31
	dw  181, 185, 190, 194, 198, 202, 206, 209	; 32 -  39
	dw  213, 216, 220, 223, 226, 229, 231, 234	; 40 -  47
	dw  237, 239, 241, 243, 245, 247, 248, 250	; 48 -  55
	dw  251, 252, 253, 254, 255, 255, 256, 256	; 56 -  63
costab	dw  256, 256, 256, 255, 255, 254, 253, 252	; 64 -  71 II.kvad SIN
	dw  251, 250, 248, 247, 245, 243, 241, 239	; 72 -  79 I.kvad COS
	dw  237, 234, 231, 229, 226, 223, 220, 216	; 80 -  87
	dw  213, 209, 206, 202, 198, 194, 190, 185	; 88 -  95
	dw  181, 177, 172, 167, 162, 157, 152, 147	; 96 - 103
	dw  142, 137, 132, 126, 121, 115, 109, 104	;104 - 111
	dw   98,  92,  86,  80,  74,  68,  62,  56	;112 - 119
	dw   50,  44,  38,  31,  25,  19,  13,   6	;120 - 127
	dw    0,  -6, -13, -19, -25, -31, -38, -44	;128 - 135 III.kvad SIN
	dw  -50, -56, -62, -68, -74, -80, -86, -92	;136 - 143 II.kvad COS
	dw  -98,-104,-109,-115,-121,-126,-132,-137	;144 - 151
	dw -142,-147,-152,-157,-162,-167,-172,-177	;152 - 159
	dw -181,-185,-190,-194,-198,-202,-206,-209	;160 - 167
	dw -213,-216,-220,-223,-226,-229,-231,-234	;168 - 175
	dw -237,-239,-241,-243,-245,-247,-248,-250	;176 - 183
	dw -251,-252,-253,-254,-255,-255,-256,-256	;184 - 191
	dw -256,-256,-256,-255,-255,-254,-253,-252	;192 - 199 IV.kvad SIN
	dw -251,-250,-248,-247,-245,-243,-241,-239	;200 - 207 III.kvad COS
	dw -237,-234,-231,-229,-226,-223,-220,-216	;208 - 215
	dw -213,-209,-206,-202,-198,-194,-190,-185	;216 - 223
	dw -181,-177,-172,-167,-162,-157,-152,-147	;224 - 231
	dw -142,-137,-132,-126,-121,-115,-109,-104	;232 - 239
	dw  -98, -92, -86, -80, -74, -68, -62, -56	;240 - 247
	dw  -50, -44, -38, -31, -25, -19, -13,  -6	;248 - 255
	dw    0,   6,  13,  19,  25,  31,  38,  44	;256 - 263 IV.kvad COS
	dw   50,  56,  62,  68,  74,  80,  86,  92	;264 - 271
	dw   98, 104, 109, 115, 121, 126, 132, 137	;272 - 279
	dw  142, 147, 152, 157, 162, 167, 172, 177	;280 - 287
	dw  181, 185, 190, 194, 198, 202, 206, 209	;288 - 295
	dw  213, 216, 220, 223, 226, 229, 231, 234	;296 - 303
	dw  237, 239, 241, 243, 245, 247, 248, 250	;304 - 311
	dw  251, 252, 253, 254, 255, 255, 256, 256	;312 - 319

biostime dd 0040006ch	;adresa systemoveho citaca
delayvar dd 0		;premenna urcena pre casovu sysnchronizaciu
delaytwi db 0           ;stavova premenna rychlosti
delayspd db 0,0,0	;nastavoenie rychlosti. ci vacsie cislo, tym vacsia
			;moze byt aj nula (1snimok/55ms)
background dd 0	;inicializacia farby pozadia
dbzvekt	   dd 0		;zaloha vektora prerusenia "divide by zero"
vram	dw 0a000h ;adresa videopamate
lins	dw 320	  ;pocet bytov na riadok
drawto	dw 0a000h ;segmentova adresa bufra do ktoreho sa realizuje kreslenie
vbuf	dw 0a000h ;segmentova adresa bufra, urceneho pre vytvaranie scen
pbuf	dw 0a000h ;seg.adr. urceneho pre pripravu polygonov
psrc	dw 0	;offset zdroja dat
pcolor	dw 0	;farba polygonu, ak >255 =>koniec
px1	dw 0	;suradnice 4- bodov polygonu
py1	dw 0	;pcolor-py4 -NEPRESUVAT!!! NEMENIT PORADIE !!!!
px2	dw 0
py2	dw 0
px3	dw 0
py3	dw 0
px4	dw 0
py4	dw 0
pfrom	dw 0	;na ktorom vykreslovanom riadku polygon zacina
pheight	dw 0	;viditelna vyska polygonu
pxx1	dw 0	;body ciary "pochodu"
pyy1	dw 0
pxx2	dw 0
pyy2	dw 0
pdx	dw 0	;derivacie pre pochod
pdy	dw 0
rows	dw 400 dup(0)	;tabulka riadkoveho rozkladu

;procedura kresli len jeden 4 uholnik z fs:[si]
poly:	ifdef checkit
	xor ckpoly,12
	endif
	mov psrc,si	;prekopirovanie parametrov polygonu na lokal
	push cs
	pop es
	mov di,offset pcolor
	segfs movsw
	segfs movsd
	segfs movsd
	segfs movsd
	segfs movsd

	mov si,7fffh	;hladanie dolneho,
	mov di,8000h	;horneho okraja polygonu
	mov bh,3	;a Xkluca zobrazitelnosti polygonu
vint	macro xx,yy
	local vint1,vint2,vint3,vint4
	mov ax,yy	;test spodu
	cmp ax,si
	jnl vint1
	mov si,ax
vint1:	cmp ax,di	;tset vrchu
	jng vint2
	mov di,ax
vint2:	mov ax,xx	;test Xkluca
	mov bl,3
	cmp ax,0
	jl vint3
	and bl,1
vint3:	cmp ax,319
	jg vint4
	and bl,2
vint4:	and bh,bl
	endm
	vint px1,py1
	vint px2,py2
	vint px3,py3
	vint px4,py4
	cmp bh,0	;testy zobrazitelnosti polygonu
	jne polyr
	cmp si,199
	jg polyr
	cmp di,0
	jl polyr
	cmp si,0	;orezanie vysky ciatocne vyditelneho polygonu
	jnl poly1
	mov si,0
poly1:	cmp di,199
	jng poly2
	mov di,199
poly2:	mov pfrom,si	;zaznamenanie 1. zobrazovaneho riadku polygonu
	sub di,si
	inc di
	mov pheight,di	;zaznamenanie vysky polygonu
	push cs		;inicializacia tabulky riadkoveho rozkladu
	pop es
	mov cx,di
	mov di,si
	shl di,2
	add di,offset rows
	mov eax,80007fffh
	rep stosd
	
	mov ax,px1	;pochod po hranici polygonu
	mov pxx1,ax
	mov ax,py1
	mov pyy1,ax
	mov ax,px2
	mov pxx2,ax
	mov ax,py2
	mov pyy2,ax
	call cross	;1. usecka
	mov ax,px3
	mov pxx1,ax
	mov ax,py3
	mov pyy1,ax
	call cross	;2. usecka
	mov ax,px4
	mov pxx2,ax
	mov ax,py4
	mov pyy2,ax
	call cross	;3. usecka
	mov ax,px1
	mov pxx1,ax
	mov ax,py1
	mov pyy1,ax
	call cross	;4. usecka
	
	mov dx,pheight	;vykreslenie riadkov polygonu
	or dx,dx
	je polyr
	mov es,drawto
	mov bp,pfrom
	mov si,bp
	shl si,2
	add si,offset rows
	imul bp,320
poly3:	lodsw		;cyklus vykreslenia riadkov z tabuky riadkoveho rozkladu
	mov bx,ax
	lodsw
	cmp bx,320
	jnl poly6
	cmp ax,0
	jl poly6
	cmp bx,0
	jnl poly4
	mov bx,0
poly4:	cmp ax,320
	jl poly5
	mov ax,319
poly5:	mov di,bp
	add di,bx
	sub ax,bx
	inc ax
	mov cx,ax
	mov ax,pcolor
	rep stosb
poly6:	add bp,320
	dec dx
	jnz poly3
polyr:	ifdef checkit
	xor ckpoly,12+1
	call check
	endif
	mov si,psrc
polyq:	retn

cross:	mov di,pyy1	;procedura prechodu po hranici polygonu
	mov si,pxx1	;vypocet derivacie
	mov bp,1
	mov dx,pyy2
	sub dx,di
	jns cross1
	neg bp
	neg dx
cross1:	mov bx,1
	mov cx,pxx2
	sub cx,si
	jns cross2
	neg bx
	neg cx
cross2:	xor ax,ax
	cmp dx,cx	;test derivanie k<1 k=1 k>1 ?
	jb cross4
	ja cross7
	inc cx		;pre k=1
cross3:	call point
	add si,bx
	add di,bp
	loop cross3
	retn
cross4:	div cx		;pre k<1
	inc cx
cross5:	call point
	add si,bx
	add dx,ax
	jnc cross6
	add di,bp
cross6:	loop cross5
	retn
cross7:	xchg cx,dx	;pre k>1
	div cx
	inc cx
cross8:	call point
	add di,bp
	add dx,ax
	jnc cross9
	add si,bx
cross9:	loop cross8
crossq:	retn 
	
point:	cmp di,200	;si=x di=y ->zapis bodu do tabulky rozkladu
	jnb point3
	push di
	shl di,2
	add di,offset rows
	cmp si,[di]
	jnl point1
	mov [di],si
point1:	cmp si,[di+2]
	jng point2
	mov [di+2],si
point2:	pop di
point3:	
pointq:	retn

;TRAN - TRANSFORMACIA 3D->2D *******************************************

	align 4
ttx	dd 0	;suradnice taziska polygonu
tty	dd 0
ttz	dd 0
txx	dw 0	;suradnice spracovavaneho bodu
tyy	dw 0
tzz	dw 0
camx	dw 0	;suradnice kamery
camy	dw 0
camz	dw 0
camxy	dw 0	;uhol otocenia kamery
camzy	dw 0
camxz	dw 0
objx	dw 0	;suradnice objektu v priestore
objy	dw 0
objz	dw 0
objxy	dw 0	;uhol otocenie objektu okolo svojeho vstazneho bodu
objzy	dw 0
objxz	dw 0
tsrc	dw 0	;offset zdroja dat (FS:)
tcolor	dw 0	;zaciatok kopie struktury polygonu 3D ;farba
tx1	dw 0	;3D suradnice jednotlivych vrcholov stvoruholnika
ty1	dw 0
tz1	dw 0
tx2	dw 0
ty2	dw 0
tz2	dw 0
tx3	dw 0
ty3	dw 0
tz3	dw 0
tx4	dw 0
ty4	dw 0	;do bufra by nalo vojst 2730 polygonov a 16 bytov rezervy
tz4	dw 0	;koniec kopie struktury polygonu
tvf	dw 0	;priznak zobrazitelnosti polygonu-ci su vsetky body v intervale
polybeg	dw 0	;smernik na zaciatok stuktury polygonov -1=NIL
polyend	dw -1	;smernik na znacku : !TU -1 znamena ze v pbuf nic nieje!!!
polyf	dw 2730	;pocet polygonov, ktore este mozu byt zapisane do bufru
ssortb	dw 256 dup(0)	;zaciatky podretazcov	;pouziva ssort
ssorte	dw 256 dup(0)	;konce podretazcov

pclear:	mov polybeg,0	;inicializacia pbuf - struktury sceny
	mov polyend,-1
	mov polyf,2730
	push es
	mov es,pbuf
	assume es:nothing
	mov word ptr es:[0],-1
	pop es
	assume es:prog
pclearq:retn

;procedura transformujuca ds:[si] 3D->2D, zapis tiez na ds:[si], posun si+6
voxel:	push si
	mov ax,[si]	;prekopirovanie do lokalnych premennych
	mov txx,ax
	mov ax,[si+2]
	mov tyy,ax
	mov ax,[si+4]
	mov tzz,ax
	rotacia txx,tyy,objxy	;rotovanie objektu okolo vlastneho
	rotacia tzz,tyy,objzy	;vstazneho bodu
	rotacia tzz,txx,objxz
	mov ax,txx		;posuny bodu do priestoru a voci kamere
	add ax,objx		;x
	sub ax,camx
	sub ax,160
	mov txx,ax
	mov ax,tyy		;y
	add ax,objy
	sub ax,camy
	sub ax,100
	mov tyy,ax
	mov ax,tzz		;z
	add ax,objz
	sub ax,camz
	mov tzz,ax
	rotacia txx,tyy,camxy	;otocenie vrcholov polygonu
	rotacia tzz,tyy,camzy
	rotacia tzz,txx,camxz
	pop si
	movsx ebx,tzz		;vypocet perspektyvy - projekcia
	add ebx,256
	add ttz,ebx
	movsx eax,txx	;X
	add ttx,eax
	sal eax,8
	cdq
	cmp ebx,256
	jl voxel5
	idiv ebx
voxel5:	add ax,160
	mov [si],ax
	cmp ax,1000
	jng voxel1
	mov tvf,0
voxel1:	cmp ax,-1000
	jnl voxel2
	mov tvf,0
voxel2:	movsx eax,tyy	;Y
	add tty,eax
	sal eax,8
	cdq
	cmp ebx,256
	jl voxel6
	idiv ebx
voxel6:	add ax,100
	mov [si+2],ax
	cmp ax,1000
	jng voxel3
	mov tvf,0
voxel3:	cmp ax,-1000
	jnl voxel4
	mov tvf,0
voxel4:	add si,6
voxelq:	retn
	
;procedura transformacie fs:si-3D polygonu na pbuf:polyend-2D polygony
tran:	ifdef checkit
	xor cktran,12
	endif
	and objxy,255
	and objzy,255
	and objxz,255
	cmp polyf,0	;nieje nahodou pbuf uz plny ?
	je tran1	;ak ano=> nema zmysel tam este nieco strkat
	mov tsrc,si	;zaloha si - smernika na zdroj udajov
	segfs lodsw	;citanie farby polygonu
	cmp ax,256	;je to zakoncovak ?
	jb tran2	;ak nie potom pokracuj
	dec si		;procedura vrati smernik na zakoncovak !
	dec si
tran1:	ifdef checkit
	xor cktran,12+2
	call check
	endif
	retn		;ukoncenie procedury -jediny bod!
tran2:	mov di,offset tcolor	;nastavenie cieloveho smernika na lokal
	push cs
	pop es
	stosw		;zapisanie farby polygonu do lokalu
	cli		;prekopisovanie suradnic vrcholov polygonu na lokal
	mov cx,6
	rep segfs movsd	;dva prefixy vyzaduju zakazane prerusenie
	sti
	mov byte ptr camxy+1,0	;uprava uhlov pohladu (na <0..255>*2)
	mov byte ptr camzy+1,0
	mov byte ptr camxz+1,0
	xor eax,eax	;vynulovanie taziska polygonu
	mov ttx,eax
	mov tty,eax
	mov ttz,eax
	mov si,offset tx1	;transformacia 3D->2D jednotlivych vrcholov
	mov tvf,1	;polygon zobrazitelny
	ifdef checkit
	xor ckvoxel,12
	endif
	call voxel		;polygonu
	call voxel
	call voxel
	call voxel
	ifdef checkit
	xor ckvoxel,12+1
	call check
	endif
	mov si,tsrc	;ak je polygon za okom pozorovatela, potom dalsi
	add si,26
	cmp ttz,0
	jl tran
	cmp tvf,1
	jne tran
	mov di,polyend	;bolo uz zapisane do bbuf?
	cmp di,-1
	jne tran3
	mov di,0	;ak nie => inicializacia smernika
	mov polybeg,di
tran3:	mov es,pbuf	;zapisanie polygonu do bufra pre pripravene polygony
	dec polyf
	mov ax,di	;zapis smernika na dalsi polygon
	add ax,24
	stosw
	mov edx,ttx	;vypocet vzdialenosti od oka pozorovatela
	sar edx,2
	imul edx,edx
	mov eax,tty
	sar eax,2
	imul eax,eax
	add eax,edx
	mov edx,ttz
	sar edx,2
	imul edx,edx
	add eax,edx
	stosd		;zapis vzdialenosti
	mov si,offset tcolor
	movsw		;prekopirovanie farby
	movsd		;-//-1.vrcholu
	inc si
	inc si
	movsd		;-//-2.vrcholu
	inc si
	inc si
	movsd		;-//-3.vrcholu
	inc si
	inc si
	movsd		;-//-4.vrcholu
	inc si
	inc si
	mov polyend,di	;zaloha smernika na koniec struktury
	mov ax,-1	;zapis zakoncovacej znacky
	stosw
	mov si,tsrc
	add si,26
tranq:	ifdef checkit
	xor cktran,12+2
	call check
	endif
	jmp tran



;prevedie jednu zo styroch faz TRIEDENIA
ssort:	ifdef checkit
	xor ckssort,12
	endif
	cmp polyend,-1	;je nieco v bufri?
	je ssortq	;ak nie => koniec
	push cs		;inicializacia tabuliek podretazcov
	pop es
	mov eax,-1
	mov cx,256
	mov di,offset ssortb
	rep stosd
	mov es,pbuf
	mov si,polybeg
ssort1:	cmp word ptr es:[si],-1	;cyklus rozdelovania do podretazcov
	je ssort3
	mov ebx,es:[si+2]	;nacitanie a modifikacia kluca
	ror ebx,8
	mov es:[si+2],ebx
	shr ebx,24
	shl bx,1
	cmp word ptr [ssortb+bx],-1	;existuje podretazec ?
	jne ssort2
	mov [ssortb+bx],si	;ak nie => zalozenie noveho podretazca
	mov [ssorte+bx],si
	mov si,es:[si]
	jmp ssort1
ssort2:	mov di,[ssorte+bx]	;inak pridanie polygonu do existujuceho
	mov es:[di],si		;podretazca
	mov [ssorte+bx],si
	mov si,es:[si]
	jmp ssort1
ssort3:	mov bp,si		;spajanie podretazcov do retazca
	mov bx,255*2
ssort4:	cmp [ssortb+bx],-1	;cyklus hladania 1. podretazca
	jne ssort5
	dec bx
	dec bx
	jns ssort4
	mov polybeg,-1
	mov polyend,-1
	ifdef checkit
	xor ckssort,12+1
	call check
	endif
	retn
ssort5:	mov si,[ssortb+bx]	;najdenie 1. podretazca
	mov polybeg,si
	mov si,[ssorte+bx]
	dec bx
	dec bx
	js ssort8
ssort6:	cmp word ptr [ssortb+bx],-1	;cyklus spajania podretazcov
	je ssort7
	mov di,[ssortb+bx]
	mov es:[si],di
	mov si,[ssorte+bx]
ssort7:	dec bx
	dec bx
	jns ssort6
ssort8:	mov es:[si],bp	;zakoncenie retazca
	mov polyend,bp
ssortq:	ifdef checkit
	xor ckssort,12+1
	call check
	endif
	retn


;VYKRESLENIE stuktury z pbuf do bufra na pripravu sceny drawto (vbuf)
draw:	ifdef checkit
	xor ckssort,12
	endif
	push fs
	cmp polyend,-1	;vykreslenie vsetkych polygonov z pripravneho bufra pbuf
	je draw2	;do bufra pre pripravu sceny drawto (vbuf)
	call ssort	;vykonanie triedenia (4 fazy) podla vzdialenosti
	call ssort	;od oka pozorovatela
	call ssort
	call ssort
	mov fs,pbuf	;struktura sa zacina na pbuf:polybeg a zakoncena je
	mov si,polybeg	;znakom -1
draw1:	cmp word ptr fs:[si],-1
	je draw2
	push si
	add si,6
	call poly
	pop si
	mov si,fs:[si]
	jmp draw1
draw2:	pop fs
	ifdef checkit
	xor ckssort,12+2
	call check
	endif
drawq:	retn


drivesp	dw 40		;jednoduche ovladanie
drive:	mov ah,1
	int 22
	jz driveq
	mov ah,0
	int 22
	cmp al,27
	je quit
	mov bx,drivesp
	or al,32
	cmp al,'o'
	jne drive1
	sub camx,bx
drive1:	cmp al,'p'
	jne drive2
	add camx,bx
drive2: cmp al,'q'
	jne drive3
	sub camy,bx
drive3:	cmp al,'a'
	jne drive4
	add camy,bx
drive4:	cmp al,'k'
	jne drive5
	add camz,bx
drive5:	cmp al,'m'
	jne drive6
	sub camz,bx
drive6:	cmp al,'s'
	jne drive7
	inc camxy
drive7:	cmp al,'d'
	jne drive8
	dec camxy
drive8:	cmp al,'w'
	jne drive9
	inc camxz
drive9:	cmp al,'e'
	jne drive10
	dec camxz
drive10:cmp al,'i'
	jne drive11
	inc camzy
drive11:cmp al,'j'
	jne drive12
	dec camzy
drive12:
driveq:	retn



moviemac macro val,p1,p2	;makro vyberu bodu z intervalu
	mov ax,p2
	sub ax,p1
	imul bx
	idiv bp
	add ax,p1
	mov val,ax
	endm
moviesh	macro xx		;nagenerovanie polohy objektu
	moviemac xx+00,gs:[si+02],gs:[si+14]
	moviemac xx+02,gs:[si+04],gs:[si+16]
	moviemac xx+04,gs:[si+06],gs:[si+18]
	moviemac xx+06,gs:[si+08],gs:[si+20]
	moviemac xx+08,gs:[si+10],gs:[si+22]
	moviemac xx+10,gs:[si+12],gs:[si+24]
	endm

	align 2
moviept	dw -1		;adresa aktualne spracovavaneho bloku
moviesg	dw 0		;segmentova adresa bloku dat
movie:	mov si,moviept
	cmp si,-1
	jne movie0
	stc
	retn
movie0:	mov gs,moviesg
	mov bp,gs:[si]
	mov bx,gs:[si+2]
	add si,6
movie1:	cmp word ptr gs:[si],-1	;koniec
	je movie3
	cmp word ptr gs:[si],-2	;kamera
	je movie2
	cmp word ptr gs:[si],-3	;painty
	je movie6
	cmp word ptr gs:[si],-4 ;zakazany objekt (iba preskocit)
	je movie7
	moviesh objx
	push bp bx si gs
	mov fs,moviesg
	mov si,fs:[si]
	call tran
	pop gs si bx bp
movie7:	add si,26
	jmp movie1
movie2:	moviesh camx
	add si,26
	jmp movie1
movie3:	inc bx
	mov si,moviept
	cmp bp,bx
	jnb movie4
	mov bx,0
	mov gs:[si+2],bx
	mov si,gs:[si+4]
	mov moviept,si
	cmp si,-1
	jne movie5
	stc
	retn
movie4:	mov gs:[si+2],bx
movie5:	clc
	retn
movie6:	moviemac moviefrp,gs:[si+4],gs:[si+8]	;osetrenie paintov
	moviemac movietop,gs:[si+6],gs:[si+10]
	push bp bx si gs
	mov fs,moviesg
	mov si,fs:[si+2]
	mov cx,moviefrp
	mov dx,movietop
	call pendr
	pop gs si bx bp
	add si,12
	jmp movie1
	
	align 2
moviefrp dw 0
movietop dw 0
pencol	db 14	;implicitna farba kreslenia
pendr:	mov es,vbuf	;volna procedura pre kreslenie paintov
	mov pencol,14
pendr5:	jcxz pendr6	;v CX - prve bod, ktory sa ma vykreslit
	dec cx		;v DX - posledny bod, ktory sa ma vykreslit
	or dx,dx	;v FS:[SI] - smernik na paint retazec lubovolnej
	jz pendr4	;dlzky
	segfs lodsw
	cmp ax,-1
	je pendr4
	cmp ax,65536-256*2
	jb pendr7
	mov pencol,al
pendr7:	jmp pendr5
pendr6:	mov al,pencol
pendr1:	mov ah,al
pendr2:	or dx,dx
	je pendr4
	mov di,fs:[si]	
	inc si
	inc si
	cmp di,65536-256*2
	jnb pendr3
	stosw
	add di,318
	stosw
	dec dx
	jmp pendr2
pendr3:	cmp di,-1
	je pendr4
	dec dx
	mov ax,di
	jmp pendr1
pendr4:	retn

;Prevzane z DLOGO.asc ---------------------------------------------------------
ifdef logodef
btapds	dw offset vbuf	;odkaz na bufer do ktoreho sa ma pozadie vykreslit
btaprot	dw 2	;2x uhol otocenia
btapscx	dw 16	;vzdialednost|meritko|velkost obrazku x(sirka)
btapscy	dw 48	;vzdialednost|meritko|velkost obrazku y(vyska)
btapx	dw 32768 ;x-ova suradnica predvypoctu
btapy	dw 1024	 ;y-ova suradnica predvypoctu
btapxx	dw 0	;pracovna suradnica zaciatku riadka
btapyy	dw 0
btapddx	dw 0	;diferencialy horizontalneho cyklu
btapddy	dw 0
btapd2x	dw 0	;diferencialy vertikalneho cyklu
btapd2y	dw 0

btap	proc near	;vykreslenie otoceneho podkladu
	mov bx,btapds	;nastavenie do spravneho ciela
	mov es,[bx]
	cld
	mov bx,btaprot	;uhol
	and bx,510
	movsx eax,word ptr [costab+bx]	;ddx=cos(rot&255)*scx/32
	imul ax,btapscx
	sar eax,5
	mov btapddx,ax
	movsx eax,word ptr [sintab+bx]	;ddy=sin(rot&255)*scy/256
	imul ax,btapscy
	sar eax,8
	mov btapddy,ax
	add bx,128		;uhol+64'
	and bx,510
	movsx eax,word ptr [costab+bx]	;d2x=cos(rot&255)*scx/32
	imul ax,btapscx
	sar eax,5
	mov btapd2x,ax
	movsx eax,word ptr [sintab+bx]	;d2y=sin(rot&255)*scy/256
	imul ax,btapscy
	sar eax,8
	mov btapd2y,ax
	movsx eax,btapddx		;xx=x-ddx*160-d2x*100
	imul ax,160
	mov edx,eax
	movsx eax,btapd2x
	imul ax,100
	add eax,edx
	movsx ebx,btapx
	sub ebx,eax
	mov btapxx,bx
	movsx eax,btapddy		;yy=y-ddy*160-d2y*100
	imul ax,160
	mov edx,eax
	movsx eax,btapd2y
	imul ax,100
	add eax,edx
	movsx ebx,btapy
	sub ebx,eax
	mov btapyy,bx
	xor di,di
	mov cx,200
btap1:	push cx
	mov cx,320
	mov dx,btapyy
	mov si,btapxx
btap2:	add dx,btapddy
	add si,btapddx
	mov bx,si
	shr bx,8
	mov bh,dh
	shr bx,2	;shr bx,3
	and bx,4095
	mov al,[logo+4+bx]
	stosb
	loop btap2
	mov ax,btapd2x
	add btapxx,ax
	mov ax,btapd2y
	add btapyy,ax
	pop cx
	loop btap1
	retn
	endp

btapmrr	dw 0	;spozdovac zmeny diferencialu rotacie
btapmdr	dw -1	;diferencial rotacie
btapmd2r dw -1	;2. diferencial rotacie
btapmdx	dw -50;diferencial horizontalneho pusunu
btapmdy dw  80;diferencial vertikalneho posunu
btapmdw	dw  -1	;diferencial horizontalneho stlacenia
btapmdh	dw  -1	;diferencial vertikalneho stlacenia


btapmod	proc near
	mov ax,btapmdx	;posun stredu rotacie
	add btapx,ax
	mov ax,btapmdy
	add btapy,ax
	cmp btapscx,150	;osetrenie zvacsovania a zmensovania
	je btapmod1
	neg btapmdw
btapmod1:cmp btapscy,150
	je btapmod2
	neg btapmdh
btapmod2:cmp btapscx,15
	je btapmod3
	neg btapmdw
btapmod3:cmp btapscy,15
	je btapmod4
	neg btapmdh
btapmod4:mov ax,btapmdw	;vykonanie stlacenia|roztiahnutia
	add btapscx,ax
	mov ax,btapmdh
	add btapscy,ax
	dec btapmrr	;vykonanie rotacie
	test btapmrr,7
	jnz btapmod7
	cmp btapmdr,8
	je btapmod5
	cmp btapmdr,-8
	jne btapmod6
btapmod5:neg btapmd2r
btapmod6:mov ax,btapmd2r
	add btapmdr,ax
btapmod7:mov ax,btapmdr
	add btaprot,ax
	retn
	endp
endif

coldnc	db 5	;spomalenie stmavovania
coldns	db 0	;stavova premenna - pre spomalovanie stmavovania

coldn	proc near	;color down
	cmp coldns,0 	;spomalovacka
	jne coldn5
	mov al,coldnc
	mov coldns,al
	mov cx,256	;zaciatok colordown
coldn1:	mov al,cl
	mov dx,3c7h
	out dx,al
	inc dx
	inc dx
	in al,dx
	cmp al,0
	je coldn2
	sub al,8
	and al,248     
	test al,196
	jz coldn2
	mov al,0
coldn2:	mov bh,al
	in al,dx
	cmp al,0
	je coldn3
	sub al,8	
	and al,248	
	test al,196
	jz coldn3
	mov al,0
coldn3:	mov bl,al
	in al,dx
	cmp al,0
	je coldn4
	sub al,8	
	and al,248	
	test al,196
	jz coldn4
	mov al,0
coldn4:	xchg al,bh
	push ax
	mov dx,3c8h
	mov al,cl
	out dx,al
	inc dx
	pop ax
	out dx,al
	mov al,bl
	out dx,al
	mov al,bh
	out dx,al
	loop coldn1
	retn
coldn5:	dec coldns
	retn
	endp

        ;posun,pripocet,pocet_hviezd,farba,krok
	align 2
starstr	dw 726,2857,50,8,-1
	dw 8263,26798,50,8,-2
	dw 8247,8247,50,7,-3
	dw 4238,8257,50,7,-4
	dw 8163,43976,40,15,-5
	dw 2394,8924,10,15,-6
	dw 0	;zakoncovak

stars	proc near		;procedura hviezd
	mov es,vbuf
	mov si,offset starstr
stars1:	cmp word ptr [si],0	;zaciatok cyklu
	jne stars2
	retn
stars2:	mov ax,[si+8]
	cmp delaytwi,0
	jne stars5
	add [si+2],ax	
stars5:	mov di,[si+2]
	mov dx,[si]
	mov cx,[si+4]
	mov ax,[si+6]
stars3:	inc dx
	add di,dx
	cmp byte ptr es:[di],0
	jne stars4
	stosb
	dec di
stars4:	loop stars3
	add si,10
	jmp stars1
        endp



waveini	proc near
	mov ah,48h
	mov bx,128
	int 33
	jnc waveini1
	mov ax,4c00h
	int 33
waveini1:mov wavebuf,ax
	mov es,ax
	mov cx,256
	sub di,di
waveini2:mov ax,waveposun	;32032
	stosw
	mov ax,1
	stosw
	loop waveini2
	retn
	endp

wavebuf	dw 0c000h
wavea	dw 0	;offset prvej wave hodnoty v buf. (posuva sa)
wavet	dw 0,2	;uhol,uhlova rychlost *2
	dw 0,2*7	;tabulka vln
	dw 0,2*11
	dw 0,2*17
	dw 0,2*5
	dw 65000	;zakoncovak

wave	proc near	;procedura vln
	mov si,offset wavet
	sub bp,bp
wave1:	lodsw
	cmp ax,64000
	jnb wave2
	mov bx,ax
	lodsw
	add bx,ax
	and bx,511
	mov [si-4],bx
	mov ax,[sintab+bx]
	sar ax,4
	add bp,ax
	jmp short wave1
wave2:	mov ax,320
	imul bp
	add ax,waveposun	;32032
	mov si,wavea
	mov ds,wavebuf
	mov [si],ax
	mov di,si
	sub di,4
	and di,1023
	mov ax,[di]
	sub ax,waveposun	;32032
	cwd
	mov cx,320
	idiv cx
	sub bp,ax
	mov [si+2],bp
	add si,4
	and si,1023
	mov cs:wavea,si
	mov es,cs:vbuf
	mov bx,256	;vykreslenie vyslednej vlny
wave3:	mov dx,321
	mov al,112
	mov di,waveposun	;32032
	sub di,bx
	add di,[si]
	mov cx,[si+2]
	test cx,8000h
	jz wave4
	neg cx
	mov dx,-319
wave4:	inc cx
wave5:	cmp byte ptr es:[di],0 ;x
	jne wave7		;x
	;stosb ;x-
	stosb
	dec di
wave7:	inc di
	sub di,dx
	loop wave5
wave6:	add si,4
	and si,1023
	dec bx
	jnz wave3
	push cs
	pop ds
	retn
	endp
waveposun=50*320-180

;Vypis textu v dolnom riadku -------------------------------------------------
rollset:mov rolll,si	;nastavenie textu na rolovanie
	mov rollb,si
	mov rolla,7
	retn
rolla	db 14	;posledna farba
	align 4
rollp	dw 8	;posun lieta <7..0>
rollb	dw rollt
rolll	dw rollt
roll	proc near
	mov es,vbuf
	dec rollp
	dec rollp
	jnz roll2
	mov rollp,8
	mov bx,rolll		;zabezpecenie posunu
	inc bx
	cmp byte ptr [bx],0
	jne roll1
	mov bx,rollb
roll1: 	cmp byte ptr [bx],1
	jne roll10
	inc bx
	mov al,[bx]
	mov rolla,al
	inc bx
roll10:	mov rolll,bx
roll2:	mov di,rollp
	add di,24*8*320
	mov bx,rolll
	mov ah,rolla
	mov cx,40	;40 znakov
roll6:	push cx      	;hlavny cyklus textu
roll3:	movzx si,[bx]
	inc bx
	or si,si
	jnz roll4
	mov bx,offset rollt
	jmp roll3
roll4:	cmp si,1
	jne roll5
	mov ah,[bx]
	inc bx
	jmp roll3
roll5:	shl si,3
	add si,14
	push ds
	mov cx,0ffa6h
	mov ds,cx
	mov dh,8
roll9:	lodsb
	mov dl,al
	mov cx,8
	mov al,ah
roll7:	rol dl,1
	jnc roll8
	stosb
	dec di
roll8:	inc di
	loop roll7
	add di,312
	dec dh
	jnz roll9
	sub di,320*8-8
	pop ds
	pop cx
	loop roll6
	mov di,24*8*320
	mov cx,8
	xor eax,eax
roll11:	stosd
	stosd
	add di,304
        stosd
	stosd
	loop roll11
	retn
	endp

rollt	db ' ',1,3,'                               '
	db 'Pre pokracovanie dalej treba stlacit ',1,14,'Enter',1,3
	db '.  Pre ukoncenie programu treba stlacit ',1,14,'Esc',1,3,'.'
	db '                                       '
	db 1,14,'SPACE 2.37.F'
	db 1,6,' - aplikacne rozhranie pre priestorove modelovanie'
	db ' v realnom case '
	db '                                                               '
	db 1,15,' Ondrej DURAS (dury)'
	db '                    '
	db 1,11,'http://www.valm.sk/~dury'
	db '            '
	db 'dury@valm.sk            tel.: +421 905 928 400'
	db '                          '
	db 0	;zakoncovak


kstat	dw 0
kstop:cmp kstat,0	;procedura sluziaca na prerusenie cyklu
	jne kstop1
	mov kstat,-1
kstop1:	cmp kstat,-1
	je kstop3
	call coldn
	dec kstat
	jnz kstop2
	mov ax,19
	int 16
	call tma
	mov ah,0
	int 22
	cmp al,27
	je kstop5
	push ax
	mov ax,0c00h
	int 33
	pop ax
	stc
	retn
kstop5:	call quit
kstop2:	clc
	retn
kstop3:	mov ah,1
	int 22
	jz kstop4
	mov kstat,5*8
kstop4:	clc
	retn

tma:	mov cx,35	;procedura pre tmu pri prepinani scen
tma1:	push cx
	call delay
	pop cx
	loop tma1
	retn



;	call waveini	;inicializacia vlny
;	mov cx,256
;op0:	push cx
;	call wave
;	pop cx
;	loop op0


;ako to pouzitat
;	call btapmod
;	call btap
;	call wave
;	call wave
;	call wave
;	call wave
;	call mstar
;	mov si,offset starssr
;	call dstars


kvader	macro xx,yy,zz,xr,yr,zr,c1,c2,c3
	dw c1, xx,yy,zz, xx+xr,yy,zz, xx+xr,yy+yr,zz, xx,yy+yr,zz ;predna
	dw c2, xx,yy,zz, xx,yy+yr,zz, xx,yy+yr,zz+zr, xx,yy,zz+zr ;lava
	dw c3, xx,yy,zz, xx,yy,zz+zr, xx+xr,yy,zz+zr, xx+xr,yy,zz ;spodna
	dw c1, xx,yy,zz+zr, xx+xr,yy,zz+zr, xx+xr,yy+yr,zz+zr, xx,yy+yr,zz+zr ;zadna
	dw c2, xx+xr,yy,zz, xx+xr,yy+yr,zz, xx+xr,yy+yr,zz+zr, xx+xr,yy,zz+zr ;prava
	dw c3, xx,yy+yr,zz, xx,yy+yr,zz+zr, xx+xr,yy+yr,zz+zr, xx+xr,yy+yr,zz ;spodna
	endm

	;;ihlan bez podstavy zo styroch polygonov
strecha	macro x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x5,y5,z5,c1,c2,c3,c4
	dw c1, x1,y1,z1, x2,y2,z2, x5,y5,z5, x5,y5,z5
	dw c2, x2,y2,z2, x3,y3,z3, x5,y5,z5, x5,y5,z5
	dw c3, x3,y3,z3, x4,y4,z4, x5,y5,z5, x5,y5,z5
	dw c4, x4,y4,z4, x1,y1,z1, x5,y5,z5, x5,y5,z5
	endm

	;horizontalny tunel z troch polygonov
h3tun	macro xx,yy,zz, xr,yr,zr, c1,c2,c3
	dw c1, xx,yy,zz, xx+xr,yy,zz, xx+xr,yy+yr,zz+zr/2, xx,yy+yr,zz+zr/2
	dw c2, xx,yy,zz+zr, xx+xr,yy,zz+zr, xx+xr,yy+yr,zz+zr/2, xx,yy+yr,zz+zr/2
	dw c3, xx,yy,zz, xx+xr,yy,zz,xx+xr,yy,zz+zr,xx,yy,zz+zr
	endm

	;ihlan bez podstavy z troch polygonov
spic	macro x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4, c1,c2,c3
	dw c1, x1,y1,z1,x2,y2,z2,x4,y4,z4,x4,y4,z4
	dw c2, x2,y2,z2,x3,y3,z3,x4,y4,z4,x4,y4,z4
	dw c3, x3,y3,z3,x1,y1,z1,x4,y4,z4,x4,y4,z4
	endm


;------------------------------------------------------------------------
spacend	macro
	db 13,10,'SPACE v.2.37F full version for demo developing'
poslednyb:
dlzkaprog=(offset poslednyb-offset prvyb)/16+1
prog	ends
end	zac
	endm

space_koniec_zdrojaku:
;********* koniec ********************************************************
