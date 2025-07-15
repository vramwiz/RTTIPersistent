unit StringListEx;

interface

uses
	Windows,Messages, SysUtils, Classes, Graphics, Controls,StdCtrls, ExtCtrls;

type
	TStringListEx = class(TStringList)
	private
		{ Private êÈåæ }
    function GetCommaTextEx: string;
    procedure SetCommaTextEx(const Value: string);
	public
		{ Public êÈåæ }
    function CommaToMarkText(const str : string) : string;
    function MarkTextToComma(const str : string) : string;
    property CommaTextEx : string read GetCommaTextEx write SetCommaTextEx;
    function GetInt() : Integer;
    function GetStr() : string;
    function GetColor() : TColor;
    function GetBool() : Boolean;
    function GetDateTime() : TDateTime;
    procedure SetInt(Value : Integer;Len : Integer = 0);
    procedure SetStr(Value : string;Len : Integer = 0);
    procedure SetBool(Value : Boolean);
    procedure SetDateTime(Value : TDateTime);
    function GetDateTimes(str : string;aDef : TDateTime) :TDateTime;
    procedure SetDateTimes(str : string;const Value : TDateTime);
    function GetStrs(str : string;aDef : string='') : string;
    procedure SetStrs(str : string;const Value : string);
    function GetInts(str : string;aDef : Integer=0) : Integer;
    procedure SetInts(str : string;const Value : Integer);
    function GetBools(str : string;aDef : Boolean=False) : Boolean;
    procedure SetBools(str : string;const Value : Boolean);
    function GetStrTblIndex(str : string;Tbl : array of string;aDef : Integer) : Integer;
    function GetFloat() : Double;
    function GetFloats(str : string;aDef : Double=0) : Double;
    procedure SetFloat(Value : Double);
    procedure SetFloats(str : string;Value : Double);
    function GetHexs(str : string;aDef : Integer=0) : Integer;
    procedure SetHexs(str : string;const Value,Digits : Integer);
	end;

implementation

{ TDataSetubiStringListEx }

function TStringListEx.CommaToMarkText(const str: string): string;
var
  s : string;
begin
  s := str;
  s :=StringReplace(s,'&','&a',[rfreplaceall]);
  s :=StringReplace(s,',','&c',[rfreplaceall]);
  s :=StringReplace(s,#$0d#$0a,'&d',[rfreplaceall]);
  s :=StringReplace(s,#$0a,'&d',[rfreplaceall]);
  result := s;
end;

function TStringListEx.GetBool: Boolean;
begin
  result := StrToIntDef(Strings[0],0) <> 0;
  Delete(0);
end;

function TStringListEx.GetColor: TColor;
begin
  result := StringToColor(Trim(Strings[0]));
  Delete(0);
end;

function TStringListEx.GetCommaTextEx: string;
var
  i : Integer;
  s : string;
begin
  result := '';
  if Count = 0 then exit;
  s :=  CommaToMarkText(Strings[0]);
  for i := 1 to Count-1 do begin
    s := s + ',' + CommaToMarkText(Strings[i]);
  end;
  result := s;
end;

function TStringListEx.GetDateTime: TDateTime;
begin
  result := StrToDateTime(Strings[0]);
  Delete(0);
end;

function TStringListEx.GetDateTimes(str: string;
  aDef: TDateTime): TDateTime;
var
  s : string;
begin
  result := aDef;
  s := Trim(Values[str]);
  if s = '' then exit;
  result := StrToDateTime(s);
end;

function TStringListEx.GetInt: Integer;
begin
  result := StrToIntDef(Trim(Strings[0]),-1);
  Delete(0);
end;

function TStringListEx.GetStr: string;
begin
  result := MarkTextToComma(Strings[0]);
  Delete(0);
end;

function TStringListEx.GetStrs(str: string; aDef: string =''): string;
var
  s : string;
begin
  result := aDef;
  s := Values[str];
  if s = '' then exit;
  result := s;
end;

function TStringListEx.GetInts(str: string; aDef: Integer): Integer;
var
  s : string;
begin
  result := aDef;
  s := Values[str];
  if s = '' then exit;
  result := StrToIntDef(s,aDef);
end;

function TStringListEx.GetBools(str: string; aDef: Boolean): Boolean;
var
  s : string;
begin
  result := aDef;
  s := Values[str];
  if s = '' then exit;
  result := Boolean(StrToIntDef(s,Integer(aDef)));
end;

function TStringListEx.MarkTextToComma(const str: string): string;
var
  s : string;
begin
  s := str;
  s := StringReplace(s,'&d',#$0d#$0a,[rfreplaceall]);
  s := StringReplace(s,'&c',',',[rfreplaceall]);
  s := StringReplace(s,'&a','&',[rfreplaceall]);
  result := s;
end;

procedure TStringListEx.SetBool(Value: Boolean);
begin
  Add(IntToStr(Integer(Value)));
end;

procedure TStringListEx.SetCommaTextEx(const Value: string);
var
  i : Integer;
  s,m : string;
begin
  Clear;
  for i := 1 to Length(Value) do begin
    m := Copy(Value,i,1);
    if m = ',' then begin
      Add(MarkTextToComma(s));
      s := '';
    end
    else begin
      s := s + m;
    end;
  end;
  //if s <> '' then Add(s);
  Add(MarkTextToComma(s));
end;

procedure TStringListEx.SetDateTime(Value: TDateTime);
begin
  Add(DateTimeToStr(Value));
end;

procedure TStringListEx.SetDateTimes(str: string; const Value: TDateTime);
begin
  Values[str] := DateTimeToStr(Value);
end;

procedure TStringListEx.SetInt(Value: Integer;Len : Integer = 0);
var
  s,ss : string;
begin
  if Len = 0 then begin
    Add(IntToStr(Value));
  end
  else begin
    ss := IntToStr(Len);
    s := '%' + ss + '.' + ss + 'd';
    s := Format(s,[Value]);
    Add(s);
  end;
end;

procedure TStringListEx.SetStr(Value: string;Len : Integer = 0);
var
  s : string;
begin
  s := CommaToMarkText(Value);
  if Len = 0 then begin
    Add(s);
  end
  else begin
    s := s + StringOfChar(' ',Len);
    s := Copy(s,1,Len);
    Add(s);
  end;
end;

procedure TStringListEx.SetStrs(str: string; const Value: string);
begin
  Values[str] := Value;
end;

procedure TStringListEx.SetInts(str: string; const Value: Integer);
begin
  Values[str] := IntToStr(Value);
end;

procedure TStringListEx.SetBools(str: string; const Value: Boolean);
begin
  Values[str] := IntToStr(Integer(Value));
end;

function TStringListEx.GetStrTblIndex(str: string; Tbl: array of string;
  aDef: Integer): Integer;
var
  s : string;
  i : Integer;
begin
  result := aDef;
  s := GetStrs(str,'');
  for i := 0 to High(Tbl) do begin
    if s = Tbl[i] then begin
      result := i;
      break;
    end;
  end;

end;

function TStringListEx.GetFloat: Double;
begin
  result := StrToFloat(Strings[0]);
  Delete(0);
end;

function TStringListEx.GetFloats(str: string; aDef: Double): Double;
var
  s : string;
begin
  result := aDef;
  s := Values[str];
  if s = '' then exit;
  result := StrToFloatDef(s,aDef);
end;

function TStringListEx.GetHexs(str: string; aDef: Integer): Integer;
var
  s : string;
begin
  result := aDef;
  s := Values[str];
  if s = '' then exit;
  result := StrToIntDef('$'+s,aDef);
end;

procedure TStringListEx.SetFloat(Value: Double);
begin
  Add(FloatToStr(Value));
end;

procedure TStringListEx.SetFloats(str : string;Value: Double);
begin
  Values[str] := Format('%3.2f',[Value]);
end;

procedure TStringListEx.SetHexs(str: string; const Value, Digits: Integer);
begin
  Values[str] := IntToHex(Value,Digits)
end;

end.
