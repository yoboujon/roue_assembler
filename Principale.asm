		

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc


;************************************************************************
; 					IMPORT/EXPORT Système
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]




; IMPORT/EXPORT de procédure           

	IMPORT Init_Cible
	

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

	


;*******************************************************************************
	
	AREA  moncode, code, readonly
		


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
;	On inverse la LED (besoin de R3)
;*******************************************************************************
Inverse_LED	  PROC
		PUSH {R12,R0}			;On stocke R12 dans R0
		LDR R12,=GPIOBASEB		;On recupère l'adresse de base
		MOV R5,#(0x01 << 10)	;1 décalé de 10 dans R5
		CMP R3,#0				;Si R3=0 (default) alors on allume, sinon on eteint
		;BEQ Allume
		;B Eteint
		BNE Eteint
Allume
	STRH R5,[R12,#OffsetSet]	;On stocke la variable R5 à l'adresse 0x0X40010C10 (set)
	MOV R3,#1;					;On remet la variable à 1
	B Fin						;Retour	
Eteint
	STRH R5,[R12,#OffsetReset]	;On stocke la variable R5 à l'adresse 0x0X40010C14 (reset)
	MOV R3,#0;					;On remet la variable à 0
	B Fin
		

Fin 
	POP {R12,R0}			;On restitue R12 dans R0
	BX LR					;Retour


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main   PROC 
;*******************************************************************************

		
		BL Init_Cible;
		MOV R0,#0;
		MOV R1,#0;
		MOV R3,#0;
Boucle
		LDR R12,=GPIOBASEA			;On récup l'adresse	du GPIOA		
		LDR R0,[R12,#OffsetInput]	;On charge sa valeur avec l'OffsetInput
		AND R0, R0, #(0x01 << 8)	;R0 est masqué pour n'avoir que le bit de l'offset input
		CMP R0, #(0x01 << 8)		;On compare R0 doit etre egal à 1 pour le front montant
		BNE Is_detect					;On allume
		MOV R1,R0				;R1 possède la valeur de R0 avant
		BL Boucle				;Sinon on boucle
				
Is_detect
		CMP R1, #(0x01 << 8)		;R1 doit etre egal à 0 pour le front montant
		BNE Boucle

T_Oui
		BL Inverse_LED				;On inverse le status de la led grace a R3
		B Boucle
		
		B .			 ; boucle inifinie terminale...
		ENDP

	END

;*******************************************************************************
