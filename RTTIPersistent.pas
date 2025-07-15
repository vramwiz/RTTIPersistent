unit RTTIPersistent;
{
******************************************************************************

  Unit Name : RTTIPersistentLib
  Purpose   : TPersistent �h���I�u�W�F�N�g��RTTI�x�[�X�ۑ��E�����x�����[�e�B���e�B

  �T�v�F
    ���̃��j�b�g�́ATPersistent ���p�������I�u�W�F�N�g�ɑ΂��ARTTI ��p����
    �v���p�e�B�̕ۑ��E�����������ȗ������邽�߂̃N���X�Q��񋟂��܂��B
    ��̓I�ɂ́AINI�t�@�C���Ȃǂւ̕ۑ��^�Ǎ��A�t�H�[���̕\���ʒu�ۑ��A
    �W�F�l���b�N�ȃI�u�W�F�N�g���X�g�̉i�����ȂǂɑΉ����Ă��܂��B

  ��ȃN���X�F
    - TRTTIPersistent       : RTTI �ɂ�� Assign �����̊��N���X
    - TRTTIPersistentIni    : �t�@�C���ۑ��E�Ǎ��@�\��ǉ������N���X
    - TRTTIFormPosition     : �t�H�[���̈ʒu�iLeft/Top�j��ۑ��E����
    - TRTTIFormBounds       : ��L�ɉ����ăT�C�Y�EWindowState ��ۑ��E����
    - TRTTIPersistentIniList<T> : �I�u�W�F�N�g�̃��X�g���t�@�C���ŕۑ��E�Ǎ�

  �ˑ����j�b�g�F
    - StringListRtti       : �I�u�W�F�N�g�� TStrings �Ԃ�RTTI�ϊ��@�\
    - StringListEx         : TStrings �̊g���i�t�@�C���Ǎ��Ȃǁj
    - StringListKey        : ������ TStrings ���L�[�t���ŊǗ�

******************************************************************************
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,StringListEx,StringListKey,System.Types,System.Generics.Collections;


type
	TRTTIPersistent = class(TPersistent)
	public
		{ Public �錾 }
    procedure Assign(Source : TPersistent);override;
	end;


//--------------------------------------------------------------------------//
//  ��{�f�[�^�ۑ��N���X                                                    //
//--------------------------------------------------------------------------//
type
	TRTTIPersistentIni = class(TRTTIPersistent)
	private
		{ Private �錾 }
    FFilename: string;
  protected
    // INI�t�@�C������ǂݍ��ރf�[�^�𕶎��񃊃X�g����擾
    procedure LoadFromStrings(ts : TStringListEx);virtual;
    // INI�t�@�C���ɕۑ�����f�[�^�� �����񃊃X�g�֒ǉ�
    procedure SaveToStrings(ts : TStringListEx);virtual;
	public
		{ Public �錾 }
    // �t�@�C���ǂݍ���
    procedure LoadFromFile();virtual;
    // �t�@�C���ۑ�
    procedure SaveToFile();virtual;
    // �ǂݍ��݂�ۑ��Ɏg�p����t�@�C����
    property Filename : string read FFilename write FFilename;
	end;

type
  TRTTIPersistentIniList<T: TRTTIPersistentIni, constructor> = class(TObjectList<T>)
  private
    FFilename: string;
  public
    procedure Assign(Source: TObjectList<T>);
    // �v�f�ǉ�
    function AddNew: T;
    // �v�f�}��
    function InsertNew(Index: Integer): T;
    // �v�f�폜
    procedure DeleteItem(Item: T);
    // �v�f����ւ�
    procedure Exchange(Index1, Index2: Integer);
    // �t�@�C���ǂݍ���
    procedure LoadFromFile;
    // �t�@�C���ۑ�
    procedure SaveToFile;

    // �ǂݍ��݂�ۑ��Ɏg�p����t�@�C����
    property Filename: string read FFilename write FFilename;
  end;

//--------------------------------------------------------------------------//
//  TForm�̕\���ɕK�v�ȍ��W��ۑ��A����                                     //
//--------------------------------------------------------------------------//
type
	TRTTIFormPosition = class(TRTTIPersistentIni)
	private
		{ Private �錾 }
    FLeft        : Integer;   //
    FTop         : Integer;
    FMonitor     : Integer;
   function IsWindowPositionVisible(ALeft, ATop: Integer): Boolean;
	public
		{ Public �錾 }
    // �l��������
    procedure InitializeFromForm(aForm : TForm);
    // �t�H�[���̍��W�����f�[�^��
    procedure FormToSelf(aForm : TForm);virtual;
    // �f�[�^���t�H�[���̏��ɕ���
    procedure SelfToForm(aForm : TForm);virtual;

  published
    property Monitor   : Integer read FMonitor   write FMonitor;
    property Left   : Integer read FLeft   write FLeft;
    property Top    : Integer read FTop    write FTop;
	end;


//--------------------------------------------------------------------------//
//  TForm�̕\���ɕK�v�ȍ��W��ۑ��A����                                     //
//--------------------------------------------------------------------------//
type
	TRTTIFormBounds = class(TRTTIFormPosition)
	private
		{ Private �錾 }
    FWindowState : Integer;   // �E�C���h�E��Ԃ��Ǘ� �ʏ� / �ő剻 / �ŏ���
    FWidth       : Integer;
    FHeight      : Integer;
	public
		{ Public �錾 }
    // �l��������
    procedure InitializeFromForm(aForm : TForm);
    // �t�H�[���̍��W�����f�[�^��
    procedure FormToSelf(aForm : TForm);override;
    // �f�[�^���t�H�[���̏��ɕ���
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
  FLeft := Screen.Width  div 2 - aForm.Width div 2;  // �����l�͉�ʒ����ɔz�u�����悤�Ɍv�Z
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
  // ���j�^�ԍ��̑Ó����`�F�b�N
  if (FMonitor < 0) or (FMonitor >= Screen.MonitorCount) then begin
    FMonitor := Screen.PrimaryMonitor.MonitorNum;
  end;

  Mon := Screen.Monitors[FMonitor];
  WorkArea := Mon.WorkareaRect;

  aLeft := WorkArea.Left + FLeft;
  aTop := WorkArea.Top + FTop;

  // ���j�^�͈͓����`�F�b�N
  if IsWindowPositionVisible(aLeft, aTop) then  begin
    aForm.Left := aLeft;
    aForm.Top := aTop;
  end
  else begin
    // �t�H�[���o�b�N�F�����ɕ\��
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
  FLeft := Screen.Width  div 2 - aForm.Width div 2;  // �����l�͉�ʒ����ɔz�u�����悤�Ɍv�Z
  FTop  := Screen.Height div 2 - aForm.Height div 2;
  FWidth := aForm.Width;
  FHeight :=aForm.Height;
end;

procedure TRTTIFormBounds.SelfToForm(aForm: TForm);
begin
  inherited;
  // �ʏ��ԂŃT�C�Y���ɐݒ�
  aForm.WindowState := wsNormal;
  aForm.Width := FWidth;
  aForm.Height := FHeight;

  // �Ō�ɏ�Ԃ𕜌�
  if TWindowState(FWindowState) <> wsNormal then
    aForm.WindowState := TWindowState(FWindowState);
end;

procedure TRTTIFormBounds.FormToSelf(aForm: TForm);
begin
  inherited;
  FWindowState := Ord(aForm.WindowState);

  // �ő剻�^�ŏ�����Ԃł͐������T�C�Y�����Ȃ����߁A�ꎞ�I�ɕ���
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
    sn := FFilename;                     // �t�@�C�����擾
    if not FileExists(sn) then exit;     // �����ꍇ�͏������Ȃ�
    ts.LoadFromFile(sn);                 // INI�t�@�C���ǂݍ���
    LoadFromStrings(ts);                     // ���ʃN���X�œǂݍ���
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
    sn := FFilename;                     // �t�@�C�����擾
    SaveToStrings(ts);
    ts.SaveToFile(sn);
    //SaveToKey(tk);                       // ���ʃN���X�Ńf�[�^��ۑ�
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
  Result := T.Create; // �� �������|�C���g�FGenerics��T�^���C���X�^���X��
  Add(Result);        // TObjectList<T> �ɒǉ��i���̃N���X���̂�TObjectList<T>���p�����Ă���j
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
      Dst.Assign(Src); // �� T �� TRTTIPersistentIni ���p�����Ă��邽�߉�
      Add(Dst);
    end;
  end
  else
    inherited; // �O�̂���
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
  Insert(Index, Result);  // TObjectList<T> �� Insert ���Ă�
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
    sn := FFilename;                   // �t�@�C�����擾
    if not FileExists(sn) then exit;     // �����ꍇ�͏������Ȃ�
    tk.LoadFromFile(sn);                 // INI�t�@�C���ǂݍ���
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
    sn := FFilename;                   // �t�@�C�����擾
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
