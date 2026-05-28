# Estrutura da Apresentação

## Slide 1 - Título

Projeto N2 - Banco de Dados Doceria  
Disciplina: Banco de Dados  
Instituição: UNIALFA

## Slide 2 - Problema Identificado

Uma doceria precisa organizar clientes, produtos, pedidos, estoque e pagamentos. Sem um banco bem estruturado, há risco de perda de informações, dificuldade para controlar estoque e falta de relatórios para tomada de decisão.

## Slide 3 - Solução Proposta

Foi desenvolvido um banco de dados relacional em MySQL para centralizar as informações da doceria e permitir cadastro, controle operacional e geração de relatórios gerenciais.

## Slide 4 - Objetivos do Banco

- Cadastrar clientes e endereços.
- Cadastrar funcionários e produtos.
- Controlar ingredientes e estoque.
- Registrar pedidos e itens vendidos.
- Controlar pagamentos.
- Gerar relatórios úteis para a gestão.

## Slide 5 - Modelagem

O banco foi normalizado e dividido em tabelas específicas: `cliente`, `endereco_cliente`, `funcionario`, `categoria`, `produto`, `ingrediente`, `estoque`, `receita_produto`, `movimentacao_estoque`, `pedido`, `item_pedido` e `pagamento`.

## Slide 6 - Relacionamentos

- Cliente possui vários endereços.
- Cliente realiza vários pedidos.
- Pedido possui vários itens.
- Produto pertence a uma categoria.
- Produto utiliza vários ingredientes.
- Ingrediente possui controle de estoque.
- Pedido possui pagamentos.

## Slide 7 - Demonstração Prática

Executar o script `00_script_completo_doceria_n2.sql` no MySQL. Demonstrar a criação do banco `doceria_n2`, a inserção dos dados e a execução de consultas com `SELECT`, `JOIN`, `GROUP BY`, `UPDATE` e `DELETE`.

## Slide 8 - Relatórios Criados

- Produtos mais vendidos.
- Clientes que mais compraram.
- Faturamento mensal.
- Produtos com estoque baixo.
- Pedidos por período.
- Formas de pagamento mais utilizadas.

## Slide 9 - Uso de Inteligência Artificial

A IA foi utilizada como apoio na revisão da modelagem, criação de scripts SQL, validação das consultas e elaboração da documentação. A validação humana foi mantida para garantir coerência com o tema e com os requisitos acadêmicos.

## Slide 10 - Conclusão

O projeto resultou em um banco de dados funcional, organizado e pronto para demonstração. A solução permite controlar as principais operações de uma doceria e gerar relatórios que apoiam a gestão do negócio.

