		

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
; Proc�dure principale et point d'entr�e du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		
		MOV R0,#0;
		BL Init_Cible;
		; SET
		LDR R12,=0x40010C00
		MOV R5,#(0x01 << 10)
		STRH R5,[R12,#0x10]	;On stocke la variable R5 � l'adresse 0x0X40010C10
		; RESET
		MOV R5,#(0x01 << 10)
		STRH R5,[R12,#0x14]	;On stocke la variable R5 � l'adresse 0x0X40010C10
		
		; ALLUMER LA LED
		LDR R5,[R12,#0x0C]		;Valeur � l'adresse de l'output
		ORR R5, R5,#(0x01 << 10)	;OU LOGIQUE pour calculer la valeur a mettre dans l'output
		STRH R5,[R12,#0x0C]			;Etat du port B (R5) stock� dans l'output 
		
		;ETEINDRE LA LED
		LDR R5,[R12,#0x0C]		;Valeur � l'adresse de l'output
		AND R5, R5,#~(0x01 << 10)	;OU LOGIQUE pour calculer la valeur a mettre dans l'output
		STRH R5,[R12,#0x0C]			;Etat du port B (R5) stock� dans l'output 
		
		B .			 ; boucle inifinie terminale...




		ENDP

	END

;*******************************************************************************
