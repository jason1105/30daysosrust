; haribote-ipl
; TAB=4

		ORG		0x7c00			; このプログラムがどこに読み込まれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		; ブートセクタの名前を自由に書いてよい（8バイト）
		DW		512				; 1セクタの大きさ（512にしなければいけない）
		DB		1				; クラスタの大きさ（1セクタにしなければいけない）
		DW		1				; FATがどこから始まるか（普通は1セクタ目からにする）
		DB		2				; FATの個数（2にしなければいけない）
		DW		224				; ルートディレクトリ領域の大きさ（普通は224エントリにする）
		DW		2880			; このドライブの大きさ（2880セクタにしなければいけない）
		DB		0xf0			; メディアのタイプ（0xf0にしなければいけない）
		DW		9				; FAT領域の長さ（9セクタにしなければいけない）
		DW		18				; 1トラックにいくつのセクタがあるか（18にしなければいけない）
		DW		2				; ヘッドの数（2にしなければいけない）
		DD		0				; パーティションを使ってないのでここは必ず0
		DD		2880			; このドライブ大きさをもう一度書く
		DB		0,0,0x29		; よくわからないけどこの値にしておくといいらしい
		DD		0xffffffff		; たぶんボリュームシリアル番号
		DB		"HARIBOTEOS "	; ディスクの名前（11バイト）
		DB		"FAT12   "		; フォーマットの名前（8バイト）
		RESB	18				; とりあえず18バイトあけておく

; プログラム本体

entry:
		MOV		AX,0			; レジスタ初期化
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; ディスクを読む

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; シリンダ0
		MOV		DH,0			; ヘッド0
		MOV		CL,2			; セクタ2
readloop:
        MOV     SI,0            ; retry count
retry:
		MOV		AH,0x02			; AH=0x02 : ディスク読み込み
		MOV		AL,1			; 1セクタ
		MOV		BX,0            ; 加?磁?数据的内存地址, ES:BX
		MOV		DL,0x00			; Aドライブ
		INT		0x13			; ディスクBIOS呼び出し
		JNC		next            ; read successfully
        ADD     SI,1            ; add retry count
        CMP     SI,5            ; if retry count >= 5 then error
        JAE     error           ;
        MOV     AH,0X00         ; else reset Floppy
        MOV     DL,0x00         ;
        INT     0x13
        JMP     retry           ; 

next:
		MOV		AX,ES           ; adding 512 to address for next loading, namely 0x200
		ADD     AX,0x20         ; ES is segment register that will * 10 for using
        MOV     ES,AX           ; updating ES. 
        ADD     CL,1            ; prepare to loading next sector
        CMP     CL,18           ; if sector <= 18 then load
        JBE     readloop        ;   then continue read next sector
        MOV     CL,1            ; else read next header
        ADD     DH,1            ;   move header
        CMP     DH,2            ; if header < 2
        JB      readloop        ;   then continue read next header
        MOV     DH,0            ; else reset header  to 0
        ADD     CH,1            ;   add 1 to cylinder
        CMP     CH,9            ; if cylinder not grater than 9
        JBE     readloop        ;   then continue read next cylinder

; IPL had successfully loaded. Now we can run OS. 
		MOV		[0x0ff0],CH		; IPLがどこまで読んだのかをメモ
		JMP		0xc200

; 読み終わったけどとりあえずやることないので寝る

fin:
		HLT						; 何かあるまでCPUを停止させる
		JMP		fin				; 無限ループ

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; SIに1を足す
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; 一文字表示ファンクション
		MOV		BX,15			; カラーコード
		INT		0x10			; ビデオBIOS呼び出し
		JMP		putloop
msg:
		DB		0x0a, 0x0a		; 改行を2つ
		DB		"load error"
		DB		0x0a			; 改行
		DB		0

		RESB	0x7dfe-$		; 0x7dfeまでを0x00で埋める命令

		DB		0x55, 0xaa
