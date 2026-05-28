-- ============================================================
-- PROJETO N2 - BANCO DE DADOS DOCERIA
-- Instituicao: UNIALFA
-- SGBD: MySQL 8.0+
-- Objetivo: banco relacional para cadastro de clientes, produtos,
-- estoque, pedidos, pagamentos e relatorios gerenciais.
-- ============================================================

DROP DATABASE IF EXISTS doceria_n2;
CREATE DATABASE doceria_n2
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE doceria_n2;

-- ============================================================
-- 1. ESTRUTURA DO BANCO
-- ============================================================

CREATE TABLE cliente (
  id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  cpf CHAR(11) NOT NULL,
  telefone VARCHAR(20),
  email VARCHAR(150),
  data_nascimento DATE,
  data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT uk_cliente_cpf UNIQUE (cpf),
  CONSTRAINT uk_cliente_email UNIQUE (email)
);

CREATE TABLE endereco_cliente (
  id_endereco INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_cliente INT UNSIGNED NOT NULL,
  logradouro VARCHAR(150) NOT NULL,
  numero VARCHAR(15) NOT NULL,
  complemento VARCHAR(80),
  bairro VARCHAR(80) NOT NULL,
  cidade VARCHAR(80) NOT NULL,
  estado CHAR(2) NOT NULL,
  cep CHAR(8) NOT NULL,
  principal TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT pk_endereco_cliente PRIMARY KEY (id_endereco),
  CONSTRAINT fk_endereco_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE funcionario (
  id_funcionario INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  cpf CHAR(11) NOT NULL,
  cargo ENUM('atendente','confeiteiro','gerente','caixa','entregador') NOT NULL,
  telefone VARCHAR(20),
  email VARCHAR(150),
  data_admissao DATE NOT NULL,
  salario DECIMAL(10,2) NOT NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT pk_funcionario PRIMARY KEY (id_funcionario),
  CONSTRAINT uk_funcionario_cpf UNIQUE (cpf),
  CONSTRAINT chk_funcionario_salario CHECK (salario >= 0)
);

CREATE TABLE categoria (
  id_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(80) NOT NULL,
  descricao TEXT,
  CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
  CONSTRAINT uk_categoria_nome UNIQUE (nome)
);

CREATE TABLE produto (
  id_produto INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_categoria INT UNSIGNED NOT NULL,
  nome VARCHAR(120) NOT NULL,
  descricao TEXT,
  preco_unitario DECIMAL(10,2) NOT NULL,
  disponivel TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT pk_produto PRIMARY KEY (id_produto),
  CONSTRAINT uk_produto_nome UNIQUE (nome),
  CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria)
    ON UPDATE CASCADE,
  CONSTRAINT chk_produto_preco CHECK (preco_unitario > 0)
);

CREATE TABLE ingrediente (
  id_ingrediente INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  unidade_medida ENUM('kg','g','litro','ml','unidade') NOT NULL,
  CONSTRAINT pk_ingrediente PRIMARY KEY (id_ingrediente),
  CONSTRAINT uk_ingrediente_nome UNIQUE (nome)
);

CREATE TABLE estoque (
  id_estoque INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_ingrediente INT UNSIGNED NOT NULL,
  quantidade_atual DECIMAL(10,3) NOT NULL DEFAULT 0,
  quantidade_minima DECIMAL(10,3) NOT NULL DEFAULT 0,
  local_armazenamento VARCHAR(80) NOT NULL DEFAULT 'Estoque principal',
  data_atualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_estoque PRIMARY KEY (id_estoque),
  CONSTRAINT uk_estoque_ingrediente UNIQUE (id_ingrediente),
  CONSTRAINT fk_estoque_ingrediente FOREIGN KEY (id_ingrediente)
    REFERENCES ingrediente (id_ingrediente)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT chk_estoque_quantidade CHECK (quantidade_atual >= 0),
  CONSTRAINT chk_estoque_minima CHECK (quantidade_minima >= 0)
);

CREATE TABLE receita_produto (
  id_produto INT UNSIGNED NOT NULL,
  id_ingrediente INT UNSIGNED NOT NULL,
  quantidade_utilizada DECIMAL(10,3) NOT NULL,
  CONSTRAINT pk_receita_produto PRIMARY KEY (id_produto, id_ingrediente),
  CONSTRAINT fk_receita_produto FOREIGN KEY (id_produto)
    REFERENCES produto (id_produto)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_receita_ingrediente FOREIGN KEY (id_ingrediente)
    REFERENCES ingrediente (id_ingrediente)
    ON UPDATE CASCADE,
  CONSTRAINT chk_receita_quantidade CHECK (quantidade_utilizada > 0)
);

CREATE TABLE movimentacao_estoque (
  id_movimentacao INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_ingrediente INT UNSIGNED NOT NULL,
  id_funcionario INT UNSIGNED,
  tipo ENUM('entrada','saida','ajuste') NOT NULL,
  quantidade DECIMAL(10,3) NOT NULL,
  motivo VARCHAR(200) NOT NULL,
  data_movimentacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_movimentacao_estoque PRIMARY KEY (id_movimentacao),
  CONSTRAINT fk_mov_ingrediente FOREIGN KEY (id_ingrediente)
    REFERENCES ingrediente (id_ingrediente)
    ON UPDATE CASCADE,
  CONSTRAINT fk_mov_funcionario FOREIGN KEY (id_funcionario)
    REFERENCES funcionario (id_funcionario)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT chk_mov_quantidade CHECK (quantidade > 0)
);

CREATE TABLE pedido (
  id_pedido INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_cliente INT UNSIGNED,
  id_funcionario INT UNSIGNED,
  id_endereco INT UNSIGNED,
  data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('aguardando','em_producao','pronto','entregue','cancelado') NOT NULL DEFAULT 'aguardando',
  tipo_entrega ENUM('retirada','delivery') NOT NULL DEFAULT 'retirada',
  observacao TEXT,
  valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT fk_pedido_funcionario FOREIGN KEY (id_funcionario)
    REFERENCES funcionario (id_funcionario)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT fk_pedido_endereco FOREIGN KEY (id_endereco)
    REFERENCES endereco_cliente (id_endereco)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT chk_pedido_total CHECK (valor_total >= 0)
);

CREATE TABLE item_pedido (
  id_item_pedido INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pedido INT UNSIGNED NOT NULL,
  id_produto INT UNSIGNED NOT NULL,
  quantidade INT UNSIGNED NOT NULL DEFAULT 1,
  preco_unitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantidade * preco_unitario) STORED,
  CONSTRAINT pk_item_pedido PRIMARY KEY (id_item_pedido),
  CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido (id_pedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_item_produto FOREIGN KEY (id_produto)
    REFERENCES produto (id_produto)
    ON UPDATE CASCADE,
  CONSTRAINT chk_item_quantidade CHECK (quantidade > 0),
  CONSTRAINT chk_item_preco CHECK (preco_unitario > 0)
);

CREATE TABLE pagamento (
  id_pagamento INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pedido INT UNSIGNED NOT NULL,
  forma_pagamento ENUM('dinheiro','pix','cartao_debito','cartao_credito','voucher') NOT NULL,
  valor_pago DECIMAL(10,2) NOT NULL,
  data_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status_pagamento ENUM('pendente','aprovado','estornado') NOT NULL DEFAULT 'pendente',
  CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
  CONSTRAINT fk_pagamento_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido (id_pedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT chk_pagamento_valor CHECK (valor_pago > 0)
);

CREATE INDEX idx_pedido_data ON pedido (data_pedido);
CREATE INDEX idx_pedido_status ON pedido (status);
CREATE INDEX idx_produto_disponivel ON produto (disponivel);
CREATE INDEX idx_pagamento_forma ON pagamento (forma_pagamento);
CREATE INDEX idx_movimentacao_data ON movimentacao_estoque (data_movimentacao);

-- ============================================================
-- 2. DADOS FICTICIOS REALISTAS
-- ============================================================

INSERT INTO cliente (nome, cpf, telefone, email, data_nascimento) VALUES
('Ana Paula Ferreira', '12345678901', '62991110001', 'ana.ferreira@email.com', '1995-03-14'),
('Bruno Carvalho', '23456789012', '62992220002', 'bruno.carvalho@email.com', '1988-07-22'),
('Carla Mendes', '34567890123', '62993330003', 'carla.mendes@email.com', '2000-11-05'),
('Diego Souza', '45678901234', '62994440004', 'diego.souza@email.com', '1992-01-30'),
('Eduarda Lima', '56789012345', '62995550005', 'eduarda.lima@email.com', '1999-06-18'),
('Fernanda Rocha', '67890123456', '62996660006', 'fernanda.rocha@email.com', '1985-09-10'),
('Gabriel Nunes', '78901234567', '62997770007', 'gabriel.nunes@email.com', '1997-12-03'),
('Helena Martins', '89012345678', '62998880008', 'helena.martins@email.com', '1990-04-25');

INSERT INTO endereco_cliente (id_cliente, logradouro, numero, complemento, bairro, cidade, estado, cep, principal) VALUES
(1, 'Rua das Flores', '123', 'Casa', 'Setor Bueno', 'Goiânia', 'GO', '74230010', 1),
(2, 'Avenida T-63', '456', NULL, 'Jardim Goiás', 'Goiânia', 'GO', '74280040', 1),
(3, 'Rua C-149', '789', 'Apto 302', 'Jardim América', 'Goiânia', 'GO', '74255080', 1),
(4, 'Rua 1010', '10', NULL, 'Setor Pedro Ludovico', 'Goiânia', 'GO', '74835010', 1),
(5, 'Avenida Anhanguera', '999', 'Sala 2', 'Setor Oeste', 'Goiânia', 'GO', '74110010', 1),
(6, 'Rua das Palmeiras', '87', NULL, 'Setor Marista', 'Goiânia', 'GO', '74150120', 1),
(7, 'Alameda dos Ipês', '220', 'Casa 4', 'Vila Nova', 'Goiânia', 'GO', '74645030', 1),
(8, 'Rua do Lazer', '45', NULL, 'Setor Central', 'Goiânia', 'GO', '74020020', 1);

INSERT INTO funcionario (nome, cpf, cargo, telefone, email, data_admissao, salario) VALUES
('Mariana Costa', '11122233344', 'gerente', '62990000001', 'mariana@doceria.com', '2024-01-10', 4200.00),
('Lucas Almeida', '22233344455', 'atendente', '62990000002', 'lucas@doceria.com', '2024-03-18', 2100.00),
('Patrícia Gomes', '33344455566', 'confeiteiro', '62990000003', 'patricia@doceria.com', '2023-08-05', 3200.00),
('Renato Alves', '44455566677', 'caixa', '62990000004', 'renato@doceria.com', '2024-06-12', 2300.00),
('Sofia Batista', '55566677788', 'entregador', '62990000005', 'sofia@doceria.com', '2025-02-03', 2000.00);

INSERT INTO categoria (nome, descricao) VALUES
('Bolos', 'Bolos inteiros e fatias para consumo local ou encomenda'),
('Docinhos', 'Doces de festa vendidos por unidade ou cento'),
('Tortas', 'Tortas doces geladas e assadas'),
('Sobremesas', 'Sobremesas individuais e especiais'),
('Bebidas', 'Cafés, sucos e bebidas geladas');

INSERT INTO produto (id_categoria, nome, descricao, preco_unitario, disponivel) VALUES
(1, 'Bolo Red Velvet', 'Bolo com massa vermelha e recheio de cream cheese', 68.00, 1),
(1, 'Bolo de Chocolate', 'Bolo de chocolate com ganache cremosa', 58.00, 1),
(1, 'Bolo de Cenoura', 'Bolo de cenoura com cobertura de brigadeiro', 46.00, 1),
(2, 'Brigadeiro Gourmet', 'Brigadeiro com chocolate belga e granulado especial', 4.50, 1),
(2, 'Beijinho Tradicional', 'Doce de coco com açúcar cristal', 4.00, 1),
(2, 'Trufa de Maracujá', 'Trufa recheada com creme de maracujá', 5.50, 1),
(3, 'Torta de Limão', 'Torta com base de biscoito, creme de limão e merengue', 48.00, 1),
(3, 'Cheesecake de Frutas Vermelhas', 'Cheesecake com calda artesanal de frutas vermelhas', 62.00, 1),
(4, 'Pudim de Leite', 'Pudim individual de leite condensado', 12.00, 1),
(4, 'Brownie Recheado', 'Brownie com recheio de doce de leite', 14.00, 1),
(5, 'Café Espresso', 'Café espresso 100% arábica', 7.00, 1),
(5, 'Chocolate Gelado', 'Bebida gelada de chocolate com leite', 10.00, 1);

INSERT INTO ingrediente (nome, unidade_medida) VALUES
('Farinha de trigo', 'kg'),
('Açúcar refinado', 'kg'),
('Chocolate em pó', 'kg'),
('Chocolate belga', 'kg'),
('Manteiga', 'kg'),
('Ovos', 'unidade'),
('Leite integral', 'litro'),
('Leite condensado', 'litro'),
('Creme de leite', 'litro'),
('Cream cheese', 'kg'),
('Coco ralado', 'kg'),
('Maracujá', 'kg'),
('Limão', 'unidade'),
('Biscoito maizena', 'kg'),
('Frutas vermelhas', 'kg'),
('Café moído', 'kg');

INSERT INTO estoque (id_ingrediente, quantidade_atual, quantidade_minima, local_armazenamento) VALUES
(1, 25.000, 5.000, 'Estoque seco'),
(2, 18.000, 4.000, 'Estoque seco'),
(3, 7.500, 2.000, 'Estoque seco'),
(4, 2.800, 1.000, 'Estoque climatizado'),
(5, 6.000, 1.500, 'Geladeira'),
(6, 160.000, 36.000, 'Geladeira'),
(7, 14.000, 3.000, 'Geladeira'),
(8, 9.000, 2.000, 'Estoque seco'),
(9, 5.000, 1.000, 'Geladeira'),
(10, 3.500, 1.000, 'Geladeira'),
(11, 1.200, 1.500, 'Estoque seco'),
(12, 1.000, 1.200, 'Freezer'),
(13, 22.000, 10.000, 'Geladeira'),
(14, 4.000, 1.000, 'Estoque seco'),
(15, 0.800, 1.000, 'Freezer'),
(16, 2.500, 0.500, 'Estoque seco');

INSERT INTO receita_produto (id_produto, id_ingrediente, quantidade_utilizada) VALUES
(1,1,0.500),(1,2,0.300),(1,6,4.000),(1,10,0.300),(1,5,0.150),
(2,1,0.500),(2,2,0.300),(2,3,0.200),(2,5,0.150),(2,6,3.000),
(3,1,0.450),(3,2,0.250),(3,6,3.000),(3,5,0.120),
(4,8,0.080),(4,4,0.030),(4,5,0.010),
(5,8,0.070),(5,11,0.030),
(6,4,0.040),(6,12,0.050),(6,9,0.030),
(7,14,0.250),(7,13,4.000),(7,8,0.120),(7,9,0.100),
(8,14,0.250),(8,10,0.300),(8,15,0.200),(8,5,0.100),
(9,8,0.120),(9,6,1.000),(9,7,0.100),
(10,1,0.080),(10,4,0.050),(10,5,0.030),
(11,16,0.020),
(12,3,0.050),(12,7,0.250);

INSERT INTO movimentacao_estoque (id_ingrediente, id_funcionario, tipo, quantidade, motivo) VALUES
(1, 1, 'entrada', 25.000, 'Compra inicial de farinha'),
(2, 1, 'entrada', 18.000, 'Compra inicial de açúcar'),
(4, 3, 'entrada', 2.800, 'Compra de chocolate belga'),
(11, 3, 'entrada', 1.200, 'Compra de coco ralado'),
(15, 3, 'entrada', 0.800, 'Compra de frutas vermelhas');

INSERT INTO pedido (id_cliente, id_funcionario, id_endereco, data_pedido, status, tipo_entrega, observacao, valor_total) VALUES
(1, 2, 1, '2026-03-05 14:20:00', 'entregue', 'delivery', 'Enviar talheres descartáveis', 81.50),
(2, 2, NULL, '2026-03-11 10:15:00', 'entregue', 'retirada', NULL, 22.50),
(3, 4, 3, '2026-04-02 16:40:00', 'entregue', 'delivery', 'Entregar após 18h', 116.00),
(4, 2, NULL, '2026-04-18 09:30:00', 'cancelado', 'retirada', 'Cliente desistiu da encomenda', 58.00),
(5, 4, NULL, '2026-05-03 12:10:00', 'entregue', 'retirada', NULL, 36.00),
(6, 2, 6, '2026-05-07 15:25:00', 'pronto', 'delivery', 'Presente de aniversário', 124.00),
(7, 4, 7, '2026-05-15 11:00:00', 'em_producao', 'delivery', NULL, 77.00),
(8, 2, NULL, '2026-05-21 17:45:00', 'aguardando', 'retirada', 'Separar para viagem', 24.00),
(NULL, 4, NULL, '2026-05-22 13:05:00', 'entregue', 'retirada', 'Venda de balcão', 31.00);

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 68.00),(1, 4, 3, 4.50),
(2, 4, 5, 4.50),
(3, 8, 1, 62.00),(3, 6, 4, 5.50),(3, 11, 2, 7.00),(3, 12, 2, 10.00),
(4, 2, 1, 58.00),
(5, 9, 3, 12.00),
(6, 8, 2, 62.00),
(7, 7, 1, 48.00),(7, 6, 4, 5.50),(7, 11, 1, 7.00),
(8, 10, 1, 14.00),(8, 12, 1, 10.00),
(9, 4, 2, 4.50),(9, 11, 1, 7.00),(9, 12, 1, 10.00),(9, 5, 1, 4.00);

INSERT INTO pagamento (id_pedido, forma_pagamento, valor_pago, data_pagamento, status_pagamento) VALUES
(1, 'pix', 81.50, '2026-03-05 14:30:00', 'aprovado'),
(2, 'dinheiro', 22.50, '2026-03-11 10:20:00', 'aprovado'),
(3, 'cartao_credito', 116.00, '2026-04-02 16:50:00', 'aprovado'),
(4, 'pix', 58.00, '2026-04-18 09:40:00', 'estornado'),
(5, 'cartao_debito', 36.00, '2026-05-03 12:20:00', 'aprovado'),
(6, 'pix', 124.00, '2026-05-07 15:30:00', 'pendente'),
(7, 'cartao_credito', 77.00, '2026-05-15 11:10:00', 'pendente'),
(8, 'dinheiro', 24.00, '2026-05-21 17:50:00', 'pendente'),
(9, 'pix', 31.00, '2026-05-22 13:10:00', 'aprovado');

-- ============================================================
-- 3. CONSULTAS SQL BASICAS
-- ============================================================

-- SELECT: listar produtos disponiveis.
SELECT id_produto, nome, preco_unitario
FROM produto
WHERE disponivel = 1
ORDER BY nome;

-- WHERE: localizar pedidos de delivery ainda nao finalizados.
SELECT id_pedido, data_pedido, status, valor_total
FROM pedido
WHERE tipo_entrega = 'delivery'
  AND status NOT IN ('entregue', 'cancelado')
ORDER BY data_pedido;

-- JOIN: consultar pedidos com nome do cliente e funcionario responsavel.
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

-- GROUP BY: quantidade de pedidos por status.
SELECT status, COUNT(*) AS quantidade_pedidos
FROM pedido
GROUP BY status
ORDER BY quantidade_pedidos DESC;

-- UPDATE: marcar um produto temporariamente como indisponivel.
UPDATE produto
SET disponivel = 0
WHERE nome = 'Chocolate Gelado';

-- DELETE: remover movimentacoes de estoque do tipo ajuste sem impacto historico.
-- Exemplo didatico: no banco populado nao ha registros desse tipo.
DELETE FROM movimentacao_estoque
WHERE tipo = 'ajuste'
  AND motivo LIKE '%teste%';

-- ============================================================
-- 4. RELATORIOS GERENCIAIS
-- ============================================================

-- Produtos mais vendidos.
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

-- Clientes que mais compraram.
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

-- Faturamento mensal.
SELECT
  DATE_FORMAT(p.data_pedido, '%Y-%m') AS mes,
  COUNT(p.id_pedido) AS pedidos_finalizados,
  SUM(p.valor_total) AS faturamento
FROM pedido p
WHERE p.status = 'entregue'
GROUP BY DATE_FORMAT(p.data_pedido, '%Y-%m')
ORDER BY mes;

-- Produtos com estoque baixo, considerando ingredientes abaixo do minimo.
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

-- Pedidos por periodo.
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

-- Formas de pagamento mais utilizadas.
SELECT
  forma_pagamento,
  COUNT(*) AS quantidade_usos,
  SUM(valor_pago) AS valor_total
FROM pagamento
WHERE status_pagamento = 'aprovado'
GROUP BY forma_pagamento
ORDER BY quantidade_usos DESC, valor_total DESC;

-- Views para facilitar a demonstracao pratica.
CREATE OR REPLACE VIEW vw_pedidos_resumidos AS
SELECT
  p.id_pedido,
  COALESCE(c.nome, 'Cliente de balcão') AS cliente,
  f.nome AS funcionario,
  p.status,
  p.tipo_entrega,
  p.valor_total,
  p.data_pedido
FROM pedido p
LEFT JOIN cliente c ON c.id_cliente = p.id_cliente
LEFT JOIN funcionario f ON f.id_funcionario = p.id_funcionario;

CREATE OR REPLACE VIEW vw_estoque_baixo AS
SELECT
  i.nome AS ingrediente,
  i.unidade_medida,
  e.quantidade_atual,
  e.quantidade_minima,
  (e.quantidade_minima - e.quantidade_atual) AS deficit
FROM estoque e
JOIN ingrediente i ON i.id_ingrediente = e.id_ingrediente
WHERE e.quantidade_atual < e.quantidade_minima;

-- Consultas finais de verificacao.
SELECT * FROM vw_pedidos_resumidos ORDER BY id_pedido;
SELECT * FROM vw_estoque_baixo ORDER BY deficit DESC;
