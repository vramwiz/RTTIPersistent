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
		{ Private �錾 }
    // �w�肳�ꂽ PPropInfo ��p���� Source ���� Dest �Ƀv���p�e�B�̒l���R�s�[����
    procedure CopyPropValue(Dest, Source: TObject; Prop: PPropInfo);
  protected
    // �w�肳�ꂽ�v���p�e�B���������݉\��
    function PropIsWritable(Prop: PPropInfo): Boolean;virtual;
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
    // Instance��Ini�`���ŃV���A���C�Y������ Dest�ɏo��
    procedure SerializeToStrings(Instance: TPersistent; Dest: TStrings);
    // Ini�`���̕����񃊃X�g����Instance�ɓ���
    procedure DeserializeFromStrings(Instance: TPersistent; const Src: TStrings);
    // INI�t�@�C���Ō���������ꕶ����K�؂ɃG�X�P�[�v ����
    function EscapeValueString(const Value: string): string;
    // \n, \=, \;, \\ �����̕�����ɖ߂�
    function UnescapeValueString(const Value: string): string;
  protected
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
    SerializeToStrings(Self,SL);         // ���g���V���A���C�Y��
    SL.SaveToFile(FFilename);            // ���t�@�C���ɕۑ�
  finally
    SL.Free;
  end;
end;


procedure TRTTIPersistentIni.SerializeToStrings(Instance: TPersistent;
  Dest: TStrings);
var
  ctx: TRttiContext;
  typ: TRttiInstanceType; // �� �^�𖾎��I�ɃL���X�g;
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
                SerializeToStrings(TRTTIPersistentIni(val.AsObject), tmpSL) // �ċA�I
              else
                SerializeToStrings(TPersistent(val.AsObject), tmpSL); // �ėp�ϊ�
              }
              SerializeToStrings(TPersistent(val.AsObject), tmpSL); // �ċA�I
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
  typ: TRttiInstanceType; // �� �^�𖾎��I�ɃL���X�g;
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
                DeserializeFromStrings(TPersistent(SubObj), tmpSL); // �ċA�I
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
      '\': Result := Result + '\\';        // �o�b�N�X���b�V�� �� �G�X�P�[�v
      ';': Result := Result + '\;';        // �Z�~�R���� �� �R�����g�h�~
      '=': Result := Result + '\=';        // �C�R�[�� �� key=value �̌�F�h�~
      #13: ;                               // CR �͖����iLF�ƃZ�b�g�ŏ����j
      #10: Result := Result + '\n';        // LF �� ���s�\��
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
        Break;  // �G���[���������I��

      case Value[i] of
        'n': Result := Result + #10;       // ���s
        '=': Result := Result + '=';       // �C�R�[��
        ';': Result := Result + ';';       // �Z�~�R����
        '\': Result := Result + '\';       // �o�b�N�X���b�V��
      else
        // �s���ȃG�X�P�[�v�͂��̂܂܏o��
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

      // �v���p�e�B���ۑ��Ώۂ��������݉\�ł��邱�Ƃ��m�F
      if not IsStoredProp(Source, Prop) then  Continue;
      if not PropIsWritable(Prop)       then  Continue;
      // �v���p�e�B�l�̑������
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
        // �N���X�^�̏ꍇ�͍ċA�I�� Assign �����݂�
        SourceObj := GetObjectProp(Source, Prop);
        DestObj   := GetObjectProp(Dest, Prop);
        if (SourceObj is TPersistent) and (DestObj is TPersistent) then
          TPersistent(DestObj).Assign(TPersistent(SourceObj))
        else
          SetObjectProp(Dest, Prop, SourceObj);  // �P���Q�ƃR�s�[
      end;

    // ���̌^�itkMethod, tkVariant�Ȃǁj�͊�{�I�ɖ���
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
        // �Z�N�V�����J�n �� ����܂ł̓��e��o�^
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

    // �Ō�̗v�f���ǉ�
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
      SL.Add(SectionName);                   // �Z�N�V�������o��

      ItemSL.Clear;
      Item.SerializeToStrings(Item,ItemSL);  // ���O��RTTI�֐��ŏo��
      SL.AddStrings(ItemSL);
    end;

    SL.SaveToFile(FFilename, TEncoding.UTF8);
  finally
    ItemSL.Free;
    SL.Free;
  end;
end;


end.
