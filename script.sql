####O código abaixo foi criado em cima do mysql.

####Entendimento sobre WITH RECURSIVE na tabela auxiliar
####https://learnsql.com/blog/recursive-cte-sql-server/


####Entendimento de como funciona a funcao FIND_IN_SET como filtro
####https://blog.renatolucena.net/post/como-usar-a-funcao-find-in-set-com-a-clausula-where-do-mys#:~:text=Quando%20usamos%20a%20fun%C3%A7%C3%A3o%20FIND_IN_SET,colunas%20das%20linhas%20em%20quest%C3%A3o.


####Criar tabela para fazer a query
CREATE TABLE db_test.edges (
	id int(11) NOT NULL auto_increment,
    start_node int,
    end_node int,
    cost int,
	PRIMARY KEY (id)
);


####Inserindo dados na tabela
INSERT INTO db_test.edges(start_node,end_node,cost) VALUES 
(1,2,10),
(1,3,15),
(1,4,20),
(2,4,25),
(2,5,15),
(3,4,30),
(3,5,5),
(4,5,10),
(5,6,10),
(5,7,5),
(6,8,5),
(7,8,15);


####1 - Encontrar o caminho mais barato do start_node 1 ao end_node 8:
WITH RECURSIVE Auxtable AS (
  SELECT start_node, end_node, cost, CAST(start_node AS CHAR(1000)) AS path_traveled
  FROM db_test.edges
  WHERE start_node = 1
  UNION ALL
  SELECT e.start_node, e.end_node, e.cost+ sp.cost, CONCAT(path_traveled, ',', e.end_node)
  FROM db_test.edges e
  JOIN Auxtable sp ON e.start_node = sp.end_node
  WHERE NOT FIND_IN_SET(e.end_node, path_traveled)
)
SELECT path_traveled, cost
FROM Auxtable
WHERE end_node = 8
ORDER BY cost asc
LIMIT 1;
###Result: 
path_traveled | cost
1,5,6,8       | 35


####2 - Calculando o custo total para cada caminho do start_node 1 ao end_node 8:
WITH RECURSIVE Auxtable AS (
  SELECT start_node, end_node, cost, CAST(start_node AS CHAR(1000)) AS path_traveled
  FROM db_test.edges
  WHERE start_node = 1
  UNION ALL
  SELECT e.start_node, e.end_node, e.cost + ap.cost, CONCAT(path_traveled, ',', e.end_node)
  FROM db_test.edges e
  JOIN Auxtable ap ON e.start_node = ap.end_node
  WHERE NOT FIND_IN_SET(e.end_node, path_traveled)
)
SELECT path_traveled, cost
FROM Auxtable
WHERE end_node = 8
ORDER BY cost asc;
###Result: 
path_traveled | cost
1,5,6,8       | 35
1,5,6,8       | 40
1,5,7,8       | 40
1,5,6,8       | 45
1,5,7,8       | 45
1,5,7,8       | 50
1,4,5,6,8     | 60
1,4,5,7,8     | 65
1,4,5,6,8     | 70
1,4,5,7,8     | 75


####3 - Calculando o custo total a mediana para cada caminho possivel do start_node 1 ao end_node 8 e mostrando apenas o caminho mais barato:
WITH RECURSIVE Auxtable AS (
  SELECT start_node, end_node, cost, CAST(start_node AS CHAR(1000)) AS path_traveled
  FROM db_test.edges
  WHERE start_node = 1
  UNION ALL
  SELECT e.start_node, e.end_node, e.cost + ap.cost, CONCAT(path_traveled, ',', e.end_node)
  FROM db_test.edges e
  JOIN Auxtable ap ON e.start_node = ap.end_node
  WHERE NOT FIND_IN_SET(e.end_node, path_traveled)
)
,
RankPaths AS (
  SELECT path_traveled, cost,
         ROW_NUMBER() OVER (ORDER BY cost) AS row_num,
         COUNT(*) OVER () AS total_rows
  FROM Auxtable
  WHERE end_node = 8
)
SELECT start_node, end_node, path_traveled, cost, median_cost, CASE 
	WHEN cost < median_cost 
    THEN "Cheap " 
    ELSE "Expensive " 
END 'avaliation'
FROM (
(SELECT * FROM Auxtable WHERE end_node = 8) as pathing
, (
SELECT AVG(cost) AS median_cost
FROM RankPaths
WHERE row_num BETWEEN total_rows / 2 AND total_rows / 2 + 1) as result_median ) order by cost
LIMIT 1
###Result 
start_node | end_node | path_traveled | cost | median_cost | avaliation
6          | 8        | 1,5,6,8       | 35   | 47.5000     | Cheap 

