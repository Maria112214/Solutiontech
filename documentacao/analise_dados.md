# Análise de dados do projeto

## Estatística

### Colunas analisadas

- distancia_solicitacao
- tempo_ate_atendimento

### Perguntas

- Qual é a distância média das solicitações?
- Qual é o tempo médio até o atendimento?
- Qual é a variação dos valores?

### Resultados importantes

A distância das solicitações apresentou:

- Média: 0,926385
- Mediana: 0,740000
- Mínimo: 0,100000
- Máximo: 8,000000

O tempo até o atendimento apresentou:

- Média: 170,691161
- Mediana: 61,000000
- Mínimo: 6,000000
- Máximo: 1563,000000

### Interpretação

Os resultados mostram que existe variação nos valores de distância e de tempo até o atendimento. A diferença entre a média e a mediana do tempo de atendimento indica que alguns registros possuem tempos de atendimento muito maiores que os valores mais comuns.

## Agregação

### Pergunta analisada

Qual é a quantidade de solicitações para cada tipo de solicitação?

### Resultados

- Alimentação: 3738 solicitações
- Abrigo: 2227 solicitações
- Roupas: 1646 solicitações
- Assistência social: 1486 solicitações
- Higiene: 903 solicitações

### Interpretação

Os dados mostram que alimentação foi o tipo de solicitação com maior quantidade de registros. Em seguida aparecem abrigo, roupas, assistência social e higiene.

Essa agregação permite identificar quais tipos de necessidade aparecem com maior frequência no histórico de solicitações.
## Classificação

### Pergunta analisada

Como as solicitações podem ser classificadas de acordo com a distância?

### Regra de classificação

As distâncias foram classificadas em três categorias:

- Curta: distância menor que 0,5
- Média: distância entre 0,5 e 1,0
- Longa: distância maior ou igual a 1,0

### Resultados

- Média: 5032 solicitações
- Longa: 2505 solicitações
- Curta: 2463 solicitações

### Interpretação

A classificação mostra que a maior parte das solicitações está na categoria média, com 5032 registros. Em seguida aparecem as solicitações de longa distância, com 2505 registros, e as de curta distância, com 2463 registros.

Essa classificação permite analisar a distribuição das solicitações de acordo com a distância e pode auxiliar na identificação de regiões que exigem maior deslocamento para o atendimento.