# IAC 23/24 - Projeto
**Filipe Oliveira**  
**Número de estudante**: ist1110633

## 📌 Descrição do Projeto  

Este projeto tem como objetivo desenvolver, em **assembly RISC-V**, um programa que implementa o **algoritmo k-means** para agrupar pontos num espaço **bidimensional (2D)**. O programa recebe um conjunto inicial de pontos e identifica **𝑘 grupos** com base na proximidade relativa dos pontos de cada grupo.   

Para garantir eficiência e precisão, a implementação segue uma estrutura modular, utilizando **RISC-V Assembly** e respeitando restrições de memória e desempenho.  

---

## 🎯 Funcionalidade do Programa  

O programa recebe os seguintes **parâmetros de entrada**:  

- **points** → Vetor de pontos no espaço 2D (cada ponto é um par `{x, y}`).  
- **n** → Número total de pontos.  
- **k** → Número de agrupamentos (**clusters**) desejados.  
- **l** → Número máximo de iterações do algoritmo.  

Durante a execução, os **clusters** e os seus **centróides** serão exibidos numa **matriz 2D** no ecrã, representados por diferentes **cores**.  

O algoritmo **k-means** será executado **uma única vez**, sem otimizações para múltiplas execuções.  

---

## 🛠 Organização do Código  

O projeto está dividido em **múltiplos procedimentos**, o que garante uma implementação modular e organizada.  

### 📌 **Procedimentos Principais**  

#### 🖥️ **Exibição no Ecrã**  
- `cleanScreen` → Limpa todos os pontos do ecrã.  
- `printClusters` → Exibe os pontos coloridos de acordo com seu cluster.  
- `printCentroids` → Exibe os centróides no ecrã.  

#### 📊 **Cálculo e Atualização de Clusters**  
- `calculateCentroids` → Calcula as coordenadas médias dos pontos em cada cluster.  
- `initializeCentroids` → Define os centróides iniciais de forma pseudo-aleatória.  

#### 🔢 **Algoritmo k-means**  
- `manhattanDistance` → Calcula a distância de Manhattan entre dois pontos.  
- `nearestCluster` → Associa um ponto ao cluster cujo centróide está mais próximo.  
- `mainKMeans` → Executa o algoritmo k-means até atingir convergência ou o limite de iterações.  

#### 🎯 **Execução Principal**  
- `mainSingleCluster` → Implementação para o caso base (`k = 1`).  
- `mainKMeans` → Execução completa do algoritmo para `k > 1`.  

---

## ▶️ Como Executar  

1. **Abrir o Simulador**: O projeto deve ser executado no **simulador Ripes** (RISC-V de 32 bits).  
2. **Configurar o Ecrã**: Utilizar um **LED Matrix** na secção de I/O do simulador.  
3. **Executar o programa** carregando o ficheiro `.S` no Ripes e iniciando a simulação.