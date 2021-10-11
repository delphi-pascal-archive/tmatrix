{ *********************************************************************** }
{                                                                         }
{         Модуль реализации класса TProcessTimer - инструмент             }
{                                                                         }
{               проверки  времени выполнения алгоритмов                   }
{                                                                         }
{                   Copyright © 2003, 2007 UzySoft                        }
{                                                                         }
{             Пожелания и предложения - jack@uzl.tula.net                 }
{ *********************************************************************** }

unit ProcTime;

interface

uses
  SysUtils;

type
  TProcessTimer = class
  private
    FBeginTime: TDateTime;
    FEndTime: TDateTime;
    FProcessing: Boolean;
    function GetTextTime: string;
    function GetTime: Extended;
  public
    constructor Create;
    procedure BeginProcess;                        // Запускает таймер
    function EndProcess: string;                   // Останавливает таймер
    property Processing: Boolean read FProcessing; // Индикатор работы таймера
    property TextTime: string read GetTextTime;    // Время как текст (сек.)
    property Time: Extended read GetTime;          // Время как число (сек.)
  end;

implementation

{ TProcessTimer }

// Вычисляет количество миллисекунд между двумя датами
function MilliSecondsBetween(const ANow, AThen: TDateTime): Int64;
begin
  if ANow < AThen then
    Result := Trunc(MSecsPerDay * (AThen - ANow))
  else
    Result := Trunc(MSecsPerDay * (ANow - AThen));
end;

constructor TProcessTimer.Create;
begin
  FBeginTime := Now;
  FEndTime := FBeginTime;
  FProcessing := False;
end;

procedure TProcessTimer.BeginProcess;
begin
  if not Processing then
  begin
    FBeginTime := Now;
    FProcessing := True
  end;
end;

function TProcessTimer.EndProcess: string;
begin
  if Processing then
  begin
    FEndTime := Now;
    FProcessing := False;
    Result := TextTime;
    Beep
  end;
end;

function TProcessTimer.GetTextTime: string;
begin
  Result := FloatToStr(Round(Time) / 1000)
end;

function TProcessTimer.GetTime: Extended;
begin
  if Processing then
    Result := MilliSecondsBetween(FBeginTime, Now)
  else
    Result := MilliSecondsBetween(FBeginTime, FEndTime)
end;

end.
