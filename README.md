# AgendaFuturista

![Logo](https://github.com/Cati94/Agenda_Cobol/blob/main/ChatGPT%20Image%20Mar%204%2C%202026%2C%2004_17_14%20PM.png)



Sistema de gestão de compromissos desenvolvido em COBOL (GNUCobol), com
persistência em ficheiro sequencial e arquitetura procedural
estruturada.

------------------------------------------------------------------------

## 1. Visão Geral

**AgendaFuturista** é uma aplicação de consola que implementa um sistema
simples de registo e consulta de compromissos utilizando ficheiros
`LINE SEQUENTIAL`.

Objetivos técnicos:

-   Manipulação de ficheiros em COBOL
-   Separação clara das DIVISIONS
-   Organização modular por parágrafos
-   Persistência de dados
-   Estrutura de controlo baseada em menu

------------------------------------------------------------------------

## 2. Arquitetura do Programa

Estrutura clássica COBOL:

    IDENTIFICATION DIVISION
    ENVIRONMENT DIVISION
    DATA DIVISION
    PROCEDURE DIVISION

### 2.1 ENVIRONMENT DIVISION

Configuração do ficheiro:

    SELECT AgendaFile ASSIGN TO "agenda.dat"
        ORGANIZATION IS LINE SEQUENTIAL.

-   Organização: sequencial
-   Acesso: leitura linear
-   Persistência: ficheiro texto

------------------------------------------------------------------------

## 3. Modelo de Dados

Exemplo estrutural:

    FD AgendaFile.
    01 AgendaRecord.
       05 DataCompromisso    PIC X(10).
       05 HoraCompromisso    PIC X(5).
       05 Descricao          PIC X(50).

  Campo             Tipo           Tamanho   Descrição
  ----------------- -------------- --------- -------------
  DataCompromisso   Alfanumérico   10        DD/MM/AAAA
  HoraCompromisso   Alfanumérico   5         HH:MM
  Descricao         Alfanumérico   50        Texto livre

------------------------------------------------------------------------

## 4. Fluxo de Execução

Estrutura típica:

    PERFORM UNTIL Opcao = 0
        PERFORM MostrarMenu
        EVALUATE Opcao
            WHEN 1 PERFORM AdicionarCompromisso
            WHEN 2 PERFORM ListarCompromissos
        END-EVALUATE
    END-PERFORM.

Operações principais:

-   Inserção (WRITE)
-   Leitura sequencial (READ)
-   Controlo de EOF
-   Fecho de ficheiro (CLOSE)

------------------------------------------------------------------------

## 5. Compilação

Requisitos: - GNUCobol 3.x ou superior

Verificar instalação:

    cobc -v

Compilar:

    cobc -x AgendaFuturista.cob -o agenda

Executar:

    ./agenda

------------------------------------------------------------------------

## 6. Limitações

-   Sem edição
-   Sem remoção
-   Sem validação formal de data/hora
-   Sem ordenação

------------------------------------------------------------------------

## 7. Evoluções Futuras

-   Implementação de ficheiro INDEXED
-   Definição de chave primária
-   Pesquisa estruturada
-   Exportação CSV
-   Separação lógica de interface

------------------------------------------------------------------------

## 8. Finalidade

Projeto académico para consolidação de:

-   Estrutura COBOL
-   Manipulação de ficheiros
-   Lógica procedural
-   Modelação básica de dados
