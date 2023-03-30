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

	EXPORT Eteint_LED
	EXPORT Allume_LED
	EXPORT Inverse_LED

;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************



;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************





;########################################################################
; Procédure ????
;########################################################################
;
; Paramètre entrant  : ???
; Paramètre sortant  : ???
; Variables globales : ???
; Registres modifiés : ???
;------------------------------------------------------------------------


;*******************************************************************************
;	On eteint la LED
;*******************************************************************************
Eteint_LED	PROC

		PUSH {R12,R0}				;On stocke R12 dans R0
		LDR R12,=GPIOBASEB			;On recupère l'adresse de base
		MOV R5,#(0x01 << 10)		;1 décalé de 10 dans R5
		STRH R5,[R12,#OffsetReset]	;On stocke la variable R5 à l'adresse 0x0X40010C14 (reset)
		POP {R12,R0}				;On restitue R12 dans R0
		BX LR						;Retour
;LDR R5,[R12,#0x0C]		;Valeur à l'adresse de l'output
;AND R5, R5,#~(0x01 << 10)	;OU LOGIQUE pour calculer la valeur a mettre dans l'output
;STRH R5,[R12,#0x0C]			;Etat du port B (R5) stocké dans l'output 	
		ENDP
				
;*******************************************************************************
;	On allume la LED
;*******************************************************************************
Allume_LED   PROC

		PUSH {R12,R0}			;On stocke R12 dans R0
		LDR R12,=GPIOBASEB		;On recupère l'adresse de base
		MOV R5,#(0x01 << 10)	;1 décalé de 10 dans R5
		STRH R5,[R12,#OffsetSet]	;On stocke la variable R5 à l'adresse 0x0X40010C10 (set)
		POP {R12,R0}			;On restitue R12 dans R0
		BX LR					;Retour
;LDR R5,[R12,#0x0C]		;Valeur à l'adresse de l'output
;ORR R5, R5,#(0x01 << 10)	;OU LOGIQUE pour calculer la valeur a mettre dans l'output
;STRH R5,[R12,#0x0C]			;Etat du port B (R5) stocké dans l'output 
			
		ENDP
			
;*******************************************************************************
;	On inverse la LED (besoin de R0)
;*******************************************************************************
Inverse_LED	  PROC
		PUSH {R12,R0}			;On stocke R12 dans R0
		LDR R12,=GPIOBASEB		;On recupère l'adresse de base
		MOV R5,#(0x01 << 10)	;1 décalé de 10 dans R5
		CMP R0,#0				;Si R3=0 (default) alors on allume, sinon on eteint
		;BEQ Allume
		;B Eteint
		BNE Eteint
Allume
		STRH R5,[R12,#OffsetSet]	;On stocke la variable R5 à l'adresse 0x0X40010C10 (set)
		MOV R0,#1;					;On remet la variable à 1
		B Fin						;Retour	
Eteint
		STRH R5,[R12,#OffsetReset]	;On stocke la variable R5 à l'adresse 0x0X40010C14 (reset)
		MOV R0,#0;					;On remet la variable à 0
		B Fin
		

Fin 
	POP {R12,R0}			;On restitue R12 dans R0
	BX LR					;Retour
	
	ENDP

;**************************************************************************
	END