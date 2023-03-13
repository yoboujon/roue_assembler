		

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc


;************************************************************************
; 					IMPORT/EXPORT Syst�me
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]




; IMPORT/EXPORT de proc�dure           

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
		LDR R12,=GPIOBASEB			;On recup�re l'adresse de base
		MOV R5,#(0x01 << 10)		;1 d�cal� de 10 dans R5
		STRH R5,[R12,#OffsetReset]	;On stocke la variable R5 � l'adresse 0x0X40010C14 (reset)
		POP {R12,R0}				;On restitue R12 dans R0
		BX LR						;Retour
;LDR R5,[R12,#0x0C]		;Valeur � l'adresse de l'output
;AND R5, R5,#~(0x01 << 10)	;OU LOGIQUE pour calculer la valeur a mettre dans l'output
;STRH R5,[R12,#0x0C]			;Etat du port B (R5) stock� dans l'output 	
		ENDP
				
;*******************************************************************************
;	On allume la LED
;*******************************************************************************
Allume_LED   PROC

		PUSH {R12,R0}			;On stocke R12 dans R0
		LDR R12,=GPIOBASEB		;On recup�re l'adresse de base
		MOV R5,#(0x01 << 10)	;1 d�cal� de 10 dans R5
		STRH R5,[R12,#OffsetSet]	;On stocke la variable R5 � l'adresse 0x0X40010C10 (set)
		POP {R12,R0}			;On restitue R12 dans R0
		BX LR					;Retour
;LDR R5,[R12,#0x0C]		;Valeur � l'adresse de l'output
;ORR R5, R5,#(0x01 << 10)	;OU LOGIQUE pour calculer la valeur a mettre dans l'output
;STRH R5,[R12,#0x0C]			;Etat du port B (R5) stock� dans l'output 
			
		ENDP
			

;*******************************************************************************
; Proc�dure principale et point d'entr�e du projet
;*******************************************************************************
main   PROC 
;*******************************************************************************

		
		MOV R0,#0;
		BL Init_Cible;
Boucle
		LDR R12,=GPIOBASEA			;On r�cup l'adresse	du GPIOA		
		LDR R0,[R12,#OffsetInput]	;On charge sa valeur avec l'OffsetInput
		AND R0, R0, #(0x01 << 8)	;R0 est masqu� pour n'avoir que le bit de l'offset input
		CMP R0, #(0x01 << 8)		;On compare R0 � 1
		BNE T_Oui					;On allume
		BL Eteint_LED				;Sinon on �teint
		B Boucle					;On reboucle
				
T_Oui
		BL Allume_LED
		B Boucle
		
		B .			 ; boucle inifinie terminale...
		ENDP

	END

;*******************************************************************************
