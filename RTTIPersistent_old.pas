unit RTTIPersistent_old;
{
******************************************************************************

  Unit Name : RTTIPersistentLib
  Purpose   : TPersistent 派生オブジェクトのRTTIベース保存・復元支援ユーティリティ

  概要：
    このユニットは、TPersistent を継承したオブジェクトに対し、RTTI を用いて
    プロパティの保存・復元処理を簡略化するためのクラス群を提供します。
    具体的には、INIファイルなどへの保存／読込、フォームの表示位置保存、
    ジェネリックなオブジェクトリストの永続化などに対応しています。

  主なクラス：
    - TRTTIPersistent       : RTTI による Assign 処理の基底クラス
    - TRTTIPersistentIni    : ファイル保存・読込機能を追加したクラス
    - TRTTIFormPosition     : フォームの位置（Left/Top）を保存・復元
    - TRTTIFormBounds       : 上記に加えてサイズ・WindowState を保存・復元
    - TRTTIPersistentIniList<T> : オブジェクトのリストをファイルで保存・読込

  依存ユニット：
    - StringListRtti       : オブジェクトと TStrings 間のRTTI変換機能
    - StringListEx         : TStrings の拡張（ファイル読込など）
    - StringListKey        : 複数の TStrings をキー付きで管理

******************************************************************************
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,StringListEx,StringListKey,System.Types,System.Generics.Collections,
  TypInfo,System.Rtti;


type
	TRTTIPersistent = class(TPersistent)
	private
		{ Private 宣言 }
    FClassNames : TStringList;
    // Assign 処理の対象にしてよいプロパティかどうかを判定
    function IsPropCopyable(Prop: PPropInfo): Boolean;
    // 指定された PPropInfo を用いて Source から Dest にプロパティの値をコピーする
    procedure CopyPropValue(Dest, Source: TObject; Prop: PPropInfo);
  protected
    // 指定されたプロパティが書き込み可能か
    function PropIsWritable(Prop: PPropInfo): Boolean;virtual;
	public
		{ Public 宣言 }
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source : TPersistent);override;
    property ClassNames: TStringList read FClassNames;
	end;


//--------------------------------------------------------------------------//
//  基本データ保存クラス                                                    //
//--------------------------------------------------------------------------//
type
	TRTTIPersistentIni = class(TRTTIPersistent)
	private
		{ Private 宣言 }
    FFilename: string;

    // INIファイルで誤解される特殊文字を適切にエスケープ する
    function EscapeValueString(const Value: string): string;
    // \n, \=, \;, \\ を元の文字列に戻す
    function UnescapeValueString(const Value: string): string;
    // プロパティの型に応じて Key=Value を TStrings に追加する
    procedure SavePropertyToStrings(const Instance: TPersistent;const Prop: TRttiProperty;
                                      Dest: TStrings);
    // インスタンスを、INI風の文字列リストに保存する
    procedure RTTIPersistentToStrings(Instance: TPersistent; Strings: TStrings);
    // INIから取得した値（文字列）をもとに、プロパティに適切な値を代入する
    procedure LoadPropertyFromStrings(Instance: TPersistent;aProp: TRttiProperty; const aValue: string);
    // TPersistent の任意のサブクラスに対して、TStrings からプロパティ値を復元する
    procedure RTTIPersistentFromStrings(Instance: TPersistent; Strings: TStrings);
    function TrySplitKeyValue(const Line: string; out Key, Value: string): Boolean;
    procedure LoadFromFile;
    procedure SaveToFile;
  protected
    // INIファイルから読み込むデータを文字列リストから取得
    procedure LoadFromStrings(Strings : TStrings);virtual;
    // INIファイルに保存するデータを 文字列リストへ追加
    procedure SaveToStrings(Dest : TStrings);virtual;
	public
		{ Public 宣言 }
    // ファイル読み込み
    //procedure LoadFromFile();virtual;
    // ファイル保存
    //procedure SaveToFile();virtual;
    // 読み込みや保存に使用するファイル名
    property Filename : string read FFilename write FFilename;
	end;

type
  TRTTIPersistentIniList<T: TRTTIPersistentIni, constructor> = class(TObjectList<T>)
  private
    FFilename: string;
  public
    procedure Assign(Source: TObjectList<T>);
    // 要素追加
    function AddNew: T;
    // 要素挿入
    function InsertNew(Index: Integer): T;
    // 要素削除
    procedure DeleteItem(Item: T);
    // 要素入れ替え
    procedure Exchange(Index1, Index2: Integer);
    // ファイル読み込み
    procedure LoadFromFile;
    // ファイル保存
    procedure SaveToFile;

    // 読み込みや保存に使用するファイル名
    property Filename: string read FFilename write FFilename;
  end;

//--------------------------------------------------------------------------//
//  TFormの表示に必要な座標を保存、復元                                     //
//--------------------------------------------------------------------------//
type
	TRTTIFormPosition = class(TRTTIPersistentIni)
	private
		{ Private 宣言 }
    FLeft        : Integer;   //
    FTop         : Integer;
    FMonitor     : Integer;
   function IsWindowPositionVisible(ALeft, ATop: Integer): Boolean;
	public
		{ Public 宣言 }
    // 値を初期化
    procedure InitializeFromForm(aForm : TForm);
    // フォームの座標情報をデータ化
    procedure FormToSelf(aForm : TForm);virtual;
    // データをフォームの情報に復元
    procedure SelfToForm(aForm : TForm);virtual;

  published
    property Monitor   : Integer read FMonitor   write FMonitor;
    property Left   : Integer read FLeft   write FLeft;
    property Top    : Integer read FTop    write FTop;
	end;


//--------------------------------------------------------------------------//
//  TFormの表示に必要な座標を保存、復元                                     //
//--------------------------------------------------------------------------//
type
	TRTTIFormBounds = class(TRTTIFormPosition)
	private
		{ Private 宣言 }
    FWindowState : Integer;   // ウインドウ状態を管理 通常 / 最大化 / 最小化
    FWidth       : Integer;
    FHeight      : Integer;
	public
		{ Public 宣言 }
    // 値を初期化
    procedure InitializeFromForm(aForm : TForm);
    // フォームの座標情報をデータ化
    procedure FormToSelf(aForm : TForm);override;
    // データをフォームの情報に復元
    procedure SelfToForm(aForm : TForm);override;

  published
    property WindowState : Integer read FWindowState write FWindowState;
    property Width  : Integer read FWidth  write FWidth;
    property Height : Integer read FHeight write FHeight;
	end;


implementation

uses StringListRtti;


{ TRTTIFormPosition }

procedure TRTTIFormPosition.InitializeFromForm(aForm: TForm);
begin
  FLeft := Screen.Width  div 2 - aForm.Width div 2;  // 初期値は画面中央に配置されるように計算
  FTop  := Screen.Height div 2 - aForm.Height div 2;
end;

function TRTTIFormPosition.IsWindowPositionVisible(ALeft,  ATop: Integer): Boolean;
var
  R: TRect;
  I: Integer;
begin
  Result := False;
  for I := 0 to Screen.MonitorCount - 1 do begin
    R := Screen.Monitors[I].WorkareaRect;
    if PtInRect(R, Point(ALeft, ATop)) then begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TRTTIFormPosition.SelfToForm(aForm: TForm);
var
  Mon: TMonitor;
  WorkArea: TRect;
  aLeft, aTop: Integer;
begin
  // モニタ番号の妥当性チェック
  if (FMonitor < 0) or (FMonitor >= Screen.MonitorCount) then begin
    FMonitor := Screen.PrimaryMonitor.MonitorNum;
  end;

  Mon := Screen.Monitors[FMonitor];
  WorkArea := Mon.WorkareaRect;

  aLeft := WorkArea.Left + FLeft;
  aTop := WorkArea.Top + FTop;

  // モニタ範囲内かチェック
  if IsWindowPositionVisible(aLeft, aTop) then  begin
    aForm.Left := aLeft;
    aForm.Top := aTop;
  end
  else begin
    // フォールバック：中央に表示
    aForm.Position := poDesktopCenter;
  end;
end;

procedure TRTTIFormPosition.FormToSelf(aForm: TForm);
begin
  FMonitor := Screen.MonitorFromWindow(aForm.Handle, mdNearest).MonitorNum;
  aForm.WindowState := wsNormal;
  FLeft := aForm.Left;
  FTop := aForm.Top;
end;

{ TDMFormPosition }

procedure TRTTIFormBounds.InitializeFromForm(aForm: TForm);
begin
  FLeft := Screen.Width  div 2 - aForm.Width div 2;  // 初期値は画面中央に配置されるように計算
  FTop  := Screen.Height div 2 - aForm.Height div 2;
  FWidth := aForm.Width;
  FHeight :=aForm.Height;
end;

procedure TRTTIFormBounds.SelfToForm(aForm: TForm);
begin
  inherited;
  // 通常状態でサイズを先に設定
  aForm.WindowState := wsNormal;
  aForm.Width := FWidth;
  aForm.Height := FHeight;

  // 最後に状態を復元
  if TWindowState(FWindowState) <> wsNormal then
    aForm.WindowState := TWindowState(FWindowState);
end;

procedure TRTTIFormBounds.FormToSelf(aForm: TForm);
begin
  inherited;
  FWindowState := Ord(aForm.WindowState);

  // 最大化／最小化状態では正しいサイズが取れないため、一時的に復元
  if aForm.WindowState <> wsNormal then
    aForm.WindowState := wsNormal;

  FWidth := aForm.Width;
  FHeight := aForm.Height;
end;


{ TRTTIPersistentIni }


function TRTTIPersistentIni.EscapeValueString(const Value: string): string;
var
  i: Integer;
  ch: Char;
begin
  Result := '';
  for i := 1 to Length(Value) do
  begin
    ch := Value[i];
    case ch of
      '\': Result := Result + '\\';        // バックスラッシュ → エスケープ
      ';': Result := Result + '\;';        // セミコロン → コメント防止
      '=': Result := Result + '\=';        // イコール → key=value の誤認防止
      #13: ;                               // CR は無視（LFとセットで処理）
      #10: Result := Result + '\n';        // LF → 改行表現
    else
      Result := Result + ch;
    end;
  end;
end;

procedure TRTTIPersistentIni.LoadFromFile;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FileName);
    //LoadFromStrings(SL);
  finally
    SL.Free;
  end;
end;

procedure TRTTIPersistentIni.LoadFromStrings(Strings: TStrings);
var
  Line: string;
  i, p: Integer;
  Key, Value: string;
  Ctx: TRttiContext;
  RttiType: TRttiInstanceType; // ← 型を明示的にキャスト;
  Prop: TRttiProperty;
begin
  Ctx := TRttiContext.Create;
  RttiType := Ctx.GetType(Self.ClassType) as TRttiInstanceType;

  for i := 0 to Strings.Count - 1 do
  begin
    Line := Strings[i];
    p := Pos('=', Line);
    if p > 0 then
    begin
      Key := Trim(Copy(Line, 1, p - 1));
      Value := Copy(Line, p + 1, MaxInt);

      // エスケープ解除
      Value := UnescapeValueString(Value);

      Prop := RttiType.GetProperty(Key);
      if Assigned(Prop) and Prop.IsWritable then
        LoadPropertyFromStrings(Self,Prop, Value);
    end;
  end;
end;

procedure TRTTIPersistentIni.LoadPropertyFromStrings(Instance: TPersistent;aProp: TRttiProperty;
  const aValue: string);
var
  Kind: TTypeKind;
  IntVal: Integer;
  BoolVal: Boolean;
  EnumType: PTypeInfo;
  enumValue : Int64;
  tmpSL: TStringList;
  SubObj: TObject;
  Unescaped: string;
begin
  Kind := aProp.PropertyType.TypeKind;

  case Kind of
    tkInteger:
      begin
        IntVal := StrToIntDef(aValue, 0);
        aProp.SetValue(Self, IntVal);
      end;

    tkFloat:
      begin
        aProp.SetValue(Self, StrToFloatDef(aValue, 0));
      end;

    tkEnumeration:
      begin
        enumValue := GetEnumValue(aProp.PropertyType.Handle, aValue);
        if enumValue <> -1 then begin
          aProp.SetValue(Instance, TValue.FromOrdinal(aProp.PropertyType.Handle, enumValue));
        end
        else begin
          EnumType := aProp.PropertyType.Handle;
          BoolVal := SameText(aValue, '1'); // 真偽型の特別処理
          if EnumType^.Name = 'Boolean' then
            aProp.SetValue(Self, BoolVal)
          else
            aProp.SetValue(Self, GetEnumValue(EnumType, aValue));
        end;
      end;

    tkChar, tkWChar, tkString, tkLString, tkWString, tkUString:
      begin
        aProp.SetValue(Self, aValue);
      end;
    tkClass:
      begin
        SubObj := aProp.GetValue(Self).AsObject;
        if Assigned(SubObj) and (SubObj is TPersistent) then
        begin
          Unescaped := UnescapeValueString(aValue);
          tmpSL := TStringList.Create;
          try
            tmpSL.Text := Unescaped;

            if SubObj is TRTTIPersistentIni then
              TRTTIPersistentIni(SubObj).LoadFromStrings(tmpSL)
            else
              //SavePropertyToStrings(TPersistent(SubObj), aProp, tmpSL);

              RTTIPersistentFromStrings(TPersistent(SubObj), tmpSL);

          finally
            tmpSL.Free;
          end;
        end;
      end;
  end;
end;

procedure TRTTIPersistentIni.RTTIPersistentFromStrings(Instance: TPersistent;
  Strings: TStrings);
var
  Ctx: TRttiContext;
  RttiType: TRttiInstanceType; // ← 型を明示的にキャスト;
  RttiProp: TRttiProperty;
  I: Integer;
  Line, Key, ValueStr: string;
  Kind: TTypeKind;
  EnumVal: Integer;
  Obj: TObject;
  tmpSL: TStringList;
begin
  Ctx := TRttiContext.Create;
  try
    RttiType := Ctx.GetType(Instance.ClassType) as TRttiInstanceType;

    for I := 0 to Strings.Count - 1 do
    begin
      Line := Strings[I];
      if Trim(Line) = '' then
        Continue;

      if not TrySplitKeyValue(Line, Key, ValueStr) then
        Continue;

      RttiProp := RttiType.GetProperty(Key);
      if (RttiProp = nil) or (not RttiProp.IsWritable) then
        Continue;

      Kind := RttiProp.PropertyType.TypeKind;

      case Kind of
        tkInteger:
          RttiProp.SetValue(Instance, StrToIntDef(ValueStr, 0));

        tkFloat:
          RttiProp.SetValue(Instance, StrToFloatDef(ValueStr, 0));

        tkEnumeration:
          begin
            EnumVal := GetEnumValue(RttiProp.PropertyType.Handle, ValueStr);
            if EnumVal <> -1 then
              RttiProp.SetValue(Instance, TValue.FromOrdinal(RttiProp.PropertyType.Handle, EnumVal));
          end;

        tkChar, tkWChar, tkString, tkLString, tkWString, tkUString:
          RttiProp.SetValue(Instance, ValueStr);

        tkClass:
          begin
            Obj := RttiProp.GetValue(Instance).AsObject;
            if Assigned(Obj) and (Obj is TPersistent) then
            begin
              tmpSL := TStringList.Create;
              try
                tmpSL.Text := UnescapeValueString(ValueStr);
                RTTIPersistentFromStrings(TPersistent(Obj), tmpSL);
              finally
                tmpSL.Free;
              end;
            end;
          end;
      end;
    end;

  finally
    Ctx.Free;
  end;
end;

procedure TRTTIPersistentIni.RTTIPersistentToStrings(Instance: TPersistent;
  Strings: TStrings);
var
  Ctx: TRttiContext;
  RttiType: TRttiInstanceType; // ← 型を明示的にキャスト;
  Prop: TRttiProperty;
  Value: TValue;
  Line: string;
begin
  if (Instance = nil) or (Strings = nil) then Exit;

  Ctx := TRttiContext.Create;
  try
    RttiType := Ctx.GetType(Instance.ClassType) as TRttiInstanceType;
    for Prop in RttiType.GetProperties do
    begin
      if not Prop.IsReadable then
        Continue;

      Value := Prop.GetValue(Instance);

      if Prop.PropertyType.TypeKind in [tkInteger, tkInt64, tkFloat, tkString, tkUString, tkChar, tkWChar] then
      begin
        Line := Prop.Name + '=' + EscapeValueString(Value.ToString);
        Strings.Add(Line);
      end
      else if Prop.PropertyType.TypeKind = tkEnumeration then
      begin
        // 真偽型含む（Booleanは列挙型の一種）
        Line := Prop.Name + '=' + EscapeValueString(Value.ToString);
        Strings.Add(Line);
      end
      else if (Prop.PropertyType.TypeKind = tkClass) and (Value.AsObject is TPersistent) then
      begin
        // 再帰的に保存（セクションは使わない想定）
        RTTIPersistentToStrings(Value.AsObject as TPersistent, Strings);
      end;
    end;
  finally
    Ctx.Free;
  end;
end;

procedure TRTTIPersistentIni.SavePropertyToStrings(const Instance: TPersistent;
  const Prop: TRttiProperty;  Dest: TStrings);
var
  key, s: string;
  tmpSL: TStringList;
  Value : TValue;
begin
  key := Prop.Name;
  value :=  prop.GetValue(Instance);
  case Prop.PropertyType.TypeKind of
    tkInteger, tkInt64, tkFloat, tkChar, tkWChar,
    tkString, tkLString, tkWString, tkUString:
      begin
        s := Value.ToString;
        s := EscapeValueString(s);
        Dest.Add(key + '=' + s);
      end;

    tkEnumeration:
      begin
        if Prop.PropertyType.Handle = TypeInfo(Boolean) then
        begin
          if Value.AsBoolean then
            s := '1'
          else
            s := '0';
        end
        else
        begin
          s := Value.ToString; // 他の列挙型
        end;

        s := EscapeValueString(s);
        Dest.Add(key + '=' + s);
      end;

    tkClass:
      begin
        if Value.IsObject then
        begin
          tmpSL := TStringList.Create;
          try
            if Value.AsObject is TRTTIPersistentIni then
            begin
              TRTTIPersistentIni(Value.AsObject).SaveToStrings(tmpSL);
            end
            else if Value.AsObject is TPersistent then
            begin
              RTTIPersistentToStrings(TPersistent(Value.AsObject), tmpSL);
            end;
            s := tmpSL.Text;
            s := EscapeValueString(s);
            Dest.Add(key + '=' + s);
          finally
            tmpSL.Free;
          end;
        end;
      end;
  end;
end;

procedure TRTTIPersistentIni.SaveToFile;
var
  SL: TStringList;
begin
  if FFilename = '' then
    raise Exception.Create('SaveToFile: Filename プロパティが未設定です');

  SL := TStringList.Create;
  try
    SaveToStrings(SL); // ← ここが再帰の入口
    SL.SaveToFile(FFilename, TEncoding.UTF8);
  finally
    SL.Free;
  end;
end;

procedure TRTTIPersistentIni.SaveToStrings(Dest: TStrings);
var
  ctx  : TRttiContext;
  typ  : TRttiInstanceType; // ← 型を明示的にキャスト
  prop : TRttiProperty;
//  value  : TValue;
begin
  if Dest = nil then Exit;

  ctx := TRttiContext.Create;
  try
    typ := ctx.GetType(Self.ClassType) as TRttiInstanceType;
    for prop in typ.GetProperties do
    begin
      if (prop.Visibility = mvPublished) and prop.IsReadable and prop.IsWritable then
      begin
        //value := prop.GetValue(Self);
        SavePropertyToStrings(Self, prop, Dest);
      end;
    end;
  finally
    ctx.Free;
  end;
end;

function TRTTIPersistentIni.TrySplitKeyValue(const Line: string; out Key,
  Value: string): Boolean;
var
  P: Integer;
begin
  P := Pos('=', Line);
  Result := P > 0;
  if Result then
  begin
    Key := Copy(Line, 1, P - 1);
    Value := Copy(Line, P + 1, Length(Line) - P);
  end;
end;

function TRTTIPersistentIni.UnescapeValueString(const Value: string): string;
var
  i: Integer;
  ch: Char;
begin
  Result := '';
  i := 1;
  while i <= Length(Value) do
  begin
    ch := Value[i];
    if ch = '\' then
    begin
      Inc(i);
      if i > Length(Value) then
        Break;  // エラー扱いせず終了

      case Value[i] of
        'n': Result := Result + #10;       // 改行
        '=': Result := Result + '=';       // イコール
        ';': Result := Result + ';';       // セミコロン
        '\': Result := Result + '\';       // バックスラッシュ
      else
        // 不明なエスケープはそのまま出力
        Result := Result + '\' + Value[i];
      end;
    end
    else
      Result := Result + ch;
    Inc(i);
  end;
end;

{

procedure TRTTIPersistentIni.LoadFromFile;
var
  tk : TStringListKey;
  sn : string;
  ti : TStringListRtti;
  ts : TStringListEx;
begin
  tk := TStringListKey.Create;
  ti := TStringListRtti.Create;
  ts := TStringListEx.Create;
  try
    sn := FFilename;                     // ファイル名取得
    if not FileExists(sn) then exit;     // 無い場合は処理しない
    ts.LoadFromFile(sn);                 // INIファイル読み込み
    LoadFromStrings(ts);                     // 下位クラスで読み込む
  finally
    ts.Free;
    ti.Free;
    tk.Free
  end;
end;

procedure TRTTIPersistentIni.LoadFromStrings(ts: TStringListEx);
var
  ti : TStringListRtti;
begin
  ti := TStringListRtti.Create;
  try
    if ts<>nil then begin
      ti.Assign(ts);
      ti.LoadFromObject(Self);
    end;
  finally
    ti.Free;
  end;
end;

procedure TRTTIPersistentIni.SaveToFile;
var
  ts : TStringListEx;
  sn : string;
begin
  ts := TStringListEx.Create;
  try
    sn := FFilename;                     // ファイル名取得
    SaveToStrings(ts);
    ts.SaveToFile(sn);
    //SaveToKey(tk);                       // 下位クラスでデータを保存
    //tk.SaveToFile(sn);
  finally
    ts.Free;
  end;
end;

procedure TRTTIPersistentIni.SaveToStrings(ts: TStringListEx);
var
  ti : TStringListRtti;
begin
  ti := TStringListRtti.Create;
  try
    ti.SaveToObject(Self);
    ts.Assign(ti);
  finally
    ti.Free;
  end;
end;

}


{ TRTTIPersistent }

constructor TRTTIPersistent.Create;
begin
  FClassNames := TStringList.Create;
  // ホワイトリストとしての初期クラス名を追加
  FClassNames.Add('TFont');
  FClassNames.Add('TPen');
  FClassNames.Add('TBrush');
  FClassNames.Add('TStringList');
  FClassNames.Add('TStrings');
  // 必要に応じてここに追加
end;

destructor TRTTIPersistent.Destroy;
begin
  FClassNames.Free;
  inherited;
end;

procedure TRTTIPersistent.Assign(Source: TPersistent);
var
  i: Integer;
  Info: PTypeInfo;
  Data: PTypeData;
  Props: PPropList;
  Prop: PPropInfo;
begin
  if not (Source is TRTTIPersistent) then
  begin
    inherited Assign(Source);
    Exit;
  end;

  Info := Self.ClassInfo;
  Data := GetTypeData(Info);
  GetMem(Props, Data^.PropCount * SizeOf(PPropInfo));
  try
    GetPropInfos(Info, Props);
    for i := 0 to Data^.PropCount - 1 do
    begin
      Prop := Props^[i];

      // プロパティが保存対象かつ書き込み可能であることを確認
      if not IsStoredProp(Source, Prop) then  Continue;
      if not PropIsWritable(Prop)       then  Continue;
      // プロパティ値の代入処理
      CopyPropValue(Self, Source, Prop);
    end;
  finally
    FreeMem(Props);
  end;
end;


function TRTTIPersistent.PropIsWritable(Prop: PPropInfo): Boolean;
begin
  Result := Assigned(Prop) and Assigned(Prop^.SetProc);
end;

function TRTTIPersistent.IsPropCopyable(Prop: PPropInfo): Boolean;
var
  Kind: TTypeKind;
begin
  Result := Assigned(Prop) and Assigned(Prop^.GetProc) and Assigned(Prop^.SetProc);
  if Result then
  begin
    Kind := Prop^.PropType^.Kind;
    // コピー可能性のない型を除外（ここでは基本的な除外にとどめる）
    Result := not (Kind in [tkUnknown, tkInterface, tkArray, tkRecord, tkMethod, tkVariant]);
  end;
end;

procedure TRTTIPersistent.CopyPropValue(Dest, Source: TObject; Prop: PPropInfo);
var
  Kind: TTypeKind;
  SourceObj,DestObj: TObject;
begin
  if not Assigned(Prop) or not Assigned(Prop^.GetProc) or not Assigned(Prop^.SetProc) then
    Exit;

  Kind := Prop^.PropType^.Kind;

  case Kind of
    tkInteger, tkChar, tkEnumeration, tkSet:
      SetOrdProp(Dest, Prop, GetOrdProp(Source, Prop));

    tkFloat:
      SetFloatProp(Dest, Prop, GetFloatProp(Source, Prop));

    tkString, tkLString, tkUString, tkWString:
      SetStrProp(Dest, Prop, GetStrProp(Source, Prop));

    tkInt64:
      SetInt64Prop(Dest, Prop, GetInt64Prop(Source, Prop));

    tkClass:
      begin
        // クラス型の場合は再帰的な Assign を試みる
        SourceObj := GetObjectProp(Source, Prop);
        DestObj   := GetObjectProp(Dest, Prop);
        if (SourceObj is TPersistent) and (DestObj is TPersistent) then
          TPersistent(DestObj).Assign(TPersistent(SourceObj))
        else
          SetObjectProp(Dest, Prop, SourceObj);  // 単純参照コピー
      end;

    // 他の型（tkMethod, tkVariantなど）は基本的に無視
  end;
end;


{
procedure TRTTIPersistent.Assign(Source: TPersistent);
var
  a : TRTTIPersistent;
  tk : TStringListRtti;
begin
  if Source is TRTTIPersistent then begin
    a := TRTTIPersistent(Source);
    tk := TStringListRtti.Create;
    try
      tk.SaveToObject(a);
      tk.LoadFromObject(Self);
    finally
      tk.Free;
    end;
  end
  else begin
    inherited;
  end;
end;
}



{ TRTTIPersistentIniList<T> }

function TRTTIPersistentIniList<T>.AddNew: T;
begin
  Result := T.Create; // ← ここがポイント：GenericsのT型をインスタンス化
  Add(Result);        // TObjectList<T> に追加（このクラス自体がTObjectList<T>を継承している）
end;

procedure TRTTIPersistentIniList<T>.Assign(Source: TObjectList<T>);
var
  SrcList: TRTTIPersistentIniList<T>;
  i: Integer;
  Src, Dst: T;
begin
  if Source is TRTTIPersistentIniList<T> then
  begin
    SrcList := TRTTIPersistentIniList<T>(Source);
    Clear;
    for i := 0 to SrcList.Count - 1 do
    begin
      Src := SrcList[i];
      Dst := T.Create;
      Dst.Assign(Src); // ← T が TRTTIPersistentIni を継承しているため可
      Add(Dst);
    end;
  end
  else
    inherited; // 念のため
end;

procedure TRTTIPersistentIniList<T>.DeleteItem(Item: T);
var
  i: Integer;
begin
  i := IndexOf(Item);
  if i >= 0 then
    Delete(i);
end;

procedure TRTTIPersistentIniList<T>.Exchange(Index1, Index2: Integer);
var
  TempOwns: Boolean;
  Temp: T;
begin
  if (Index1 < 0) or (Index1 >= Count) then Exit;
  if (Index2 < 0) or (Index2 >= Count) then Exit;
  if Index1 = Index2 then Exit;

  TempOwns := OwnsObjects;
  OwnsObjects := False;
  try
    Temp := Items[Index1];
    Items[Index1] := Items[Index2];
    Items[Index2] := Temp;
  finally
    OwnsObjects := TempOwns;
  end;
end;

function TRTTIPersistentIniList<T>.InsertNew(Index: Integer): T;
begin
  Result := T.Create;
  Insert(Index, Result);  // TObjectList<T> の Insert を呼ぶ
end;

procedure TRTTIPersistentIniList<T>.LoadFromFile;
var
  tk : TStringListKey;
  sn : string;
  i : Integer;
  ti : TStringListRtti;
  ts : TStringListEx;
  d : TRTTIPersistentIni;
begin
  tk := TStringListKey.Create;
  ti := TStringListRtti.Create;
  try
    sn := FFilename;                   // ファイル名取得
    if not FileExists(sn) then exit;     // 無い場合は処理しない
    tk.LoadFromFile(sn);                 // INIファイル読み込み
    i := 0;
    Clear();
    while True do begin
      ts := tk.Values[IntToStr(i)];
      if ts = nil then break;
      ti.Assign(ts);
      d := AddNew;
      ti.LoadFromObject(d);
      //ti.LoadFromObject(AddNew);
      Inc(i);
    end;
  finally
    ti.Free;
    tk.Free
  end;
end;


procedure TRTTIPersistentIniList<T>.SaveToFile;
var
  tk : TStringListKey;
  ti : TStringListRtti;
  sn : string;
  i: Integer;
begin
  tk := TStringListKey.Create;
  ti := TStringListRtti.Create;
  try
    sn := FFilename;                   // ファイル名取得
    for i := 0 to Count-1 do begin
      ti.SaveToObject(Items[i]);
      tk.Add(IntToStr(i),ti);
    end;
    tk.SaveToFile(sn);
  finally
    ti.Free;
    tk.Free
  end;
end;


end.
