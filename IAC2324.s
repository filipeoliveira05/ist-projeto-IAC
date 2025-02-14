#
# IAC 2023/2024 k-means
#
# Tecnico/ULisboa


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10


# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters:    .zero 4




#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text
    #Invoca a funcao principal
    jal mainKMeans
 
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall



### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    


### cleanScreen
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    addi sp, sp, -16 #Reserva espaco na pilha
    sw s0, 0(sp) #Guarda o registo s0
    sw s1, 4(sp) #Guarda o registo s1
    sw s2, 8(sp) #Guarda o registo s2
    sw s3, 12(sp) #Guarda o registo s3
    
    li s0, LED_MATRIX_0_SIZE #Guarda em s0 o endereco do ultimo pixel da matriz
    li s1, white #Guarda em s1 a cor branca
    li s2, 0 #Inicializa s2 a 0
    
    loop_cleanScreen:
        bgt s2, s0, end_loop_cleanScreen #Salta para "end_loop_cleanScreen" se s2 maior do que s0
        li s3, LED_MATRIX_0_BASE #Inicializacao do endereco da matriz em s3
        add s3, s2, s3 #s3 tem o endereco do pixel
        sw s1, 0(s3) #Pintar o pixel na cor guardada em s1
        addi s2, s2, 4 #Incrementa o contador
        j loop_cleanScreen #Avanca para a proxima iteracao
    end_loop_cleanScreen:
    
    lw s0, 0(sp) #Repoe o registo s0
    lw s1, 4(sp) #Repoe o registo s1
    lw s2, 8(sp) #Repoe o registo s2
    lw s3, 12(sp) #Repoe o registo s3
    addi sp, sp, 16 #Liberta espaco na pilha
    
    jr ra #Retorna para o ponto de invocacao

    
    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    addi sp, sp, -40 #Reserva espaco na pilha
    sw s0, 0(sp) #Guarda o registo s0
    sw s1, 4(sp) #Guarda o registo s1
    sw s2, 8(sp) #Guarda o registo s2
    sw s3, 12(sp) #Guarda o registo s3
    sw s4, 16(sp) #Guarda o registo s4
    sw s5, 20(sp) #Guarda o registo s5
    sw s6, 24(sp) #Guarda o registo s6
    sw s7, 28(sp) #Guarda o registo s7
    sw s8, 32(sp) #Guarda o registo s8
    sw s9, 36(sp) #Guarda o registo s9

    lw s0, n_points #Guarda em s0 o numero de pontos
    slli s0, s0, 3 #Multiplica s0 por 8
    li s1, 0 #Inicializa s1 a 0 (contador do points)
    li s5, 0 #Inicializa s5 a 0 (contador do clusters)
    la s2, points #Guarda em s2 o endereco inicial dos pontos
    lw s3, clusters #Guarda em s3 o endereco inicial dos clusters
    la s4, colors #Guarda em s4 o endereco inicial das cores

    loop_printClusters:
        bge s1, s0, end_loop_printClusters #Salta para "end_loop_printClusters" se s1 maior ou igual a s0
        
        addi sp, sp, -20 #Reserva espaco na pilha
        sw ra, 0(sp) #Guarda o endereco de retorno
        sw a0, 4(sp) #Guarda o registo a0
        sw a1, 8(sp) #Guarda o registo a1
        sw a2, 12(sp) #Guarda o registo a2
        sw a3, 16(sp) #Guarda o registo a3
        
        add s6, s2, s1 #s6 tem o endereco do ponto
        lw a0, 0(s6) #Carrega para a0 a coordenada x do ponto
        lw a1, 4(s6) #Carrega para a1 a coordenada y do ponto

        add s7, s3, s5 #s7 tem o endereco do cluster a que o ponto pertence
        lw s9, 0(s7) #Carrega para s9 o cluster a que o ponto pertence
    
        slli s9, s9, 2 #Multiplica o indice do cluster por 4 (tamanho de cada cor)
        add s8, s4, s9 #s8 tem o endereco da cor no vetor colors
        lw a2, 0(s8) #Carrega a cor correspondente ao cluster em a2

        jal printPoint #Invoca a funcao printPoint
        lw ra, 0(sp) #Repoe o endereco de retorno
        lw a0, 4(sp) #Repoe o registo a0
        lw a1, 8(sp) #Repoe o registo a1
        lw a2, 12(sp) #Repoe o registo a2
        lw a3, 16(sp) #Repoe o registo a3
        addi sp, sp, 20 #Liberta espaco na pilha

        addi s1, s1, 8 #Incrementa o contador do points
        addi s5, s5, 4 #Incrementa o contador do clusters
        j loop_printClusters #Avanca para a proxima iteracao

    end_loop_printClusters:
        
    lw s0, 0(sp) #Repoe o registo s0
    lw s1, 4(sp) #Repoe o registo s1
    lw s2, 8(sp) #Repoe o registo s2
    lw s3, 12(sp) #Repoe o registo s3
    lw s4, 16(sp) #Repoe o registo s4
    lw s5, 20(sp) #Repoe o registo s5
    lw s6, 24(sp) #Repoe o registo s6
    lw s7, 28(sp) #Repoe o registo s7
    lw s8, 32(sp) #Repoe o registo s8
    lw s9, 36(sp) #Repoe o registo s9
    addi sp, sp, 40 #Liberta espaco na pilha

    jr ra #Retorna para o ponto de invocacao



### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    addi sp, sp, -16 #Reserva espaco na pilha
    sw s0, 0(sp) #Guarda o registo s0
    sw s1, 4(sp) #Guarda o registo s1
    sw s2, 8(sp) #Guarda o registo s2
    sw s3, 12(sp) #Guarda o registo s3
    
    lw s0, k #Carrega para s0 o numero de agrupamentos
    li s1, 0 #Inicializa s1 a 0
    
    loop_printCentroids:
        bge s1, s0, end_loop_printCentroids #Salta para "end_loop_printCentroids" se s1 maior ou igual do que s0
        la s2, centroids #Guarda em s2 o endereco inicial dos centroides
        slli s3, s1, 3 #Multiplica s1 por 8
        add s2, s3, s2 #s2 tem o endereco do centroide
        
        addi sp, sp, -20 #Reserva espaco na pilha
        sw ra, 0(sp) #Guarda o endereco de retorno
        sw a0, 4(sp) #Guarda o registo a0
        sw a1, 8(sp) #Guarda o registo a1
        sw a2, 12(sp) #Guarda o registo a2
        sw a3, 16(sp) #Guarda o registo a3
        
        lw a0, 0(s2) #Carrega para a0 a coordenada x do centroide
        lw a1, 4(s2) #Carrega para a1 a coordenada y do centroide
        
        li a2, black #Incializa a2 com a cor preta
        
        jal printPoint #Invoca a funcao printPoint
        
        lw ra, 0(sp) #Repoe o endereco de retorno
        lw a0, 4(sp) #Repoe o registo a0
        lw a1, 8(sp) #Repoe o registo a1
        lw a2, 12(sp) #Repoe o registo a2
        lw a3, 16(sp) #Repoe o registo a3
        addi sp, sp, 20 #Liberta espaco na pilha
        
        addi s1, s1, 1 #Incrementa o contador
        j loop_printCentroids #Avanca para a proxima iteracao
    end_loop_printCentroids:
    
    lw s0, 0(sp) #Repoe o registo s0
    lw s1, 4(sp) #Repoe o registo s1
    lw s2, 8(sp) #Repoe o registo s2
    lw s3, 12(sp) #Repoe o registo s3
    addi sp, sp, 16 #Liberta espaco na pilha
    
    jr ra #Retorna para o ponto de invocacao
    


### calculateCentroids
#OPTIMIZATION
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno:
# a0: 0 se os centroides nao foram alterados, outro numero se foram alterados

calculateCentroids:
    addi sp, sp, -44 #Reserva espaco na pilha
    sw s0, 0(sp) #Guarda o registo s0
    sw s1, 4(sp) #Guarda o registo s1
    sw s2, 8(sp) #Guarda o registo s2
    sw s3, 12(sp) #Guarda o registo s3
    sw s4, 16(sp) #Guarda o registo s4
    sw s5, 20(sp) #Guarda o registo s5
    sw s6, 24(sp) #Guarda o registo s6
    sw s7, 28(sp) #Guarda o registo s7
    sw s8, 32(sp) #Guarda o registo s8
    sw s9, 36(sp) #Guarda o registo s9
    sw s10, 40(sp) #Guarda o registo s10
    
    li a0, 0 #Inicializa a0 a 0
    lw s0, k #Carrega para s0 o numero de agrupamentos
    li s1, 0 #Inicializa s1 a 0 (iterador dos centroides)
    loop_calculateCentroids:
        bge s1, s0, end_loop_calculateCentroids #Salta para "end_loop_calculateCentroids" se s1 maior ou igual do que s0
        lw s2, n_points #Guarda em s2 o numero de pontos
        li s3, 0 #Inicializa s3 a 0 (iterador dos pontos)
        li s4, 0 #Inicializa s4 a 0 (soma da componente x)
        li s5, 0 #Inicializa s5 a 0 (soma da componente y)
        li s6, 0 #Inicializa s6 a 0 (numero de pontos no cluster)
        calculateSum:
            bge s3, s2, end_calculateSum #Salta para "end_calculateSum" se s3 maior ou igual do que s2
            
            slli s7, s3, 2 #Multiplica s3 por 4
            lw s8, clusters #Guarda em s8 o endereco inicial dos clusters
            add s8, s7, s8 #s8 tem o endereco do cluster
            lw s7, 0(s8) #Carrega o cluster em s7
            beq s7, s1, if_calculateSum #Salta para "if_calculateSum" se s7 for igual a s1
            j else_if_calculateSum #Salta para "else_if_calculateSum"
            
            if_calculateSum:
                slli s7, s3, 3 #Multiplica s3 por 8
                la s8, points #Guarda em s8 o endereco inicial dos pontos
                add s8, s7, s8 #s8 tem o endereco do ponto
                lw s7, 0(s8) #Carrega para s7 a coordenada x do ponto
                lw s8, 4(s8) #Carrega para s8 a coordenada y do ponto
                add s4, s4, s7 #Soma a coordenada x do ponto � soma da componente x
                add s5, s5, s8 #Soma a coordenada y do ponto � soma da componente y
                addi s6, s6, 1 #Incrementa o numero de pontos no cluster        
            else_if_calculateSum:
                
            addi s3, s3, 1 #Incrementa o contador
            j calculateSum #Salta para "calculateSum"
        end_calculateSum:
            beqz s6, do_not_calculateAverage #Salta para "do_not_calculateAverage" se s6 for igual a zero
            calculateAverage:
                div s4, s4, s6 #Divide o somatorio das componentes x pelo numero de pontos no cluster (media dos x)
                div s5, s5, s6 #Divide o somatorio das componentes y pelo numero de pontos no cluster (media dos y)
                slli s7, s1, 3 #Multiplica s1 por 8
                la s8, centroids #Guarda em s8 o endereco dos centroides
                add s7, s7, s8 #s7 tem o endereco do centroide
                lw s9, 0(s7) #Carrega para s9 a coordenada x do centroide
                lw s10, 4(s7) #Carrega para s10 a coordenada y do centroide
                
                bne s4, s9, if_calculateAverage #Salta para "if_calculateAverage" se s4 for diferente de s9
                bne s5, s10, if_calculateAverage #Salta para "if_calculateAverage" se s5 for diferente de s10
                j else_calculateAverage #Salta para "else_calculateAverage"
                
                if_calculateAverage:
                    addi a0, a0, 1 #Incrementa a0
                else_calculateAverage:
                    sw s4, 0(s7) #Guarda a media dos x em s4
                    sw s5, 4(s7) #Guarda a media dos y em s5
                
            do_not_calculateAverage:
                addi s1, s1, 1 #Incrementa o contador
                j loop_calculateCentroids #Salta para "loop_calculateCentroids"
    
    end_loop_calculateCentroids:

    lw s0, 0(sp) #Repoe o registo s0
    lw s1, 4(sp) #Repoe o registo s1
    lw s2, 8(sp) #Repoe o registo s2
    lw s3, 12(sp) #Repoe o registo s3
    lw s4, 16(sp) #Repoe o registo s4
    lw s5, 20(sp) #Repoe o registo s5
    lw s6, 24(sp) #Repoe o registo s6
    lw s7, 28(sp) #Repoe o registo s7
    lw s8, 32(sp) #Repoe o registo s8
    lw s9, 36(sp) #Repoe o registo s9
    lw s10, 40(sp) #Repoe o registo s10
    addi sp, sp, 44 #Liberta espaco na pilha

    jr ra #Retorna para o ponto de invocacao




### initializeCentroids
# Inicializa os centroides com valores pseudoaleatorios
# Argumentos: nenhum
# Retorno: nenhum

initializeCentroids:
    addi sp sp -32 #Reserva espaco na pilha
    sw s0 0(sp) #Guarda o registo s0
    sw s1 4(sp) #Guarda o registo s1
    sw s2 8(sp) #Guarda o registo s2
    sw s3 12(sp) #Guarda o registo s3
    sw s4 16(sp) #Guarda o registo s4
    sw s5 20(sp) #Guarda o registo s5
    sw s6 24(sp) #Guarda o registo s6
    sw s7 28(sp) #Guarda o registo s7
    
    la s0 centroids #Guarda em s2 o endereco dos centroides
    
    addi s5 s5 5 #Adiciona 5 a s5
    li s1 0 #Inicializa s1 a 0
    lw s2 k #Carrega para s2 o numero de agrupamentos
    slli s2, s2, 1 #Multiplica s2 por 2
    
    addi sp, sp, -12 #Reserva espaco na pilha
    sw a0, 0(sp) #Guarda o registo a0
    sw a1, 4(sp) #Guarda o registo a1
    sw a7, 8(sp) #Guarda o registo a7
    li a7, 30 #Inicializa a7 a 30
    ecall #Invoca a system call Time_msec
    add s3, a0, x0 #Guarda o retorno da system call em s3
    lw a0, 0(sp) #Repoe o registo a0
    lw a1, 4(sp) #Repoe o registo a1
    lw a7, 8(sp) #Repoe o registo a7
    addi sp, sp, 12 #Liberta espaco na pilha
    
    li s4, 1103515245 #Inicializa s4 com um numero escolhido aleatoriamente
    li s5, 12345 #Inicializa s5 a com um numero escolhido aleatoriamente
    
    geraAleatorios:
        beq s2 s1 end_geraAleatorios #Salta para "end_geraAleatorios" se s2 for igual a s1
        mul s3, s3, s4 #Multiplica s3 e s4
        add s3, s5, s3 #Soma s5 e s3
        andi s6, s3, 0b011111 #Seleciona os 5 bits de menor ordem
        slli s7, s1, 2 #Multiplica s1 por 4
        add s7, s7, s0 #s7 tem o endereco da coordenada a ser gerada atual
        sw s6 0(s7) #Guarda o numero gerado
        addi s1 s1 1 #Incrementa o contador
        j geraAleatorios #Salta para "geraAleatorios"
        
   end_geraAleatorios:

    lw s0 0(sp) #Repoe o registo s0
    lw s1 4(sp) #Repoe o registo s1
    lw s2 8(sp) #Repoe o registo s2
    lw s3 12(sp) #Repoe o registo s3
    lw s4 16(sp) #Repoe o registo s4
    lw s5 20(sp) #Repoe o registo s5
    lw s6 24(sp) #Repoe o registo s6
    lw s7 28(sp) #Repoe o registo s7
    addi sp sp 32 #Liberta espaco na pilha
    
    jr ra #Retorna para o ponto de invocacao



### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    addi sp, sp, -16 #Reserva espaco na pilha
    sw s0, 0(sp) #Guarda o registo s0 (x do primeiro ponto)
    sw s1, 4(sp) #Guarda o registo s1 (y do primeiro ponto)
    sw s2, 8(sp) #Guarda o registo s2 (x do segundo ponto)
    sw s3, 12(sp) #Guarda o registo s3 (y do segundo ponto)
    
    add s0 a0 x0 #s0 tem o x do primeiro ponto
    add s1 a1 x0 #s1 tem o y do primeiro ponto
    add s2 a2 x0 #s2 tem o x do segundo ponto
    add s3 a3 x0 #s3 tem o y do segundo ponto
    
    sub s0 s0 s2 #s0 tem a diferenca de coordenadas na componente x
    sub s1 s1 s3 #s1 tem a diferenca de coordenadas na componente y
    
    bltz s0, negativo_x #verififca se a componente x eh negativa
    j positivo_x #Salta para "positivo_x"
    
    negativo_x:
        neg s0, s0 #Transfora s0 no seu simetrico
    
    positivo_x:
        bltz s1, negativo_y #verifica se a componente y e negativa
        j positivo_y #Salta para "positivo_y"
            
    negativo_y:
        neg s1, s1 #Transfora s1 no seu simetrico
    positivo_y:
    
    add s0 s0 s1 #soma as duas componentes (manhattan distance)
    
    add a0 s0 x0 #manhattan distance fica no a0
    
    lw s0, 0(sp) #Repoe o registo s0
    lw s1, 4(sp) #Repoe o registo s1
    lw s2, 8(sp) #Repoe o registo s2
    lw s3, 12(sp) #Repoe o registo s3
    addi sp, sp, 16 #Liberta espaco na pilha

    jr ra #Retorna para o ponto de invocacao



### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    addi sp, sp, -28 #Reserva espaco na pilha
    sw s0, 0(sp) #Guarda o registo s0
    sw s1, 4(sp) #Guarda o registo s1
    sw s2, 8(sp) #Guarda o registo s2
    sw s3, 12(sp) #Guarda o registo s3
    sw s4, 16(sp) #Guarda o registo s4
    sw s5, 20(sp) #Guarda o registo s5
    sw s6, 24(sp) #Guarda o registo s6
    
    lw s0, k #Carrega para s0 o numero de agrupamentos
    li s1, 0 #Inicializa s1 a 0
    li s2, 0 #Inicializa s2 a 0
    li s3, 64 #Inicializa s3 a 64 (distancia maxima)
    
    loop_nearestCluster:
        bge s1, s0, end_loop_nearestCluster #Salta para "end_loop_nearestCluster" se s1 maior ou igual do que s0
        la s4, centroids #Guarda em s4 o endereco inicial dos centroides
        slli s5, s1, 3 #Multiplica s1 por 8
        add s5, s4, s5 #s5 tem o endereco do centroide
        
        addi sp, sp, -20 #Reserva espaco na pilha
        sw ra, 0(sp) #Guarda o endereco de retorno
        sw a0, 4(sp) #Guarda o registo a0
        sw a1, 8(sp) #Guarda o registo a1
        sw a2, 12(sp) #Guarda o registo a2
        sw a3, 16(sp) #Guarda o registo a3
        
        lw a2, 0(s5) #Carrega para a2 a coordenada x do centroide
        lw a3, 4(s5) #Carrega para a3 a coordenada y do centroide
        
        jal manhattanDistance #Executa a funcao "manhattanDistance"
     
        blt a0, s3, if_nearestCluster #Salta para "if_nearestCluster" se a0 for menor que s3
        j end_if_nearestCluster #Salta para "end_if_nearestCluster"
        
        if_nearestCluster:
            add s2, s1, x0 #s2 tem o valor de s1
            add s3, a0, x0 #s3 tem o valor de a0
        end_if_nearestCluster:
        
        lw ra, 0(sp) #Repoe o endereco de retorno
        lw a0, 4(sp) #Repoe o registo a0
        lw a1, 8(sp) #Repoe o registo a1
        lw a2, 12(sp) #Repoe o registo a2
        lw a3, 16(sp) #Repoe o registo a3
        addi sp, sp, 20 #Liberta espaco na pilha
        
        addi s1, s1, 1 #Incrementa o contador
        j loop_nearestCluster #Avanca para a proxima iteracao
    end_loop_nearestCluster:
    
    add a0, s2, x0 #a0 tem o valor de s2
    
    lw s0, 0(sp) #Repoe o registo s0
    lw s1, 4(sp) #Repoe o registo s1
    lw s2, 8(sp) #Repoe o registo s2
    lw s3, 12(sp) #Repoe o registo s3
    lw s4, 16(sp) #Repoe o registo s4
    lw s5, 20(sp) #Repoe o registo s5
    lw s6, 24(sp) #Repoe o registo s6
    addi sp, sp, 28 #Liberta espaco na pilha
    
    jr ra #Retorna para o ponto de invocacao



### updateClusters
# Funcao secundaria implementada pelo grupo
# Associa cada ponto a um cluster
# Argumentos: nenhum
# Retorno: nenhum

updateClusters:
    addi sp, sp, -16 #Reserva espaco na pilha
    sw s0, 0(sp) #Guarda o registo s0
    sw s1, 4(sp) #Guarda o registo s1
    sw s2, 8(sp) #Guarda o registo s2
    sw s3, 12(sp) #Guarda o registo s3
    
    lw s0, n_points #Carrega para s0 o numero de pontos
    li s1, 0 #Inicializa s1 a 0
    
    loop_updateClusters:
        bge s1, s0, end_loop_updateClusters #Salta para "end_loop_updateClusters" se s1 for maior ou igual que s0
        la s2, points #Guarda em s2 o endereco inicial dos pontos
        slli s3, s1, 3 #Multiplica s1 por 8
        add s2, s2, s3 #s2 tem o endereco do ponto
        
        addi sp, sp, -12 #Reserva espaco na pilha
        sw ra, 0(sp) #Guarda o endereco de retorno
        sw a0, 4(sp) #Guarda o registo a0
        sw a1, 8(sp) #Guarda o registo a1
        
        lw a0, 0(s2) #Carrega para a0 a coordenada x do ponto
        lw a1, 4(s2) #Carrega para a1 a coordenada y do ponto
        
        jal nearestCluster #Executa a funcao "nearestCluster"
        
        lw s2, clusters #Guarda em s2 o endereco inicial dos clusters
        slli s3, s1, 2 #Multiplica s1 por 4
        add s2, s2, s3 #s2 tem o endereco do cluster
        sw a0, 0(s2) #Guarda em a0 a coordenada x no cluster
        
        lw ra, 0(sp) #Repoe o endereco de retorno
        lw a0, 4(sp) #Repoe o registo a0
        lw a1, 8(sp) #Repoe o registo a1
        addi sp, sp, 12 #Liberta espaco na pilha
        
        addi s1, s1, 1 #Incrementa o contador
        j loop_updateClusters #Salta para "loop_updateClusters"
        
    end_loop_updateClusters:
 
    lw s0, 0(sp) #Repoe o registo s0
    lw s1, 4(sp) #Repoe o registo s1
    lw s2, 8(sp) #Repoe o registo s2
    lw s3, 12(sp) #Repoe o registo s3
    addi sp, sp, 16 #Liberta espaco na pilha
    
    jr ra #Retorna para o ponto de invocacao

### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    addi sp, sp, -12 #Reserva espaco na pilha
    sw s0, 0(sp) #Guarda o registo s0
    sw s1, 4(sp) #Guarda o registo s1
    sw s2, 8(sp) #Guarda o registo s2
    
    lw s0, n_points #Guarda em s0 o numero de pontos
    slli s0, s0, 2 #Multiplica s0 por 4
    sub sp, sp, s0 #Reserva espaco na pilha
    la s1, clusters #Guarda em s1 o endereco inicial dos clusters
    sw sp, 0(s1) #Guarda o endereco da pilha na variavel clusters
    
    addi sp, sp, -4 #Reserva espaco na pilha
    sw ra, 0(sp) #Guarda o endereco de retorno
    jal cleanScreen #Executa a funcao "cleanScreen"
    jal initializeCentroids #Executa a funcao "initializeCentroids"
    jal updateClusters #Executa a funcao "updateClusters"
    jal printClusters #Executa a funcao "printClusters"
    jal printCentroids #Executa a funcao "printCentroids"
    lw ra, 0(sp) #Repoe o endereco de retorno
    addi sp, sp, 4 #Liberta espaco na pilha
    
    lw s1, L #Carrega para s1 o numero maximo de iteracoes do algoritmo
    li s2, 1 #Inicializa s2 a 1
    
    loop_mainKMeans:
        bge s2, s1, end_loop_mainKMeans #Salta para "end_loop_mainKMeans" se s2 for maior ou igual que s1
        
        addi sp, sp, -4 #Reserva espaco na pilha
        sw ra, 0(sp) #Guarda o endereco de retorno
        jal cleanScreen #Executa a funcao "cleanScreen"
        jal calculateCentroids #Executa a funcao "calculateCentroids"
        jal updateClusters #Executa a funcao "updateClusters"
        jal printClusters #Executa a funcao "printClusters"
        jal printCentroids #Executa a funcao "printCentroids"
        beqz a0, end_loop_mainKMeans2 #Salta para "end_loop_mainKMeans2" se a0 for igual a zero
        lw ra, 0(sp) #Repoe o endereco de retorno
        addi sp, sp, 4 #Liberta espaco na pilha
        
        addi s2, s2, 1 #Incrementa o contador
        j loop_mainKMeans #Salta para "loop_mainKMeans"

    end_loop_mainKMeans2:
        lw ra, 0(sp) #Repoe o endereco de retorno
        addi sp, sp, 4 #Liberta espaco na pilha
    
    end_loop_mainKMeans:
    
    add sp, sp, s0 #Liberta espaco na pilha
    
    lw s0, 0(sp) #Repoe o registo s0
    lw s1, 4(sp) #Repoe o registo s1
    lw s2, 8(sp) #Repoe o registo s2
    addi sp, sp, 12 #Liberta espaco na pilha
    
    jr ra #Retorna para o ponto de invocacao