.data
productos:    .word 18
              .space 16
pedidos:      .word 30
              .space 16
estado:       .word 0

.text
.globl main

main:
    la   $s3, productos
    la   $s4, pedidos
    la   $s5, estado

    lw   $t1, 0($s3)
    add  $t2, $t1, $t1
    sub  $t3, $t2, $t1

    add  $t4, $t1, $t2
    addi $t1, $zero, 8

    add  $t5, $t2, $t3
    sub  $t5, $t2, $t1

    add  $t6, $t2, $t3
    sub  $t7, $t2, $t3

    lw   $t8, 0($s4)
    add  $t9, $t6, $t7

    beq  $t9, $zero, CERO
    addi $t0, $zero, 202

    sw   $t0, 0($s5)
    j    FIN

CERO:
    addi $t0, $zero, 0
    sw   $t0, 0($s5)

FIN:
    li   $v0, 10
    syscall