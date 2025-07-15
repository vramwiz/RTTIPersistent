program RTTIPersistentSample;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {FormMain},
  RTTIPersistent in 'RTTIPersistent.pas',
  StringListRtti in 'StringListRtti.pas',
  StringListEx in 'StringListEx.pas',
  StringListKey in 'StringListKey.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
