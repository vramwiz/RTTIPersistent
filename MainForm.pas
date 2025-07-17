unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,RTTIPersistent;

type
  TSubItem = class(TPersistent)
  private
    FValue: Double;
  published
    property Value: Double read FValue write FValue;
  end;

type
  TSampleItem = class(TRTTIPersistentIni)
  private
    FName     : string;
    FEnabled  : Boolean;
    FAge      : Integer;
    FScore    : Double;
    FChar     : Char;
    FKind     : TAlignment; // Enumå^
    FFlags    : TFontStyles; // Setå^
    FDate     : TDateTime;
    FSubItem  : TSubItem;
  public
    constructor Create;
  published
    property Name    : string      read FName    write FName;
    property Enabled : Boolean     read FEnabled write FEnabled;
    property Age     : Integer     read FAge     write FAge;
    property Score   : Double      read FScore   write FScore;
    property Char    : Char        read FChar    write FChar;
    property Kind    : TAlignment  read FKind    write FKind;
    property Flags   : TFontStyles read FFlags   write FFlags;
    property Date    : TDateTime   read FDate    write FDate;
    property Sub     : TSubItem    read FSubItem write FSubItem;
  end;

type
	TSampleList  = class(TRTTIPersistentIniList<TSampleItem>)
	private
		{ Private êÈåæ }
	public
		{ Public êÈåæ }
    // ë„ì¸
    //procedure Assign(Source: TSampleList);

	end;

type
  TFormMain = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Panel5: TPanel;
    Panel6: TPanel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Panel7: TPanel;
    ComboBox1: TComboBox;
    Button4: TButton;
    Button5: TButton;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit2: TEdit;
    Panel8: TPanel;
    Panel9: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Exit(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private êÈåæ }
    FItem1 : TSampleItem;
    FList1 : TSampleList;
    FItem2 : TSampleItem;
    FList2 : TSampleList;

    function GetTempIniFileName(Index: Integer): string;
    procedure ShowMode();
    procedure ShowForm2();
    procedure InitData();
    procedure DatatoForm1(Item : TSampleItem);
    procedure DatatoForm2(Item : TSampleItem);
    procedure Form1ToData(Item : TSampleItem);
    procedure DatatoList1(Items : TSampleList);
    procedure DatatoList2(Items : TSampleList);
  public
    { Public êÈåæ }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FItem1 := TSampleItem.Create;
  FList1 := TSampleList.Create();
  FItem2 := TSampleItem.Create;
  FList2 := TSampleList.Create();
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FList2.Free;
  FItem2.Free;
  FList1.Free;
  FItem1.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ComboBox1.Clear;
  ComboBox1.Items.Add('TRTTIPersistentIniÇÃë„ì¸é¿å±');
  ComboBox1.Items.Add('TRTTIPersistentIniListÇÃë„ì¸é¿å±');
  ComboBox1.ItemIndex := 0;
  ShowMode();
  InitData();
  DatatoList1(FList1);
end;

function TFormMain.GetTempIniFileName(Index: Integer): string;
var
  BasePath: string;
  FileName: string;
begin
  BasePath := ExtractFilePath(ParamStr(0));
  FileName := Format('temp%d.ini', [Index]);  // ó·: temp0.ini, temp1.ini
  Result := IncludeTrailingPathDelimiter(BasePath) + FileName;
end;

procedure TFormMain.InitData;
var
  Item: TSampleItem;
begin
  FItem1.Name := 'SampleName';
  FItem1.Enabled := True;

  Item := FList1.AddNew;
  Item.Name := 'UserName1';
  Item.Enabled := True;
  Item := FList1.AddNew;
  Item.Name := 'UserName2';
  Item.Enabled := False;
end;

procedure TFormMain.ListBox1Click(Sender: TObject);
var
  i : Integer;
begin
  i := ListBox1.ItemIndex;
  if i <> -1 then DatatoForm1(FList1[i]);
end;

procedure TFormMain.ListBox2Click(Sender: TObject);
var
  i : Integer;
begin
  i := ListBox2.ItemIndex;
  if i <> -1 then DatatoForm2(FList2[i]);
end;

procedure TFormMain.ShowForm2;
begin
  DatatoList2(FList2);
end;

procedure TFormMain.ShowMode;
var
  i : Integer;
  f : Boolean;
begin
  i := ComboBox1.ItemIndex;
  f := (i <> 0);

  Panel5.Enabled := f;
  Panel6.Enabled := f;

end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
  FItem2.Assign(FItem1);
  FList2.Assign(FList1);
  ShowForm2();
end;

procedure TFormMain.Button2Click(Sender: TObject);
var
  s: string;
begin
  s := GetTempIniFileName(1);
  FItem1.Filename := s;
  FItem1.SaveToFile;
  if ComboBox1.ItemIndex = 0 then begin
    Memo1.Lines.LoadFromFile(s);
  end;

  s := GetTempIniFileName(2);
  FList1.Filename := s;
  FList1.SaveToFile;
  if ComboBox1.ItemIndex = 1 then begin
    Memo1.Lines.LoadFromFile(s);
  end;
end;

procedure TFormMain.Button3Click(Sender: TObject);
var
  s: string;
begin
  s := GetTempIniFileName(1);
  FItem2.Filename := s;
  FItem2.LoadFromFile();

  s := GetTempIniFileName(2);
  FList2.Filename := s;
  FList2.LoadFromFile();
  ShowForm2();
end;

procedure TFormMain.Button4Click(Sender: TObject);
var
  i : Integer;
begin
  i := ListBox1.ItemIndex;
  if i = -1 then begin
    FList1.AddNew;
  end
  else begin
    FList1.InsertNew(i);
  end;
  DatatoList1(FList1);
end;

procedure TFormMain.Button5Click(Sender: TObject);
var
  i : Integer;
begin
  i := ListBox1.ItemIndex;
  if i <> -1 then DatatoForm1(FList1[i]);
  if FList1.Count = 1 then exit;
  FList1.Delete(i);
  DatatoList1(FList1);
end;

procedure TFormMain.CheckBox1Exit(Sender: TObject);
var
  i : Integer;
begin
  if ComboBox1.ItemIndex = 0 then begin
    Form1ToData(FItem1);
  end
  else begin
    i := ListBox1.ItemIndex;
    if i = -1 then exit;
    Form1ToData(FList1[i]);
  end;
end;

procedure TFormMain.ComboBox1Change(Sender: TObject);
begin
  ShowMode();
  DatatoList1(FList1);
  DatatoList2(FList2);
end;

procedure TFormMain.DatatoForm1(Item: TSampleItem);
begin
  Edit1.Text := Item.Name;
  CheckBox1.Checked := Item.Enabled;
end;

procedure TFormMain.DatatoForm2(Item: TSampleItem);
begin
  Edit2.Text := Item.Name;
  CheckBox2.Checked := Item.Enabled;
end;

procedure TFormMain.Form1ToData(Item: TSampleItem);
begin
  Item.Name := Edit1.Text;
  Item.Enabled := CheckBox1.Checked;
end;

procedure TFormMain.DatatoList1(Items: TSampleList);
var
  i : Integer;
begin
  ListBox1.Clear;
  for i := 0 to Items.Count-1 do begin
    ListBox1.Items.Add('['+IntToStr(i)+']');
  end;
  if ListBox1.Items.Count>0 then ListBox1.ItemIndex := 0;


  if ComboBox1.ItemIndex = 0 then begin
    DatatoForm1(FItem1);
  end
  else begin
    i := ListBox1.ItemIndex;
    if i <> -1 then DatatoForm1(Items[i]);
  end;

end;

procedure TFormMain.DatatoList2(Items: TSampleList);
var
  i : Integer;
begin
  ListBox2.Clear;
  for i := 0 to Items.Count-1 do begin
    ListBox2.Items.Add('['+IntToStr(i)+']');
  end;
  if ListBox2.Items.Count>0 then ListBox2.ItemIndex := 0;


  if ComboBox1.ItemIndex = 0 then begin
    DatatoForm2(FItem2);
  end
  else begin
    i := ListBox2.ItemIndex;
    if i <> -1 then DatatoForm2(Items[i]);
  end;
end;



{ TSampleList }

{
procedure TSampleList.Assign(Source: TSampleList);
var
  SrcList: TSampleList;
  i: Integer;
  Src, Dst: TSampleItem;
begin
  if Source is TSampleList then
  begin
    SrcList := TSampleList(Source);
    Clear;

    for i := 0 to SrcList.Count - 1 do
    begin
      Src := SrcList[i];
      Dst := TSampleItem.Create;
      Dst.Assign(Src);
      Add(Dst);
    end;
   end;
end;
}

{ TSampleItem }

constructor TSampleItem.Create;
begin
  inherited;
  FName    := 'Test Name';
  FEnabled := True;
  FAge     := 42;
  FScore   := 99.9;
  FChar    := 'A';
  FKind    := taCenter;
  FFlags   := [fsBold, fsItalic];
  FDate    := EncodeDate(2023, 5, 10) + EncodeTime(15, 30, 0, 0);
  FSubItem := TSubItem.Create;
  FSubItem.Value := 123.456;
end;

end.
