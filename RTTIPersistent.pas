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

  依存ユニット：
    - StringListRtti       : オブジェクトと TStrings 間のRTTI変換機能
    - StringListEx         : TStrings の拡張（ファイル読込など）
    - StringListKey        : 複数の TStrings をキー付きで管理

******************************************************************************
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,StringListEx,StringListKey,System.Types,System.Generics.Collections;


type
	TRTTIPersistent = class(TPersistent)
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
  protected
    // INIファイルから読み込むデータを文字列リストから取得
    procedure LoadFromStrings(ts : TStringListEx);virtual;
    // INIファイルに保存するデータを 文字列リストへ追加
    procedure SaveToStrings(ts : TStringListEx);virtual;
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

uses StringListRtti ;


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
  tk : TStringListKey;
  ts : TStringListEx;
  ti : TStringListRtti;
  sn : string;
begin
  tk := TStringListKey.Create;
  ti := TStringListRtti.Create;
  ts := TStringListEx.Create;
  try
    sn := FFilename;                     // ファイル名取得
    SaveToStrings(ts);
    ts.SaveToFile(sn);
    //SaveToKey(tk);                       // 下位クラスでデータを保存
    //tk.SaveToFile(sn);
  finally
    ts.Free;
    ti.Free;
    tk.Free
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




{ TDMPersistent }

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
