unit RTTIPersistent_old;
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
  StdCtrls, ExtCtrls,StringListEx,StringListKey,System.Types,System.Generics.Collections,
  TypInfo,System.Rtti;


type
	TRTTIPersistent = class(TPersistent)
	private
		{ Private �錾 }
    FClassNames : TStringList;
    // Assign �����̑Ώۂɂ��Ă悢�v���p�e�B���ǂ����𔻒�
    function IsPropCopyable(Prop: PPropInfo): Boolean;
    // �w�肳�ꂽ PPropInfo ��p���� Source ���� Dest �Ƀv���p�e�B�̒l���R�s�[����
    procedure CopyPropValue(Dest, Source: TObject; Prop: PPropInfo);
  protected
    // �w�肳�ꂽ�v���p�e�B���������݉\��
    function PropIsWritable(Prop: PPropInfo): Boolean;virtual;
	public
		{ Public �錾 }
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source : TPersistent);override;
    property ClassNames: TStringList read FClassNames;
	end;


//--------------------------------------------------------------------------//
//  ��{�f�[�^�ۑ��N���X                                                    //
//--------------------------------------------------------------------------//
type
	TRTTIPersistentIni = class(TRTTIPersistent)
	private
		{ Private �錾 }
    FFilename: string;

    // INI�t�@�C���Ō���������ꕶ����K�؂ɃG�X�P�[�v ����
    function EscapeValueString(const Value: string): string;
    // \n, \=, \;, \\ �����̕�����ɖ߂�
    function UnescapeValueString(const Value: string): string;
    // �v���p�e�B�̌^�ɉ����� Key=Value �� TStrings �ɒǉ�����
    procedure SavePropertyToStrings(const Instance: TPersistent;const Prop: TRttiProperty;
                                      Dest: TStrings);
    // �C���X�^���X���AINI���̕����񃊃X�g�ɕۑ�����
    procedure RTTIPersistentToStrings(Instance: TPersistent; Strings: TStrings);
    // INI����擾�����l�i������j�����ƂɁA�v���p�e�B�ɓK�؂Ȓl��������
    procedure LoadPropertyFromStrings(Instance: TPersistent;aProp: TRttiProperty; const aValue: string);
    // TPersistent �̔C�ӂ̃T�u�N���X�ɑ΂��āATStrings ����v���p�e�B�l�𕜌�����
    procedure RTTIPersistentFromStrings(Instance: TPersistent; Strings: TStrings);
    function TrySplitKeyValue(const Line: string; out Key, Value: string): Boolean;
    procedure LoadFromFile;
    procedure SaveToFile;
  protected
    // INI�t�@�C������ǂݍ��ރf�[�^�𕶎��񃊃X�g����擾
    procedure LoadFromStrings(Strings : TStrings);virtual;
    // INI�t�@�C���ɕۑ�����f�[�^�� �����񃊃X�g�֒ǉ�
    procedure SaveToStrings(Dest : TStrings);virtual;
	public
		{ Public �錾 }
    // �t�@�C���ǂݍ���
    //procedure LoadFromFile();virtual;
    // �t�@�C���ۑ�
    //procedure SaveToFile();virtual;
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

uses StringListRtti;


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
  RttiType: TRttiInstanceType; // �� �^�𖾎��I�ɃL���X�g;
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

      // �G�X�P�[�v����
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
          BoolVal := SameText(aValue, '1'); // �^�U�^�̓��ʏ���
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
  RttiType: TRttiInstanceType; // �� �^�𖾎��I�ɃL���X�g;
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
  RttiType: TRttiInstanceType; // �� �^�𖾎��I�ɃL���X�g;
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
        // �^�U�^�܂ށiBoolean�͗񋓌^�̈��j
        Line := Prop.Name + '=' + EscapeValueString(Value.ToString);
        Strings.Add(Line);
      end
      else if (Prop.PropertyType.TypeKind = tkClass) and (Value.AsObject is TPersistent) then
      begin
        // �ċA�I�ɕۑ��i�Z�N�V�����͎g��Ȃ��z��j
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
          s := Value.ToString; // ���̗񋓌^
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
    raise Exception.Create('SaveToFile: Filename �v���p�e�B�����ݒ�ł�');

  SL := TStringList.Create;
  try
    SaveToStrings(SL); // �� �������ċA�̓���
    SL.SaveToFile(FFilename, TEncoding.UTF8);
  finally
    SL.Free;
  end;
end;

procedure TRTTIPersistentIni.SaveToStrings(Dest: TStrings);
var
  ctx  : TRttiContext;
  typ  : TRttiInstanceType; // �� �^�𖾎��I�ɃL���X�g
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
  ts : TStringListEx;
  sn : string;
begin
  ts := TStringListEx.Create;
  try
    sn := FFilename;                     // �t�@�C�����擾
    SaveToStrings(ts);
    ts.SaveToFile(sn);
    //SaveToKey(tk);                       // ���ʃN���X�Ńf�[�^��ۑ�
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
  // �z���C�g���X�g�Ƃ��Ă̏����N���X����ǉ�
  FClassNames.Add('TFont');
  FClassNames.Add('TPen');
  FClassNames.Add('TBrush');
  FClassNames.Add('TStringList');
  FClassNames.Add('TStrings');
  // �K�v�ɉ����Ă����ɒǉ�
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

function TRTTIPersistent.IsPropCopyable(Prop: PPropInfo): Boolean;
var
  Kind: TTypeKind;
begin
  Result := Assigned(Prop) and Assigned(Prop^.GetProc) and Assigned(Prop^.SetProc);
  if Result then
  begin
    Kind := Prop^.PropType^.Kind;
    // �R�s�[�\���̂Ȃ��^�����O�i�����ł͊�{�I�ȏ��O�ɂƂǂ߂�j
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
