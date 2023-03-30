;***************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8

;**************************************************************************
;  Fichier Vierge.asm
; Auteur : V.MAHOUT
; Date :  12/11/2013
;**************************************************************************

;***************IMPORT/EXPORT**********************************************

	IMPORT DataSend
	EXPORT Init_TVI

;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 
	include LUMIERES.inc

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

Timer_Up_Reg			EQU	25
Timer_Cc_Reg			EQU	27
MAX_Interrupt			EQU 256
TVI_Flash				EQU 0x0
TVI_Pile				EQU	0x20000200		;9 bits de poids faible = 0

;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************

Init_TVI PROC
	;On copie toute la TVI dans la RAM (0x2....)
	;On modifie les interruptions Up et CC pour pointer sur nos fonctions rien qu'à nous
	;On fait pointer à SCB_VTOR l'adresse de la TVI que nous avons copié
	LDR R0,=TVI_Flash				;On Lit le premier TVI
	LDR R1,=TVI_Pile				;Nouvelle TVI
	MOV R2,#0						;i
for_tvi								;for(int i=0;i<MAX_Interrupt;i++)
	LDR R3,[R0]						;temp = TVI_Flash[i]
	STR R3, [R1]					;TVI_Pile[i] = temp
	ADD R1,R1,#4					;TVI_Pile++
	ADD R0,R0,#4					;TVI_Flash++
	ADD R2,R2,#1					;i++
	CMP R2,#MAX_Interrupt			;is i == MAX_Interrupt?
	BNE	for_tvi
scbvector_link
	LDR R1,=TVI_Pile				;On relit l'adresse de TVIPile
	LDR R0,=SCB_VTOR				;ON lit l'adresse de SCB_VTOR
	STR R1,[R0]						;On met l'adresse de TVI_Pile dans le SCB_VTOR
	
	ENDP
;**************************************************************************
END
