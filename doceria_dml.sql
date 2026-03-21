-- ============================================================
--  DML: Dados de exemplo — Doceria
--  Executar APÓS o DDL (doceria_ddl.sql)
-- ============================================================

USE doceria;

-- ============================================================
-- 1. CLIENTES
-- ============================================================

INSERT INTO cliente (nome, cpf, telefone, email, data_nascimento) VALUES
  ('Ana Paula Ferreira',  '12345678901', '62991110001', 'ana.paula@email.com',   '1995-03-14'),
  ('Bruno Carvalho',      '23456789012', '62992220002', 'bruno.carv@email.com',  '1988-07-22'),
  ('Carla Mendes',        '34567890123', '62993330003', 'carla.m@email.com',     '2000-11-05'),
  ('Diego Souza',         '45678901234', '62994440004', 'diego.s@email.com',     '1992-01-30'),
  ('Eduarda Lima',        '56789012345', '62995550005', 'edu.lima@email.com',    '1999-06-18');

-- ============================================================
-- 2. ENDEREÇOS
-- ============================================================

INSERT INTO endereco_cliente (id_cliente, logradouro, numero, bairro, cidade, estado, cep, principal) VALUES
  (1, 'Rua das Flores',       '123', 'Setor Bueno',    'Goiânia', 'GO', '74230010', 1),
  (2, 'Av. T-63',             '456', 'Jardim Goiás',   'Goiânia', 'GO', '74280040', 1),
  (3, 'Rua C-149',            '789', 'Jardim América', 'Goiânia', 'GO', '74255080', 1),
  (4, 'Rua 1010',             '10',  'Setor Pedro Ludovico', 'Goiânia', 'GO', '74835010', 1),
  (5, 'Av. Anhanguera',       '999', 'Setor Oeste',    'Goiânia', 'GO', '74110010', 1);

-- ============================================================
-- 3. CATEGORIAS
-- ============================================================

INSERT INTO categoria (nome, descricao) VALUES
  ('Bolos',       'Bolos inteiros e fatias, sob encomenda ou no balcão'),
  ('Docinhos',    'Brigadeiros, beijinhos, cajuzinhos e variações'),
  ('Tortas',      'Tortas doces geladas e assadas'),
  ('Bebidas',     'Sucos, achocolatados e cafés'),
  ('Salgadinhos', 'Coxinhas, empadas e mini-quiches');

-- ============================================================
-- 4. PRODUTOS
-- ============================================================

INSERT INTO produto (id_categoria, nome, descricao, preco_unitario) VALUES
  -- Bolos
  (1, 'Bolo de Chocolate',      'Massa úmida com ganache e granulado',         55.00),
  (1, 'Bolo Red Velvet',        'Massa vermelha com cream cheese',             65.00),
  (1, 'Bolo de Cenoura',        'Massa fofinha com cobertura de brigadeiro',   48.00),
  -- Docinhos
  (2, 'Brigadeiro Tradicional', 'Brigadeiro de chocolate belga, por unidade',   3.50),
  (2, 'Beijinho',               'Coco fresco com açúcar cristal, por unidade',  3.50),
  (2, 'Trufa de Maracujá',      'Trufa com recheio de maracujá, por unidade',   4.50),
  -- Tortas
  (3, 'Torta de Limão',         'Base de biscoito, creme e merengue',          42.00),
  (3, 'Torta de Morango',       'Creme patissière e morangos frescos',         50.00),
  -- Bebidas
  (4, 'Café Espresso',          'Café 100% arábica, dose simples',              6.00),
  (4, 'Achocolatado Gelado',    'Chocolate em pó com leite gelado',             8.00),
  -- Salgadinhos
  (5, 'Coxinha de Frango',      'Massa crocante com recheio cremoso',           6.50),
  (5, 'Empada de Queijo',       'Massa amanteigada com queijo minas',           5.50);

-- ============================================================
-- 5. INGREDIENTES
-- ============================================================

INSERT INTO ingrediente (nome, unidade_medida, qtd_estoque, qtd_minima) VALUES
  ('Farinha de trigo',   'kg',      20.000,  5.000),
  ('Açúcar refinado',    'kg',      15.000,  3.000),
  ('Chocolate em pó',    'kg',       8.000,  2.000),
  ('Manteiga',           'kg',       6.000,  1.500),
  ('Ovos',               'unidade', 120.000, 24.000),
  ('Leite integral',     'litro',   10.000,  2.000),
  ('Creme de leite',     'litro',    5.000,  1.000),
  ('Coco ralado',        'kg',       2.000,  0.500),
  ('Morango',            'kg',       3.000,  1.000),
  ('Limão',              'unidade',  30.000,  8.000),
  ('Queijo minas',       'kg',       4.000,  1.000),
  ('Frango desfiado',    'kg',       5.000,  1.000),
  ('Biscoito maizena',   'kg',       3.000,  0.500),
  ('Leite condensado',   'litro',    8.000,  2.000),
  ('Café moído',         'kg',       2.000,  0.500);

-- ============================================================
-- 6. RECEITAS (ingredientes por produto)
-- ============================================================

-- Bolo de Chocolate (id 1)
INSERT INTO receita (id_produto, id_ingrediente, quantidade) VALUES
  (1,  1, 0.500),  -- farinha
  (1,  2, 0.300),  -- açúcar
  (1,  3, 0.200),  -- chocolate em pó
  (1,  4, 0.150),  -- manteiga
  (1,  5, 3.000),  -- ovos
  (1,  6, 0.250);  -- leite

-- Brigadeiro Tradicional (id 4)
INSERT INTO receita (id_produto, id_ingrediente, quantidade) VALUES
  (4, 14, 0.100),  -- leite condensado (por unidade)
  (4,  3, 0.020),  -- chocolate em pó
  (4,  4, 0.010);  -- manteiga

-- Torta de Morango (id 8)
INSERT INTO receita (id_produto, id_ingrediente, quantidade) VALUES
  (8, 13, 0.200),  -- biscoito
  (8,  4, 0.100),  -- manteiga
  (8,  9, 0.300),  -- morango
  (8,  7, 0.200),  -- creme de leite
  (8,  2, 0.100);  -- açúcar

-- Coxinha de Frango (id 11)
INSERT INTO receita (id_produto, id_ingrediente, quantidade) VALUES
  (11,  1, 0.100),  -- farinha
  (11, 12, 0.080),  -- frango desfiado
  (11,  6, 0.050);  -- leite

-- ============================================================
-- 7. MOVIMENTAÇÕES DE ESTOQUE (entradas iniciais)
-- ============================================================

INSERT INTO movimentacao_estoque (id_ingrediente, tipo, quantidade, motivo) VALUES
  (1,  'entrada', 20.000, 'Compra inicial — fornecedor Moinho Goiás'),
  (2,  'entrada', 15.000, 'Compra inicial — distribuidora'),
  (3,  'entrada',  8.000, 'Compra inicial — distribuidora'),
  (4,  'entrada',  6.000, 'Compra inicial — laticínios'),
  (5,  'entrada', 120.000,'Compra inicial — granja local'),
  (6,  'entrada', 10.000, 'Compra inicial — laticínios'),
  (14, 'entrada',  8.000, 'Compra inicial — distribuidora'),
  (9,  'entrada',  3.000, 'Compra inicial — feira');

-- ============================================================
-- 8. PEDIDOS
-- ============================================================

INSERT INTO pedido (id_cliente, status, tipo_entrega, id_endereco, observacao, valor_total) VALUES
  (1, 'entregue',    'delivery',  1, 'Sem glúten se possível',           110.00),
  (2, 'entregue',    'retirada',  NULL, NULL,                             17.50),
  (3, 'em_producao', 'delivery',  3, 'Entregar após 18h',                 65.00),
  (4, 'aguardando',  'retirada',  NULL, 'Bolo com escrita "Feliz Aniver"', 55.00),
  (5, 'pronto',      'retirada',  NULL, NULL,                              27.00),
  (NULL, 'entregue', 'retirada',  NULL, 'Cliente balcão',                  19.50); -- venda anônima

-- ============================================================
-- 9. ITENS DOS PEDIDOS
-- ============================================================

-- Pedido 1: Bolo de Chocolate + 2x Brigadeiro
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
  (1, 1, 1, 55.00),
  (1, 4, 2,  3.50);  -- subtotal 110 ≈ 55 + 7 + extras no valor_total

-- Pedido 2: 5x Brigadeiro
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
  (2, 4, 5, 3.50);

-- Pedido 3: Bolo Red Velvet
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
  (3, 2, 1, 65.00);

-- Pedido 4: Bolo de Chocolate
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
  (4, 1, 1, 55.00);

-- Pedido 5: 3x Trufa de Maracujá + Café
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
  (5, 6, 3, 4.50),
  (5, 9, 1, 6.00);

-- Pedido 6 (balcão): 3x Coxinha
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
  (6, 11, 3, 6.50);

-- ============================================================
-- 10. PAGAMENTOS
-- ============================================================

INSERT INTO pagamento (id_pedido, forma, valor, status) VALUES
  (1, 'pix',            110.00, 'aprovado'),
  (2, 'dinheiro',        17.50, 'aprovado'),
  (3, 'cartao_credito',  65.00, 'pendente'),
  (4, 'pix',             55.00, 'pendente'),
  (5, 'cartao_debito',   27.00, 'aprovado'),
  (6, 'dinheiro',        19.50, 'aprovado');

-- ============================================================
-- CONSULTAS DE VERIFICAÇÃO (opcional — rode para conferir)
-- ============================================================

-- Ver todos os pedidos com nome do cliente
-- SELECT p.id_pedido, c.nome, p.status, p.valor_total, p.data_pedido
-- FROM pedido p
-- LEFT JOIN cliente c ON c.id_cliente = p.id_cliente
-- ORDER BY p.data_pedido DESC;

-- Ver itens de um pedido específico
-- SELECT ip.id_pedido, pr.nome, ip.quantidade, ip.preco_unitario, ip.subtotal
-- FROM item_pedido ip
-- JOIN produto pr ON pr.id_produto = ip.id_produto
-- WHERE ip.id_pedido = 1;

-- Ver ingredientes abaixo do estoque mínimo
-- SELECT nome, unidade_medida, qtd_estoque, qtd_minima
-- FROM ingrediente
-- WHERE qtd_estoque < qtd_minima;