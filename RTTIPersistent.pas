unit RTTIPersistent;
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

******************************************************************************
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,System.Types,System.Generics.Collections,
  TypInfo,System.Rtti;


type
	TRTTIPersistent = class(TPersistent)
	private
		{ Private 宣言 }
    // 指定された PPropInfo を用いて Source から Dest にプロパティの値をコピーする
    procedure CopyPropValue(Dest, Source: TObject; Prop: PPropInfo);
  protected
    // 指定されたプロパティが書き込み可能か
    function PropIsWritable(Prop: PPropInfo): Boolean;virtual;
	public
		{ Public 宣言 }
    procedure Assign(Source : TPersistent);override;
	end;


//--------------------------------------------------------------------------//
//  基本データ保存クラス                                                    //
//--------------------------------------------------------------------------//
type
	TRTTIPersistentIni = class(TRTTIPersistent)
	private
		{ Private 宣言 }
    FFilename: string;
    // InstanceをIni形式でシリアライズ化して Destに出力
    procedure SerializeToStrings(Instance: TPersistent; Dest: TStrings);
    // Ini形式の文字列リストからInstanceに入力
    procedure DeserializeFromStrings(Instance: TPersistent; const Src: TStrings);
    // INIファイルで誤解される特殊文字を適切にエスケープ する
    function EscapeValueString(const Value: string): string;
    // \n, \=, \;, \\ を元の文字列に戻す
    function UnescapeValueString(const Value: string): string;
  protected
	public
		{ Public 宣言 }
    // ファイル読み込み
    procedure LoadFromFile();virtual;
    // ファイル保存
    procedure SaveToFile();virtual;
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


procedure TRTTIPersistentIni.LoadFromFile;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FFilename, TEncoding.UTF8);
    DeserializeFromStrings(Self, SL);
  finally
    SL.Free;
  end;
end;

procedure TRTTIPersistentIni.SaveToFile;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SerializeToStrings(Self,SL);         // 自身をシリアライズ化
    SL.SaveToFile(FFilename);            // 実ファイルに保存
  finally
    SL.Free;
  end;
end;


procedure TRTTIPersistentIni.SerializeToStrings(Instance: TPersistent;
  Dest: TStrings);
var
  ctx: TRttiContext;
  typ: TRttiInstanceType; // ← 型を明示的にキャスト;
  prop: TRttiProperty;
  val: TValue;
  tmpSL: TStringList;
  s: string;
begin
  ctx := TRttiContext.Create;
  try
    typ := ctx.GetType(Instance.ClassType) as TRttiInstanceType;
    for prop in typ.GetProperties do
    begin
      if not prop.IsReadable or not prop.IsWritable then Continue;
      val := prop.GetValue(Instance);

      case prop.PropertyType.TypeKind of
        tkInteger, tkFloat, tkEnumeration,
        tkChar, tkWChar, tkString, tkLString, tkWString, tkUString:
          Dest.Add(prop.Name + '=' + TRTTIPersistentIni(Instance).EscapeValueString(val.ToString));

        tkClass:
          if val.IsObject and (val.AsObject is TPersistent) then
          begin
            tmpSL := TStringList.Create;
            try
              {
              if val.AsObject is TRTTIPersistentIni then
                SerializeToStrings(TRTTIPersistentIni(val.AsObject), tmpSL) // 再帰！
              else
                SerializeToStrings(TPersistent(val.AsObject), tmpSL); // 汎用変換
              }
              SerializeToStrings(TPersistent(val.AsObject), tmpSL); // 再帰！
              s := tmpSL.Text;
              s := TRTTIPersistentIni(Instance).EscapeValueString(s);
              Dest.Add(prop.Name + '=' + s);
            finally
              tmpSL.Free;
            end;
          end;
      end;
    end;
  finally
    ctx.Free;
  end;
end;

procedure TRTTIPersistentIni.DeserializeFromStrings(Instance: TPersistent;
  const Src: TStrings);
var
  ctx       : TRttiContext;
  typ: TRttiInstanceType; // ← 型を明示的にキャスト;
  prop      : TRttiProperty;
  I, P      : Integer;
  Line      : string;
  Key       : string;
  ValueStr  : string;
  Kind      : TTypeKind;
  SubObj    : TObject;
  tmpSL     : TStringList;
  EnumVal   : Integer;
begin
  ctx := TRttiContext.Create;
  try
    typ := ctx.GetType(Instance.ClassType) as TRttiInstanceType;

    for I := 0 to Src.Count - 1 do
    begin
      Line := Trim(Src[I]);
      if Line = '' then Continue;

      P := Pos('=', Line);
      if P <= 0 then Continue;

      Key := Trim(Copy(Line, 1, P - 1));
      ValueStr := Copy(Line, P + 1, MaxInt);
      ValueStr := TRTTIPersistentIni(Instance).UnescapeValueString(ValueStr);

      prop := typ.GetProperty(Key);
      if (prop = nil) or (not prop.IsWritable) then Continue;

      Kind := prop.PropertyType.TypeKind;

      case Kind of
        tkInteger:
          prop.SetValue(Instance, StrToIntDef(ValueStr, 0));

        tkInt64:
          prop.SetValue(Instance, StrToInt64Def(ValueStr, 0));

        tkFloat:
          prop.SetValue(Instance, StrToFloatDef(ValueStr, 0));

        tkEnumeration:
          begin
            EnumVal := GetEnumValue(prop.PropertyType.Handle, ValueStr);
            if EnumVal <> -1 then
              prop.SetValue(Instance, TValue.FromOrdinal(prop.PropertyType.Handle, EnumVal));
          end;

        tkChar, tkWChar, tkString, tkLString, tkWString, tkUString:
          prop.SetValue(Instance, ValueStr);

        tkClass:
          begin
            SubObj := prop.GetValue(Instance).AsObject;
            if Assigned(SubObj) and (SubObj is TPersistent) then
            begin
              tmpSL := TStringList.Create;
              try
                tmpSL.Text := ValueStr;
                DeserializeFromStrings(TPersistent(SubObj), tmpSL); // 再帰！
              finally
                tmpSL.Free;
              end;
            end;
          end;
      end;
    end;

  finally
    ctx.Free;
  end;
end;

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


{ TRTTIPersistent }

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
  SL, ItemSL: TStringList;
  i: Integer;
  Line: string;
  Item: T;
begin
  SL := TStringList.Create;
  ItemSL := TStringList.Create;
  try
    SL.LoadFromFile(FFilename, TEncoding.UTF8);
    Clear;

    for i := 0 to SL.Count - 1 do
    begin
      Line := SL[i].Trim;
      if (Line <> '') and (Line[1] = '[') then
      begin
        // セクション開始 → それまでの内容を登録
        if ItemSL.Count > 0 then
        begin
          Item := AddNew;
          Item.DeserializeFromStrings(Item, ItemSL);
          ItemSL.Clear;
        end;
      end
      else
        ItemSL.Add(Line);
    end;

    // 最後の要素も追加
    if ItemSL.Count > 0 then
    begin
      Item := AddNew;
      Item.DeserializeFromStrings(Item, ItemSL);
    end;

  finally
    ItemSL.Free;
    SL.Free;
  end;
end;


procedure TRTTIPersistentIniList<T>.SaveToFile;
var
  SL, ItemSL: TStringList;
  i: Integer;
  SectionName: string;
  Item: T;
begin
  SL := TStringList.Create;
  ItemSL := TStringList.Create;
  try
    for i := 0 to Count - 1 do
    begin
      Item := Items[i];
      SectionName := Format('[%d]', [i]);
      SL.Add(SectionName);                   // セクション見出し

      ItemSL.Clear;
      Item.SerializeToStrings(Item,ItemSL);  // 自前のRTTI関数で出力
      SL.AddStrings(ItemSL);
    end;

    SL.SaveToFile(FFilename, TEncoding.UTF8);
  finally
    ItemSL.Free;
    SL.Free;
  end;
end;


end.
