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

	EXPORT Set_SCLK
	EXPORT Reset_SCLK
	EXPORT DriverGlobal

;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

 
Barette1 	DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			


;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************

Set_SCLK	PROC
		PUSH {R12,R0}			;On stocke R12 dans R0
		LDR R12,=GPIOBASEA		;On recupère l'adresse de base
		LDR R5,[R12,#MaskSclk]		;Valeur à l'adresse de l'output
		ORR R5, R5,#(0x01 << 5)	;OU LOGIQUE pour calculer la valeur a mettre dans l'output
		STRH R5,[R12,#0x0C]			;Etat du port B (R5) stocké dans l'output 
		BX LR					;Retour
	
	ENDP

Reset_SCLK	PROC
		PUSH {R12,R0}			;On stocke R12 dans R0
		LDR R12,=GPIOBASEB		;On recupère l'adresse de base
		LDR R5,[R12,#MaskSclk]		;Valeur à l'adresse de l'SCLK
		AND R5, R5,#~(0x01 << 5)	;OU LOGIQUE pour calculer la valeur a mettre dans l'output
		STRH R5,[R12,#0x0C]			;Etat du port B (R5) stocké dans l'output 	
		BX LR					;Retour
	
	ENDP
		
;****************************************************************************
;R6 = NBLed
;R7 = *ValCourante
;R8 = ValCourante[NBLed]
;****************************************************************************
DriverGlobal	PROC
		BL Set_SCLK;
		MOV R6, #0;
WHILE_NBLED
		;Pour NbLed = 1 à 48
		LDR R7,=Barette1	;On recupère l'adresse de base
		LDRB R8,[R7,R6]		;R8 = ValCourante[...NBLed]
		
		LSL R8,#24			;ValCourante[NBLed]<<24
		
		ADD R6, R6, #1		;On incrémente R6
		CMP R6, #47			; SI R6==47 alors on arrête la boucle
		BNE WHILE_NBLED
	ENDP

;**************************************************************************
	END