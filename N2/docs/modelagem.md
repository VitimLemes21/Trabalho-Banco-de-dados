# Modelagem do Banco de Dados da Doceria

## Visão Geral

O banco `doceria_n2` foi modelado para atender às principais necessidades operacionais de uma doceria: cadastro de clientes, controle de produtos, gestão de ingredientes em estoque, registro de pedidos, controle de pagamentos e geração de relatórios gerenciais.

A modelagem utiliza normalização para reduzir redundâncias e preservar a integridade dos dados. As entidades foram separadas conforme sua responsabilidade: clientes ficam separados de endereços, produtos ficam separados de categorias, pedidos ficam separados de itens, e estoque fica separado de ingredientes.

## Principais Tabelas

### cliente

Armazena os dados cadastrais dos clientes. Possui chave primária `id_cliente`, CPF único e e-mail único. O campo `ativo` permite desativar um cliente sem excluir seu histórico.

### endereco_cliente

Registra um ou mais endereços para cada cliente. A relação com `cliente` é de 1:N, pois um cliente pode ter vários endereços. A exclusão de um cliente remove seus endereços por meio de `ON DELETE CASCADE`.

### funcionario

Armazena os colaboradores da doceria, como atendentes, confeiteiros, gerente, caixa e entregador. Essa tabela permite identificar quem registrou ou acompanhou cada pedido.

### categoria

Organiza os produtos em grupos como bolos, docinhos, tortas, sobremesas e bebidas. Essa separação evita repetição do nome da categoria em todos os produtos.

### produto

Contém o cardápio da doceria. Cada produto pertence a uma categoria e possui preço, descrição e disponibilidade. O relacionamento com `categoria` é N:1.

### ingrediente

Registra os insumos utilizados na produção dos doces, como farinha, açúcar, chocolate, ovos e leite condensado.

### estoque

Controla a quantidade disponível de cada ingrediente. Foi criada separadamente de `ingrediente` para separar o cadastro do insumo do controle de quantidade, local de armazenamento e nível mínimo.

### receita_produto

Representa o relacionamento N:M entre produtos e ingredientes. Um produto pode usar vários ingredientes e um ingrediente pode compor vários produtos.

### movimentacao_estoque

Registra entradas, saídas e ajustes no estoque. Essa tabela cria histórico operacional, importante para auditoria e análise de consumo.

### pedido

Armazena os pedidos realizados, relacionando cliente, funcionário, endereço de entrega, status, tipo de entrega e valor total.

### item_pedido

Representa os produtos vendidos em cada pedido. Essa tabela resolve o relacionamento N:M entre `pedido` e `produto`. O subtotal é calculado automaticamente com coluna gerada.

### pagamento

Registra a forma de pagamento, valor pago, data e status do pagamento. Um pedido pode ter pagamento aprovado, pendente ou estornado.

## Relacionamentos

- `cliente` 1:N `endereco_cliente`
- `cliente` 1:N `pedido`
- `funcionario` 1:N `pedido`
- `categoria` 1:N `produto`
- `produto` N:M `ingrediente` por meio de `receita_produto`
- `ingrediente` 1:1 `estoque`
- `ingrediente` 1:N `movimentacao_estoque`
- `pedido` 1:N `item_pedido`
- `produto` 1:N `item_pedido`
- `pedido` 1:N `pagamento`

## Boas Práticas Aplicadas

- Uso de chaves primárias numéricas com `AUTO_INCREMENT`.
- Uso de `FOREIGN KEY` para garantir integridade referencial.
- Separação de entidades para evitar redundância.
- Uso de `CHECK` para impedir valores inválidos, como preço ou quantidade negativa.
- Uso de `UNIQUE` para CPF, e-mail e nomes que não devem se repetir.
- Uso de índices em campos consultados com frequência, como status, datas e formas de pagamento.
- Uso de `ENUM` em campos de domínio controlado, como status do pedido, cargo e forma de pagamento.

