-- ============================================================
-- PROJETO N2 - CONSULTAS SQL BASICAS
-- Banco: doceria_n2
-- Executar apos o script completo criar e popular o banco.
-- ============================================================

USE doceria_n2;

-- 1. SELECT: listar produtos disponiveis no cardapio.
SELECT id_produto, nome, preco_unitario
FROM produto
WHERE disponivel = 1
ORDER BY nome;

-- 2. WHERE: localizar pedidos de delivery ainda nao finalizados.
SELECT id_pedido, data_pedido, status, valor_total
FROM pedido
WHERE tipo_entrega = 'delivery'
  AND status NOT IN ('entregue', 'cancelado')
ORDER BY data_pedido;

-- 3. JOIN: pedidos com cliente e funcionario responsavel.
SELECT
  p.id_pedido,
  COALESCE(c.nome, 'Cliente de balcão') AS cliente,
  f.nome AS funcionario,
  p.status,
  p.valor_total
FROM pedido p
LEFT JOIN cliente c ON c.id_cliente = p.id_cliente
LEFT JOIN funcionario f ON f.id_funcionario = p.id_funcionario
ORDER BY p.id_pedido;

-- 4. GROUP BY: quantidade de pedidos por status.
SELECT status, COUNT(*) AS quantidade_pedidos
FROM pedido
GROUP BY status
ORDER BY quantidade_pedidos DESC;

-- 5. ORDER BY: produtos ordenados do maior para o menor preco.
SELECT nome, preco_unitario
FROM produto
ORDER BY preco_unitario DESC;

-- 6. UPDATE: marcar um produto temporariamente como indisponivel.
UPDATE produto
SET disponivel = 0
WHERE nome = 'Chocolate Gelado';

-- 7. DELETE: remover movimentacoes de teste sem apagar historico real.
DELETE FROM movimentacao_estoque
WHERE tipo = 'ajuste'
  AND motivo LIKE '%teste%';
