//**********************************************************************//
//                                                                      //
//  �P��TStringList����L�[���g���ĕ�����TStringList���Ǘ�����N���X  //
//                                                                      //
//**********************************************************************//
unit StringListKey;

interface

uses
	Windows,Messages, SysUtils, Classes, Graphics, Controls,StdCtrls, ExtCtrls,
  StringListEx;

//--------------------------------------------------------------------------//
//  �L�[���Ǘ�����N���X                                                    //
//--------------------------------------------------------------------------//
type
	TStringListKey = class(TPersistent)
	private
		{ Private �錾 }
    FKeys: TStringList;           // �L�[�̈ꗗ
    FValues: TList;               // ���e�̊Ǘ�
    function GetKeyValues(Key: string): TStringListEx;
	public
		{ Public �錾 }
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
//  �`�@�N���X�����C�x���g�@�`                                              //
//                                                                          //
//   - Input -  �Ȃ�                                                        //
//   - Output - �Ȃ�                                                        //
//                                                                          //
//**************************************************************************//
constructor TStringListKey.Create;
begin
  FKeys   := TStringList.Create;
  FValues := TList.Create;
end;

//**************************************************************************//
//                                                                          //
//  �`�@�N���X�j���C�x���g�@�`                                              //
//                                                                          //
//   - Input -  �Ȃ�                                                        //
//   - Output - �Ȃ�                                                        //
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
//  �`�@�L�[�ƒl��TStringList�`���ɕϊ��@�`                                 //
//                                                                          //
//   - Input -  t : �o�͂���N���X                                          //
//                                                                          //
//   - Output - �Ȃ�                                                        //
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
//  �`�@TStringList�`������L�[�ƒl���쐬�@�`                               //
//                                                                          //
//   - Input -  t : �ϊ�����N���X                                          //
//                                                                          //
//   - Output - �Ȃ�                                                        //
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
//  �`�@�t�@�C������ǂݍ��ށ@�`                                            //
//                                                                          //
//   - Input -  FileName : �ǂݍ��݃t�@�C����                               //
//                                                                          //
//   - Output - �Ȃ�                                                        //
//                                                                          //
//**************************************************************************//
function TStringListKey.LoadFromFile(const FileName: string) : Boolean;
var
  t : TStringList;
begin
  t := TStringList.Create;
  try
    result := False;
    t.LoadFromFile(FileName);      // �t�@�C����ǂݍ���
    StringsToKeys(t);              // �L�[�ƒl�Ƃ̌`���ɕϊ�
    result := True;
  finally
    t.Free;
  end;
end;

//**************************************************************************//
//                                                                          //
//  �`�@�t�@�C���ɏ������ށ@�`                                              //
//                                                                          //
//   - Input -  FileName : �������ރt�@�C����                               //
//                                                                          //
//   - Output - �Ȃ�                                                        //
//                                                                          //
//**************************************************************************//
function TStringListKey.SaveToFile(const FileName: string) : Boolean;
var
  t : TStringList;
begin
  t := TStringList.Create;
  try
    result := False;
    KeysToStrings(t);            // StringList�`���ɕϊ�
    t.SaveToFile(FileName,TEncoding.UTF8);      // �t�@�C���ɏ�������
    result := True;
  finally
    t.Free;
  end;
end;

//**************************************************************************//
//                                                                          //
//  �`�@�V�����l��ǉ��@�`                                                  //
//                                                                          //
//   - Input -  Key   : �ǉ�����L�[                                        //
//              Value : �ǉ�������e                                        //
//                                                                          //
//   - Output - �Ȃ�                                                        //
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
//  �`�@�L�[���폜�@�`                                                      //
//                                                                          //
//   - Input -  Key   : �폜����L�[                                        //
//                                                                          //
//   - Output - �Ȃ�                                                        //
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
//  �`�@�S�ẴL�[�ƒl���������@�`                                          //
//                                                                          //
//   - Input -  �Ȃ�                                                        //
//   - Output - �Ȃ�                                                        //
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
