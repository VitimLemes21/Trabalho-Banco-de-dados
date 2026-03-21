CREATE TABLE IF NOT EXISTS `cliente` (
	`id_cliente` INTEGER NOT NULL AUTO_INCREMENT,
	`nome` VARCHAR(100) NOT NULL,
	`cpf` CHAR(11) UNIQUE,
	`telefone` VARCHAR(20),
	`email` VARCHAR(150) UNIQUE,
	`data_nascimento` DATE,
	`data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`ativo` TINYINT NOT NULL DEFAULT 1,
	PRIMARY KEY(`id_cliente`)
);


CREATE TABLE IF NOT EXISTS `endereco_cliente` (
	`id_endereco` INTEGER NOT NULL AUTO_INCREMENT,
	`id_cliente` INTEGER NOT NULL,
	`logradouro` VARCHAR(150) NOT NULL,
	`numero` VARCHAR(10) NOT NULL,
	`complemento` VARCHAR(60),
	`bairro` VARCHAR(80) NOT NULL,
	`cidade` VARCHAR(80) NOT NULL,
	`estado` CHAR(2) NOT NULL,
	`cep` CHAR(8) NOT NULL,
	`principal` TINYINT NOT NULL DEFAULT 0,
	PRIMARY KEY(`id_endereco`)
);


CREATE TABLE IF NOT EXISTS `categoria` (
	`id_categoria` INTEGER NOT NULL AUTO_INCREMENT,
	`nome` VARCHAR(80) NOT NULL,
	`descricao` TEXT,
	PRIMARY KEY(`id_categoria`)
);


CREATE TABLE IF NOT EXISTS `produto` (
	`id_produto` INTEGER NOT NULL AUTO_INCREMENT,
	`id_categoria` INTEGER NOT NULL,
	`nome` VARCHAR(120) NOT NULL,
	`descricao` TEXT,
	`preco_unitario` DECIMAL(10,2) NOT NULL,
	`disponivel` TINYINT NOT NULL DEFAULT 1,
	PRIMARY KEY(`id_produto`)
);


CREATE INDEX `idx_produto_disponivel`
ON `produto` (`disponivel`);
CREATE TABLE IF NOT EXISTS `ingrediente` (
	`id_ingrediente` INTEGER NOT NULL AUTO_INCREMENT,
	`nome` VARCHAR(100) NOT NULL,
	`unidade_medida` VARCHAR(20) NOT NULL,
	`qtd_estoque` DECIMAL(10,3) NOT NULL DEFAULT 0,
	`qtd_minima` DECIMAL(10,3) NOT NULL DEFAULT 0,
	PRIMARY KEY(`id_ingrediente`)
);


CREATE INDEX `idx_ingrediente_estoque`
ON `ingrediente` (`qtd_estoque`);
CREATE TABLE IF NOT EXISTS `receita` (
	`id_produto` INTEGER NOT NULL,
	`id_ingrediente` INTEGER NOT NULL,
	`quantidade` DECIMAL(10,3) NOT NULL,
	PRIMARY KEY(`id_produto`, `id_ingrediente`)
);


CREATE TABLE IF NOT EXISTS `movimentacao_estoque` (
	`id_movimentacao` INTEGER NOT NULL AUTO_INCREMENT,
	`id_ingrediente` INTEGER NOT NULL,
	`tipo` ENUM('entrada', 'saida') NOT NULL,
	`quantidade` DECIMAL(10,3) NOT NULL,
	`motivo` VARCHAR(200),
	`data_mov` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY(`id_movimentacao`)
);


CREATE TABLE IF NOT EXISTS `pedido` (
	`id_pedido` INTEGER NOT NULL AUTO_INCREMENT,
	`id_cliente` INTEGER,
	`data_pedido` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`status` ENUM('aguardando', 'em_producao', 'pronto', 'entregue', 'cancelado') NOT NULL DEFAULT 'aguardando',
	`tipo_entrega` ENUM('retirada', 'delivery') NOT NULL DEFAULT 'retirada',
	`id_endereco` INTEGER,
	`observacao` TEXT,
	`valor_total` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
	PRIMARY KEY(`id_pedido`)
);


CREATE INDEX `idx_pedido_status`
ON `pedido` (`status`);
CREATE INDEX `idx_pedido_data`
ON `pedido` (`data_pedido`);
CREATE TABLE IF NOT EXISTS `item_pedido` (
	`id_item` INTEGER NOT NULL AUTO_INCREMENT,
	`id_pedido` INTEGER NOT NULL,
	`id_produto` INTEGER NOT NULL,
	`quantidade` INTEGER NOT NULL DEFAULT 1,
	`preco_unitario` DECIMAL(10,2) NOT NULL,
	`subtotal` DECIMAL(10,2),
	PRIMARY KEY(`id_item`)
);


CREATE TABLE IF NOT EXISTS `pagamento` (
	`id_pagamento` INTEGER NOT NULL AUTO_INCREMENT,
	`id_pedido` INTEGER NOT NULL,
	`forma` ENUM('dinheiro', 'cartao_debito', 'cartao_credito', 'pix', 'outro') NOT NULL,
	`valor` DECIMAL(10,2) NOT NULL,
	`data_pagamento` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`status` ENUM('pendente', 'aprovado', 'estornado') NOT NULL DEFAULT 'pendente',
	PRIMARY KEY(`id_pagamento`)
);


ALTER TABLE `endereco_cliente`
ADD FOREIGN KEY(`id_cliente`) REFERENCES `cliente`(`id_cliente`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `produto`
ADD FOREIGN KEY(`id_categoria`) REFERENCES `categoria`(`id_categoria`)
ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE `receita`
ADD FOREIGN KEY(`id_produto`) REFERENCES `produto`(`id_produto`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `receita`
ADD FOREIGN KEY(`id_ingrediente`) REFERENCES `ingrediente`(`id_ingrediente`)
ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE `movimentacao_estoque`
ADD FOREIGN KEY(`id_ingrediente`) REFERENCES `ingrediente`(`id_ingrediente`)
ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE `pedido`
ADD FOREIGN KEY(`id_cliente`) REFERENCES `cliente`(`id_cliente`)
ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE `pedido`
ADD FOREIGN KEY(`id_endereco`) REFERENCES `endereco_cliente`(`id_endereco`)
ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE `item_pedido`
ADD FOREIGN KEY(`id_pedido`) REFERENCES `pedido`(`id_pedido`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `item_pedido`
ADD FOREIGN KEY(`id_produto`) REFERENCES `produto`(`id_produto`)
ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE `pagamento`
ADD FOREIGN KEY(`id_pedido`) REFERENCES `pedido`(`id_pedido`)
ON UPDATE CASCADE ON DELETE CASCADE;