#	$s0 seed
#	$s1 string pointer dinamico
#	$s3 string pointer statico (per fare calcoli su precisi offset della stringa)

#	$s5 contiene il contatore delle celle esplorate
#	$s6 contiene il contatore delle posizioni da 2 a 0 {si dovrà saltare la direzione di provenienza}
#	$s7 contiene la direzione di provenienza

.data

spbackup: .word 0
xy: .space 2
labirinto: .space 1157 #alloco lo spazio massimo (labirinto 16x16)

benvenuto: .asciiz "\nGeneratore procedurale di labirinti in MIPS"
saluto: .asciiz "\nProgramma terminato!\nCreato da Ciacco Davide 794163"
stringX: .asciiz " Inserire la larghezza del labirinto [4..16]: "
stringY: .asciiz " Inserire l'altezza del labirinto [4..16]: "
stringS: .asciiz " Inserire il seed: "

.text
main:


	#salva sp
	la $t0, spbackup
	sw $sp, ($t0)

	#STORE X
	li $v0, 4				# selezione di print_string (codice = 4)
	la $a0, stringX			# $a0 = indirizzo di string1
	syscall					# lancio print_string
	li $v0, 5				# Selezione read_int (codice = 5)
	syscall

	blt $v0, 2, reset 		#x>=4
	bgt $v0, 16, reset 		#x<=16

	la $t1, xy
	sb $v0, ($t1)

	#STORE Y
	li $v0, 4				# selezione di print_string (codice = 4)
	la $a0, stringY			# $a0 = indirizzo di string1
	syscall					# lancio print_string
	li $v0, 5				# Selezione read_int (codice = 5)
	syscall

	blt $v0, 2, reset 		#x>=4
	bgt $v0, 16, reset 		#x<=16

	sb $v0, 1($t1)

	la $s1, labirinto 		#carica l'indirizzo di labirinto in $s1


	#start doppio for x,y

	lb $t3, 1($t1) 			#carico la y in t2
	mul $t3, $t3, 2
	addi $t3, $t3, 1
	fory:
		lb $t2, ($t1)			#carico la x in t1
		mul $t2, $t2, 2
		addi $t2, $t2, 1

	forx:
		addi $t0, $zero, 35
		sb $t0, ($s1)

		addi $s1, $s1, 1
		addi $t2, $t2, -1

		bne $t2, $zero, forx

	addi $t0, $zero, 10
	sb $t0, ($s1)

	addi $s1, $s1, 1
	addi $t3, $t3, -1
	bne $t3, $zero, fory

	addi $t0, $zero, 0
	sb $t0, ($s1)
	#jr $ra


	la $s2, labirinto 	#non serve caricare subito la default finchè non si vuole fare il reset
						#$s2 invece mi serve per calcolare l'offset sulla stringa $s1 > $s2+11
	la $s1, labirinto

	jal seed

	# x,y in $t8,$t9
	la $t1, xy
	lb $t8, 0($t1) #larghezza
	add $a0, $zero, $t8
	jal rand 			#GENERA la X
	add $t3, $zero, $v0 #salva la x in $t3
	lb $t9, 1($t1) #altezza
	add $a0, $zero, $t9
	jal rand 			#GENERA la Y
	add $t4, $zero, $v0 #salva la y in $t4

	#DETERMINO L'OFFSET SULLA STRINGA DEL LABIRINTO e lo salvo in $t2
	mul $t3, $t3, 2		#(2*x)

	mul $t5, $t8, 2		# 2*larghezza
	addi $t5, $t5, 2	#(2*larghezza + 2)
	mul $t5, $t5, 2		#(2*larghezza + 2)*2

	mul $t4, $t4, $t5	#((2*larghezza + 2)*2)*y

	add $t2, $t3, $t4	#(2*x)+((2*larghezza+2)*2)*y
	add $t2, $t2, $t8	#(2*x)+((2*larghezza+2)*2)*y+larghezza
	add $t2, $t2, $t8	#(2*x)+((2*larghezza+2)*2)*y+2*larghezza
	addi $t2, $t2, 3	#(2*x)+((2*larghezza+2)*2)*y+(2*larghezza+3)

	#POSIZIONO IL PUNTO DI PARTENZA
	li $t0, 65			#carico il carattere A di partenza in $t0
	add $s1, $s1, $t2	#sposto il puntatore sulla casella
	sb $t0, ($s1)		#salva il carattere A nel labirinto

	addi $a2, $zero, 4 	#direzione di provenienza nulla
	addi $s3, $zero, 1	#setta 'celle esplorate' a uno
	#setta le direzioni provate tutte a 'no'
	addi $s4, $zero, 0	#direzione provata? nord [1:no,0:si,2:provenienza]
	addi $s5, $zero, 0	#direzione provata? est
	addi $s6, $zero, 0	#direzione provata? sud
	addi $s7, $zero, 0	#direzione provata? ovest

esplora:

	ricalcolaDirezione:
	#VerificaDirezione:
	#controlla se tutte le celle sono state esplorate ($s3==16)
	mul $t7, $t8, $t9	#numero di celle esplorabili (lo posso calcolare ogni volta visto che e' storato in dei registri temporanei, ma per ora e' uno spreco di risorse anche se non conforme alle convenzioni MIPS)
	beq $s3, $t7, termina #il termina stampera' direttamente la B
	#controlla se tutte le direzioni sono state provate
	beq $s4, $zero, continua
	beq $s5, $zero, continua
	beq $s6, $zero, continua
	beq $s7, $zero, continua
	j passoIndietro				#se tutte le direzioni sono state provate allora torna indietro
	continua:

	#$v0 contiene la direzione
	#$s1 contiene il pointer
	#$s2 contiene l'offset iniziale (pointer all'inizio della stringa labirinto)
	#$t1 e $t2 utilizzati per i controlli di spostamento
	#$s4,$s5,$s6,$s7 utilizzati per controllare di aver provato tutte le direzioni

	#ricalcolaDirezione:
	addi $a0, $zero, 4		#set dell'argomento da passare a rand
	jal rand 				#GENERA la direzione e la controlla
	add $a2, $zero, $v0		#salva la direzione di movimento per passarla al passo avanti
	beq $v0, $zero, nord 	#0:nord
	addi $v0, $v0, -1
	beq $v0, $zero, est 	#1:est
	addi $v0, $v0, -1
	beq $v0, $zero, sud 	#2:sud
	addi $v0, $v0, -1
	beq $v0, $zero, ovest 	#3:ovest
	j ExitSwitch	#ATTENZIONE: qui abbiamo portato $t0 a 0, quindi non possiamo più ricavarne la dir di prov per il passo successivo!

	nord:
	#controlla se la destinazione è già stata provata
	bne $s4, 0, ricalcolaDirezione
	#segna che ha considerato questa direzione
	addi $s4, $zero, 1
	#controlla se può andare a nord
	mul $t7, $t8, 2		# 2*larghezza
	addi $t7, $t7, 2	#(2*larghezza + 2)
	mul $t7, $t7, 3		#(2*larghezza + 2)*2
	add $t1, $s2, $t7
	blt $s1, $t1, ricalcolaDirezione
	#controlla se la destinazione è già stata esplorata anche da qualche altro punto

	mul $t7, $t8, 4
	addi $t7, $t7, 4

	sub $t1, $s1, $t7
	lb $t1, ($t1)
	bne $t1, 35, ricalcolaDirezione	#se è # allora non è ancora esplorato (carattere 35 = #)

	li $a0, 46			#carico il carattere '.' in $a0 per passarlo alla funzione storeChar
	div $t7, $t7, 2
	sub $s1, $s1, $t7
	jal storeChar
	sub $s1, $s1, $t7
	jal storeChar
	j ExitSwitch

	est:
	#controlla se la destinazione è già stata provata
	bne $s5, 0, ricalcolaDirezione
	#segna che ha considerato questa direzione
	addi $s5, $zero, 1
	#controlla se può andare a est

	mul $t7, $t8, 2
	addi $t7, $t7, 3
	sub $t6, $s1, $s2 #$s1-$s2
	sub $t7, $t6, $t7 #($s1-$s2)-(2*larghezza+3)
	addi $t6, $t8, -1 #(x-1)
	mul $t6, $t6, 2  #2*(x-1)
	add $t7, $t7, $t6 #2*(x-1)+($s1-$s2)-(2*larghezza+3)
	beq $t7, $zero, ricalcolaDirezione

	mul $t6, $t8, 2		# 2*larghezza
	addi $t6, $t6, 2	#(2*larghezza + 2)
	mul $t6, $t6, 2		#(2*larghezza + 2)*2
	div $t7, $t7, $t6
	mfhi $t7
	beq $t7, $zero, ricalcolaDirezione

	#controlla se la destinazione è già stata esplorata
	addi $t1, $s1, 2
	lb $t1, ($t1)
	bne $t1, 35, ricalcolaDirezione	#se è # allora non è ancora esplorato (carattere 35 = #)

	li $a0, 46			#carico il carattere '.' in $a0 per passarlo alla funzione storeChar
	addi $s1, $s1, 1
	jal storeChar
	addi $s1, $s1, 1
	jal storeChar
	j ExitSwitch

	sud:
	#controlla se la destinazione è già stata provata
	bne $s6, 0, ricalcolaDirezione
	#segna che ha considerato questa direzione
	addi $s6, $zero, 1
	#controlla se può andare a sud

	mul $t7, $t8, 2
	addi $t7, $t7, 2
	mul $t6, $t9, 2
	addi $t6, $t6, 2
	mul $t7, $t7, $t6#lunghezza stringa
	mul $t6, $t8, 2#larghezza*2
	addi $t6, $t6, 2#larghezza*2)+2
	mul $t6, $t6, 3
	sub $t7, $t7, $t6

	add $t1, $s2, $t7
	bgt $s1, $t1, ricalcolaDirezione
	#controlla se la destinazione è già stata esplorata

	#prima ricalcola la casella sotto
	mul $t7, $t8, 4
	addi $t7, $t7, 4

	add $t1, $s1, $t7
	lb $t1, ($t1)
	bne $t1, 35, ricalcolaDirezione	#se è # allora non è ancora esplorato (carattere 35 = #)

	li $a0, 46			#carico il carattere '.' in $a0 per passarlo alla funzione storeChar
	div $t7, $t7, 2
	add $s1, $s1, $t7
	jal storeChar
	add $s1, $s1, $t7
	jal storeChar
	j ExitSwitch

	ovest:
	#controlla se la destinazione è già stata provata
	bne $s7, 0, ricalcolaDirezione
	#segna che ha considerato questa direzione
	addi $s7, $zero, 1
	#controlla se può andare a ovest

	mul $t7, $t8, 2
	addi $t7, $t7, 3
	sub $t6, $s1, $s2 #$s1-$s2
	sub $t7, $t6, $t7 #($s1-$s2)-(2*larghezza+3)
	beq $t7, $zero, ricalcolaDirezione

	mul $t6, $t8, 2		# 2*larghezza
	addi $t6, $t6, 2	#(2*larghezza + 2)
	mul $t6, $t6, 2		#(2*larghezza + 2)*2
	div $t7, $t7, $t6
	mfhi $t7
	beq $t7, $zero, ricalcolaDirezione


	#controlla se la destinazione è già stata esplorata
	addi $t1, $s1, -2
	lb $t1, ($t1)
	bne $t1, 35, ricalcolaDirezione	#se è # allora non è ancora esplorato (carattere 35 = #)

	li $a0, 46			#carico il carattere '.' in $a0 per passarlo alla funzione storeChar
	addi $s1, $s1, -1
	jal storeChar
	addi $s1, $s1, -1
	jal storeChar
	j ExitSwitch

	ExitSwitch:

	#stack save
	addi $sp, $sp, -4
	sb $s7, 3($sp)
	sb $s6, 2($sp)
	sb $s5, 1($sp)
	sb $s4, 0($sp)

	addi $s3, $s3, 1 #aggiungi 1 alle celle esplorate (solo quando si muove in avanti)

	#setta la provenienza (invertita perche' dovra' essere usata dalla prossima posizione)
	add $t0, $zero, $a2
	bne $t0, $zero, notNord
	addi $s4, $zero, 0
	addi $s5, $zero, 0
	addi $s6, $zero, 2
	addi $s7, $zero, 0
	j notOvest
	notNord:
	addi $t0, $t0, -1
	bne $t0, $zero, notEst
	addi $s4, $zero, 0
	addi $s5, $zero, 0
	addi $s6, $zero, 0
	addi $s7, $zero, 2
	j notOvest
	notEst:
	addi $t0, $t0, -1
	bne $t0, $zero, notSud
	addi $s4, $zero, 2
	addi $s5, $zero, 0
	addi $s6, $zero, 0
	addi $s7, $zero, 0
	j notOvest
	notSud:
	addi $t0, $t0, -1
	bne $t0, $zero, notOvest
	addi $s4, $zero, 0
	addi $s5, $zero, 2
	addi $s6, $zero, 0
	addi $s7, $zero, 0
	notOvest:

	j esplora






passoIndietro:
	#fa un passo indietro nella direzione da cui era arrivato (0:sud,1:ovest,2:nord,3:est)
	beq $s4, 2, backToNord
	beq $s5, 2, backToEst
	beq $s6, 2, backToSud
	beq $s7, 2, backToOvest

	#j wentBack
	j termina #dovrebbe essere impossibile arrivare qui, giusto?

	backToNord:
	mul $t7, $t8, 2		# 2*larghezza
	addi $t7, $t7, 2	#(2*larghezza + 2)

	li $a0, 32			#carico il carattere ' ' in $a0 per passarlo alla funzione storeChar
	jal storeChar
	sub $s1, $s1, $t7
	jal storeChar
	sub $s1, $s1, $t7
	j wentBack

	backToEst:
	li $a0, 32			#carico il carattere ' ' in $a0 per passarlo alla funzione storeChar
	jal storeChar
	addi $s1, $s1, 1
	jal storeChar
	addi $s1, $s1, 1
	j wentBack

	backToSud:
	mul $t7, $t8, 2		# 2*larghezza
	addi $t7, $t7, 2	#(2*larghezza + 2)

	li $a0, 32			#carico il carattere ' ' in $a0 per passarlo alla funzione storeChar
	jal storeChar
	add $s1, $s1, $t7
	jal storeChar
	add $s1, $s1, $t7
	j wentBack

	backToOvest:
	li $a0, 32			#carico il carattere ' ' in $a0 per passarlo alla funzione storeChar
	jal storeChar
	addi $s1, $s1, -1
	jal storeChar
	addi $s1, $s1, -1
	j wentBack

	wentBack:
	#stack reload
	lb $s7, 3($sp)
	lb $s6, 2($sp)
	lb $s5, 1($sp)
	lb $s4, 0($sp)
	addi $sp, $sp, 4


	j esplora



termina:	#da migliorare con menu per la scelta: 0:termina 1:reset e restart!

	li $t3, 66			#carico il carattere 'B' in $t0
	sb $t3, ($s1)		#salva il char

	li $v0, 4				# selezione di print_string
	la $a0, labirinto		# $a0 = indirizzo di string2
	syscall					# lancio print_string

	li $v0, 4		#stampo l'autore del programma
	la $a0, saluto
	syscall




	resetStack:
	la $t0, spbackup
	lw $t0, ($t0)
	add $sp, $zero, $t0



	j reset	#ORA CONTINUA ALL'INFINITO CHIEDENDO SEMPRE NUOVI SEEDS

	li $v0, 10     	#termino il programma tramite syscall apposita
	syscall





seed:
	li $v0, 4				# selezione di print_string (codice = 4)
	la $a0, stringS			# $a0 = indirizzo di string1
	syscall					# lancio print_string

	li $v0, 5				# Selezione read_int (codice = 5)
	syscall

	beq $v0, $zero, seed 	#IL SEED DEVE ESSERE DIVERSO DA 0
	add $s0, $zero, $v0		# memorizzo il seed iniziale in $s0

	jr $ra


rand:	#restituisce in $v0 un valore pseudorandom [0..$a0]
	srl $t0, $s0, 3			#shift a destra di 2
	xor $s0, $s0, $t0		#xor tra seed e shiftato
	sll $t0, $s0, 5			#shift a sinistra di 6
	xor $s0, $s0, $t0		#xor tra seed e shiftato

	div $t0, $s0, $a0	#divide per il valore passato attraverso $a0
	mfhi $t0
	abs $v0 $t0  #l'abs potrebbe essere semplice usando una xor?
	jr $ra


storeChar:				# void storeChar($a0) accetta un byte per salvare il corrispondente ascii nella stringa
	sb $a0, ($s1)		#salva il char contenuto in $a0 #dovrei passargli anche $s1? o è una "variabile globale"?
	jr $ra
