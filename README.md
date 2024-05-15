# Descrição do Desafio
Dada uma tabela temporária representando um grafo, que contém colunas para o ponto de
partida (`start_node`), ponto de chegada (`end_node`) e o custo (`cost`) associado à
transição entre esses pontos, você deverá:
1 - Escrever uma consulta SQL que determine o caminho mais barato do nó 1 ao nó 8.
2 - Calcular o custo total para cada caminho possível do nó 1 ao nó 8.
3 - Usando as funções estatísticas, determinar se o custo total do caminho mais barato está abaixo, acima, ou na mediana dos custos de todos os caminhos possíveis.

Requisitos Específicos
● Use a tabela temporária abaixo para simular o grafo:
CREATE TEMP TABLE edges AS
SELECT * FROM UNNEST([
STRUCT(1 AS start_node, 2 AS end_node, 10 AS cost),
STRUCT(1, 3, 15),
STRUCT(1, 4, 20),
STRUCT(2, 4, 25),
STRUCT(2, 5, 15),
STRUCT(3, 4, 30),
STRUCT(3, 5, 5),
STRUCT(4, 5, 10),
STRUCT(5, 6, 10),
STRUCT(5, 7, 5),
STRUCT(6, 8, 5),
STRUCT(7, 8, 15)
]);

● Apresente o caminho como um array que mostra a sequência de nós percorridos do
início ao fim.

● Aplique funções estatísticas para calcular a média e a mediana dos custos dos
caminhos.

● Classifique o custo do caminho mais barato em relação à mediana dos custos dos
caminhos.
