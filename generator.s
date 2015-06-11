#	$s0 seed
#	$s1 seed
#	$s2 string pointer
#	$s3 string pointer (reset default)
#	$s4 string pointer dinamico

#	$s5 contiene il contatore delle zone esplorate
#	$s6 contiene il contatore delle posizioni da 2 a 0 {si dovrà saltare la direzione di provenienza}
#	$s7 contiene la direzione di provenienza 





.data

labirinto: .byte 	35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,0
default: .byte 	35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,35,35,35,35,35,35,35,35,35,10,0

saluto: .asciiz "\nProgramma terminato!\nCreato da Ciacco Davide 794163"
string1: .asciiz "\nInserire il seed: "



.text
main:

la $s2, labirinto 	#non serve caricare subito la default finchè non si vuole fare il reset
					#$s2 invece mi serve per calcolare l'offset sulla stringa $s4 > $s2+11
la $s4, labirinto 	

jal seed

jal rand 			#GENERA la X
add $t3, $zero, $t2 #salva la x in $t3
jal rand 			#GENERA la Y
add $t4, $zero, $t2 #salva la y in $t4
#FORSE BISOGNEREBBE SALVARE LE COORDINATE IN UN POSTO MIGLIORE (devo poter far backtracking risalendo la stack!)

#DETERMINO L'OFFSET SULLA STRINGA DEL LABIRINTO e lo salvo in $t2
mul $t3, $t3, 2		#(2*x)
mul $t4, $t4, 20	#(20*y)
add $t2, $t3, $t4	#(2*x)+(20*y)
addi $t2, $t2, 11	#11+((2*x)+(20*y))

#POSIZIONO IL PUNTO DI PARTENZA
li $t0, 65			#carico il carattere A di partenza in $t0
add $s4, $s4, $t2	#sposto il puntatore sulla casella
sb $t0, ($s4)		#salva il carattere A nel labirinto



li $s7, 4 #carico subito la direzione di provenienza nulla

#TEMP
addi $t3, $zero, 1	#direzione provata? nord [1:no,0:si]
addi $t4, $zero, 1	#direzione provata? est
addi $t5, $zero, 1	#direzione provata? sud
addi $t6, $zero, 1	#direzione provata? ovest
#/TEMP
jal passo













termina:	#da migliorare con menu per la scelta: 0:termina 1:reset e restart!

li $v0, 4				# selezione di print_string
la $a0, labirinto		# $a0 = indirizzo di string2
syscall					# lancio print_string

li $v0, 4		#stampo l'autore del programma
la $a0, saluto
syscall


j pre_reset	#ORA CONTINUA ALL'INFINITO CHIEDENDO SEMPRE NUOVI SEEDS


li $v0, 10     	#termino il programma tramite syscall apposita
syscall



pre_reset:
la $s2, labirinto
la $s3, default

reset: #reset funzionante!

lb $t0, ($s3)	#prende un char dalla stringa di default
sb $t0, ($s2)	#salva il char nel buffer(?)

beq $t0, 0 main	#exit loop

addi $s3, $s3, 1 	#incremento i puntatori
addi $s2, $s2, 1

j reset 		#loop










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
srl $s1, $s0, 3			#shift a destra di 2
xor $s0, $s0, $s1		#xor tra seed e shiftato
sll $s1, $s0, 5			#shift a sinistra di 6
xor $s0, $s0, $s1		#xor tra seed e shiftato
#per fare il modulo basta dividere per 4 e prendere il resto della divisione!
div $t0, $s0, 4
mfhi $t0
abs $t0 $t0  #l'abs potrebbe essere semplice usando una xor?
jr $ra







dot:
li $t0, 46			#carico il carattere . in $t0
sb $t0, ($s4)		#salva il char
jr $ra



passo:
#stack save
addi $sp, $sp, -4
sw $ra, 0($sp)

addi $t3, $zero, 1	#direzione provata? nord [1:no,0:si]
addi $t4, $zero, 1	#direzione provata? est
addi $t5, $zero, 1	#direzione provata? sud
addi $t6, $zero, 1	#direzione provata? ovest


#PROVVISORIO stampa il labirinto
li $v0, 4				# selezione di print_string
la $a0, labirinto		# $a0 = indirizzo di string2
syscall					# lancio print_string


ricalcolaDirezione:
add $t0, $zero, $t3
add $t0, $t0, $t4
add $t0, $t0, $t5
add $t0, $t0, $t6
addi $t0, $t0, -1	#perchè la direzione di provenienza non la conta quindi sono tutti a zero tranne uno
beq $t0, $zero, ExitSwitch	#se sono tutti a 0 quindi ogni direzione è stata esplorata allora esci
jal rand 			#GENERA la direzione

beq $t0, $s7, ricalcolaDirezione

add $s7, $zero, $t0 #salvo (TEMP: da salvare nella stack per poter tornare indietro!)
addi $s7, $s7, 2	#calcolo l'inverso della direzione 
div $s7, $s7, 4
mfhi $s7

#$t0 contiene la direzione
#$s4 contiene il pointer
#$s2 contiene l'offset iniziale (pointer all'inizio della stringa labirinto)
#$t1 e $t2 utilizzati per i controlli di spostamento
#$t3,$t4,$t5,$t6 utilizzati per controllare di aver provato tutte le direzioni

beq $t0, $zero, nord 	#0:nord
addi $t0, $t0, -1
beq $t0, $zero, est 	#1:est
addi $t0, $t0, -1
beq $t0, $zero, sud 	#2:sud
addi $t0, $t0, -1
beq $t0, $zero, ovest 	#3:ovest
j ExitSwitch	#ATTENZIONE: qui abbiamo portato $t0 a 0, quindi non possiamo più ricavarne la dir di prov per il passo successivo!

nord:
addi $t3, $zero, 0 #TEMP: salva la direzione considerata
addi $t1, $s2, 20
blt $s4, $t1, ricalcolaDirezione	#controlla se può andare a nord
#controlla se la destinazione è già stata esplorata
addi $t1, $s4, -20
lb $t1, ($t1)
addi $t2, $zero, 35					#carattere 35 = #
bne $t1, $t2, ricalcolaDirezione	#se è # allora non è ancora esplorato

addi $s4, $s4, -10
jal dot
addi $s4, $s4, -10
jal dot
j ExitSwitch

est:
addi $t4, $zero, 0 #TEMP: salva la direzione considerata
addi $t1, $s2, 17
beq $s4, $t1, ricalcolaDirezione	#controlla se può andare a est
addi $t1, $s2, 37
beq $s4, $t1, ricalcolaDirezione
addi $t1, $s2, 57
beq $s4, $t1, ricalcolaDirezione
addi $t1, $s2, 77
beq $s4, $t1, ricalcolaDirezione
#controlla se la destinazione è già stata esplorata
addi $t1, $s4, 2
lb $t1, ($t1)
addi $t2, $zero, 35					#carattere 35 = #
bne $t1, $t2, ricalcolaDirezione	#se è # allora non è ancora esplorato

addi $s4, $s4, 1
jal dot
addi $s4, $s4, 1
jal dot
j ExitSwitch

sud:
addi $t5, $zero, 0 #TEMP: salva la direzione considerata
addi $t1, $s2, 60
bgt $s4, $t1, ricalcolaDirezione	#controlla se può andare a sud
#controlla se la destinazione è già stata esplorata
addi $t1, $s4, 20
lb $t1, ($t1)
addi $t2, $zero, 35					#carattere 35 = #
bne $t1, $t2, ricalcolaDirezione	#se è # allora non è ancora esplorato

addi $s4, $s4, 10
jal dot
addi $s4, $s4, 10
jal dot
j ExitSwitch

ovest:
addi $t6, $zero, 0 #TEMP: salva la direzione considerata
addi $t1, $s2, 11
beq $s4, $t1, ricalcolaDirezione	#controlla se può andare a ovest
addi $t1, $s2, 31
beq $s4, $t1, ricalcolaDirezione
addi $t1, $s2, 51
beq $s4, $t1, ricalcolaDirezione
addi $t1, $s2, 71
beq $s4, $t1, ricalcolaDirezione
#controlla se la destinazione è già stata esplorata
addi $t1, $s4, -2
lb $t1, ($t1)
addi $t2, $zero, 35					#carattere 35 = #
bne $t1, $t2, ricalcolaDirezione	#se è # allora non è ancora esplorato

addi $s4, $s4, -1
jal dot
addi $s4, $s4, -1
jal dot
j ExitSwitch

ExitSwitch:
#stack reload
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra