-- ============================================================
--  BANCO DE DADOS: Doceria
--  SGBD: MySQL 8.0+
--  DESCRIÇÃO: Schema relacional para gestão de doceria,
--             cobrindo clientes, cardápio, estoque,
--             vendas e pedidos.
-- ============================================================

CREATE DATABASE IF NOT EXISTS doceria
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE doceria;

-- ============================================================
-- 1. CLIENTES
-- ============================================================

CREATE TABLE cliente (
  id_cliente     INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  nome           VARCHAR(100)     NOT NULL,
  cpf            CHAR(11)         UNIQUE,               -- apenas dígitos
  telefone       VARCHAR(20),
  email          VARCHAR(150)     UNIQUE,
  data_nascimento DATE,
  data_cadastro  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ativo          TINYINT(1)       NOT NULL DEFAULT 1,   -- soft delete
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
);

-- ============================================================
-- 2. ENDEREÇO DO CLIENTE (1:N — cliente pode ter mais de um)
-- ============================================================

CREATE TABLE endereco_cliente (
  id_endereco    INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  id_cliente     INT UNSIGNED     NOT NULL,
  logradouro     VARCHAR(150)     NOT NULL,
  numero         VARCHAR(10)      NOT NULL,
  complemento    VARCHAR(60),
  bairro         VARCHAR(80)      NOT NULL,
  cidade         VARCHAR(80)      NOT NULL,
  estado         CHAR(2)          NOT NULL,
  cep            CHAR(8)          NOT NULL,             -- apenas dígitos
  principal      TINYINT(1)       NOT NULL DEFAULT 0,
  CONSTRAINT pk_endereco_cliente  PRIMARY KEY (id_endereco),
  CONSTRAINT fk_end_cliente       FOREIGN KEY (id_cliente)
                                  REFERENCES cliente (id_cliente)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE
);

-- ============================================================
-- 3. CATEGORIA DO CARDÁPIO  (ex.: bolos, docinhos, tortas…)
-- ============================================================

CREATE TABLE categoria (
  id_categoria   INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  nome           VARCHAR(80)      NOT NULL,
  descricao      TEXT,
  CONSTRAINT pk_categoria PRIMARY KEY (id_categoria)
);

-- ============================================================
-- 4. PRODUTO (cardápio)
-- ============================================================

CREATE TABLE produto (
  id_produto     INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  id_categoria   INT UNSIGNED     NOT NULL,
  nome           VARCHAR(120)     NOT NULL,
  descricao      TEXT,
  preco_unitario DECIMAL(10,2)    NOT NULL,
  disponivel     TINYINT(1)       NOT NULL DEFAULT 1,
  CONSTRAINT pk_produto           PRIMARY KEY (id_produto),
  CONSTRAINT fk_prod_categoria    FOREIGN KEY (id_categoria)
                                  REFERENCES categoria (id_categoria)
                                  ON UPDATE CASCADE
);

-- ============================================================
-- 5. INGREDIENTE  (unidade de controle de estoque)
-- ============================================================

CREATE TABLE ingrediente (
  id_ingrediente  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  nome            VARCHAR(100)    NOT NULL,
  unidade_medida  VARCHAR(20)     NOT NULL,  -- ex.: kg, litro, unidade
  qtd_estoque     DECIMAL(10,3)   NOT NULL DEFAULT 0,
  qtd_minima      DECIMAL(10,3)   NOT NULL DEFAULT 0,  -- alerta de reposição
  CONSTRAINT pk_ingrediente PRIMARY KEY (id_ingrediente)
);

-- ============================================================
-- 6. RECEITA — ingredientes necessários para cada produto (N:M)
-- ============================================================

CREATE TABLE receita (
  id_produto      INT UNSIGNED    NOT NULL,
  id_ingrediente  INT UNSIGNED    NOT NULL,
  quantidade      DECIMAL(10,3)   NOT NULL,             -- por unidade produzida
  CONSTRAINT pk_receita           PRIMARY KEY (id_produto, id_ingrediente),
  CONSTRAINT fk_rec_produto       FOREIGN KEY (id_produto)
                                  REFERENCES produto (id_produto)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE,
  CONSTRAINT fk_rec_ingrediente   FOREIGN KEY (id_ingrediente)
                                  REFERENCES ingrediente (id_ingrediente)
                                  ON UPDATE CASCADE
);

-- ============================================================
-- 7. MOVIMENTAÇÃO DE ESTOQUE  (entradas e saídas manuais)
-- ============================================================

CREATE TABLE movimentacao_estoque (
  id_movimentacao INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  id_ingrediente  INT UNSIGNED    NOT NULL,
  tipo            ENUM('entrada','saida') NOT NULL,
  quantidade      DECIMAL(10,3)   NOT NULL,
  motivo          VARCHAR(200),
  data_mov        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_movimentacao      PRIMARY KEY (id_movimentacao),
  CONSTRAINT fk_mov_ingrediente   FOREIGN KEY (id_ingrediente)
                                  REFERENCES ingrediente (id_ingrediente)
                                  ON UPDATE CASCADE
);

-- ============================================================
-- 8. PEDIDO
-- ============================================================

CREATE TABLE pedido (
  id_pedido      INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  id_cliente     INT UNSIGNED,                          -- NULL = balcão (anônimo)
  data_pedido    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status         ENUM(
                   'aguardando',
                   'em_producao',
                   'pronto',
                   'entregue',
                   'cancelado'
                 )                NOT NULL DEFAULT 'aguardando',
  tipo_entrega   ENUM('retirada','delivery') NOT NULL DEFAULT 'retirada',
  id_endereco    INT UNSIGNED,                          -- NULL se retirada
  observacao     TEXT,
  valor_total    DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
  CONSTRAINT pk_pedido            PRIMARY KEY (id_pedido),
  CONSTRAINT fk_ped_cliente       FOREIGN KEY (id_cliente)
                                  REFERENCES cliente (id_cliente)
                                  ON DELETE SET NULL
                                  ON UPDATE CASCADE,
  CONSTRAINT fk_ped_endereco      FOREIGN KEY (id_endereco)
                                  REFERENCES endereco_cliente (id_endereco)
                                  ON DELETE SET NULL
                                  ON UPDATE CASCADE
);

-- ============================================================
-- 9. ITEM DO PEDIDO  (N:M entre pedido e produto)
-- ============================================================

CREATE TABLE item_pedido (
  id_item        INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  id_pedido      INT UNSIGNED     NOT NULL,
  id_produto     INT UNSIGNED     NOT NULL,
  quantidade     INT UNSIGNED     NOT NULL DEFAULT 1,
  preco_unitario DECIMAL(10,2)    NOT NULL,             -- snapshot do preço
  subtotal       DECIMAL(10,2)    GENERATED ALWAYS AS (quantidade * preco_unitario) STORED,
  CONSTRAINT pk_item_pedido       PRIMARY KEY (id_item),
  CONSTRAINT fk_item_pedido       FOREIGN KEY (id_pedido)
                                  REFERENCES pedido (id_pedido)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE,
  CONSTRAINT fk_item_produto      FOREIGN KEY (id_produto)
                                  REFERENCES produto (id_produto)
                                  ON UPDATE CASCADE
);

-- ============================================================
-- 10. PAGAMENTO
-- ============================================================

CREATE TABLE pagamento (
  id_pagamento   INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  id_pedido      INT UNSIGNED     NOT NULL,
  forma          ENUM(
                   'dinheiro',
                   'cartao_debito',
                   'cartao_credito',
                   'pix',
                   'outro'
                 )                NOT NULL,
  valor          DECIMAL(10,2)    NOT NULL,
  data_pagamento DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status         ENUM('pendente','aprovado','estornado') NOT NULL DEFAULT 'pendente',
  CONSTRAINT pk_pagamento         PRIMARY KEY (id_pagamento),
  CONSTRAINT fk_pag_pedido        FOREIGN KEY (id_pedido)
                                  REFERENCES pedido (id_pedido)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE
);

-- ============================================================
-- ÍNDICES EXTRAS (performance em consultas frequentes)
-- ============================================================

CREATE INDEX idx_pedido_status       ON pedido (status);
CREATE INDEX idx_pedido_data         ON pedido (data_pedido);
CREATE INDEX idx_produto_disponivel  ON produto (disponivel);
CREATE INDEX idx_ingrediente_estoque ON ingrediente (qtd_estoque);