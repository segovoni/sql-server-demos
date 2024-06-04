unit DelphiSecureSQLDatabase.MainPresenter;

interface

uses
  DelphiSecureSQLDatabase.Interfaces;

type

  TAlwaysEncryptedMainPresenter = class
  protected
    FMainView: IMainView;
  public
    constructor Create(AMainView: IMainView);
    procedure Connect;
    procedure OpenQuery;
    procedure UpdatePerson;
    procedure DisplayPerson;
  end;

implementation

uses
  DelphiSecureSQLDatabase.DataModule, Data.DB,
  DelphiSecureSQLDatabase.Person.ActiveRecord;

{ TAlwaysEncryptedMainPresenter }

procedure TAlwaysEncryptedMainPresenter.Connect;
var
  LDriverID: string;
  LServerName: string;
  LDatabaseName: string;
  LUserName: string;
  LPassword: string;
  LODBCAdvanced: string;
begin
  LDriverID := FMainView.GetDriverID;
  LServerName := FMainView.GetServerName;
  LDatabaseName := FMainView.GetDatabaseName;
  LUserName := FMainView.GetUserName;
  LPassword := FMainView.GetPassword;

  DM.FDConnection.Connected := False;
  DM.FDConnection.Params.Clear;

  DM.FDConnection.Params.DriverID := LDriverID;
  DM.FDConnection.Params.Add('Server=' + LServerName);
  DM.FDConnection.Params.Database := LDatabaseName;
  DM.FDConnection.Params.UserName := LUserName;
  DM.FDConnection.Params.Password := LPassword;

  {
  DM.FDConnection.Params.Add('ODBCAdvanced=Trusted_Connection=No;' +
    'APP=Professional;' +
    'WSID='+LServerName+';' +
    'TrustServerCertificate=Yes;' +
    'ColumnEncryption=Enabled');
  }

  LODBCAdvanced := 'ODBCAdvanced=APP=Professional;WSID='+LServerName+';';

  // FireDAC connection configured to encrypt/decrypt data before letting SQL Server
  // or Azure SQL manage it. Enable both parameter encryption and result set
  // encrypted column decryption is by setting the value of the ColumnEncryption
  // connection string keyword to Enabled

  if FMainView.GetTrustServerCertificate then
    LODBCAdvanced := LODBCAdvanced + 'TrustServerCertificate=yes;';

  if FMainView.GetColumnEncryption then
    LODBCAdvanced := LODBCAdvanced + 'ColumnEncryption=Enabled;';

  DM.FDConnection.Params.Add(LODBCAdvanced);

  DM.FDConnection.Connected := True;

  if DM.FDConnection.Connected then
    FMainView.DisplayMessage('Connected!')
  else
    FMainView.DisplayMessage('Not connected, see the previous error!');
end;

constructor TAlwaysEncryptedMainPresenter.Create(
  AMainView: IMainView);
begin
  FMainView := AMainView;
end;

procedure TAlwaysEncryptedMainPresenter.DisplayPerson;
var
  LPersonAR: TPersonActiveRecord;
begin
  LPersonAR := TPersonActiveRecord.Get(
    FMainView.GetdsQueryEncryptedData.DataSet.FieldByName('ID').AsInteger);

  FMainView.DisplayFirstName(LPersonAR.FirstName);
  FMainView.DisplayLastName(LPersonAR.LastName);
  FMainView.DisplayBirthDate(LPersonAR.BirthDate);
  FMainView.DisplaySocialSecurityNumber(LPersonAR.SocialSecurityNumber);
  FMainView.DisplayCreditCardNumber(LPersonAR.CreditCardNumber);
  FMainView.DisplaySalary(LPersonAR.Salary);
end;

procedure TAlwaysEncryptedMainPresenter.OpenQuery;
var
  LSQL: string;
  LDataSource: TDataSource;
begin
  LSQL := FMainView.GetSELECTSQLText;

  if (LSQL <> '') then
  begin
    LDataSource := FMainView.GetdsQueryEncryptedData;
    LDataSource.DataSet := DM.FDQrySelectEncryptedData;
    DM.FDQrySelectEncryptedData.Close;
    DM.FDQrySelectEncryptedData.SQL.Text := LSQL;
    DM.FDQrySelectEncryptedData.Open;
  end
  else
    FMainView.DisplayMessage('SQL query text is empty!');
end;

procedure TAlwaysEncryptedMainPresenter.UpdatePerson;
var
  LPersonAR: TPersonActiveRecord;
begin
  TPersonActiveRecord.Connection := DM.FDConnection;
  LPersonAR := TPersonActiveRecord.Get(
    FMainView.GetdsQueryEncryptedData.DataSet.FieldByName('ID').AsInteger);

  try
    LPersonAR.FirstName := FMainView.GetFirstName;
    LPersonAR.LastName := FMainView.GetLastName;
    LPersonAR.BirthDate := FMainView.GetBirthDate;
    LPersonAR.SocialSecurityNumber := FMainView.GetSocialSecurityNumber;
    LPersonAR.CreditCardNumber := FMainView.GetCreditCardNumber;
    LPersonAR.Salary := FMainView.GetSalary;
    LPersonAR.Update;
  finally
    LPersonAR.Free;
  end;
end;

end.
