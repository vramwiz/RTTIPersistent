unit StringListRtti;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,StringListEx,TypInfo;


//--------------------------------------------------------------------------//
//  �g��TPersistent�N���X�iDefineProperties���\�b�h�̋������J�j             //
//--------------------------------------------------------------------------//
type  TPersistentEx = class(TPersistent);


//--------------------------------------------------------------------------//
//  ���s���^���𗘗p�����I�u�W�F�N�g�̕ۑ��Ɠǂݍ��݂���N���X            //
//--------------------------------------------------------------------------//
type
// �^���
  TRttiType = (rtNormal,rtBoolean,rtImitation,rtComponent,rtClass,rtCollection,rtRootClass);
	TStringListRtti = class(TStringListEx)
	private
		{ Private �錾 }
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
		{ Public �錾 }
    // Key=Value �`���̕����񃊃X�g���w�肳�ꂽ�I�u�W�F�N�g�̕ϐ��ɏ�������
    function LoadFromObject(aObject : TObject) : Boolean;
    // �w�肳�ꂽ�I�u�W�F�N�g����͂��� Key=Value�`���̕����񃊃X�g�ɂ���
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
      // �U�v���p�e�B�̏���
      result := rtImitation;
    end
    else if GetObjectProp(FObject,PName) <> nil then begin
      // �N���X�̏���
      if GetObjectProp(FObject,PName) is TComponent then begin
        // TComponent����̔h���N���X�̂Ƃ�
        result := rtComponent;
      end
      else begin
        // TComponent�ȊO����̔h���N���X�̂Ƃ�
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
          //  ���s���^��񂩂琔�l�^�̓ǂݍ���
          aInt := GetOrdProp(FObject,PName);
          //  Ini�t�@�C������Integer�^�̓ǂݍ��� �t�@�C���ɖ����ꍇ�����l���̗p ��2025/06/30
          aInt := GetInts(PName,aInt);
          SetOrdProp(FObject,p,aInt);
        end;
        tkString : begin
          //  �Z��������^�̏�������
          aStr := GetStrProp(FObject,PName);
          //  Ini�t�@�C������String�^�̓ǂݍ��� �t�@�C���ɖ����ꍇ�����l���̗p ��2025/06/30
          aStr := GetStrs(PName,aStr);
          aStr := MarkTextToComma(aStr);
          SetStrProp(FObject,p,aStr);
        end;
        tkUString,
        tkLString,
        tkWString : begin
          //  ���s���^��񂩂璷��������^�̓ǂݍ���
          aStr := GetStrProp(FObject,PName);
          //  Ini�t�@�C������String�^�̓ǂݍ��� �t�@�C���ɖ����ꍇ�����l���̗p ��2025/06/30
          aStr := GetStrs(PName,aStr);
          aStr := MarkTextToComma(aStr);
          SetStrProp(FObject,p,aStr);
        end;
        tkFloat : begin
          //  ���s���^��񂩂�Float�^�̓ǂݍ���
           aFloat := GetFloatProp(FObject,PName);
           //  Ini�t�@�C������Float�^�̓ǂݍ��� �t�@�C���ɖ����ꍇ�����l���̗p ��2025/06/30
           aFloat := GetFloats(PName,aFloat);
           SetFloatProp(FObject,p,aFloat);
        end;
        tkInt64 : begin
          //  ���s���^��񂩂�Int64�^�̓ǂݍ���
          aInt64 := GetInt64Prop(FObject,PName);
          //  Ini�t�@�C������Int64�^�̓ǂݍ��� �t�@�C���ɖ����ꍇ�����l���̗p ��2025/06/30
          aStr := GetStrs(PName,'');
          aInt64 := StrToInt64Def(aStr,aInt64);
          SetInt64Prop(FObject,p,aInt64);
        end;
        tkEnumeration : begin
          //  ���s���^��񂩂�񋓌^�̓ǂݍ���
          aInt := GetOrdProp(FObject,PName);
          //  Ini�t�@�C������񋓌^�̓ǂݍ���  �t�@�C���ɖ����ꍇ�����l���̗p ��2025/06/30
          aByte := GetInts(PName,aInt);
          SetOrdProp(FObject,p,aByte);
        end;
        tkSet : begin
          //  ���s���^��񂩂�W���^�̓ǂݍ���
          aInt := GetOrdProp(FObject,PName);
          //  Ini�t�@�C������W���^�̓ǂݍ���  �t�@�C���ɖ����ꍇ�����l���̗p ��2025/06/30
          aInt := GetInts(PName,aInt);
          SetOrdProp(FObject,p,aInt);
        end;
      end;
    end;
    rtBoolean : begin
      //  ���s���^��񂩂�Boolean�^�̓ǂݍ���
      aInt := GetOrdProp(FObject,PName);
      // Ini�t�@�C������Boolean�^�̓ǂݍ���  �t�@�C���ɖ����ꍇ�����l���̗p ��2025/06/30
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
        //  Boolean�^�̏�������
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
      //  Integer�^�̏�������
      aInt := GetOrdProp(FObject,PName);
      SetInts(PName,aInt);
    end;
    tkInt64 : begin
      //  Int64�^�̏�������
      aInt64 := GetInt64Prop(FObject,PName);
      s := IntToStr(aInt64);
      SetStrs(PName,s);
    end;
    tkString : begin
      //  �Z��������^�̏�������
      aStr := GetStrProp(FObject,PName);
      SetStrs(PName,aStr);
    end;
    tkUString,
    tkLString,
    tkWString : begin
      //  ����������^�̏�������
      aStr := GetStrProp(FObject,PName);
      aStr := CommaToMarkText(aStr);
      SetStrs(PName,aStr);
    end;
    tkEnumeration : begin
      //  �񋓌^�̏�������
      aInt := GetOrdProp(FObject,PName);
      SetInts(PName,aInt);
    end;
    tkSet : begin
      //  �W���^�̏�������
      aInt := GetOrdProp(FObject,PName);
      SetInts(PName,aInt);
    end;
    tkFloat : begin
      //  Float�^�̏�������
      aFloat := GetFloatProp(FObject,PName);
      aStr := FloatToStr(aFloat);
      SetStrs(PName,aStr);
    end;
  end;
end;

end.
