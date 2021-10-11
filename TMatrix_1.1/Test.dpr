{ *********************************************************************** }
{                                                                         }
{         Пример использования класса TMatrix - решение СЛАУ              }
{                                                                         }
{                   Copyright © 2003, 2007 UzySoft                        }
{                                                                         }
{             Пожелания и предложения - jack@uzl.tula.net                 }
{ *********************************************************************** }

program Test;

uses
  Windows,
  Matrixes,
  ProcTime;
  
var
  A, B, X: TMatrix;
  Timer: TProcessTimer;
begin
  Timer := TProcessTimer.Create;     // Создаём таймер
  Timer.BeginProcess;                // Запускаем таймер
  A := TMatrix.Create('A.txt');      // Матрица коэффициентов
  B := TMatrix.Create('B.txt');      // Матрица свободных членов
  A.Clone(X);                        // X = A
  X.Ret.Mult(B).SaveToFile('X.txt'); // X = (X^-1)*B  и пишем в файл
  Timer.EndProcess;                  // Останавливаем таймер
  MessageBox(0, PChar(Timer.TextTime), '!', 0);
  A.Free;
  B.Free;
  X.Free;
end.
