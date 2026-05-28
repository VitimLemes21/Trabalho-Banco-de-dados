-- ============================================================
--  QUERIES: Consultas, Alterações, Eliminação e Trigger
--  Doceria — MySQL 8.0+
--  Executar APÓS doceria_ddl.sql e doceria_dml.sql
-- ============================================================

USE doceria;

-- ============================================================
-- PARTE 1: SELECT — Consultas
-- ============================================================

-- 1.1 Todos os pedidos com nome do cliente, status e total
SELECT
    p.id_pedido,
    COALESCE(c.nome, 'Balcão') AS cliente,
    p.status,
    p.tipo_entrega,
    p.valor_total,
    p.data_pedido
FROM pedido p
LEFT JOIN cliente c ON c.id_cliente = p.id_cliente
ORDER BY p.data_pedido DESC;

-- -------------------------------------------------------

-- 1.2 Itens de cada pedido com nome do produto e subtotal
SELECT
    ip.id_pedido,
    COALESCE(c.nome, 'Balcão')  AS cliente,
    pr.nome                     AS produto,
    ip.quantidade,
    ip.preco_unitario,
    ip.subtotal
FROM item_pedido ip
JOIN pedido  p  ON p.id_pedido  = ip.id_pedido
JOIN produto pr ON pr.id_produto = ip.id_produto
LEFT JOIN cliente c ON c.id_cliente = p.id_cliente
ORDER BY ip.id_pedido, pr.nome;

-- -------------------------------------------------------

-- 1.3 Produtos mais vendidos (ranking por quantidade)
SELECT
    pr.nome                         AS produto,
    cat.nome                        AS categoria,
    SUM(ip.quantidade)              AS total_vendido,
    SUM(ip.subtotal)                AS receita_total
FROM item_pedido ip
JOIN produto  pr  ON pr.id_produto  = ip.id_produto
JOIN categoria cat ON cat.id_categoria = pr.id_categoria
JOIN pedido    p   ON p.id_pedido    = ip.id_pedido
WHERE p.status != 'cancelado'
GROUP BY pr.id_produto, pr.nome, cat.nome
ORDER BY total_vendido DESC;

-- -------------------------------------------------------

-- 1.4 Ingredientes abaixo do estoque mínimo (alerta de reposição)
SELECT
    i.nome,
    i.unidade_medida,
    i.qtd_estoque,
    i.qtd_minima,
    (i.qtd_minima - i.qtd_estoque) AS deficit
FROM ingrediente i
WHERE i.qtd_estoque < i.qtd_minima
ORDER BY deficit DESC;

-- -------------------------------------------------------

-- 1.5 Receita total por dia (relatório de faturamento)
SELECT
    DATE(p.data_pedido)     AS dia,
    COUNT(p.id_pedido)      AS total_pedidos,
    SUM(p.valor_total)      AS faturamento
FROM pedido p
WHERE p.status NOT IN ('cancelado', 'aguardando')
GROUP BY DATE(p.data_pedido)
ORDER BY dia DESC;

-- -------------------------------------------------------

-- 1.6 Clientes com maior gasto total (programa de fidelidade)
SELECT
    c.nome,
    c.email,
    COUNT(p.id_pedido)  AS qtd_pedidos,
    SUM(p.valor_total)  AS total_gasto
FROM cliente c
JOIN pedido p ON p.id_cliente = c.id_cliente
WHERE p.status = 'entregue'
GROUP BY c.id_cliente, c.nome, c.email
ORDER BY total_gasto DESC
LIMIT 10;

-- -------------------------------------------------------

-- 1.7 Pedidos de delivery pendentes com endereço de entrega
SELECT
    p.id_pedido,
    COALESCE(c.nome, 'Balcão')  AS cliente,
    c.telefone,
    CONCAT(e.logradouro, ', ', e.numero, ' — ', e.bairro, ', ', e.cidade) AS endereco,
    p.status,
    p.observacao
FROM pedido p
LEFT JOIN cliente         c ON c.id_cliente  = p.id_cliente
LEFT JOIN endereco_cliente e ON e.id_endereco = p.id_endereco
WHERE p.tipo_entrega = 'delivery'
  AND p.status NOT IN ('entregue', 'cancelado')
ORDER BY p.data_pedido;

-- -------------------------------------------------------

-- 1.8 Receita de cada produto (ingredientes necessários por unidade)
SELECT
    pr.nome         AS produto,
    i.nome          AS ingrediente,
    r.quantidade    AS qtd_por_unidade,
    i.unidade_medida
FROM receita r
JOIN produto     pr ON pr.id_produto    = r.id_produto
JOIN ingrediente i  ON i.id_ingrediente = r.id_ingrediente
ORDER BY pr.nome, i.nome;

-- ============================================================
-- PARTE 2: UPDATE — Alterações
-- ============================================================

-- 2.1 Atualizar status de um pedido (ex.: pedido 3 saiu para entrega)
UPDATE pedido
SET    status = 'entregue'
WHERE  id_pedido = 3;

-- -------------------------------------------------------

-- 2.2 Reajuste de preço: bolos com aumento de 10%
UPDATE produto
SET    preco_unitario = ROUND(preco_unitario * 1.10, 2)
WHERE  id_categoria = 1;   -- categoria "Bolos"

-- -------------------------------------------------------

-- 2.3 Repor estoque de um ingrediente após compra
UPDATE ingrediente
SET    qtd_estoque = qtd_estoque + 10.000
WHERE  id_ingrediente = 1;  -- farinha de trigo

-- -------------------------------------------------------

-- 2.4 Registrar reposição na tabela de movimentações
INSERT INTO movimentacao_estoque (id_ingrediente, tipo, quantidade, motivo)
VALUES (1, 'entrada', 10.000, 'Reposição de emergência — fornecedor Moinho Goiás');

-- -------------------------------------------------------

-- 2.5 Desativar produto temporariamente (fora de temporada)
UPDATE produto
SET    disponivel = 0
WHERE  id_produto = 9;   -- Torta de Morango (morango fora de época)

-- -------------------------------------------------------

-- 2.6 Corrigir e-mail de um cliente
UPDATE cliente
SET    email = 'ana.paulaf@email.com'
WHERE  id_cliente = 1;

-- ============================================================
-- PARTE 3: DELETE — Eliminação
-- ============================================================

-- 3.1 Cancelar um pedido (soft: só muda o status)
UPDATE pedido
SET    status = 'cancelado'
WHERE  id_pedido = 4;

-- -------------------------------------------------------

-- 3.2 Remover um item específico de um pedido (erro de lançamento)
DELETE FROM item_pedido
WHERE  id_pedido = 5
  AND  id_produto = 9;   -- remove Café Espresso do pedido 5

-- -------------------------------------------------------

-- 3.3 Desativar cliente (soft delete — preserva histórico)
UPDATE cliente
SET    ativo = 0
WHERE  id_cliente = 5;

-- -------------------------------------------------------

-- 3.4 Excluir endereço secundário de um cliente
DELETE FROM endereco_cliente
WHERE  id_cliente  = 1
  AND  principal   = 0;   -- remove somente endereços não-principais

-- -------------------------------------------------------

-- 3.5 Remover categoria vazia (sem produtos vinculados)
DELETE FROM categoria
WHERE id_categoria NOT IN (
    SELECT DISTINCT id_categoria FROM produto
);

-- ============================================================
-- PARTE 4: TRIGGER — Desconto automático de estoque
-- ============================================================
-- Quando um pedido passa para "em_producao", o trigger desconta
-- automaticamente os ingredientes com base na receita de cada
-- produto do pedido. Isso garante integridade do estoque sem
-- depender de código externo.
-- ============================================================

DELIMITER $$

CREATE TRIGGER trg_descontar_estoque
AFTER UPDATE ON pedido
FOR EACH ROW
BEGIN
    -- Só age quando o status muda para "em_producao"
    IF NEW.status = 'em_producao' AND OLD.status != 'em_producao' THEN

        -- Desconta os ingredientes de cada item do pedido
        UPDATE ingrediente ing
        JOIN (
            SELECT
                r.id_ingrediente,
                SUM(r.quantidade * ip.quantidade) AS total_consumido
            FROM item_pedido ip
            JOIN receita r ON r.id_produto = ip.id_produto
            WHERE ip.id_pedido = NEW.id_pedido
            GROUP BY r.id_ingrediente
        ) consumo ON consumo.id_ingrediente = ing.id_ingrediente
        SET ing.qtd_estoque = ing.qtd_estoque - consumo.total_consumido;

        -- Registra saídas no histórico de movimentações
        INSERT INTO movimentacao_estoque (id_ingrediente, tipo, quantidade, motivo)
        SELECT
            r.id_ingrediente,
            'saida',
            SUM(r.quantidade * ip.quantidade),
            CONCAT('Pedido #', NEW.id_pedido, ' em produção')
        FROM item_pedido ip
        JOIN receita r ON r.id_produto = ip.id_produto
        WHERE ip.id_pedido = NEW.id_pedido
        GROUP BY r.id_ingrediente;

    END IF;
END$$

DELIMITER ;

-- -------------------------------------------------------
-- Teste do trigger: muda pedido 1 para em_producao
-- e verifica se o estoque da farinha diminuiu
-- -------------------------------------------------------

-- Antes:
-- SELECT nome, qtd_estoque FROM ingrediente WHERE id_ingrediente = 1;

UPDATE pedido SET status = 'em_producao' WHERE id_pedido = 1;

-- Depois (deve ter diminuído 0.5 kg de farinha — receita do Bolo de Chocolate):
-- SELECT nome, qtd_estoque FROM ingrediente WHERE id_ingrediente = 1;

-- ============================================================
-- PARTE 5: VIEW — Acessibilidade dos dados
-- ============================================================
-- VIEWs simplificam consultas complexas para outros usuários
-- do sistema (ex.: atendente que não conhece SQL avançado)
-- ============================================================

-- 5.1 View: pedidos ativos resumidos
CREATE OR REPLACE VIEW vw_pedidos_ativos AS
SELECT
    p.id_pedido,
    COALESCE(c.nome, 'Balcão') AS cliente,
    p.status,
    p.tipo_entrega,
    p.valor_total,
    p.data_pedido
FROM pedido p
LEFT JOIN cliente c ON c.id_cliente = p.id_cliente
WHERE p.status NOT IN ('entregue', 'cancelado');

-- 5.2 View: estoque crítico
CREATE OR REPLACE VIEW vw_estoque_critico AS
SELECT
    nome,
    unidade_medida,
    qtd_estoque,
    qtd_minima,
    (qtd_minima - qtd_estoque) AS deficit
FROM ingrediente
WHERE qtd_estoque < qtd_minima;

-- 5.3 View: faturamento do dia
CREATE OR REPLACE VIEW vw_faturamento_hoje AS
SELECT
    COUNT(id_pedido)    AS pedidos_finalizados,
    SUM(valor_total)    AS faturamento_total
FROM pedido
WHERE DATE(data_pedido) = CURDATE()
  AND status = 'entregue';

-- Uso das views (simples, sem JOIN):
-- SELECT * FROM vw_pedidos_ativos;
-- SELECT * FROM vw_estoque_critico;
-- SELECT * FROM vw_faturamento_hoje;