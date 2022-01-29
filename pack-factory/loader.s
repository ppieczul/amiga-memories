




	lea	doslib(pc),a1
	clr.l	d0
	move.l	$4.w,a6
	jsr	-552(a6)
	move.l	d0,a6

	clr.l	d7
	move.w	$0,d7
	mulu	#4,d7
	lea	Zbiorek(pc),a5
	move.l	(a5,d7.w),d1
execute	clr.l	d2
	clr.l	d3
	jsr	-$de(a6)
	clr.l	d0
	rts

intbase	dc.b	'intuition.library',0
doslib	dc.b	'dos.library',0		; na dysku musi byç dos.library,
			; bo jak nie to b©dzie tylko na rom 2.0 lub wy±szy
Zbiorek:dc.l	PackName
	dc.l	name1,name2,name3,name4,name5,name6,name7,name8,name9,name10
	dc.l	name11,name12,name13,name14,name15,name16,name17 

name1	dc.b	'SYS:1',0 ; tu musisz wpisaç nazwy inter.
name2	dc.b	'SYS:2',0 ; niezapomnij o ,0 na koncu.
name3	dc.b	'SYS:3',0 ; niemusi byç df0:, mo±e byç sys: itp.
name4	dc.b	'SYS:4',0;jeßli nieb©dzie az tyle inter, to mo±esz wpisaç 
name5	dc.b	'SYS:5',0;byle co, wa±ne ±eby w paku by£o dobrze ustawione
name6	dc.b	'SYS:6',0;ile jest pozycji.
name7	dc.b	'SYS:7',0
name8	dc.b	'SYS:8',0
name9	dc.b	'SYS:9',0
name10	dc.b	'SYS:10',0
name11	dc.b	'SYS:11',0
name12	dc.b	'SYS:12',0
name13	dc.b	'SYS:13',0
name14	dc.b	'SYS:14',0
name15	dc.b	'SYS:15',0
name16	dc.b	'SYS:16',0
name17	dc.b	'SYS:17',0

Packname dc.b	'SYS:pack.exe',0   ;tu wpisz nazw© paka. W razie jakby coß by£o
			       ;nie tak to on si© wczyta.
