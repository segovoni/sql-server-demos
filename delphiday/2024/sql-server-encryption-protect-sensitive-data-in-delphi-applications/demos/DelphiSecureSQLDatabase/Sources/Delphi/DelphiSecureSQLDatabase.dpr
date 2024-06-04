program DelphiSecureSQLDatabase;

uses
  Vcl.Forms,
  DelphiSecureSQLDatabase.DataModule in 'DataModules\DelphiSecureSQLDatabase.DataModule.pas' {DM: TDataModule},
  DelphiSecureSQLDatabase.Interfaces in 'Interfaces\DelphiSecureSQLDatabase.Interfaces.pas',
  DelphiSecureSQLDatabase.Base.ActiveRecord in 'Models\DelphiSecureSQLDatabase.Base.ActiveRecord.pas',
  DelphiSecureSQLDatabase.Person.ActiveRecord in 'Models\DelphiSecureSQLDatabase.Person.ActiveRecord.pas',
  DelphiSecureSQLDatabase.MainPresenter in 'Presenters\DelphiSecureSQLDatabase.MainPresenter.pas',
  DelphiSecureSQLDatabase.FMain in 'Views\DelphiSecureSQLDatabase.FMain.pas' {frmAlwaysEncryptedMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmAlwaysEncryptedMain, frmAlwaysEncryptedMain);
  Application.Run;
end.
