{ *********************************************************************** }
{                                                                         }
{         ������ ������������� ������ TMatrix - ������� ����              }
{                                                                         }
{                   Copyright � 2003, 2007 UzySoft                        }
{                                                                         }
{             ��������� � ����������� - jack@uzl.tula.net                 }
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
  Timer := TProcessTimer.Create;     // ������ ������
  Timer.BeginProcess;                // ��������� ������
  A := TMatrix.Create('A.txt');      // ������� �������������
  B := TMatrix.Create('B.txt');      // ������� ��������� ������
  A.Clone(X);                        // X = A
  X.Ret.Mult(B).SaveToFile('X.txt'); // X = (X^-1)*B  � ����� � ����
  Timer.EndProcess;                  // ������������� ������
  MessageBox(0, PChar(Timer.TextTime), '!', 0);
  A.Free;
  B.Free;
  X.Free;
end.
