# Projeto N2 - Banco de Dados Doceria

Este diretório reúne a entrega organizada da N2 da disciplina de Banco de Dados da UNIALFA. O projeto foi estruturado para apresentar uma solução relacional em MySQL para uma doceria, contemplando clientes, funcionários, produtos, estoque, pedidos, itens de pedido, pagamentos e relatórios.

## Arquivos principais

- `sql/00_script_completo_doceria_n2.sql`: script único com criação do banco, tabelas, dados, consultas, relatórios e views.
- `sql/01_consultas_sql.sql`: consultas separadas para demonstração de `SELECT`, `WHERE`, `JOIN`, `GROUP BY`, `ORDER BY`, `UPDATE` e `DELETE`.
- `sql/02_relatorios_sql.sql`: relatórios gerenciais separados para apresentação.
- `docs/modelagem.md`: explicação da modelagem, tabelas e relacionamentos.
- `docs/uso_ia.md`: texto acadêmico sobre o uso de Inteligência Artificial no desenvolvimento.
- `docs/slides.md`: roteiro pronto para montar a apresentação.

## Como executar

No MySQL Workbench ou no terminal MySQL, execute:

```sql
SOURCE C:/Users/USER/Downloads/Trabalho-Banco-de-dados-main/N2/sql/00_script_completo_doceria_n2.sql;
```

Se for usar o MySQL local preparado neste projeto, primeiro inicie o servidor:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\USER\Downloads\Trabalho-Banco-de-dados-main\start_mysql_doceria.ps1
```

Dados da conexão local:

- Host: `127.0.0.1`
- Porta: `3309`
- Usuário: `root`
- Senha: vazia
- Banco criado: `doceria_n2`
