# FinancialSystem

## O que é isto?

Este é o meu projeto para o desafio https://github.com/stone-payments/tech-challenge.

É um sistema financeiro com as seguintes características:

* Livre de pontos flutuantes.
* Interrompe a execução em caso de erro (Filosofia [Let It Crash](https://ferd.ca/the-zen-of-erlang.html)).
* Respeita a **ISO 4217**.
* Realiza câmbio.
* Realiza split de operações.

## Dependências

* Elixir 1.6 ou superior
* Quinn 1.1 ou superior: utilizado para recuperar informação sobre as moedas
* Coverex: utilizado para teste de cobertura

Mais informações no arquivo mix.exs.

## Como instalar?

**TODO**

## Como usar?

Primeiro se familiarize com as estruturas e funções:

### Estruturas

* `Account`: A conta. Possui id e uma lista de Money de diversas moedas
* `Money`: Representa uma quantia de dinheiro. Evita pontos flutuantes armazenando parte inteira e parte fracionária em inteiros separados.
* `Currency`: Representa uma moeda. Deve ser inicializada pela função currency_by_code/1.
* `Ratio`: Razão entre moedas, utilizada pra câmbio. É um numero decimal, mas possui abordagem diferente de `Money`, com `value` de mantissa e `neg_exp_of_ten` como expoente negativo de dez.

### Funções

* `account_exchange/5`: Converte uma quantia dentro de uma conta em outra e guarda essa quantia nessa conta.
* `compare/2`: Compara se uma quantia é maior que a outra. Retorna átomos :smaller, :equal, :greater.
* `currency_by_code`: Constrói uma moeda a partir de seu código .
* `exchange/3`: Converte uma quantia de uma moeda para outra de acordo com a razão passada de parâmetro.
* `sub/2`: Subtrai dinheiro.
* `sum/2`: Soma dinheiro.
* `transfer_split/3`: Realiza uma transferência com splits.
* `transfer/3`: Transfere dinheiro de uma conta para outra.

`Currency` deve ser criado com a função `currency_by_code/3` caso não seja o Real.
Todas as funções poder interromper a execução do programa por meio de `exit`, nenhuma delas retorna `{:ok, result}`.


## Licença

Este projeto está na licensa MIT.

## Créditos

Projeto individual de Vítor Trindade.
