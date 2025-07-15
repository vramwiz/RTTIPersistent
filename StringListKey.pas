//**********************************************************************//
//                                                                      //
//  １つのTStringListからキーを使って複数のTStringListを管理するクラス  //
//                                                                      //
//**********************************************************************//
unit StringListKey;

interface

uses
	Windows,Messages, SysUtils, Classes, Graphics, Controls,StdCtrls, ExtCtrls,
  StringListEx;

//--------------------------------------------------------------------------//
//  キーを管理するクラス                                                    //
//--------------------------------------------------------------------------//
type
	TStringListKey = class(TPersistent)
	private
		{ Private 宣言 }
    FKeys: TStringList;           // キーの一覧
    FValues: TList;               // 内容の管理
    function GetKeyValues(Key: string): TStringListEx;
	public
		{ Public 宣言 }
    constructor Create;
    destructor Destroy; override;
    function LoadFromFile(const FileName: string) : Boolean;
    function SaveToFile(const FileName: string) : Boolean;
    procedure StringsToKeys(t : TStringList);
    procedure KeysToStrings(t : TStringList);
    procedure Add(Key : string;Value : TStringList);
    procedure Delete(Key : string);
    procedure Clear();
    property Keys : TStringList read FKeys;
    property Values[Key : string] : TStringListEx read GetKeyValues;
  end;

implementation

{ TStringListKey }

//**************************************************************************//
//                                                                          //
//  ～　クラス生成イベント　～                                              //
//                                                                          //
//   - Input -  なし                                                        //
//   - Output - なし                                                        //
//                                                                          //
//**************************************************************************//
constructor TStringListKey.Create;
begin
  FKeys   := TStringList.Create;
  FValues := TList.Create;
end;

//**************************************************************************//
//                                                                          //
//  ～　クラス破棄イベント　～                                              //
//                                                                          //
//   - Input -  なし                                                        //
//   - Output - なし                                                        //
//                                                                          //
//**************************************************************************//
destructor TStringListKey.Destroy;
var
  i : Integer;
begin
  for i := 0 to FValues.Count - 1 do begin
    TStringList(FValues[i]).Free
  end;
  FValues.Clear;
  FValues.Free;
  FKeys.Free;
  inherited;
end;

function TStringListKey.GetKeyValues(Key: string): TStringListEx;
var
  i : Integer;
begin
  result := nil;
  i := FKeys.IndexOf(Key);
  if i < 0 then exit;
  result := FValues[i];
end;

//**************************************************************************//
//                                                                          //
//  ～　キーと値をTStringList形式に変換　～                                 //
//                                                                          //
//   - Input -  t : 出力するクラス                                          //
//                                                                          //
//   - Output - なし                                                        //
//                                                                          //
//**************************************************************************//
procedure TStringListKey.KeysToStrings(t: TStringList);
var
  i,j : Integer;
  t2 : TStringList;
  s : string;
begin
  t.Clear;
  for i := 0 to FKeys.Count-1 do begin
    t.Add('[' + FKeys[i] + ']');
    t2 := TStringList(FValues[i]);
    for j := 0 to t2.Count-1 do begin
      s := t2[j];
      t.Add(t2[j]);
    end;
  end;
  s := t.Text;
  s := s;
end;

//**************************************************************************//
//                                                                          //
//  ～　TStringList形式からキーと値を作成　～                               //
//                                                                          //
//   - Input -  t : 変換するクラス                                          //
//                                                                          //
//   - Output - なし                                                        //
//                                                                          //
//**************************************************************************//
procedure TStringListKey.StringsToKeys(t: TStringList);
var
  s,sk : string;
  i,j,k : Integer;
  f : Boolean;
  t2 : TStringListEx;
begin
  Clear();
  f := False;
  j := 0;
  for i := 0 to t.Count-1 do begin
    s := t.Strings[i];
    if Length(s) = 0 then continue;
    if s[1] = '[' then begin
      if Length(s) > 2 then begin
        sk := Copy(s,2,Length(s)-2);
        FKeys.Add(sk);
        if f then begin
          t2 := TStringListEx.Create;
          for k := j to i-1 do begin
            t2.Add(t[k]);
          end;
          FValues.Add(Pointer(t2));
        end;
        j := i + 1;
        f := True;
      end;
    end;
  end;
  if f then begin
    t2 := TStringListEx.Create;
    t2.Clear;
    for k := j to t.Count-1 do begin
      t2.Add(t[k]);
    end;
    FValues.Add(Pointer(t2));
  end;

end;

//**************************************************************************//
//                                                                          //
//  ～　ファイルから読み込む　～                                            //
//                                                                          //
//   - Input -  FileName : 読み込みファイル名                               //
//                                                                          //
//   - Output - なし                                                        //
//                                                                          //
//**************************************************************************//
function TStringListKey.LoadFromFile(const FileName: string) : Boolean;
var
  t : TStringList;
begin
  t := TStringList.Create;
  try
    result := False;
    t.LoadFromFile(FileName);      // ファイルを読み込む
    StringsToKeys(t);              // キーと値との形式に変換
    result := True;
  finally
    t.Free;
  end;
end;

//**************************************************************************//
//                                                                          //
//  ～　ファイルに書き込む　～                                              //
//                                                                          //
//   - Input -  FileName : 書き込むファイル名                               //
//                                                                          //
//   - Output - なし                                                        //
//                                                                          //
//**************************************************************************//
function TStringListKey.SaveToFile(const FileName: string) : Boolean;
var
  t : TStringList;
begin
  t := TStringList.Create;
  try
    result := False;
    KeysToStrings(t);            // StringList形式に変換
    t.SaveToFile(FileName,TEncoding.UTF8);      // ファイルに書き込む
    result := True;
  finally
    t.Free;
  end;
end;

//**************************************************************************//
//                                                                          //
//  ～　新しい値を追加　～                                                  //
//                                                                          //
//   - Input -  Key   : 追加するキー                                        //
//              Value : 追加する内容                                        //
//                                                                          //
//   - Output - なし                                                        //
//                                                                          //
//**************************************************************************//
procedure TStringListKey.Add(Key: string; Value: TStringList);
var
  i : Integer;
  t : TStringListEx;
begin
  i := FKeys.IndexOf(Key);
  if i < 0 then begin
    FKeys.Add(Key);
    t := TStringListEx.Create;
    t.Assign(Value);
    FValues.Add(Pointer(t));
  end
  else begin
    TStringList(FValues[i]).Assign(Value);
  end;
end;

//**************************************************************************//
//                                                                          //
//  ～　キーを削除　～                                                      //
//                                                                          //
//   - Input -  Key   : 削除するキー                                        //
//                                                                          //
//   - Output - なし                                                        //
//                                                                          //
//**************************************************************************//
procedure TStringListKey.Delete(Key: string);
var
  i : Integer;
begin
  i := FKeys.IndexOf(Key);
  if i = -1 then exit;
  FKeys.Delete(i);
  TStringList(FValues[i]).Free;
  FValues.Delete(i);

end;

//**************************************************************************//
//                                                                          //
//  ～　全てのキーと値を初期化　～                                          //
//                                                                          //
//   - Input -  なし                                                        //
//   - Output - なし                                                        //
//                                                                          //
//**************************************************************************//
procedure TStringListKey.Clear;
var
  i : Integer;
begin
  FKeys.Clear;
  for i := 0 to FValues.Count - 1 do begin
    TStringList(FValues[i]).Free
  end;
  FValues.Clear;
end;

end.
