-- ============================================================
-- PROJETO N2 - RELATORIOS SQL
-- Banco: doceria_n2
-- Executar apos o script completo criar e popular o banco.
-- ============================================================

USE doceria_n2;

-- 1. Produtos mais vendidos.
SELECT
  pr.nome AS produto,
  c.nome AS categoria,
  SUM(ip.quantidade) AS total_vendido,
  SUM(ip.subtotal) AS receita_bruta
FROM item_pedido ip
JOIN produto pr ON pr.id_produto = ip.id_produto
JOIN categoria c ON c.id_categoria = pr.id_categoria
JOIN pedido p ON p.id_pedido = ip.id_pedido
WHERE p.status <> 'cancelado'
GROUP BY pr.id_produto, pr.nome, c.nome
ORDER BY total_vendido DESC, receita_bruta DESC;

-- 2. Clientes que mais compraram.
SELECT
  c.nome AS cliente,
  c.email,
  COUNT(p.id_pedido) AS quantidade_pedidos,
  SUM(p.valor_total) AS total_gasto
FROM cliente c
JOIN pedido p ON p.id_cliente = c.id_cliente
WHERE p.status = 'entregue'
GROUP BY c.id_cliente, c.nome, c.email
ORDER BY total_gasto DESC;

-- 3. Faturamento mensal.
SELECT
  DATE_FORMAT(p.data_pedido, '%Y-%m') AS mes,
  COUNT(p.id_pedido) AS pedidos_finalizados,
  SUM(p.valor_total) AS faturamento
FROM pedido p
WHERE p.status = 'entregue'
GROUP BY DATE_FORMAT(p.data_pedido, '%Y-%m')
ORDER BY mes;

-- 4. Ingredientes com estoque baixo.
SELECT
  i.nome AS ingrediente,
  e.quantidade_atual,
  e.quantidade_minima,
  (e.quantidade_minima - e.quantidade_atual) AS quantidade_a_repor,
  e.local_armazenamento
FROM estoque e
JOIN ingrediente i ON i.id_ingrediente = e.id_ingrediente
WHERE e.quantidade_atual < e.quantidade_minima
ORDER BY quantidade_a_repor DESC;

-- 5. Pedidos por periodo.
SELECT
  p.id_pedido,
  COALESCE(c.nome, 'Cliente de balcão') AS cliente,
  p.data_pedido,
  p.status,
  p.valor_total
FROM pedido p
LEFT JOIN cliente c ON c.id_cliente = p.id_cliente
WHERE p.data_pedido BETWEEN '2026-05-01' AND '2026-05-31 23:59:59'
ORDER BY p.data_pedido;

-- 6. Formas de pagamento mais utilizadas.
SELECT
  forma_pagamento,
  COUNT(*) AS quantidade_usos,
  SUM(valor_pago) AS valor_total
FROM pagamento
WHERE status_pagamento = 'aprovado'
GROUP BY forma_pagamento
ORDER BY quantidade_usos DESC, valor_total DESC;

-- 7. Pedidos detalhados com itens vendidos.
SELECT
  p.id_pedido,
  COALESCE(c.nome, 'Cliente de balcão') AS cliente,
  pr.nome AS produto,
  ip.quantidade,
  ip.preco_unitario,
  ip.subtotal,
  p.status
FROM item_pedido ip
JOIN pedido p ON p.id_pedido = ip.id_pedido
JOIN produto pr ON pr.id_produto = ip.id_produto
LEFT JOIN cliente c ON c.id_cliente = p.id_cliente
ORDER BY p.id_pedido, pr.nome;

