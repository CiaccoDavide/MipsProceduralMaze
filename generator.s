#	$s0 seed
#	$s1 seed
#	$s2 string pointer
#	$s3 string pointer (reset default)




.data
labirinto: .byte 	35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,0

default: .byte 	35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,0

saluto: .asciiz "\nProgramma terminato!\nCreato da Ciacco Davide 794163"
string1: .asciiz "\nInserire il seed: "



.text
main:

la $s2, labirinto 	#non serve caricare subito la default finchè non si vuole fare il reset

jal seed

jal rand 			#GENERA la X
add $t3, $zero, $t2
jal rand 			#GENERA la Y
add $t4, $zero, $t2


#DETERMINO L'OFFSET SULLA STRINGA DEL LABIRINTO e lo salvo in $t2
mul $t3, $t3, 2		#(2*x)
mul $t4, $t4, 20	#(20*y)
add $t2, $t3, $t4	#(2*x)+(20*y)
addi $t2, $t2, 11	#11+((2*x)+(20*y))

#POSIZIONO IL PUNTO DI PARTENZA
li $t0, 65		#carico il carattere A di partenza in $t0
add $s2, $s2, $t2	#sposto il puntatore sulla casella
sb $t0, ($s2)	#salva il char nel buffer(?)



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
la $s1, labirinto
la $s3, default

reset: #reset funzionante!

lb $t0, ($s3)	#prende un char dalla stringa di default
sb $t0, ($s1)	#salva il char nel buffer(?)

beq $t0, 0 main

addi $s3, $s3, 1 	#incremento i puntatori
addi $s1, $s1, 1

j reset 		#loop










seed:

li $v0, 4				# selezione di print_string (codice = 4)
la $a0, string1			# $a0 = indirizzo di string1
syscall					# lancio print_string

li $v0, 5				# Selezione read_int (codice = 5)
syscall					
add $s0, $zero, $v0		# memorizzo il seed iniziale in $s0

jr $ra

rand:

#GENERA la X
srl $s1, $s0, 2			#shift a destra di 2
xor $s0, $s0, $s1		#xor tra seed e shiftato
sll $s1, $s0, 6			#shift a sinistra di 6
xor $s0, $s0, $s1		#xor tra seed e shiftato

#per fare il modulo basta dividere per 4 e prendere il resto della divisione!
div $t2, $s0, 4
mfhi $t2
abs $t2 $t2  #l'abs potrebbe essere semplice usando una xor?

jr $ra