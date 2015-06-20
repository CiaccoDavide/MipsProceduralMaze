#	$s0 seed
#	$s1 seed
#	$s2 string pointer
#	$s3 string pointer (reset default)
#	$s1 string pointer dinamico

#	$s5 contiene il contatore delle celle esplorate
#	$s6 contiene il contatore delle posizioni da 2 a 0 {si dovrà saltare la direzione di provenienza}
#	$s7 contiene la direzione di provenienza 

.data

labirinto: .byte 35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,0
default: .byte 35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,0

saluto: .asciiz "\nProgramma terminato!\nCreato da Ciacco Davide 794163"
string1: .asciiz "\nInserire il seed: "

.text
main:

la $s2, labirinto 	#non serve caricare subito la default finchè non si vuole fare il reset
					#$s2 invece mi serve per calcolare l'offset sulla stringa $s1 > $s2+11
la $s1, labirinto 	

jal seed

jal rand 			#GENERA la X
add $t3, $zero, $v0 #salva la x in $t3
jal rand 			#GENERA la Y
add $t4, $zero, $v0 #salva la y in $t4
#FORSE BISOGNEREBBE SALVARE LE COORDINATE IN UN POSTO MIGLIORE (devo poter far backtracking risalendo la stack!)

#DETERMINO L'OFFSET SULLA STRINGA DEL LABIRINTO e lo salvo in $t2
mul $t3, $t3, 2		#(2*x)
mul $t4, $t4, 20	#(20*y)
add $t2, $t3, $t4	#(2*x)+(20*y)
addi $t2, $t2, 11	#11+((2*x)+(20*y))

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
j esplora #funz ricorsiva




esplora:

ricalcolaDirezione:
#VerificaDirezione:
#controlla se tutte le celle sono state esplorate ($s3==16)
beq $s3, 16, termina #il termina stampera' direttamente la B
#controlla se tutte le direzioni sono state provate
beq $s4, $zero, continua
beq $s5, $zero, continua
beq $s6, $zero, continua
beq $s7, $zero, continua
j passoIndietro
continua:

#$v0 contiene la direzione
#$s1 contiene il pointer
#$s2 contiene l'offset iniziale (pointer all'inizio della stringa labirinto)
#$t1 e $t2 utilizzati per i controlli di spostamento
#$s4,$s5,$s6,$s7 utilizzati per controllare di aver provato tutte le direzioni

#ricalcolaDirezione:
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
addi $t1, $s2, 20
blt $s1, $t1, ricalcolaDirezione
#controlla se la destinazione è già stata esplorata anche da qualche altro punto
addi $t1, $s1, -20
lb $t1, ($t1)
bne $t1, 35, ricalcolaDirezione	#se è # allora non è ancora esplorato (carattere 35 = #)

addi $s1, $s1, -10
jal dot
addi $s1, $s1, -10
jal dot
j ExitSwitch

est:
#controlla se la destinazione è già stata provata
bne $s5, 0, ricalcolaDirezione
#segna che ha considerato questa direzione
addi $s5, $zero, 1
#controlla se può andare a est
addi $t1, $s2, 17
beq $s1, $t1, ricalcolaDirezione
addi $t1, $s2, 37
beq $s1, $t1, ricalcolaDirezione
addi $t1, $s2, 57
beq $s1, $t1, ricalcolaDirezione
addi $t1, $s2, 77
beq $s1, $t1, ricalcolaDirezione
#controlla se la destinazione è già stata esplorata
addi $t1, $s1, 2
lb $t1, ($t1)
bne $t1, 35, ricalcolaDirezione	#se è # allora non è ancora esplorato (carattere 35 = #)

addi $s1, $s1, 1
jal dot
addi $s1, $s1, 1
jal dot
j ExitSwitch

sud:
#controlla se la destinazione è già stata provata
bne $s6, 0, ricalcolaDirezione
#segna che ha considerato questa direzione
addi $s6, $zero, 1
#controlla se può andare a sud
addi $t1, $s2, 60
bgt $s1, $t1, ricalcolaDirezione
#controlla se la destinazione è già stata esplorata
addi $t1, $s1, 20
lb $t1, ($t1)
bne $t1, 35, ricalcolaDirezione	#se è # allora non è ancora esplorato (carattere 35 = #)

addi $s1, $s1, 10
jal dot
addi $s1, $s1, 10
jal dot
j ExitSwitch

ovest:
#controlla se la destinazione è già stata provata
bne $s7, 0, ricalcolaDirezione
#segna che ha considerato questa direzione
addi $s7, $zero, 1
#controlla se può andare a ovest
addi $t1, $s2, 11
beq $s1, $t1, ricalcolaDirezione
addi $t1, $s2, 31
beq $s1, $t1, ricalcolaDirezione
addi $t1, $s2, 51
beq $s1, $t1, ricalcolaDirezione
addi $t1, $s2, 71
beq $s1, $t1, ricalcolaDirezione
#controlla se la destinazione è già stata esplorata
addi $t1, $s1, -2
lb $t1, ($t1)
bne $t1, 35, ricalcolaDirezione	#se è # allora non è ancora esplorato (carattere 35 = #)

addi $s1, $s1, -1
jal dot
addi $s1, $s1, -1
jal dot
j ExitSwitch

ExitSwitch:

#stack save
addi $sp, $sp, -24
sw $s7, 16($sp)
sw $s6, 12($sp)
sw $s5, 8($sp)
sw $s4, 4($sp)
sw $ra, 0($sp) #provenienza
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

j wentBack

backToNord:
jal pulisci
addi $s1, $s1, -10
jal pulisci
addi $s1, $s1, -10
j wentBack

backToEst:
jal pulisci
addi $s1, $s1, 1
jal pulisci
addi $s1, $s1, 1
j wentBack

backToSud:
jal pulisci
addi $s1, $s1, 10
jal pulisci
addi $s1, $s1, 10
j wentBack

backToOvest:
jal pulisci
addi $s1, $s1, -1
jal pulisci
addi $s1, $s1, -1
j wentBack

wentBack:
#stack reload
lw $s7, 16($sp)
lw $s6, 12($sp)
lw $s5, 8($sp)
lw $s4, 4($sp)
lw $ra, 0($sp) #provenienza
addi $sp, $sp, 24
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

	j reset	#ORA CONTINUA ALL'INFINITO CHIEDENDO SEMPRE NUOVI SEEDS

	li $v0, 10     	#termino il programma tramite syscall apposita
	syscall

reset:
	la $s2, labirinto
	la $s3, default
resetLoop: #reset funzionante!
	lb $t0, ($s3)	#prende un char dalla stringa di default
	sb $t0, ($s2)	#salva il char nel buffer(?)

	beq $t0, 0 main	#exit loop

	addi $s3, $s3, 1 	#incremento i puntatori
	addi $s2, $s2, 1

	j resetLoop 		#loop

seed:	
	li $v0, 4				# selezione di print_string (codice = 4)
	la $a0, string1			# $a0 = indirizzo di string1
	syscall					# lancio print_string

	li $v0, 5				# Selezione read_int (codice = 5)
	syscall

	beq $v0, $zero, seed 	#IL SEED DEVE ESSERE DIVERSO DA 0
	add $s0, $zero, $v0		# memorizzo il seed iniziale in $s0

	jr $ra

rand:	#restituisce in $t0 un valore pseudorandom [0..3]
	srl $t0, $s0, 3			#shift a destra di 2
	xor $s0, $s0, $t0		#xor tra seed e shiftato
	sll $t0, $s0, 5			#shift a sinistra di 6
	xor $s0, $s0, $t0		#xor tra seed e shiftato
	#per fare il modulo basta dividere per 4 e prendere il resto della divisione!
	div $t0, $s0, 4
	mfhi $t0
	abs $v0 $t0  #l'abs potrebbe essere semplice usando una xor?
	jr $ra

dot:
	li $t3, 46			#carico il carattere '.' in $t0
	sb $t3, ($s1)		#salva il char
	jr $ra

pulisci:
	li $t3, 32			#carico il carattere ' ' in $t0
	sb $t3, ($s1)		#salva il char
	jr $ra

inserisciCarattere: #inserisce il carattere il cui codice ascii si trova in $a0
	sb $a0, ($s1)
	jr $ra

