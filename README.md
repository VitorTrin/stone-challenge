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

Mais informações no arquivo mix.exs.

## Como instalar?

**TODO**

## Como usar?

Para utilizar as funções primeiro conheça as estruturas:

* **Account**: A conta. Possui id e uma lista de Money de diversas moedas
* **Money**: Representa uma quantia de dinheiro. Evita pontos flutuantes armazenando parte inteira e parte fracionária em inteiros separados.
* **Currency**: Representa uma moeda. Deve ser inicializada pela função currency_by_code/1.
* **Ratio**: Razão entre moedas, utilizada pra câmbio. É um numero decimal, mas possui abordagem diferente de **Money**, com **value** de mantissa e **neg_exp_of_ten** como expoente negativo de dez.  

##Licença

Este projeto está na licensa MIT.

##Créditos

Projeto individual de Vítor Trindade.
