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

vrch01:	pkvrchol  1, 01,     0,     0,15,03,11	;vrcholy
vrch02:	pkvrchol  3, 02,vrch01,vrch03,15,03,11	;vrcholy
vrch03:	pkvrchol  1, 03,     0,     0,15,03,11	;vrcholy
vrch04:	pkvrchol  6, 04,vrch02,vrch06,15,03,14	;vrcholy
vrch06:	pkvrchol  2, 06,     0,vrch07,15,03,14	;vrcholy
vrch07:	pkvrchol  1, 07,     0,     0,15,03,14	;vrcholy
vrch08:	pkvrchol 14, 08,vrch04,vrch12,15,03,11	;vrcholy
vrch09:	pkvrchol  1, 09,     0,     0,15,03,14	;vrcholy
vrch10:	pkvrchol  3, 10,vrch09,vrch11,15,03,14	;vrcholy
vrch11:	pkvrchol  1, 11,     0,     0,15,03,11	;vrcholy
vrch12:	pkvrchol  7, 12,vrch10,vrch14,15,03,14	;vrcholy
vrch13:	pkvrchol  1, 13,     0,     0,15,03,11	;vrcholy
vrch14:	pkvrchol  3, 14,vrch13,vrch15,15,03,11	;vrcholy
vrch15:	pkvrchol  1, 15,     0,     0,15,03,11	;vrcholy

malystrom proc near
	push treebeg
	push treeaty
	mov treebeg,offset vrch08
	mov treeaty,120
	call tree
	pop treeaty
	pop treebeg
	retn
	endp

uvod:	wproc zaklad_p
	wat 153,38
	db wmarg,20,wco,0,'VOJENSKA AKADEMIA',wmarg,15,nl
	db '   Liptovsky Mikulas'
	wat 150,35
	db wmarg,20,wco,15,'VOJENSKA AKADEMIA',wmarg,15,nl
	db '   Liptovsky Mikulas',wmarg,17
	wat 63,373
	db wco,0,'LOZENIE PO VYVAZENYCH STROMOCH',nl,wmarg,15
	db '           ucebna pomocka',wmarg,17
	wat 61,370
	db wco,15,'LOZENIE PO VYVAZENYCH STROMOCH',nl,wmarg,15
	db '           ucebna pomocka'
	wproc malystrom
	db wlines
	line 260,245,310,280,12	;skrtanec
	line 260,280,310,245,12
	line 360,245,370,245,12	;kruh III.
	line 360,245,330,268,12
	line 370,245,380,272,12
	line 380,272,365,275,12
	line 365,275,330,268,12
	line 365,240,380,200,12	;sipka III.
	line 380,200,342,155,12
	line 338,160,338,148,12
	line 338,148,365,162,12
	line 325,113,315,113,12	;kruh II.
	line 325,113,335,124,12
	line 315,113,305,124,12
	line 335,124,335,134,12
	line 305,124,305,134,12
	line 305,134,320,144,12
	line 335,134,320,144,12
	line 312,130,280,240,12	;sipka II.
	line 270,230,280,242,12
	line 290,230,280,242,12

	line 390+020,320+000 ,440+020,350+000 , 09	;B vecko
	line 440+020,350+000 ,510+020,170+000 , 09
	line 391+020,321+000 ,441+020,351+000 , 09	;B
	line 441+020,351+000 ,511+020,171+000 , 09
	line 392+020,322+000 ,442+020,352+000 , 09	;B
	line 442+020,352+000 ,512+020,172+000 , 09
	line 393+020,323+000 ,443+020,353+000 , 01	;B
	line 443+020,353+000 ,513+020,173+000 , 01
	line 394+020,324+000 ,444+020,354+000 , 01	;B
	line 444+020,354+000 ,514+020,174+000 , 01

	line 390+010,320+000 ,440+010,350+000 , 10	;G vecko
	line 440+010,350+000 ,510+010,170+000 , 10
	line 391+010,321+000 ,441+010,351+000 , 10	;G
	line 441+010,351+000 ,511+010,171+000 , 10
	line 392+010,322+000 ,442+010,352+000 , 10	;G
	line 442+010,352+000 ,512+010,172+000 , 10
	line 393+010,323+000 ,443+010,353+000 , 02	;G
	line 443+010,353+000 ,513+010,173+000 , 02
	line 394+010,324+000 ,444+010,354+000 , 02	;G
	line 444+010,354+000 ,514+010,174+000 , 02

	line 390+000,320+000 ,440+000,350+000 , 12	;R vecko
	line 440+000,350+000 ,510+000,170+000 , 12
	line 391+000,321+000 ,441+000,351+000 , 12	;R
	line 441+000,351+000 ,511+000,171+000 , 12
	line 392+000,322+000 ,442+000,352+000 , 12	;R
	line 442+000,352+000 ,512+000,172+000 , 12
	line 393+000,323+000 ,443+000,353+000 , 04	;R
	line 443+000,353+000 ,513+000,173+000 , 04
	line 394+000,324+000 ,444+000,354+000 , 04	;R
	line 444+000,354+000 ,514+000,174+000 , 04


;----------------------------------------
	dw 64000
	wat 250,290
	db wco,12,wmarg,9,'I.'
	wat 255,190
	db 'II.'
	wat 390,180
	db 'III.'
	db wend

