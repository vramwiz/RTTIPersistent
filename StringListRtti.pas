unit StringListRtti;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,StringListEx,TypInfo;


//--------------------------------------------------------------------------//
//  拡張TPersistentクラス（DefinePropertiesメソッドの強制公開）             //
//--------------------------------------------------------------------------//
type  TPersistentEx = class(TPersistent);


//--------------------------------------------------------------------------//
//  実行時型情報を利用したオブジェクトの保存と読み込みするクラス            //
//--------------------------------------------------------------------------//
type
// 型種類
  TRttiType = (rtNormal,rtBoolean,rtImitation,rtComponent,rtClass,rtCollection,rtRootClass);
	TStringListRtti = class(TStringListEx)
	private
		{ Private 宣言 }
    FObject : TObject;
    FInfo  : PTypeInfo;
    FData  : PTypeData;
    FProps : PPropList;
    procedure GetRttiInfo();
    function CheckRttiType(aProp : PPropInfo) : TRttiType;
    function CheckImitationProperty(aObject : TObject) : Boolean;
    procedure SaveToObjectNormal(i : Integer);
    procedure LoadFromObjectNormal(i : Integer);
	public
		{ Public 宣言 }
    // Key=Value 形式の文字列リストを指定されたオブジェクトの変数に書き込む
    function LoadFromObject(aObject : TObject) : Boolean;
    // 指定されたオブジェクトを解析して Key=Value形式の文字列リストにする
    function SaveToObject(aObject : TObject) : Boolean;
	end;

implementation

{ TStringListRtti }

function TStringListRtti.CheckImitationProperty(aObject: TObject): Boolean;
var
  stm : TWriter;
  m : TStringStream;
  s : string;
begin
  result := False;
  if aObject = nil then exit;
  m := TStringStream.Create(s);
  stm := TWriter.Create(m,4096);
  try
    //result := False;
    TPersistentEx(aObject).DefineProperties(stm);
    stm.FlushBuffer;
    m.Seek(0, soFromBeginning);
    result := m.DataString <> '';
  finally
    m.Free;
    stm.Free;
  end;
end;

function TStringListRtti.CheckRttiType(aProp: PPropInfo): TRttiType;
var
  PName : string;
begin
  result := rtNormal;
  PName := string(aProp.Name);
  if (aProp.PropType^.Kind = tkClass) then begin
    if (CheckImitationProperty(GetObjectProp(FObject,aProp))) then begin
      // 偽プロパティの処理
      result := rtImitation;
    end
    else if GetObjectProp(FObject,PName) <> nil then begin
      // クラスの処理
      if GetObjectProp(FObject,PName) is TComponent then begin
        // TComponentからの派生クラスのとき
        result := rtComponent;
      end
      else begin
        // TComponent以外からの派生クラスのとき
        result := rtClass;
      end;
    end;
  end
  else if aProp.PropType^.Name = 'Boolean' then begin
    result := rtBoolean;
  end;
end;

procedure TStringListRtti.GetRttiInfo;
begin
  FInfo := FObject.ClassInfo;
  FData := GetTypeData(FInfo);

  GetMem(FProps,FData^.PropCount * SizeOf(PPropInfo));
  GetPropInfos(FInfo,FProps);

end;

function TStringListRtti.LoadFromObject(aObject: TObject): Boolean;
var
  i : Integer;
begin
  FObject := aObject;
  GetRttiInfo();
  for i :=0  to FData^.PropCount-1 do begin
    if not IsStoredProp(FObject,FProps^[i]) then Continue;
    LoadFromObjectNormal(i);
    {
    case CheckRttiType(FProps^[i]) of
      rtNormal: LoadFromObjectNormal(i);
    end;
    }
  end;
  result := true;
end;

procedure TStringListRtti.LoadFromObjectNormal(i: Integer);
var
  aStr : string;
  aInt : Integer;
  aInt64 : Int64;
  aFloat : Double;
  p : PPropInfo;
  PName : string;
  aByte : Byte;
begin
  p := FProps[i];
  PName := string(FProps^[i].Name);
  case CheckRttiType(p) of
    rtNormal: begin
      case p.PropType^.Kind of
        tkChar,
        tkWChar,
        tkInteger : begin
          //  実行時型情報から数値型の読み込み
          aInt := GetOrdProp(FObject,PName);
          //  IniファイルからInteger型の読み込み ファイルに無い場合初期値を採用 ※2025/06/30
          aInt := GetInts(PName,aInt);
          SetOrdProp(FObject,p,aInt);
        end;
        tkString : begin
          //  短い文字列型の書き込み
          aStr := GetStrProp(FObject,PName);
          //  IniファイルからString型の読み込み ファイルに無い場合初期値を採用 ※2025/06/30
          aStr := GetStrs(PName,aStr);
          aStr := MarkTextToComma(aStr);
          SetStrProp(FObject,p,aStr);
        end;
        tkUString,
        tkLString,
        tkWString : begin
          //  実行時型情報から長い文字列型の読み込み
          aStr := GetStrProp(FObject,PName);
          //  IniファイルからString型の読み込み ファイルに無い場合初期値を採用 ※2025/06/30
          aStr := GetStrs(PName,aStr);
          aStr := MarkTextToComma(aStr);
          SetStrProp(FObject,p,aStr);
        end;
        tkFloat : begin
          //  実行時型情報からFloat型の読み込み
           aFloat := GetFloatProp(FObject,PName);
           //  IniファイルからFloat型の読み込み ファイルに無い場合初期値を採用 ※2025/06/30
           aFloat := GetFloats(PName,aFloat);
           SetFloatProp(FObject,p,aFloat);
        end;
        tkInt64 : begin
          //  実行時型情報からInt64型の読み込み
          aInt64 := GetInt64Prop(FObject,PName);
          //  IniファイルからInt64型の読み込み ファイルに無い場合初期値を採用 ※2025/06/30
          aStr := GetStrs(PName,'');
          aInt64 := StrToInt64Def(aStr,aInt64);
          SetInt64Prop(FObject,p,aInt64);
        end;
        tkEnumeration : begin
          //  実行時型情報から列挙型の読み込み
          aInt := GetOrdProp(FObject,PName);
          //  Iniファイルから列挙型の読み込み  ファイルに無い場合初期値を採用 ※2025/06/30
          aByte := GetInts(PName,aInt);
          SetOrdProp(FObject,p,aByte);
        end;
        tkSet : begin
          //  実行時型情報から集合型の読み込み
          aInt := GetOrdProp(FObject,PName);
          //  Iniファイルから集合型の読み込み  ファイルに無い場合初期値を採用 ※2025/06/30
          aInt := GetInts(PName,aInt);
          SetOrdProp(FObject,p,aInt);
        end;
      end;
    end;
    rtBoolean : begin
      //  実行時型情報からBoolean型の読み込み
      aInt := GetOrdProp(FObject,PName);
      // IniファイルからBoolean型の読み込み  ファイルに無い場合初期値を採用 ※2025/06/30
      aInt := GetInts(PName,aInt);
      SetOrdProp(FObject,p,aInt);
    end;
    else begin
    end;
  end;

end;

function TStringListRtti.SaveToObject(aObject: TObject): Boolean;
var
  i,aInt : Integer;
  PName : string;
begin
  FObject := aObject;
  GetRttiInfo();
  for i :=0  to FData^.PropCount-1 do begin
    if not IsStoredProp(FObject,FProps^[i]) then Continue;
    PName := string(FProps^[i].Name);
    case CheckRttiType(FProps^[i]) of
      rtNormal: SaveToObjectNormal(i);
      rtBoolean : begin
        //  Boolean型の書き込み
        aInt := GetOrdProp(FObject,PName);
        SetInts(PName,aInt);
      end;
    end;
  end;
  result := True;
end;

procedure TStringListRtti.SaveToObjectNormal(i: Integer);
var
  aStr : string;
  aInt : Integer;
  aInt64 : Int64;
  aFloat : Double;
  s,PName : string;
begin
  PName := string(FProps^[i].Name);
  case FProps^[i].PropType^.Kind of
    tkChar,
    tkWChar,
    tkInteger : begin
      //  Integer型の書き込み
      aInt := GetOrdProp(FObject,PName);
      SetInts(PName,aInt);
    end;
    tkInt64 : begin
      //  Int64型の書き込み
      aInt64 := GetInt64Prop(FObject,PName);
      s := IntToStr(aInt64);
      SetStrs(PName,s);
    end;
    tkString : begin
      //  短い文字列型の書き込み
      aStr := GetStrProp(FObject,PName);
      SetStrs(PName,aStr);
    end;
    tkUString,
    tkLString,
    tkWString : begin
      //  長い文字列型の書き込み
      aStr := GetStrProp(FObject,PName);
      aStr := CommaToMarkText(aStr);
      SetStrs(PName,aStr);
    end;
    tkEnumeration : begin
      //  列挙型の書き込み
      aInt := GetOrdProp(FObject,PName);
      SetInts(PName,aInt);
    end;
    tkSet : begin
      //  集合型の書き込み
      aInt := GetOrdProp(FObject,PName);
      SetInts(PName,aInt);
    end;
    tkFloat : begin
      //  Float型の書き込み
      aFloat := GetFloatProp(FObject,PName);
      aStr := FloatToStr(aFloat);
      SetStrs(PName,aStr);
    end;
  end;
end;

end.
