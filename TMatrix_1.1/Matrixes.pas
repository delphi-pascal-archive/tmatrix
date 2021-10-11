{ *********************************************************************** }
{                                                                         }
{   Модуль реализации класса TMatrix - Основные действия над матрицами    }
{                                                                         }
{                   Copyright © 2003, 2007 UzySoft                        }
{                                                                         }
{             Пожелания и предложения - jack@uzl.tula.net                 }
{ *********************************************************************** }

{
                              История версий
  Версия 1.1 - 04.09.07 21.14
  - Cвойство Origin переделанно в локальную переменную, для того чтобы оно
  было одинаково для всех матриц. Доступ к ней осуществляется с помощью
  функции GetOrigin и процедуры SetOrigin.
  - Некоторые изменения в именовании параметров методов.

  Версия 1.0 - 01.05.06 11.43 первая полноценная версия.
  - В конструкцие больше не использутся тип PMatrixData = ^TMatrixData.


  Версия 0.4b - 29.04.06 13.52
  + Добавлено свойство Origin - начальный индекс элементов матрицы.
    По умолчанию = 1. В связи с чем переписана часть методов, которые работают
    с индексами элементов.
  - Переписан метод Runk - работает как минимум вдвое быстрее старого.
    

  Версия 0.3b - 20.04.06 01.22
  - Удалён из uses модуль Classes (переписан метод LoadFromFile без
    использования StringList), что уменьшает размер исполняемого файла.
  - Небольшие изменения в функции DetMatrix.
  - Переписан метод RetMatrix (тестовая матрица 100x100 обращается за 0,047
    с., старый метод делал это за 88 с.).
  - Удалена функция DetMatrix, т.к. для поиска обратной матрицы она не нужна.
  - Исправлена ошибка переполнения в методе Rank.
  + Добавлен метод ApplyFunction, который даёт возможность применить какую-либо
    функцию одного аргумента ко всем элементам матрицы, например можно забить
    её псевдослучайными числами.
  + Добавлен ещё один конструктор с одним параметром для создания квадратных
    матриц (Create(Count: Word)).


  Версия 0.2b - 18.04.06 14.20
  - Удалены из uses модули Dialogs и Math (они использовались при отладке)
    что неприменно уменьшило размер исполняемого файла.


  Версия 0.1b - 18.04.06 12.13 - первый выход в люди
      Класс TMatrix реализует основные действия над матрицами действительных
  чисел. Может быть применён для решения систем уравнений в матричной форме
  (A * X = B => X = A^(-1) * B), различных матричных преобразований и везде там,
  где производятся действия над матрицами.


                                 Возможности:
      1. Загрузка матрицы из текстового файла (Пример файла содержиться в
  архиве). Создание дубликата матрицы. Поэлементное создание матрицы. Быстрое
  создание единичной матрицы.
      2. Умножение матрицы на число. Сложение, вычитание матриц. Умножение
  матриц. Возведение матрицы в целую степень.
      3. Нахождение определителя матрицы.
      4. Нахождение минора матрицы.
      5. Нахождение ранга матрицы.
      6. Удаление (вставка) строк (столбцов). При вставке необходимо создать
  матрицу которую будем вставлять.
      7. А также другие элементарные действия над матрицами (Транспонирование,
  поворот, отражение);


                                 Ограничения:
      1. Количество столбцов или строк не может быть больше 65535 (Мощность
  типа Word); }

unit Matrixes;

interface

uses
  SysUtils;

procedure SetOrigin(Value: Integer); // Работа с Origin;
function GetOrigin: Integer;

type
  TMatrixData = array of array of Extended;
  EMatrixError = class(Exception);
  TFunction = function(X: Extended): Extended;
  TIndFunction = function(X: Extended; i, j: Word): Extended;

  TMatrix = class
  protected
    FData: TMatrixData; // сама матрица
    procedure DoChangeCols(ColIndex1, ColIndex2: Word);
    procedure DoChangeRows(RowIndex1, RowIndex2: Word); // для местных нужд
    procedure DoDeleteItems(RowIndex, ARowCount, ColIndex, AColCount: Word);
    function DoGetMinor(Row, Col: Word): Extended;
    procedure DoPower(Exponent: SmallInt);
    procedure ChangeAndFree(Arr: TMatrixData); // Заменяет данные в матрице
    function Get(RowIndex, ColIndex: Integer): Extended;
    function GetColCount: Word;
    function GetMinor(Row, Col: Integer): Extended;
    function GetRowCount: Word;
    procedure Put(Row, Col: Integer; const Value: Extended);
  public
    constructor Create(const Rows, Cols: Word); overload; // Создаёт нулевую матрицу
    constructor Create(const Count: Word); overload; // Создаёт квадратную матрицу
    constructor Create(Arr: TMatrixData); overload;
      // Создаёт матрицу из массива
    constructor Create(Matrix: TMatrix); overload; // Создаёт матрицу из матрицы
    constructor Create(const FileName: string); overload; // Создаёт матрицу из файла
    constructor CreateE(const N: Word); // Создаёт единичную матрицу порядка N
    function Addition(Matrix: TMatrix): TMatrix; // Сумма матриц
    procedure ApplyFunction(Func: TFunction); overload;
      // Обработка всех элементов функцией одного аргумента;
    procedure ApplyFunction(Func: TIndFunction); overload;
      { Обработка всех элементов функцией 3 аргументов
      (2 поседних - индекс строки и столбца в которых находится элемент) }
    function ChangeCols(ColIndex1, ColIndex2: Integer): TMatrix; // Обмен столбцами
    function ChangeRows(RowIndex1, RowIndex2: Integer): TMatrix; // Обмен строками
    function Clone(var Matrix: TMatrix): Boolean; // Создание копии матрицы
    function DeleteCols(Index: Integer; Count: Word): TMatrix; // Удаляет столбцы
    function DeleteRows(Index: Integer; Count: Word): TMatrix; // Удаляет строки
    function Det: Extended; // Определитель матрицы
    function Equivalent(Matrix: TMatrix; Epsilon: Extended = 0): Boolean;
      // Сравнение матриц
    class procedure Error(const Msg: string; Data: Integer); overload; virtual;
    class procedure Error(Msg: PResStringRec; Data: Integer); overload;
    function FlipHorizontal: TMatrix; // Отражает слева направо
    function FlipVertical: TMatrix; // Отражает сверху вниз
    function InsertCols(Matrix: TMatrix; Index: Word): TMatrix;
    // Вставляет столбцы
    function InsertRows(Matrix: TMatrix; Index: Word): TMatrix;
    // Вставляет Строки
    function LoadFromFile(FileName: string): Boolean;
    // Загружает матрицу из файла
    function Mult(Matrix: TMatrix): TMatrix; overload; // Умножение на матрицу
    function Mult(const Num: Extended): TMatrix; overload; // Умножение на число
    function Power(Exponent: SmallInt): TMatrix;
    function Rank: Word; // Ранг матрицы
    function Ret: TMatrix; // Обращает Матрицу;
    function SaveToFile(FileName: string): Boolean; // Сохраняет матрицу в файл
    function Square: Boolean; // Проверка квадратности матрицы
    function Subtraction(Matrix: TMatrix): TMatrix; // Разность матриц
    function Trace: Extended; // След Матрицы.
    function Transposing: TMatrix; // Транспонирует матрицу
    function TurnLeft: TMatrix; // Поворот против часовой стрелки
    function TurnRight: TMatrix; // Поворот по часовой стрелки
    property ColCount: Word read GetColCount; // Кол-во столбцов
    property Items[Row, Col: Integer]: Extended read Get write Put; default;
    // Элементы матрицы
    property Minor[Row, Col: Integer]: Extended read GetMinor;
    // Минор к элементу Items [Row, Col]
    property RowCount: Word read GetRowCount; // Кол-во строк
  end;

const
  MaxDimentionOfMatrix = High(Word);

implementation

resourcestring
  SNotSquare = 'Matrix not square';
  SRowIndexError = 'Rows index out of bounds (%d)';
  SColIndexError = 'Cols index out of bounds (%d)';
  SSingularError = 'Matrix is singular (det (M) = 0)';
  SMultError = 'ColCount in the first matrix <> RowCount in the second matrix';
  SAdditionError = 'First matrix size <> second matrix size';
  SInsertRowError = 'First matrix ColCount <> second matrix ColCount (%d)';
  SInsertColError = 'First matrix RowCount <> second matrix RowCount (%d)';
  SOriginError ='Matrix origin out of bounds (%d)';
  
const
  HighOrigin = High(Integer) - MaxDimentionOfMatrix;
  LowOrigin = Low(Integer);

var
  Origin: Integer = 1; // Начальный индекс матриц

{ TMatrix }

procedure SetOrigin(Value: Integer);
begin
  if Value > HighOrigin - MaxDimentionOfMatrix then
    TMatrix.Error(SOriginError, Value)
  else
    Origin := Value;
end;

function GetOrigin: Integer;
begin
  Result := Origin;
end;

constructor TMatrix.Create(const Rows, Cols: Word);
var
  i, j: Word;
begin
  if Rows = 0 then
    Error(SRowIndexError, Rows);
  if Cols = 0 then
    Error(SRowIndexError, Cols);
  SetLength(FData, Rows, Cols);
  for i := 0 to RowCount - 1 do
    for j := 0 to ColCount - 1 do
      FData[i, j] := 0;
end;

constructor TMatrix.Create(const Count: Word);
begin
  Create(Count, Count);
end;

constructor TMatrix.Create(Arr: TMatrixData);
var
  i, j: Word;
begin
  if (Arr = nil) or (Length(Arr) = 0) then
    Create(1, 1)
  else
    begin
      SetLength(FData, Length(Arr), Length(Arr[0]));
      for i := 0 to RowCount - 1 do
        for j := 0 to ColCount - 1 do
          FData[i, j] := Arr[i, j]
    end;
end;

function TMatrix.Det: Extended;
var
  Temp, A: TMatrixData;
  Cols, Rows, Count: Word;
  i, j, k: Integer;
begin
  if not Square then
    Error(SNotSquare, 1);
  Count := Length(FData);
  Result := 1;
  SetLength(A, Count, Count);
  SetLength(Temp, 1, Count);
  for i := 0 to Count - 1 do
    for j := 0 to Count - 1 do
      A[i, j] := FData[i, j];
  for i := 0 to Count - 2 do {Начало преобразования к верхнему треугольному виду}
  begin
    for j := i to Count - 1 do                                 {*  Поиск    }
    begin                                                      {*  нулевых  }
      Rows := 0;                                               {*  строк    }
      Cols := 0;                                               {*  и        }
      for k := i to Count - 1 do                               {*  столбцов }
      begin                                                    {*  в        }
        Rows := Rows + Ord(A[j, k] = 0);                       {*  матрице  }
        Cols := Cols + Ord(A[k, j] = 0);                       {*           }
      end;                                                     {*           }
      if Rows + Cols = 0 then                                  {*           }
        Break;                                                 {*           }
      if (Cols = Count - i) or (Rows = Count - i) then         {*           }
      begin                                                    {*           }
        Result := 0;                                           {*           }
        Exit                                                   {*           }
      end                                                      {*           }
    end;                                                       {*           }
    if A[i, i] = 0 then
      for j := i + 1 to Count - 1 do
        if A[j, i] <> 0 then
        begin
          Result := -Result;                {* меняем строку              }
          Temp[0] := A[i];                  {* на строку с                }
          A[i] := A[j];                     {* первым                     }
          A[j] := Temp[0];                  {* ненулевым                  }
          Break                             {* элементом                  }
        end;
    for j := i + 1 to Count - 1 do
      if A[j, i] <> 0 then
      begin
        for k := i + 1 to Count - 1 do
          A[j, k] := A[j, k] - A[i, k] * A[j, i] / A[i, i];
        A[j, i] := 0
      end
  end; {Конец преобразования}
  for i := 0 to Count - 1 do     { Определитель как произведение }
    Result := Result * A[i, i];  { элементов на главной диагонали}
end;

function TMatrix.Get(RowIndex, ColIndex: Integer): Extended;
begin
  if (RowIndex - Origin + 1 > RowCount) or (RowIndex < Origin) then
    Error(SRowIndexError, RowIndex);
  if (ColIndex - Origin + 1 > ColCount) or (ColIndex < Origin) then
    Error(SColIndexError, ColIndex);
  Result := FData[RowIndex - Origin, ColIndex - Origin];
end;

function TMatrix.Ret: TMatrix;
var
  Temp, A: TMatrixData;
  Cols, Rows, Count: Word;
  i, j, k: Integer;
begin {det}
  if not Square then
    Error(SNotSquare, 1);
  Count := RowCount;
  Result := Self;
  SetLength(A, Count, Count * 2);
  SetLength(Temp, 1, Count * 2);
  for i := 0 to Count - 1 do
  begin
    for j := 0 to Count - 1 do         {Создаём матрицу вида [A|E]}
      A[i, j] := FData[i, j];
    for j := Count to Count * 2 - 1 do
      A[i, j] := Ord(i = (j - Count));
  end;

  for i := 0 to Count - 1 do {Начало преобразования к виду [E|B]}
  begin
    for j := i to Count - 1 do                                 {*  Поиск    }
    begin                                                      {*  нулевых  }
      Rows := 0;                                               {*  строк    }
      Cols := 0;                                               {*  и        }
      for k := i to Count - 1 do                               {*  столбцов }
      begin                                                    {*  в        }
        Rows := Rows + Ord(A[j, k] = 0);                       {*  матрице  }
        Cols := Cols + Ord(A[k, j] = 0);                       {*           }
      end;                                                     {*           }
      if Rows + Cols = 0 then                                  {*           }
        Break;                                                 {*           }
      if (Cols = Count - i) or (Rows = Count - i) then         {*           }
        Error(SSingularError, 1);                              {*           }
    end;
    
    if A[i, i] = 0 then
      for j := i + 1 to Count - 1 do
        if A[j, i] <> 0 then
        begin
          Temp[0] := A[i];           {* меняем строку  на строку с }
          A[i] := A[j];              {* первым ненулевым элементом }
          A[j] := Temp[0];
          Break
        end;

    for j := 0 to i - 1 do           {* собственно само преобразование}
      if A[j, i] <> 0 then
      begin
        for k := i + 1 to 2 * Count - 1 do
          A[j, k] := A[j, k] - A[i, k] * A[j, i] / A[i, i];
        A[j, i] := 0
      end;
    for j := i + 1 to Count - 1 do
      if A[j, i] <> 0 then
      begin
        for k := i + 1 to 2 * Count - 1 do
          A[j, k] := A[j, k] - A[i, k] * A[j, i] / A[i, i];
        A[j, i] := 0
      end;
  end; {Конец преобразования}
  for i := 0 to Count - 1 do              // Забираем значение обратной матрицы
    for j := 0 to Count - 1 do
      FData [i, j] := A[i, j + Count] / A[i, i];
end;

function TMatrix.SaveToFile(FileName: string): Boolean;
var
  F: TextFile;
  S: string;
  i, j: Word;
begin
  Result := False;
  try
    AssignFile(F, FileName);
    Rewrite(F);
  except
    Exit;
  end;
  for i := 0 to RowCount - 1 do
  begin
    S := '';
    for j := 0 to ColCount - 1 do
      S := S + FloatToStr(FData[i, j]) + ';';
    Delete(S, Length(S), 1);
    WriteLn(F, S);
  end;
  CloseFile(F);
  Result := True
end;

function TMatrix.LoadFromFile(FileName: string): Boolean;

type
  PStringData = ^TStringData;
  TStringData = record
    Data: string;
    Next: PStringData;
  end;

var
  Temp: Longint;
  TempData: TMatrixData;
  i, j, FCols, FRows: Word;
  F: TextFile;
  FirstSData, CurSData, TempSData: PStringData;

  procedure RemoveSpace(var S: string);  // Удаление всех пробелов
  var
    i: Cardinal;
  begin
    for i := Length(S) downto 1 do
      if S[i] in [#0..#32] then
        Delete(S, i, 1);
  end;

  procedure FreeData; // Освобождение памяти от списка
  begin
    CurSData := FirstSData;
    repeat
      TempSData := CurSData;
      CurSData := CurSData.Next;
      Finalize(TempSData.Data);
      Dispose(TempSData)
    until CurSData = nil;
  end;

begin
  Result := False;
  AssignFile(F, FileName);
  Reset(F);
  New(FirstSData);
  FirstSData.Next := nil;
  FirstSData.Data := '';

  while (FirstSData.Data = '') and (not Eof(f)) do  
  begin                                  // пропуск первых пуcтых строк
    ReadLn(F, FirstSData.Data);
    RemoveSpace(FirstSData.Data);
  end;

  if FirstSData.Data = '' then 
  begin                // Если ни одной строки так и не найдено, то выходим
    FreeData;
    Exit
  end;

  if FirstSData.Data[Length(FirstSData.Data)] <> ';' then
    FirstSData.Data := FirstSData.Data + ';';
  FCols := 1;

  for i := 1 to Length(FirstSData.Data) - 1 do
    if FirstSData.Data [i] = ';' then
      Inc(FCols);

  CurSData := FirstSData;
  FRows := 1; // Так как 1 строку прочитали.

  while not Eof(F) do // Располагаем все строки в списке
  begin
    New(TempSData);
    TempSData.Next := nil;
    ReadLn(F, TempSData.Data);
    CurSData.Next := TempSData;
    CurSData := TempSData;
    Inc(FRows);
  end;

  CurSData := FirstSData; // Перемещаем указатель на первый элемент;

  SetLength(TempData, FRows, FCols); // Заносим данные в массив.
  for i := 0 to FRows - 1 do
  begin
    if CurSData.Data = '' then
    begin
      FreeData;
      Exit;
    end;
    RemoveSpace(CurSData.Data);
    if CurSData.Data[Length(CurSData.Data)] <> ';' then
      CurSData.Data := CurSData.Data + ';';
    for j := 0 to FCols - 1 do
    begin
      Temp := Pos(';', CurSData.Data);
      try
        TempData[i, j] := StrToFloat(Copy(CurSData.Data, 1, Temp - 1));
      except
        FreeData;
        Exit;
      end;
      Delete(CurSData.Data, 1, Temp)
    end;
    CurSData := CurSData.Next;
  end;
  ChangeAndFree(TempData);
  FreeData;
  Result := True
end;

procedure TMatrix.Put(Row, Col: Integer; const Value: Extended);
begin
  if (Row - Origin + 1 > RowCount) or (Row < Origin) then
    Error(SRowIndexError, Row);
  if (Col - Origin + 1 > ColCount) or (Col < Origin) then
    Error(SColIndexError, Col);
  FData[Row - Origin, Col - Origin] := Value
end;

function TMatrix.Transposing: TMatrix;
var
  i: Word;
  j: Word;
  TempData: TMatrixData;
begin
  SetLength(TempData, ColCount, RowCount);
  for i := 0 to RowCount - 1 do
    for j := 0 to ColCount - 1 do
      TempData[j, i] := FData[i, j];
  ChangeAndFree(TempData);
  Result := Self
end;

function TMatrix.Mult(Matrix: TMatrix): TMatrix;
var
  i, j, k: Word;
  TempData: TMatrixData;
begin
  if ColCount <> Matrix.RowCount then
    Error(SMultError, 1);
  SetLength(TempData, RowCount, Matrix.ColCount);
  for i := 0 to RowCount - 1 do
    for j := 0 to Matrix.ColCount - 1 do
    begin
      TempData[i, j] := 0;
      for k := 0 to ColCount - 1 do
        TempData[i, j] := TempData[i, j] + FData[i, k] * Matrix.FData[k, j]
    end;
  ChangeAndFree(TempData);
  Result := Self
end;

constructor TMatrix.Create(Matrix: TMatrix);
var
  i: Word;
begin
  SetLength(FData, Matrix.RowCount, Matrix.ColCount);
  for i := 0 to RowCount - 1 do
    FData[i] := Copy(Matrix.FData[i]);
end;

procedure TMatrix.ChangeAndFree(Arr: TMatrixData);
var
  TempPoint: TMatrixData;
begin
  TempPoint := Arr;
  Arr := FData;
  FData := TempPoint;
  Finalize(Arr)
end;

constructor TMatrix.Create(const FileName: string);
begin
  if not LoadFromFile(FileName) then
    Create(1, 1)
end;

constructor TMatrix.CreateE(const N: Word);
var
  i, j: Word;
begin
  SetLength(FData, N, N);
  for i := 0 to RowCount - 1 do
    for j := 0 to ColCount - 1 do
      FData[i, j] := Ord(i = j)
end;

function TMatrix.Mult(const Num: Extended): TMatrix;
var
  i, j: Word;
begin
  for i := 0 to RowCount - 1 do
    for j := 0 to ColCount - 1 do
      FData[i, j] := FData[i, j] * Num;
  Result := Self
end;

function TMatrix.Addition(Matrix: TMatrix): TMatrix;
var
  i, j: Word;
begin
  if (ColCount = Matrix.ColCount) and (RowCount = Matrix.RowCount) then
    for i := 0 to RowCount - 1 do
      for j := 0 to ColCount - 1 do
        FData[i, j] := FData[i, j] + Matrix.FData[i, j]
  else
    Error(SAdditionError, 1);
  Result := Self
end;

function TMatrix.Subtraction(Matrix: TMatrix): TMatrix;
var
  i, j: Word;
begin
  if (ColCount = Matrix.ColCount) and (RowCount = Matrix.RowCount) then
    for i := 0 to RowCount - 1 do
      for j := 0 to ColCount - 1 do
        FData[i, j] := FData[i, j] - Matrix.FData[i, j]
  else
    Error(SAdditionError, 1);
  Result := Self
end;

function TMatrix.GetRowCount: Word;
begin
  Result := Length(FData);
end;

function TMatrix.GetColCount: Word;
begin
  Result := Length(FData[0]);
end;

function TMatrix.Trace: Extended;
var
  i: Integer;
begin
  Result := 0;
  if Square then
    for i := 0 to RowCount - 1 do
      Result := Result + FData[i, i]
  else
    Error(SNotSquare, 1);
end;

function TMatrix.Square: Boolean;
begin
  Result := RowCount = ColCount;
end;

function TMatrix.DeleteCols(Index: Integer; Count: Word): TMatrix;
begin
  if (Index < Origin) then
    Error(SColIndexError, Index);
  if (Count = 0) then
    Error(SColIndexError, Origin - 1);
  if (Index = Origin) and (Count = ColCount) then
    Error(SColIndexError, Origin);
  if (Index + Count - Origin > ColCount) then
    Error(SColIndexError, Index + Count - 1);
  DoDeleteItems(0, 0, Index - Origin, Count);
  Result := Self;
end;

procedure TMatrix.DoDeleteItems(RowIndex, ARowCount, ColIndex, AColCount: Word);
var
  TempData: TMatrixData;
  i, j: Integer;
  Rows, Cols: Word;
begin
  Rows := 0;
  SetLength(TempData, RowCount - ARowCount, ColCount - AColCount);
  for i := 0 to RowCount - 1 do
  begin
    if (i > RowIndex - 1) and (i < RowIndex + ARowCount) then
      Continue;
    Cols := 0;
    for j := 0 to ColCount - 1 do
    begin
      if (j > ColIndex - 1) and (j < ColIndex + AColCount) then
        Continue;
      TempData[Rows, Cols] := FData[i, j];
      Inc(Cols);
    end;
    Inc(Rows);
  end;
  ChangeAndFree(TempData);
end;

function TMatrix.DeleteRows(Index: Integer; Count: Word): TMatrix;
begin
  if (Index < Origin) then
    Error(SRowIndexError, Index);
  if (Count = 0) then
    Error(SRowIndexError, Origin - 1);
  if (Index = Origin) and (Count = RowCount) then
    Error(SRowIndexError, Origin);
  if (Index + Count - Origin > RowCount) then
    Error(SRowIndexError, Index + Count - 1);
  DoDeleteItems(Index - Origin, Count, 0, 0);
  Result := Self;
end;

function TMatrix.InsertCols(Matrix: TMatrix; Index: Word): TMatrix;
var
  M: TMatrixData;
  i, j: Integer;
begin
  if Matrix.RowCount <> RowCount then
    Error(SInsertColError, Matrix.RowCount);
  if ColCount + Matrix.ColCount > MaxDimentionOfMatrix then
    Error(SColIndexError, ColCount + Index);
  if (Index < Origin) then
    Error(SColIndexError, Index);
  if (Index - Origin > ColCount) then
    Error(SColIndexError, Index);
  SetLength(M, RowCount, ColCount + Matrix.ColCount);
  Index := Index - Origin;
  for i := 0 to RowCount - 1 do
    for j := 0 to ColCount + Matrix.ColCount - 1 do
    begin
      if j < Index then
      begin
        M[i, j] := FData[i, j];
        Continue
      end;
      if (j >= Index) and (j < Index + Matrix.ColCount) then
        M[i, j] := Matrix.FData[i, j - Index]
      else
        M[i, j] := FData[i, j - Matrix.ColCount];
    end;
  ChangeAndFree(M);
  Result := Self;
end;

function TMatrix.InsertRows(Matrix: TMatrix; Index: Word): TMatrix;
var
  M: TMatrixData;
  i: Integer;
begin
  if Matrix.ColCount <> ColCount then
    Error(SInsertRowError, Matrix.ColCount);
  if RowCount + Matrix.RowCount > MaxDimentionOfMatrix then
    Error(SRowIndexError, RowCount + Index);
  if (Index < Origin) then
    Error(SRowIndexError, Index);
  if (Index - Origin > RowCount) then
    Error(SRowIndexError, Index);
  SetLength(M, RowCount + Matrix.RowCount, ColCount);
  Index := Index - Origin;
  for i := 0 to RowCount + Matrix.RowCount - 1 do
  begin
    if i < Index then
    begin
      M[i] := Copy(FData[i]);
      Continue
    end;
    if (i >= Index) and (i < Index + Matrix.RowCount) then
      M[i] := Copy(Matrix.FData[i - Index])
    else
      M[i] := Copy(FData[i - Matrix.RowCount]);
  end;
  ChangeAndFree(M);
  Result := Self;
end;

class procedure TMatrix.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
    MOV EAX, [EBP + 4]
  end;

begin
  raise EMatrixError.CreateFmt(Msg, [Data])at ReturnAddr;
end;

class procedure TMatrix.Error(Msg: PResStringRec; Data: Integer);
begin
  TMatrix.Error(LoadResString(Msg), Data);
end;

function TMatrix.FlipVertical: TMatrix;
var
  i: Integer;
begin
  for i := 0 to RowCount div 2 - 1 do
    DoChangeRows(i, RowCount - i - 1);
  Result := Self;
end;

function TMatrix.FlipHorizontal: TMatrix;
var
  i: Integer;
begin
  for i := 0 to ColCount div 2 - 1 do
    DoChangeCols(i, ColCount - i - 1);
  Result := Self;
end;

function TMatrix.TurnLeft: TMatrix;
begin
  Transposing;
  FlipVertical;
  Result := Self;
end;

function TMatrix.TurnRight: TMatrix;
begin
  Transposing;
  FlipHorizontal;
  Result := Self;
end;

function TMatrix.Equivalent(Matrix: TMatrix; Epsilon: Extended = 0): Boolean;
var
  i, j: Integer;
begin
  Result := False;
  Epsilon := Abs(Epsilon);
  if (Matrix.RowCount <> RowCount) or (Matrix.ColCount <> ColCount) then
    Exit;
  for i := 0 to RowCount - 1 do
    for j := 0 to ColCount - 1 do
      if Abs(FData[i, j] - Matrix.FData[i, j]) > Epsilon then
        Exit;
  Result := True;
end;

function TMatrix.ChangeCols(ColIndex1, ColIndex2: Integer): TMatrix;
begin
  Result := Self;
  if ColIndex1 = Colindex2 then
    Exit;
  if ColIndex1 < Origin then
    Error(SColIndexError, ColIndex1);
  if ColIndex2 < Origin then
    Error(SColIndexError, ColIndex2);
  if ColIndex1 > ColCount + Origin - 1 then
    Error(SColIndexError, ColIndex1);
  if ColIndex2 > ColCount + Origin - 1 then
    Error(SColIndexError, ColIndex2);
  DoChangeCols(ColIndex1 - Origin, ColIndex2 - Origin);
end;

function TMatrix.ChangeRows(RowIndex1, RowIndex2: Integer): TMatrix;
begin
  Result := Self;
  if RowIndex1 = RowIndex2 then
    Exit;
  if RowIndex1 < Origin then
    Error(SRowIndexError, RowIndex1);
  if RowIndex2 < Origin then
    Error(SRowIndexError, RowIndex2);
  if RowIndex1 > RowCount + Origin - 1 then
    Error(SRowIndexError, RowIndex1);
  if RowIndex2 > RowCount + Origin - 1 then
    Error(SRowIndexError, RowIndex2);
  DoChangeRows(RowIndex1 - Origin, RowIndex2 - Origin);
end;

function TMatrix.Clone(var Matrix: TMatrix): Boolean;
begin
  Result := False;
  try
    Matrix.Free;
  except
    Exit
  end;
  Matrix := TMatrix.Create(Self);
  Result := True
end;

procedure TMatrix.DoChangeCols(ColIndex1, ColIndex2: Word);
var
  i: Word;
  Temp: Extended;
begin
  for i := 0 to RowCount - 1 do
  begin
    Temp := FData[i, ColIndex1];
    FData[i, ColIndex1] := FData[i, ColIndex2];
    FData[i, ColIndex2] := Temp;
  end;
end;

procedure TMatrix.DoChangeRows(RowIndex1, RowIndex2: Word);
var
  Temp: TMatrixData;
begin
  SetLength(Temp, 1, ColCount);
  Temp[0] := FData[RowIndex1];
  FData[RowIndex1] := FData[RowIndex2];
  FData[RowIndex2] := Temp[0];
end;

function TMatrix.DoGetMinor(Row, Col: Word): Extended;
begin
  with TMatrix.Create(Self) do
  begin
    DoDeleteItems(Row, 1, Col, 1);
    Result := Det;
    Free
  end;
end;

function TMatrix.GetMinor(Row, Col: Integer): Extended;
begin
  if (Row - Origin + 1 > RowCount) or (Row < Origin) then
    Error(SRowIndexError, Row);
  if (Col - Origin + 1 > ColCount) or (Col < Origin) then
    Error(SColIndexError, Col);
  if not Square then
    Error(SNotSquare, 1);
  Result := DoGetMinor(Row - Origin, Col - Origin);
end;

procedure TMatrix.DoPower(Exponent: SmallInt);
var
  i, j, k, l: Word;
  TempData1, TempData2: TMatrixData;
  TempPoint: TMatrixData;
  Exp: Integer;
begin
  Exp := Exponent;
  TempPoint := nil;
  if Exponent = 0 then
  begin
    for i := 0 to RowCount - 1 do
      for j := 0 to ColCount - 1 do
        FData[i, j] := Ord(i = j);
    Exit;
  end;
  if Exponent < 0 then
  begin
    Ret;
    Exp := -Exp;
  end;
  SetLength(TempData1, RowCount, ColCount);
  SetLength(TempData2, RowCount, ColCount);
  for i := 0 to RowCount - 1 do
    TempData1[i] := Copy(FData[i]);
  for l := 1 to Exp - 1 do
  begin
    for i := 0 to RowCount - 1 do
      for j := 0 to ColCount - 1 do
      begin
        TempData2[i, j] := 0;
        for k := 0 to ColCount - 1 do
          TempData2[i, j] := TempData2[i, j] + TempData1[i, k] * FData[k, j]
      end;
    TempPoint := TempData2;
    TempData2 := TempData1;
    TempData1 := TempPoint;
  end;
  ChangeAndFree(TempData1);
end;

function TMatrix.Power(Exponent: SmallInt): TMatrix;
begin
  if not Square then
    Error(SNotSquare, 1);
  DoPower(Exponent);
  Result := Self
end;

procedure TMatrix.ApplyFunction(Func: TFunction);
var
  i, j: Integer;
begin
  for i := 0 to RowCount - 1 do
    for j := 0 to ColCount - 1 do
      FData[i, j] := Func(FData[i, j]);
end;

procedure TMatrix.ApplyFunction(Func: TIndFunction);
var
  i, j: Integer;
begin
  for i := 0 to RowCount - 1 do
    for j := 0 to ColCount - 1 do
      FData[i, j] := Func(FData[i, j], i + Origin, j + Origin);
end;

function TMatrix.Rank: Word;
var
  M: TMatrix;
  i, j: Word;
  Zero: Boolean;
  Cols, Rows: Word;
  Temp: Extended;
begin
  Result := 0;
  M := TMatrix.Create(Self);
  Rows := RowCount; // кол-во ненулевых строк;
  Cols := ColCount; // кол-во ненулевых столбцов;
  repeat
    Zero := True; // Если осталась 1 строка или 1 столбец
    if (Cols = 1) or (Rows = 1) then
    begin
      if Cols = 1 then
      begin
        Cols := Rows;
        M.Transposing;
      end;
      for i := 0 to Cols - 1 do
      begin
        if M.FData[0, i] <> 0 then
        begin
          Zero := False;
          Break;
        end;
      end;
      if not Zero then
        Inc(Result);
      Break
    end;
    for i := Rows - 1 downto 0 do // перемещение нулевых строк в конец;
    begin
      Zero := True;
      for j := 0 to Cols - 1 do
      begin
        if M.FData[i, j] <> 0 then
        begin
          Zero := False;
          Break;
        end;
      end;
      if Zero then
      begin
        M.DoChangeRows(i, Rows - 1);
        Dec(Rows);
        if Rows = 1 then
          Break
      end;
    end;
    if Rows = 1 then
      Continue;
    for i := Cols - 1 downto 0 do // перемещение нулевых столбцов в конец;
    begin
      Zero := True;
      for j := 0 to Rows - 1 do
      begin
        if M.FData[j, i] <> 0 then
        begin
          Zero := False;
          Break
        end;
      end;
      if Zero then
      begin
      //  M.DoChangeCols(i, Cols - 1); // Код обмена столбцами
        for j := 0 to Rows - 1 do
        begin
          Temp := M.FData[j, i];
          M.FData[j, i] := M.FData[j, Cols - 1];
          M.FData[j, Cols - 1] := Temp
        end;
        Dec(Cols);
        if Cols = 1 then
          Break
      end;
    end;
    if Cols = 1 then
      Continue;
    if M.FData[0, 0] = 0 then // Приведение матрицы к трапецевидному виду
      for i := 1 to Rows - 1 do
        // Поиск строки с первым ненулевым элементом
        if M.FData[i, 0] <> 0 then
          M.DoChangeRows(0, i);
    for i := 1 to Rows - 1 do // Преведение к трапецевидному виду
      if M.FData[i, 0] <> 0 then
      begin
        for j := 1 to Cols - 1 do
          M.FData[i, j] := M.FData[i, j] - M.FData[0, j] *
          M.FData[i, 0] / M.FData[0, 0];
        M.FData[i, 0] := 0
      end;
    Inc(Result);
    M.DoChangeRows(0, Rows - 1);
    Dec(Rows);

    for j := 0 to Rows - 1 do  // Код обмена столбцами
    begin
      Temp := M.FData[j, 0];
      M.FData[j, 0] := M.FData[j, Cols - 1];
      M.FData[j, Cols - 1] := Temp
    end;
    Dec(Cols);
  until False;
  M.Destroy;
end;

end.
