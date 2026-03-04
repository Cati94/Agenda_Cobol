       IDENTIFICATION DIVISION.
       PROGRAM-ID. AgendaFuturista.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AgendaFile ASSIGN TO "agenda.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS FileStatus.

       DATA DIVISION.
       FILE SECTION.
       FD AgendaFile.
       01 RegistroAgenda.
           05 DataComp      PIC 9(8).
           05 HoraComp      PIC 9(4).
           05 Duracao       PIC 9(3).
           05 Prioridade    PIC 9.
           05 DescricaoComp PIC X(50).

       WORKING-STORAGE SECTION.
       77 Opcao        PIC 9.
       77 Continuar    PIC X VALUE 'S'.
       77 FileStatus   PIC XX.
       77 Today        PIC 9(8).
       77 CurrTime     PIC 9(4).
       77 CountAgenda  PIC 9(3) VALUE 0.
       77 Conflict     PIC X VALUE 'N'.

       01 ArrayAgenda.
           05 AgendaItem OCCURS 100 TIMES INDEXED BY IDX.
               10 DataArr      PIC 9(8).
               10 HoraArr      PIC 9(4).
               10 DuracaoArr   PIC 9(3).
               10 PriorArr     PIC 9.
               10 DescArr      PIC X(50).

       77 I            PIC 9(3).
       77 J            PIC 9(3).
       77 TempDate     PIC 9(8).
       77 TempHora     PIC 9(4).
       77 TempDur      PIC 9(3).
       77 TempPrior    PIC 9.
       77 TempDesc     PIC X(50).
       77 TempInt      PIC 9(4).

       PROCEDURE DIVISION.

       MAIN.
          MOVE FUNCTION CURRENT-DATE(1:8) TO Today
          MOVE FUNCTION CURRENT-DATE(9:12) TO CurrTime

           OPEN I-O AgendaFile
           IF FileStatus = "35"
               OPEN OUTPUT AgendaFile
               CLOSE AgendaFile
               OPEN I-O AgendaFile
           END-IF

           PERFORM CarregarAgenda
           PERFORM MostrarProximo
           PERFORM MostrarBlocosLivres

           PERFORM UNTIL Continuar = 'N'
               DISPLAY "====== AGENDA FUTURISTA ======"
               DISPLAY "1 - Adicionar"
               DISPLAY "2 - Listar Todos"
               DISPLAY "3 - Consultar"
               DISPLAY "4 - Remover"
               DISPLAY "5 - Exportar CSV"
               DISPLAY "0 - Sair"
               ACCEPT Opcao

               EVALUATE Opcao
                   WHEN 1 PERFORM Adicionar
                   WHEN 2 PERFORM Listar
                   WHEN 3 PERFORM Consultar
                   WHEN 4 PERFORM Remover
                   WHEN 5 PERFORM ExportarCSV
                   WHEN 0 MOVE 'N' TO Continuar
                   WHEN OTHER DISPLAY "Opcao invalida."
               END-EVALUATE
           END-PERFORM

           PERFORM SalvarAgenda
           CLOSE AgendaFile
           DISPLAY "Fim da agenda."
           STOP RUN.

       *>----------------- CARREGAR AGENDA -----------------
       CarregarAgenda.
           MOVE 0 TO CountAgenda
           PERFORM UNTIL FileStatus = "10"
               READ AgendaFile NEXT
                   AT END MOVE "S" TO Conflict
                   NOT AT END
                       ADD 1 TO CountAgenda
                       MOVE DataComp TO DataArr(CountAgenda)
                       MOVE HoraComp TO HoraArr(CountAgenda)
                       MOVE Duracao TO DuracaoArr(CountAgenda)
                       MOVE Prioridade TO PriorArr(CountAgenda)
                       MOVE DescricaoComp TO DescArr(CountAgenda)
               END-READ
           END-PERFORM
           MOVE 'N' TO Conflict
           PERFORM OrdenarAgenda
           .

       *>----------------- MOSTRAR PROXIMO -----------------
       MostrarProximo.
           DISPLAY "---- PROXIMO COMPROMISSO ----"
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CountAgenda
               IF DataArr(I) > Today OR (DataArr(I) = Today AND HoraArr(I) >= CurrTime)
                   DISPLAY "Data:" DataArr(I) " Hora:" HoraArr(I)
                   DISPLAY "Prioridade:" PriorArr(I)
                   DISPLAY "Descricao:" DescArr(I)
                   EXIT PERFORM
               END-IF
           END-PERFORM
           DISPLAY "-----------------------------"
           .

       *>----------------- MOSTRAR BLOCOS LIVRES -----------------
       MostrarBlocosLivres.
           DISPLAY "---- BLOCOS LIVRES DO DIA ----"
           MOVE 0 TO TempInt
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CountAgenda
               IF DataArr(I) = Today
                   IF TempInt < HoraArr(I)
                       DISPLAY TempInt " até " HoraArr(I)
                   END-IF
                   ADD DuracaoArr(I) TO HoraArr(I)
                   MOVE HoraArr(I) TO TempInt
               END-IF
           END-PERFORM
           DISPLAY TempInt " até 2400 (fim do dia)"
           DISPLAY "-----------------------------"
           .

       *>----------------- ADICIONAR -----------------
       Adicionar.
           DISPLAY "Data (AAAAMMDD): "
           ACCEPT TempDate
           DISPLAY "Hora (HHMM): "
           ACCEPT TempHora
           DISPLAY "Duracao (minutos): "
           ACCEPT TempDur
           DISPLAY "Prioridade (1-9): "
           ACCEPT TempPrior
           DISPLAY "Descricao: "
           ACCEPT TempDesc

           PERFORM VerificarConflito
           IF Conflict = 'N'
               ADD 1 TO CountAgenda
               MOVE TempDate TO DataArr(CountAgenda)
               MOVE TempHora TO HoraArr(CountAgenda)
               MOVE TempDur TO DuracaoArr(CountAgenda)
               MOVE TempPrior TO PriorArr(CountAgenda)
               MOVE TempDesc TO DescArr(CountAgenda)
               DISPLAY "Compromisso adicionado."
           ELSE
               DISPLAY "Conflito de horario!"
           END-IF
           PERFORM OrdenarAgenda
           .

       *>----------------- VERIFICAR CONFLITO -----------------
       VerificarConflito.
           MOVE 'N' TO Conflict
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CountAgenda
               IF TempDate = DataArr(I)
                   IF (TempHora >= HoraArr(I) AND TempHora < HoraArr(I) + DuracaoArr(I)) OR
                      (TempHora + TempDur > HoraArr(I) AND TempHora + TempDur <= HoraArr(I) + DuracaoArr(I))
                       MOVE 'S' TO Conflict
                       EXIT PERFORM
                   END-IF
               END-IF
           END-PERFORM
           .

       *>----------------- ORDENAR -----------------
       OrdenarAgenda.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I >= CountAgenda
               MOVE I TO J
               ADD 1 TO J
               PERFORM VARYING J FROM J BY 1 UNTIL J > CountAgenda
                   IF DataArr(I) > DataArr(J)
                       PERFORM Trocar
                   ELSE
                       IF DataArr(I) = DataArr(J) AND HoraArr(I) > HoraArr(J)
                           PERFORM Trocar
                       ELSE
                           IF DataArr(I) = DataArr(J) AND HoraArr(I) = HoraArr(J) AND PriorArr(I) < PriorArr(J)
                               PERFORM Trocar
                           END-IF
                       END-IF
                   END-IF
               END-PERFORM
           END-PERFORM
           .

       *>----------------- TROCAR -----------------
       Trocar.
           MOVE DataArr(I) TO TempDate
           MOVE HoraArr(I) TO TempHora
           MOVE DuracaoArr(I) TO TempDur
           MOVE PriorArr(I) TO TempPrior
           MOVE DescArr(I) TO TempDesc

           MOVE DataArr(J) TO DataArr(I)
           MOVE HoraArr(J) TO HoraArr(I)
           MOVE DuracaoArr(J) TO DuracaoArr(I)
           MOVE PriorArr(J) TO PriorArr(I)
           MOVE DescArr(J) TO DescArr(I)

           MOVE TempDate TO DataArr(J)
           MOVE TempHora TO HoraArr(J)
           MOVE TempDur TO DuracaoArr(J)
           MOVE TempPrior TO PriorArr(J)
           MOVE TempDesc TO DescArr(J)
           .

       *>----------------- LISTAR -----------------
       Listar.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CountAgenda
               DISPLAY DataArr(I) " " HoraArr(I) " | Pri:" PriorArr(I) " Desc:" DescArr(I)
           END-PERFORM
           .

       *>----------------- CONSULTAR -----------------
       Consultar.
           DISPLAY "Data (AAAAMMDD): "
           ACCEPT TempDate
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CountAgenda
               IF DataArr(I) = TempDate
                   DISPLAY "Hora:" HoraArr(I) " | Pri:" PriorArr(I) " Desc:" DescArr(I)
               END-IF
           END-PERFORM
           .

       *>----------------- REMOVER -----------------
       Remover.
           DISPLAY "Data (AAAAMMDD): "
           ACCEPT TempDate
           DISPLAY "Hora (HHMM): "
           ACCEPT TempHora
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CountAgenda
               IF DataArr(I) = TempDate AND HoraArr(I) = TempHora
                   PERFORM VARYING J FROM I BY 1 UNTIL J = CountAgenda
                       MOVE DataArr(J + 1) TO DataArr(J)
                       MOVE HoraArr(J + 1) TO HoraArr(J)
                       MOVE DuracaoArr(J + 1) TO DuracaoArr(J)
                       MOVE PriorArr(J + 1) TO PriorArr(J)
                       MOVE DescArr(J + 1) TO DescArr(J)
                   END-PERFORM
                   SUBTRACT 1 FROM CountAgenda
                   DISPLAY "Compromisso removido."
                   EXIT PERFORM
               END-IF
           END-PERFORM
           .

       *>----------------- EXPORTAR CSV -----------------
       ExportarCSV.
           OPEN OUTPUT AgendaFile
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CountAgenda
               DISPLAY DataArr(I) "," HoraArr(I) "," DuracaoArr(I) "," PriorArr(I) "," DescArr(I)
           END-PERFORM
           CLOSE AgendaFile
           DISPLAY "Exportacao concluida."
           .

       *>----------------- SALVAR -----------------
       SalvarAgenda.
           OPEN OUTPUT AgendaFile
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CountAgenda
               MOVE DataArr(I) TO DataComp
               MOVE HoraArr(I) TO HoraComp
               MOVE DuracaoArr(I) TO Duracao
               MOVE PriorArr(I) TO Prioridade
               MOVE DescArr(I) TO DescricaoComp
               WRITE RegistroAgenda
           END-PERFORM
           CLOSE AgendaFile
           .
