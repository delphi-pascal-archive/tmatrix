{ *********************************************************************** }
{                                                                         }
{         ������ ���������� ������ TProcessTimer - ����������             }
{                                                                         }
{               ��������  ������� ���������� ����������                   }
{                                                                         }
{                   Copyright � 2003, 2007 UzySoft                        }
{                                                                         }
{             ��������� � ����������� - jack@uzl.tula.net                 }
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
    procedure BeginProcess;                        // ��������� ������
    function EndProcess: string;                   // ������������� ������
    property Processing: Boolean read FProcessing; // ��������� ������ �������
    property TextTime: string read GetTextTime;    // ����� ��� ����� (���.)
    property Time: Extended read GetTime;          // ����� ��� ����� (���.)
  end;

implementation

{ TProcessTimer }

// ��������� ���������� ����������� ����� ����� ������
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
