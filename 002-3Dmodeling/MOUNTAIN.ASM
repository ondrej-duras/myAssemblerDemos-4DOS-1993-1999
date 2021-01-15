;MOUNTAIN.ASM / MOUNTAIN.COM - Modelovanie 3D krajinky
;19991201, rtm. Ondrej DURAS (dury)


;pre kompilaciu bol pouzivany TASM v2.02 a TLINK v3.01
;=cc TASM.EXE MOUNTAIN.ASM
;=cc TLINK.EXE MOUNTAIN.OBJ,MOUNTAIN.COM /t
;=cc DEL MOUNTAIN.OBJ
;=cc DEL MOUNTAIN.MAP


;HISTORICKA POZNAMKA:
; Toto 3D modelovanie bol asi tak technicky vrchol mojho assembleru v 20. storoci.
; Potom si uz okolnosti/praca vynutili programovanie v inych jazykoch.
; Assembler uz potom po statniciach ostal iba ako konzultacna
; zalezitost pre spoluziakov, ktori z necho potrebovali spravit skusku.
; Posledni inzinieri opustili akademiu v lete 2006. S nimi sa
; snad iba docasne skoncilo aj moje programovanie v assembleri.
; snad to raz prepisem pre Raspberry s vyuzitim jeho GPU ...


include SPACEFUL.INC
	mov background,95959595h ;95959595h zimna obloha na horach
	mov camy,-200		 ;4d4d4d4dh denne svetlo na horach
	mov moviept,offset scena

op1:	call land
	call pclear
	call movie
	jnc dal1
	mov moviept,offset scena
dal1:	call draw
	push moviept
	mov ax,ndscena
	mov moviept,ax
	call movie
	jnc dal2
	mov moviept,offset mscena
dal2:	mov ax,moviept
	mov ndscena,ax
	pop moviept
	call draw	
	call snow
	call video
	call kstop
	jmp op1

	align 2
ndscena	dw mscena
scena	dw 100,0,scenab		;kopce
	dw -2, 0,-200,0, 0,0,0, 0,-500,0, 0,0,30
	dw dmountain, 0,50,2000, 0,0,0, 0,50,2000,0,0,0
	dw dmountain, 0,50,1000, 0,0,0, 0,50,1000,0,0,0
	dw dmountain, -1500,50,1000, 0,0,178, -1500,50,1000,0,0,178
	dw -1
scenab	dw 100,0,-1
	dw -2, 0,-500,0, 0,0,30, 0,-200,0, 0,0,0
	dw dmountain, 0,50,1000, 0,0,0, 0,50,1000,0,0,0
	dw dmountain, 0,50,2000, 0,0,0, 0,50,2000,0,0,0
	dw dmountain, -1500,50,1000, 0,0,178, -1500,50,1000,0,0,178
	dw -1

mscena	dw 100,0,mscenab	;stromy
	dw -2, 0,-200,0, 0,0,0, 0,-500,0, 0,0,30
	dw dstromi4, 500,0,500, 0,0,0, 500,0,500, 0,0,0
	dw dstromi4, -500,0,500, 0,0,64, -500,0,500, 0,0,64
	dw dstromi4, -1000,0,500, 0,0,-64, -1000,0,500, 0,0,-64
	dw dstromi4, -400,0,700, 0,0,112, -400,0,700, 0,0,112
	dw dstromi3, -200,0,300, 0,0,112, -200,0,300, 0,0,112
	dw dstromi3,  150,0,350, 0,0,112,  150,0,350, 0,0,112
	dw dstromi3,   50,0,550, 0,0,112,   50,0,550, 0,0,112
	dw dstromi2,  250,0,250, 0,0,112,  250,0,250, 0,0,112
	dw dstromi2, -130,0,450, 0,0,112, -130,0,450, 0,0,112
	dw dstroml,  -550,0,400, 0,0, 38, -550,0,400, 0,0, 38
	dw dstroml,  -650,0,300, 0,0, 38, -650,0,300, 0,0, 38
	dw dstlp,    -700,0,400, 0,0, 0, -700,0,400, 0,0, 0
	dw dstlp,    -800,0,1000, 0,0, 0, -800,0,1000, 0,0, 0
	dw dauto,     600,0,150, 0,0,128,-500,0,150, 0,0,128
	dw dauto,    -500,0,200, 0,0,0, 600,0,200, 0,0,0
	dw -1
mscenab	dw 100,0,-1
	dw -2, 0,-500,0, 0,0,30, 0,-200,0, 0,0,0
	dw dstromi4, 500,0,500, 0,0,0, 500,0,500, 0,0,0
	dw dstromi4, -500,0,500, 0,0,64, -500,0,500, 0,0,64
	dw dstromi4, -1000,0,500, 0,0,-64, -1000,0,500, 0,0,64
	dw dstromi4, -400,0,700, 0,0,112, -400,0,700, 0,0,112
	dw dstromi3, -200,0,300, 0,0,112, -200,0,300, 0,0,112
	dw dstromi3,  150,0,350, 0,0,112,  150,0,350, 0,0,112
	dw dstromi3,   50,0,550, 0,0,112,   50,0,550, 0,0,112
	dw dstromi2,  250,0,250, 0,0,112,  250,0,250, 0,0,112
	dw dstromi2, -130,0,450, 0,0,112, -130,0,450, 0,0,112
	dw dstroml,  -550,0,400, 0,0, 38, -550,0,400, 0,0, 38
	dw dstroml,  -650,0,300, 0,0, 38, -650,0,300, 0,0, 38
	dw dstlp,    -700,0,400, 0,0, 0, -700,0,400, 0,0, 0
	dw dstlp,    -800,0,1000, 0,0, 0, -800,0,1000, 0,0, 0
	dw dauto,     600,0,150, 0,0,128,-500,0,150, 0,0,128
	dw dauto,    -500,0,200, 0,0,0, 600,0,200, 0,0,0
	dw -1

akruh	macro xx,yy,zz,rr,c
	dw c, xx,yy-rr,zz, xx-rr/2,yy-rr/2,zz, xx-rr,yy+rr,zz, xx,yy+rr,zz
	dw c, xx,yy-rr,zz, xx+rr/2,yy-rr/2,zz, xx+rr,yy+rr,zz, xx,yy+rr,zz
	endm

dauto:	kvader -100,-15,-15, 100,-5,30, 138,139,140
	kvader 0,-15,-15, 5,-30,30, 138,139,140
	kvader 5,-15,-15, 30,-27,30, 112,113,114
	kvader 35,-15,-15, 5,-5,30, 138,139,140
	kvader -80,-20,-15, 80,-35,30, 19,20,21
	akruh -70,-7,-15, 7,17
	akruh -70,-7, 15, 7,17
	akruh  15,-7,-15, 7,17
	akruh  15,-7, 15, 7,17
	dw -1 ;zakoncovak


dmountain:
    spic -1000,0,250, -500,0,0, -500,0,500, -750,-730,250, 25,26,23
    strecha -500,0,0, 0,0,0, 0,0,500, -500,0,500, -250,-900,250, 25,26,27,25
    spic 1000,0,250, 500,0,0, 500,0,500, 750,-800,250, 27,26,25
    strecha 500,0,0, 0,0,0, 0,0,500, 500,0,500, 250,-750,250, 25,23,26,25
    spic 0,0,0, 250,0,-500, 500,0,0, 250,-650,-250 27,26,25
    dw -1	;zakoncovak


	
snowd	dw 639	;pripocet riadku
	dw 0,40058,300	;poc.h.,poc.prip.,pocet,farba
	db 100
	dw 319
	dw 856,49371,400
	db 101
	dw 959
	dw 587,50345,170
	db 102
	dw 0	;zakoncovak

snow:	mov si,offset snowd	;snezenie
snow1:	lodsw
	or ax,ax
	jz snow3
	mov bx,ax
	lodsw
	mov di,ax
	lodsw
	mov dx,ax
	lodsw
	mov cx,ax
	lodsb
	mov ah,al
	add di,bx
	mov [si-7],di
	neg bx
snow2:	mov es,vbuf
	mov es:[di],ah
	inc dx
	add di,dx
	loop snow2
	jmp snow1
snow3:	retn

land:	push objx objy objz objxy objzy objxz 
	push camx camz camxy camzy camxz fs
	xor ax,ax
	mov camx,ax
	mov camz,ax
	mov camxy,ax
	mov camzy,ax
	mov camxz,ax
	mov objx,ax
	mov objy,ax
	mov objz,ax
	mov objxy,ax
	mov objzy,ax
	mov objxz,ax
	call pclear
	push cs
	pop fs
	mov si,offset landcolor
	call tran
	call draw
	pop  fs camxz camzy camxy camz camx 
	pop objxz objzy objxy objz objy objx
	retn
landcolor dw 24	;farba zeme
	dw -500,0,0, 500,0,0, 2300,0,3000, -2000,0,3000
	dw -1


dstromi4 dw 114, -10,0,-10, 10,0,-10, 10,-40,-10, -10,-40,-10
	 dw 115,  10,0,-10, 0,0,10, 0,-40,10, 10,-40,-10
	 dw 116, -10,0,-10, 0,0,10, 0,-40,10, -10,-40,-10
	spic -50,-20,-50, 50,-20,-50, 0,-20,55, 0, -70,0, 117,120,123
	spic -50,-50,-50, 50,-50,-50, 0,-50,55, 0,-100,0, 117,120,123
	spic -50,-80,-50, 50,-80,-50, 0,-80,55, 0,-130,0, 117,120,123
	spic -30,-110,-30, 30,-110,-30, 0,-110,33, 0,-155,0, 117,120,123
	dw -1	;zakoncovak
dstromi3 dw 114, -10,0,-10, 10,0,-10, 10,-40,-10, -10,-40,-10
	 dw 115,  10,0,-10, 0,0,10, 0,-40,10, 10,-40,-10
	 dw 116, -10,0,-10, 0,0,10, 0,-40,10, -10,-40,-10
	spic -50,-20,-50, 50,-20,-50, 0,-20,55, 0, -70,0, 117,120,123
	spic -50,-50,-50, 50,-50,-50, 0,-50,55, 0,-100,0, 117,120,123
	spic -30,-80,-30, 30,-80,-30, 0,-80,33, 0,-125,0, 117,120,123
	dw -1	;zakoncovak
dstromi2 dw 114, -10,0,-10, 10,0,-10, 10,-40,-10, -10,-40,-10
	 dw 115,  10,0,-10, 0,0,10, 0,-40,10, 10,-40,-10
	 dw 116, -10,0,-10, 0,0,10, 0,-40,10, -10,-40,-10
	spic -50,-20,-50, 50,-20,-50, 0,-20,55, 0, -70,0, 117,120,123
	spic -30,-50,-30, 30,-50,-30, 0,-50,33, 0,-95,0, 117,120,123
	dw -1	;zakoncovak
dstromi1: spic -40,0,-40, 40,0,-40, 0,0,44, 0,-130,0, 117,120,123
	dw -1
dstroml: kvader -20,0,-20, 40,-50,40, 114,116,115
	kvader -35,-50,-35, 70,-70,70, 117,120,123
	dw -1
dstlp	dw 18,-20,0,-10, -20,0,10, -20,-250,10, -20,-250,-10	;el.stlp
	dw 18, 20,0,-10,  20,0,10,  20,-250,10,  20,-250,-10
	dw 20,-20,-250,10, -20,-250,-10, 20,-250,-10, 20,-250,10
	dw 18,-20,-250,10, -20,-250,-10, 0,-280,-10, 0,-280,10
	dw 18, 20,-250,-10, 20,-250,10, 0,-280,10,  0,-280,-10
	dw 20,-20,-200,10, -20,-200,-10, 20,-200,-10, 20,-200,10
	dw 20, -20,-200,10, -20,-200,-10, -80,-230,0, -80,-230,0
	dw 20, -20,-250,10, -20,-250,-10, -80,-280,0, -80,-280,0
	dw 20,  20,-200,10,  20,-200,-10,  80,-230,0,  80,-230,0
	dw 20,  20,-250,10,  20,-250,-10,  80,-280,0,  80,-280,0
	dw -1


spacend
