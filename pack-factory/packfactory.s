
	jmp	Start
; - - - - - - - Poustawiaj sobie !!! - - - - - - - - - - - -
Ruch1=2         ;predkosc ruchu paskow w gøre  - musi byc podzielne przez 2
Ruch2=6         ;predkosc ruchu paskow na boki - musi byc podzielne przez 2
Fajne=$ffff	;chropowatosc paska. zwyk£y = $ffff(fajnie jest $fff7,$fff9itp.
ColorPas=15	;cos w stylu koloru paskow. fajnie jest np. 15, -14
		; normalnie 8
Filter=$0fff	; Jakæ skladowæ koloru RGB wykluczyç z paskøw. np. $0f0f
		; nie b©dzie zielonego.
ColorPaska=$0a8f	;(do wybierania) w RGB
ilepozycji=5	; ile jest pozycji do wybrania. Jeßli wpiszesz za ma£o
		; to mo±esz spotkaç mistrza Guru., ew. skopaç ekran.
		; max. 16 !
JakiRuch=$fF	; co ile ma skaksc menus. np: $f0- co 16, $f8 - co 8,
		;$fe - co 2,  $ff - co 1.
text	; pierwsze 4 linie mo±na wyko±ystaç (ya!) na jakieß rø±ne ±eczy np. nr.
	dc.b	'                      ',13
	dc.b	'                      ',13 ; text musi byç w ' '
	dc.b	'        ISSUE 003     ',13            ;,13 to koniec lini
	DC.B	'                      ',13              ; nieuzywaj tab'a
	DC.B	'  INTRO BY COMPACT ',13; od tæd mozna wpisywc nazwy.
	DC.B	'  INTRO BY SWING ',13
	DC.B	'  HC 14 BY JORMA ',13
	DC.B    '  YODEL VONFERENCE INTRO ',13
	dc.b	0        ;0 to koniec textu
	even	
; Max. 16. pozycji.

scrolltext
	dc.b	' RMB CACHE OFF   WLCOME IN A NEW ISSUE OF PACK FACTORY BY ILLUSION. CREDITS  CODE BY NIUNIEK OF ILLUSION, GFX BY MAGOR OF PIL, MUSIC BY MTC OF ILLUSION.  ASCII LOGO BY TROPPER OF ANALOG,  SUPPORT BY BLAST OF ENERGY.  FOR SUPPORT THIS PACK WRITE TO:   QBA OF ILLUSION    P.O. BOX 105    12-100 SZCZYTNO    POLAND (THIS ADDY ALSO FOR SWAP).   NOW GREETZ FROM QBA TO: ABYSS (SKINDIVER), ALCATRAZ (STING), ANALOG (TROPPER), APPENDIX (ESC), APPLAUSE (BACKFIRE, LOVELY, PHANTOM, ROBERTS), ARISE (VIRUS), BLAZE (SKY, SLAYER), BONZAI (MDB), BRONX (TURBO), CASYOPEA (BARTESEK, EDI), CREDO, (TORMENTOR), DAMAGE (MEPHI, MIKLESZ), DAMONES (MESSERSCHMITT), DELICIOUS (DADDY FREDDY), DIFFUSION (ASTRAL), D.N.A. (JARKO), EFFECT (RADAVI), ENERGY (BLAST), ESKIMOS (DANY KANE), F.C.I. (CARLO, CHMIEL, DREAMER, ZIBI), FUN FUCTORY (QQLEK), FUNZINE (METAL), GENERATION (CDX), GRAVITY (ADOX), HUMANS (JUTU, SCRABY), IDK (UFO), INFECTION (RADZIK), ILLUSION (AXEL D., DEATH ANGEL, NIUNIEK, PEPE, RYGAR, SIGGE, STAN, THE KING, VEROX), INDEPENDET (ANDREAS, DESTROY, MARCO, PABLO), INTENSE (FICTION), INTERACTIVE (DODGER), INQUISITION (ENDER),  IRIS (MINO 63, PANTERA), KEFRENS (ZINKO), LAMERS (LAMESOFT), LBD (RANGER), LIME (GROGGY), LSD (DENZIL), MAD ELKS (ALICE, ALIS, AVENGER, IRON, RED MAN), MAGIC 12 (ZOZO), MAYHEM (GOOCIOO), METRO (KURSEN), MYSTIC (MARS, XTD), OBSCENE (AIR), OBSESSION (LATRO, WARHAWK), ORION (CHITIN, VADIUM), OUTLAWS (FATE), PIL (GOODMAN, MAGOR), PLC (MOWGLIE), POLKA BROTHERS (ZINKO), PRIDE (DOMIN, KAJETAN), PSL (CORNER), PULSE (DONK), RAM JAM (MOGUL), RAZOR 1911 (COLORBIRD), REVOLT CELLS (SZUWAR), S!P (GENERAL LEE), SAINTS (WOOBER), SAINTS GROUP (ARAGO), SCOOPEX (CHRIS, MR.KING), SCOPE (TRASH HEAD, QWERTY), SKULLS (LARRY), SPASM (OXTONE), SPEEDY (BREAK BEAT), STATUS O.K. (GOSCIAK), SUSPIRIA (FERIX), SYGMA (TESUO), TECHNOLOGY (IMMORTAL), TILT (EXOLON), TURNIPS (DR.MULAK), THE EDGE (BODZIO, UNHOLY), THE WAVE (CETRIX), TRANCE (PRODIGY), TRSI (BALD HORSE, NORBY, PYTHON, TEES), UNLIMITED (THE BRAIN), VALUM (DEVTER), VEGA (KRATKA), X-TREME (PET)   '
	DC.B	'        TEXT RESTART                 '
	DC.B	' ',0
	even
; w scrollu tak samo, (tylko niema konca lini) 
; Musi byc duzymi literami !. Na koncu textu postaw kilkanascie spacji !
; Poniewaz Magor nienarysoawal wszystkich fontow to musisz uwazac.!!!


;-----------------

intlib:	dc.b	'intuition.library',0
intbase	dc.l	0
scree	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
sin	DC.W	$1,$1,$1,$2,$2,$2,$3,$3,$3,$4,$4,$4,$4,$5,$5,$5,$5,$6,$6,$6,$6,$7,$7,$7,$7,$8,$8,$8,$8,$8,$9,$9,$9,$9,$9,$9,$9,$9,$a,$a,$a,7,0
	dc.l	0,0,0,0,0,0
X	DC.w	0
y	dc.w	70

;-----------------

start	
	lea	$dff000,a6
	move.l	$4.w,a6
	jsr	-$78(a6)
	jsr	-$84(a6)	
	lea	Intlib(pc),a1
	move.l	$4.w,a6
	clr.l	d0
	jsr	-$228(a6)
	move.l	d0,a6
	move.l	d0,intbase
	move.l	60(a6),a4
	move.l	a4,scree
	lea	sin,a5
mov	move.w	(a5)+,d1
	beq.b	startq
	clr.l	d0
	move.l	a4,a0
;	jsr	-$a2(a6) ;postaw ; przed jsr jez Eli ma niebyc opadania ekranu
	bra.b	mov
Startq	jsr	mt_init
	clr.l	d6
	jsr	ScreenInit
	clr.l	d6
	bra.W	Postaw

main	cmpi.b	#$2f,$dff006
	bne.b	MAIN

	bsr.w	sinusek
	BSR.W	WPISZSINUSEK
	bsr.w	mt_music
	bsr.w	sprpoz
tu	bsr.w	scroll
	btst	#2,$dff016
	bne	niemap
	bsr.w	mt_end
	move.l	$4.w,a6
	lea	graflib(pc),a1
	clr.l	d0 
	jsr	-$228(a6)
	move.l	d0,a0

	move.l	38(a0),a0
	move.l	a0,$dff080
	clr.w	$dff088
	moveq	#0,d0
map	btst	#2,$dff016
	beq	map
	lea	kill(pc),a5
	move.l	$4.w,a6
	move.w	296(a6),d6
	btst	#1,d6
	beq	palant
	jsr	-$30(a6)
palant
	lea	Intlib,a1
	clr.l	d0
	jsr	-$228(a6)
	move.l	d0,a6
	lea	sin,a5
kqmov	move.w	(a5)+,d1
	beq	koniec
	neg.w	d1
	clr.l	d0
	move.l	scree,a0
	jsr	-$a2(a6)
	bra	kqmov
*****************************************************************************
niemap	btst	#$6,$bfe001
	bne.w 	main
exit:	bsr.w	mt_end
	move.l	$4.w,a6
	lea	graflib(pc),a1
	clr.l	d0 
	jsr	-$228(a6)
	move.l	d0,a0

	move.l	38(a0),a0
	move.l	a0,$dff080
	clr.w	$dff088
	moveq	#0,d0

	lea	Intlib,a1
	move.l	$4.w,a6
	clr.l	d0
	jsr	-$228(a6)
	move.l	d0,a6
	lea	sin,a5
qmov	move.w	(a5)+,d1
	beq	koniec
	neg.w	d1
	clr.l	d0
	move.l	scree,a0
	jsr	-$a2(a6)
	bra	qmov
koniec	move.l	$4.w,a6
	jsr	-$7e(a6)
	jsr	-$8a(a6)
	move.W	WEKTO,d0
	divu	#16,d0
	addq	#1,d0	
	move.w	d0,0
	moveq	#0,d0
	rts
kill	dc.l	$4e7a0002
	andi.l	#$80004000,d0 ;cache off
	dc.l	$4e7b0002
	rte
;*/*/*/*/*/*/*/*/*/*/*/*/**/
sprpoz		lea	$dff000,a6
		BTST	#14,$02(A6)
		BNE.B	sprpoz
		MOVE.l	#$ffffffff,$44(A6)
		MOVE.L	#$09f00000,$40(A6)	;USE A,D LFx :D=A
		MOVE.L	#$000000AA,$64(A6)
		lea	Menus,a0
		clr.l	d0
		move.w	wekto(PC),d0
		mulu	#30,d0
		add.l	d0,a0
		move.l	a0,$50(A6)	;SOURC
		MOVE.L	#obraz+200*60+40,$54(A6)	;DEST
		MOVE.W	#156*64+30/2,$58(a6)
		clr.W	d0
		move.b	$dff00a,d0
		and.b	#jakiruch,d0
		cmp.b	#(ilepozycji*16)-16,d0
		bcc	rt
		cmp.b	#0,d0
		bls	rt2
		
		move.w	d0,wekto
		rts

rt		move.w	#(ilepozycji*16)-16,wekto
		rts	
rt2		move.w	#0,wekto
		rts	
;*/*/*/*/*/*/*/*/*/*/*/*/**/
scroll		addq.w	#1,d6
 		cmpi.w	#8,d6
 		bne.b	SCROLL2
		moveq	#1,d6		
scroll2		BTST	#14,$02(A6)
		BNE.B	scroll2
		MOVE.l	#$0fffffff,$44(A6)
		MOVE.l	#$29f00002,$40(A6)
		clr.l	$64(A6)
		MOVE.L	#obraz2+200*33,$50(A6)	;SOURCE
		MOVE.L	#obraz2+200*33,$54(A6)	;DEST
		MOVE.W	#32*5*64+40/2,$58(a6)

scroll3		BTST	#14,$02(A6)
		BNE.B	scroll3
		MOVE.l	#$ffffffff,$44(A6)
		MOVE.l	#$09f00000,$40(A6)	;USE A,D LFx :D=A
		MOVE.l	#$000a000a,$64(A6)
		MOVE.L	#obraz2,$50(A6)	;SOURC
		MOVE.L	#obraz+200*220,$54(A6)	;DEST
		MOVE.W	#32*5*64+30/2,$58(a6)

		cmp.w	#1,d6
		bne.b	lenin
		lea	scrolltext(pc),a0
		move.w	licz(pc),d0
		clr.l	d1
		move.b	(a0,d0.w),d1
		addQ.w	#1,licz
		tst.b	d1
		bne.b	scrollcont
		clr.w	licz
		RTS

scrollcont	sub.b	#32,d1
		lea	fontyb,a2
		lsl.w	#1,d1; pok
		add.l	d1,a2
		lea	obraz2+38,a1
		move.l	#33*5,d7
staw		move.w	(a2),(a1)
		;or.w	#$ffff,(a1)
		add.l	#118,a2
		add.l	#40,a1
		dbf	d7,staw
lenin		rts
;*/*/*/*/*/*/*/*/*/*/*/*/**/
postaw:	clr.w	x
	clr.w	y
	lea	text,a0
Ploop	clr.l	d0
	move.b	(a0)+,d0
	beq.w	tu
	cmp.b	#13,d0
	beq.b	PnextL
	addq.w	#1,x
	cmp.b	#' ',d0
	beq.b	qasw
	sub.b	#48,d0	;	zmien to !!!!!!!!!!!!
	bra.b	wystawianka
qasw	move.b	#91-48,d0
wystawianka
	lea	Menus,a1
	clr.l	d2
	move.w	x,d2
	add.l	d2,a1
	clr.l	d2
	move.w	y(pc),d2
	mulu	#30,d2
	add.l	d2,a1 ;tu postaw
wystawiankaII
	lea	fonty8,a2
	add.l	d0,a2
	move.l	#12,d7
klov	move.b	(a2),(a1)
	add.l	#30,a1
	add.l	#44,a2
	dbf	d7,klov
	bra.b	Ploop	

PnextL	add.w	#16,y
	clr.w	x
	bra.b	ploop
screeninit
	lea	cooperlist(pc),a1
	lea	obraz,a0
	move.l	a0,d0
	move.w	#5-1,d1;ilosc bitplanøw-1
wpisz	move.w	d0,6(a1)
       	swap	d0
       	move.w	d0,2(a1)
	swap	d0
	add.l	#40,d0;Szerokosc ekranu 
	addq.l	#8,a1
	dbf	d1,wpisz
	lea	cooperlist(pc),a1
  	move.l	a1,$dff080
  	clr.w	$dff088
 	rts
;*/*/*/*/*/*/*/*/*/*/*/*/**/
wpiszsinusek:
	lea	bufbuf(pc),a4
	lea	buf(pc),a0
	move.l	#$6401fffe,d0
	move.l	#155,d7
wsLoop	add.l	#$01000000,d0
	cmp.l	mod,d0
	bne.b	asa
	move.l	d0,(a0)+
	move.w	#$0186,(a0)+
	move.w	#colorpaska,(a0)+
	move.w	#$0184,(a0)+
	move.w	#colorpaska,(a0)+
asa
	cmp.l	mod2,d0
	bne.b	asa2
	move.l	d0,(a0)+
	move.l	#$01860fce,(a0)+
	move.l	#$01840fce,(a0)+
asa2
	cmp.l	#$ff01fffe,d0
	bne.b	wsCont
	move.l	#$ffdffffe,(a0)+
	move.l	#$0001fffe,d0
WsCont	move.l	d0,(a0)+
	move.w	(a4)+,d5
	move.l	(a4)+,d1
	swap	d1
	move.w	#$00e0,(a0)+
	move.w	d1,(a0)+
	move.w	#$00e2,(a0)+
	swap	d1
	move.w	d1,(a0)+
	move.w	#$0182,(a0)+
	or.w	#%0000000000001111,d5
	sub.w	#colorpas,d5
	and.w	#filter,d5
	move.w	d5,(a0)+
	dbf	d7,wsloop
	move.l	#$01820000,(a0)+
	move.l	#obraz+200*220,d0
;	move.l	#pac,d0
	move.l	#$0501fffe,d1
	move.l	d1,(a0)+
	move.l	#$01800111,(a0)+
	swap	d0
	move.w	#$e0,(a0)+
	move.w	d0,(a0)+
	move.w	#$e2,(a0)+
	swap	d0
	move.w	d0,(a0)+
	lea	DupafrajerMojamama,a1
	move.l	#31,d0
poprawkolory
	move.l	(a1)+,(a0)+
	dbf	d0,poprawkolory
	move.l	#-2,(a0)+
	rts
;*/*/*/*/*/*/*/*/*/*/*/*/**/
licz	dc.l	0
wekto	dc.w	0
mod	dc.l	$a501fffe
mod2	dc.l	$b501fffe
cooperlist:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
	dc.w	$00e8,$0000
	dc.w	$00ea,$0000
	dc.w	$00ec,$0000
	dc.w	$00ee,$0000
	dc.w	$00f0,$0000
	dc.w	$00f2,$0000
	dc.w	$1fc,$0000
	dc.l	$01200000
	dc.l	$01220000
	dc.l	$01240000
	dc.l	$01260000
	dc.l	$01280000
	dc.l	$012a0000
	dc.l	$012c0000
	dc.l	$012e0000
	dc.l	$01300000
	dc.l	$01320000
	dc.l	$01340000
	dc.l	$01360000
	dc.l	$01380000
	dc.l	$013a0000
	dc.l	$013c0000
	dc.l	$013e0000

	dc.w	$0104,$0024
	dc.w	$008e,$2981,$0090,$29c1,$0092,$0038,$0094,$00d0
	dc.w	$0100,$5200,$010a,$00a0,$0108,$00a0
cop1:	dc.w	$0180,$0000,$0182,$0FDF,$0184,$0fdf,$0186,$0fdf,$0188,$0666,$018A,$0666,$018C,$0777,$018E,$0888,$0190,$0999,$0192,$0AA9,$0194,$0BBA,$0196,$0CCB,$0198,$0DDC,$019A,$0EED,$019C,$0FFE,$019E,$0FFF,$01A0,$0111,$01A2,$0222,$01A4,$0333,$01A6,$0444,$01A8,$0555,$01AA,$0666,$01AC,$0777,$01AE,$0888,$01B0,$099A,$01B2,$0AAB,$01B4,$0AAC,$01B6,$0BBD,$01B8,$0CCE,$01BA,$0DDF,$01BC,$0EEE,$01BE,$0FFF
BUF	BLK.L	 170*4,$01800000
	dc.w    $ffff,$fffe

Dupafrajermojamama: dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000,$0188,$0000,$018A,$0777,$018C,$0888,$018E,$0999,$0190,$0222,$0192,$0BBA,$0194,$0AAC,$0196,$0CCE,$0198,$0DDC,$019A,$0EED,$019C,$0FFE,$019E,$0FFF,$01A0,$0111,$01A2,$0222,$01A4,$0333,$01A6,$0444,$01A8,$0555,$01AA,$0666,$01AC,$0777,$01AE,$0888,$01B0,$099A,$01B2,$0AAB,$01B4,$0AAC,$01B6,$0BBD,$01B8,$0CCE,$01BA,$0DDF,$01BC,$0EEE,$01BE,$0FFF,$01BE,$0FFF,$01BE,$0FFF
bufbuf	blk.w	180*3,0

sinusek	MOVE.L	WskSinI(pc),A0
	MOVE.L	SinusII(pc),A1
	MOVE.W	#160,D5
	lea	bufbuf,a4
sinLoop	MOVE.W	(A0)+,D0
	asl.w	#1,d0
	add.W	(A1)+,D0
	cmp.w	#$ff,d0
	bls.b	gfg
	move.w	#$ff,d0
gfg	and.w	#fajne,d0
	move.w	d0,(a4)+
	lea	paski,a2
	mulu	#40,d0
	
	add.l	d0,a2
	MOVE.L	A2,(A4)+

	DBRA	D5,sinLoop
	ADD.L	#Ruch1,WskSinI
	CMPi.L	#SinusIII,WskSinI
	BLT.S	SinCont
	MOVE.L	#lbL0018C0,WskSinI
SinCont	ADD.L	#ruch2,sinusII
	CMP.L	#lbL002142,sinusII
	BLT.S	lbC00075C
	MOVE.L	#lbL001F04,sinusII
lbC00075C
	rts
WskSinI	dc.l	lbL0018C0

graflib	dc.b	'graphics.library',0
	even
pomoc		dc.w	0
ostatniawart	dc.w	0

;| **** Protracker V1.0C  Playroutine **** |
; mt_chanXtemp offsets
n_note		EQU	0  ; W
n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; low B of n_cmd
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; W

mt_init	LEA	mt_data,A0
	MOVE.L	A0,mt_SongDataPtr
	MOVE.L	A0,A1
	LEA	952(A1),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
mtloop	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT	mtloop
	DBRA	D0,mtloop2
	ADDQ.B	#1,D2
			
	LEA	mt_SampleStarts(PC),A1
	ASL.L	#8,D2
	ASL.L	#2,D2
	ADD.L	#1084,D2
	ADD.L	A0,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	42(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	#30,A0
	DBRA	D0,mtloop3

	OR.B	#2,$BFE001
	MOVE.B	#6,mt_speed
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	CLR.B	mt_counter
	CLR.B	mt_SongPos
	CLR.W	mt_PatternPos
	RTS

mt_end	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	MOVE.W	#$F,$DFF096
	RTS

mt_music
	MOVEM.L	D0-D4/A0-A6,-(SP)
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ	mt_GetNewNote
	BSR	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	$DFF0A0,A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	$DFF0B0,A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	$DFF0C0,A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	$DFF0D0,A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PatternPos(PC),D1
	CLR.W	mt_DMACONtemp

	LEA	$DFF0A0,A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_PlayVoice
	LEA	$DFF0B0,A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_PlayVoice
	LEA	$DFF0C0,A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_PlayVoice
	LEA	$DFF0D0,A5
	LEA	mt_chan4temp(PC),A6
	BSR	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE	mt_plvskip
	BSR	mt_PerNop
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ	mt_NoLoop
	MOVE.L	n_start(A6),D2	; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2		; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0	; Get repeat
	ADD.W	6(A3,D4.L),D0	; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
	BRA	mt_SetRegs

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D7
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS	mt_ftufound
	ADDQ.L	#2,D0
	DBRA	D7,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	ADD.L	D1,A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ	mt_CheckMoreEfx

	MOVE.W	n_dmabit(A6),$DFF096
	BTST	#2,n_wavecontrol(A6)
	BNE	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),(A5)	; Set start
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,6(A5)		; Set period
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.W	#300,D0
mt_WaitDMA
	DBRA	D0,mt_WaitDMA
	MOVE.W	mt_DMACONtemp(PC),D0
	OR.W	#$8000,D0
	MOVE.W	D0,$DFF096
	MOVE.W	#300,D0
mt_WaitDMA2
	DBRA	D0,mt_WaitDMA2

	LEA	$DFF000,A5
	LEA	mt_chan4temp(PC),A6
	MOVE.L	n_loopstart(A6),$D0(A5)
	MOVE.W	n_replen(A6),$D4(A5)
	LEA	mt_chan3temp(PC),A6
	MOVE.L	n_loopstart(A6),$C0(A5)
	MOVE.W	n_replen(A6),$C4(A5)
	LEA	mt_chan2temp(PC),A6
	MOVE.L	n_loopstart(A6),$B0(A5)
	MOVE.W	n_replen(A6),$B4(A5)
	LEA	mt_chan1temp(PC),A6
	MOVE.L	n_loopstart(A6),$A0(A5)
	MOVE.W	n_replen(A6),$A4(A5)

mt_dskip
	ADD.W	#16,mt_PatternPos
	MOVE.B	mt_PattDelTime,D0
	BEQ	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ	mt_dska
	SUB.W	#16,mt_PatternPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
mt_nnpysk
	CMP.W	#1024,mt_PatternPos
	BLO	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO	mt_NoNewPosYet
	CLR.B	mt_SongPos
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag
	BNE	mt_NextPosition
	MOVEM.L	(SP)+,D0-D4/A0-A6
	RTS

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),6(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return2
	RTS

mt_PerNop
	MOVE.W	n_period(A6),6(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#36,D7
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BHS	mt_Arpeggio4
	ADDQ.L	#2,A0
	DBRA	D7,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	D2,6(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ	mt_StpGoss
	TST.W	D0
	BEQ	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ	mt_ClearTonePorta
	BGE	mt_Return2
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS	mt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA	mt_vib_set
mt_vib_sine
	MOVE.B	0(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI	mt_VibratoNeg
	ADD.W	D2,D0
	BRA	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA	mt_tre_set
mt_tre_sine
	MOVE.B	0(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI	mt_TremoloNeg
	ADD.W	D2,D0
	BRA	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,8(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ	mt_Return2
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
	CMP.B	#$F,D0
	BEQ	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	RTS	

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ	mt_SetFineTune
	CMP.B	#6,D0
	BEQ	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#1,D0
	ASL.B	#1,D0
	AND.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ	mt_jumpcnt
	SUB.B	#1,n_loopcount(A6)
	BEQ	mt_Return2
mt_jmploop	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE	mt_rtnskp
	MOVE.W	n_note(A6),D1
	AND.W	#$0FFF,D1
	BNE	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE	mt_rtnend
mt_DoRetrig
	MOVE.W	n_dmabit(A6),$DFF096	; Channel DMA off
	MOVE.L	n_start(A6),(A5)	; Set sampledata pointer
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	#300,D0
mt_rtnloop1
	DBRA	D0,mt_rtnloop1
	MOVE.W	n_dmabit(A6),D0
	BSET	#15,D0
	MOVE.W	D0,$DFF096
	MOVE.W	#300,D0
mt_rtnloop2
	DBRA	D0,mt_rtnloop2
	MOVE.L	n_loopstart(A6),(A5)
	MOVE.L	n_replen(A6),4(A5)
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return2
	CLR.B	n_volume(A6)
	MOVE.W	#0,8(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_Counter,D0
	BNE	mt_Return2
	MOVE.W	(A6),D0
	BEQ	mt_Return2
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return2
mt_UpdateFunk
	MOVEM.L	A0/D1-D2,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ	mt_funkend
	CLR.B	n_funkoffset(A6)

	MOVE.L	n_start(A6),D1
	MOVEQ	#0,D2
	MOVE.W	n_reallength(A6),D2
	LSL.W	#1,D2
	ADD.L	D2,D1
	MOVE.W	n_replen(A6),D2
	LSL.L	#1,D2
	SUB.L	D2,D1

	MOVE.L	n_wavestart(A6),D2
	MOVEQ	#0,D0
	MOVE.W	n_replen(A6),D0
	LSL.L	#1,D0
	ADD.L	D0,D2
	CMP.L	D1,D2
	BLS	mt_funkok
	MOVE.L	n_loopstart(A6),D2
mt_funkok
	MOVE.L	D2,n_wavestart(A6)
	MOVE.L	D2,(A5)
mt_funkend
	MOVEM.L	(SP)+,A0/D1-D2
	RTS


mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	dc.l	0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,0,$00080000,0,  0,0,0,0

mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr	dc.l 0

mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0
		dc.b 0

mt_PatternPos	dc.w 0
mt_DMACONtemp	dc.w 0


lbL0018C0
	dc.l	$4D004F,$4F0050,$50004F,$4F004D,$4C004A,$480046,$430041,$3E003B,$380036
	dc.l	$330030,$2E002C,$2A0029,$280027,$260026,$260027,$28002A,$2C002E,$300033
	dc.l	$360039,$3D0040,$430047,$4A004D,$510054,$560059,$5B005D,$5E005F,$600060
	dc.l	$60005F,$5E005D,$5B0059,$570054,$52004F,$4C0049,$460043,$40003D,$3B0038
	dc.l	$360035,$330032,$310031,$310032,$320034,$350037,$39003C,$3F0041,$440048
	dc.l	$4B004E,$510054,$57005A,$5C005E,$600061,$620063,$640063,$630062,$61005F
	dc.l	$5D005B,$580056,$53004F,$4C0049,$460042,$3F003C,$390037,$340032,$30002F
	dc.l	$2E002D,$2D002D,$2E002F,$300032,$340036,$38003B,$3E0040,$430046,$49004C
	dc.l	$4E0051,$530055,$560058,$580059,$590059,$580057,$550053,$51004F,$4C0049
	dc.l	$460042,$3F003B,$380034,$31002E,$2A0028,$250023,$21001F,$1E001D,$1D001D
	dc.l	$1D001E,$1F0021,$230025,$270029,$2C002F,$320034,$37003A,$3C003E,$400042
	dc.l	$440045
	dcb.l	2,$460046
	dc.l	$450044,$420040,$3E003B,$390035,$32002F,$2B0028,$240021,$1D001A,$170014
	dc.l	$120010,$E000C,$B000A,$A000A,$B000B,$D000E,$100012,$150017,$1A001D
	dc.l	$200023,$250028,$2B002D,$2F0031,$330034,$350036,$360036,$350034,$330031
	dc.l	$2F002C,$2A0027,$240021,$1D001A,$170014,$10000D,$B0008,$60004,$20001
	dcb.l	2,0
	dc.l	$10002,$30005,$70009,$C000F,$120015,$18001B,$1F0022,$240027,$2A002C
	dc.l	$2E002F,$310031,$320032,$320031,$30002E,$2D002B,$280026,$230020,$1D001A
	dc.l	$170014,$11000F,$C000A,$80006,$50004,$30003,$30004,$50006,$8000A
	dc.l	$D000F,$120016,$19001C,$200023,$26002A,$2D0030,$330035,$370039,$3B003C
	dc.l	$3D003D,$3D003C,$3B003A,$390037,$350033,$30002D,$2B0028,$250022,$20001D
	dc.l	$1B0019,$170016,$140014,$130013,$140014,$160017,$19001B,$1E0021,$240027
	dc.l	$2A002E,$320035,$39003C
	dc.l	$3F0042,$450048,$4A004C
SinusIII	dc.l	$4D004F
	dc.l	$4F0050,$50004F,$4F004D,$4C004A,$480046,$430041,$3E003B,$380036,$330030
	dc.l	$2E002C,$2A0029,$280027,$260026,$260027,$28002A,$2C002E,$300033,$360039
	dc.l	$3D0040,$430047,$4A004D,$510054,$560059,$5B005D,$5E005F,$600060,$60005F
	dc.l	$5E005D,$5B0059,$570054,$52004F,$4C0049,$460043,$40003D,$3B0038,$360035
	dc.l	$330032,$310031,$310032,$320034,$350037,$39003C,$3F0041,$440048,$4B004E
	dc.l	$510054,$57005A,$5C005E,$600061,$620063,$640063,$630062,$61005F,$5D005B
	dc.l	$580056,$53004F,$4C0049,$460042,$3F003C,$390037,$340032,$30002F,$2E002D
	dc.l	$2D002D,$2E002F,$300032,$340036,$38003B,$3E0040,$430046,$49004C,$4E0051
	dc.l	$530055,$560058,$580059,$590059,$580057,$550053,$51004F,$4C0049,$460042
	dc.l	$3F003B,$380034,$31002E,$2A0028,$250023,$21001F,$1E001D,$1D001D,$1D001E
	dc.l	$1F0021,$230025,$270029,$2C002F,$320034,$37003A,$3C003E,$400042,$440045
	dcb.l	2,$460046
	dc.l	$450044,$420040,$3E003B,$390035,$32002F,$2B0028,$240021,$1D001A,$170014
	dc.l	$120010,$E000C,$B000A,$A000A,$B000B,$D000E,$100012,$150017,$1A001D
	dc.l	$200023,$250028,$2B002D,$2F0031,$330034,$350036,$360036,$350034,$330031
	dc.l	$2F002C,$2A0027,$240021
	dc.l	$1D001A,$170014,$10000D
	dc.l	$B0008,$60004,$20001
	dcb.l	2,0
	dc.l	$10002,$30005,$70009,$C000F,$120015,$18001B,$1F0022,$240027,$2A002C
	dc.l	$2E002F,$310031,$320032,$320031,$30002E,$2D002B,$280026,$230020,$1D001A
	dc.l	$170014,$11000F,$C000A,$80006,$50004,$30003,$30004,$50006,$8000A
	dc.l	$D000F,$120016,$19001C,$200023,$26002A,$2D0030,$330035,$370039,$3B003C
	dc.l	$3D003D,$3D003C,$3B003A,$390037,$350033,$30002D,$2B0028,$250022,$20001D
	dc.l	$1B0019,$170016,$140014,$130013,$140014,$160017,$19001B,$1E0021,$240027
	dc.l	$2A002E,$320035,$39003C
	dc.l	$3F0042,$450048,$4A004C
sinusII	dc.l	lbL001F04
lbL001F04	dc.l	$1F0020,$210022,$230024,$250027,$280029,$2A002C,$2D002F
	dc.l	$300031,$320034,$350036,$370038,$390039,$3A003B,$3B003B,$3B003C,$3B003B
	dc.l	$3B003A,$3A0039,$380038,$360035,$340033,$320030,$2F002D,$2C002A,$280027
	dc.l	$250024,$220021,$1F001E,$1C001B,$1A0019,$180017,$160015,$150014,$140013
	dc.l	$130013,$130014,$140014,$150015,$160017,$180018,$19001A,$1B001C,$1D001E
	dc.l	$1F0020,$210022,$230024
	dc.l	$250025
	dc.l	$260026
	dcb.l	3,$270027
	dc.l	$270026,$260025,$250024,$230022,$210020,$1E001D,$1C001A,$190017,$160014
	dc.l	$120011,$F000E,$C000B,$90008,$70005,$40003,$20002
	dc.l	$10000
	dcb.l	4,0
	dc.l	$10002,$20003,$40005,$60008,$9000A,$B000D,$E000F,$110012,$140015
	dc.l	$160017,$180019,$1A001B
	dc.l	$1C001D
	dc.l	$1E001E
	dcb.l	3,$1F001F
	dc.l	$1F001E,$1E001D,$1D001C
	dc.l	$1B001A,$190018,$170016
	dc.l	$150014,$130012,$110010
	dc.l	$F000E,$D000C,$B000B
	dc.l	$A0009
	dc.l	$90009
	dcb.l	2,$80008
	dc.l	$90009,$A000A,$B000C
	dc.l	$D000E,$F0010,$120013
	dc.l	$140016,$180019,$1B001E
	dc.l	$1F0021,$230024,$260027
	dc.l	$29002A,$2C002D,$2E002F
	dc.l	$300031,$320032,$330033
	dc.l	$330034,$340033,$330033
	dc.l	$320032,$310031,$30002F
	dc.l	$2E002D,$2C002B,$2A0029
	dc.l	$280026,$250024,$230022
	dc.l	$210020,$20001F,$1E001E
	dc.l	$1D001D,$1D001C,$1C001C
	dc.l	$1D001D
	dc.l	$1D001E
	dc.w	$1E
lbL002142	dc.l	$1F0020
	dc.l	$210022,$230024,$250027
	dc.l	$280029,$2A002C,$2D002F
	dc.l	$300031,$320034,$350036
	dc.l	$370038,$390039,$3A003B
	dc.l	$3B003B,$3B003C,$3B003B
	dc.l	$3B003A,$3A0039,$380038
	dc.l	$360035,$340033,$320030
	dc.l	$2F002D,$2C002A,$280027
	dc.l	$250024,$220021,$1F001E
	dc.l	$1C001B,$1A0019,$180017
	dc.l	$160015,$150014,$140013
	dc.l	$130013,$130014,$140014
	dc.l	$150015,$160017,$180018
	dc.l	$19001A,$1B001C,$1D001E
	dc.l	$1F0020,$210022,$230024
	dc.l	$250025
	dc.l	$260026
	dcb.l	3,$270027
	dc.l	$270026,$260025,$250024
	dc.l	$230022,$210020,$1E001D
	dc.l	$1C001A,$190017,$160014
	dc.l	$120011,$F000E,$C000B
	dc.l	$90008,$70005,$40003
	dc.l	$20002
	dc.l	$10000
	dcb.l	4,0
	dc.l	$10002,$20003,$40005
	dc.l	$60008,$9000A,$B000D
	dc.l	$E000F,$110012,$140015
	dc.l	$160017,$180019,$1A001B
	dc.l	$1C001D
	dc.l	$1E001E
	dcb.l	3,$1F001F
	dc.l	$1F001E,$1E001D,$1D001C
	dc.l	$1B001A,$190018,$170016
	dc.l	$150014,$130012,$110010
	dc.l	$F000E,$D000C,$B000B
	dc.l	$A0009
	dc.l	$90009
	dcb.l	2,$80008
	dc.l	$90009,$A000A,$B000C,$D000E,$F0010,$120013,$140016,$180019,$1B001E
	dc.l	$1F0021,$230024,$260027,$29002A,$2C002D,$2E002F,$300031,$320032,$330033
	dc.l	$330034,$340033,$330033,$320032,$310031,$30002F,$2E002D,$2C002B,$2A0029
	dc.l	$280026,$250024,$230022,$210020,$20001F,$1E001E,$1D001D,$1D001C,$1C001C
	dc.l	$1D001D,$1D001E,$1E

	incdir
mt_data:incbin 'pack/mod.nevermind#2'; Nazwa modu£u+sciezka 
paski	incbin 'paski2'
fontyb:	INCBIN '@FONTeraw'
menus:	blk.b	(30*16)*(ilepozycji+10),$00
fonty8:	INCBIN 'FONTY8.raw'
obraz	incbin 'pac3'
obraz2	blk.b	40*5*35,$0
	end
