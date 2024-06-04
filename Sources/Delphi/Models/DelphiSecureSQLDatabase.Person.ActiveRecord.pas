unit DelphiSecureSQLDatabase.Person.ActiveRecord;

interface

uses
  DelphiSecureSQLDatabase.Base.ActiveRecord, System.Generics.Collections,
  FireDAC.Comp.Client;

type

  TPersons = class;

  TPersonActiveRecord = class(TBaseActiveRecord)
  const
    SQL_INSERT =
      'INSERT INTO dbo.Persons ' +
      '(FirstName, LastName, BirthDate, SocialSecurityNumber, CreditCardNumber, Salary) ' +
      'VALUES ' +
      '(:FirstName, :LastName, :BirthDate, :SocialSecurityNumber, :CreditCardNumber, :Salary)';
    SQL_UPDATE =
      'UPDATE dbo.Persons SET ' +
        'FirstName = :FirstName ' +
        ',LastName = :LastName ' +
        ',BirthDate = :BirthDate ' +
        ',SocialSecurityNumber = :SocialSecurityNumber ' +
        ',CreditCardNumber = :CreditCardNumber ' +
        ',Salary = :Salary ' +
      'WHERE ' +
        '(ID = :ID)';
    SQL_FIND_ALL =
      'SELECT ID, FirstName, LastName, BirthDate, SocialSecurityNumber, CreditCardNumber, Salary FROM dbo.Persons';
    SQL_FIND_BY_PK =
      'SELECT ID, FirstName, LastName, BirthDate, SocialSecurityNumber, CreditCardNumber, Salary FROM dbo.Persons WHERE (ID = %d)';
    SQL_DELETE =
      'DELETE FROM dbo.Persons WHERE (ID = %d)';
    SQL_DELETE_ALL =
      'DELETE FROM dbo.Persons';
  private
    FID: Integer;
    FFirstName: string;
    FLastName: string;
    FBirthDate: TDateTime;
    FSocialSecurityNumber: string;//[11];
    FCreditCardNumber: string;//[19];
    FSalary: Currency;
    procedure SetFirstName(const AValue: string);
    procedure SetLastName(const AValue: string);
    procedure SetBirthDate(const AValue: TDateTime);
    procedure SetSocialSecurityNumber(const AValue: string);
    procedure SetCreditCardNumber(const AValue: string);
    procedure SetSalary(const AValue: Currency);
  private
    class function LoadPerson(AReader: TFDAdaptedDataSet): TPersonActiveRecord;
    class function FillPersonList(const ASQL: string): TPersons;
  public
    class function Get(AID: Integer): TPersonActiveRecord;
    class function GetAll: TPersons;
    class procedure DeleteAll;
    procedure Insert;
    procedure Update;
    procedure Delete;
    property ID: Integer read FID;
    property FirstName: string read FFirstName write SetFirstName;
    property LastName: string read FLastName write SetLastName;
    property BirthDate: TDateTime read FBirthDate write SetBirthDate;
    property SocialSecurityNumber: string read FSocialSecurityNumber write SetSocialSecurityNumber;
    property CreditCardNumber: string read FCreditCardNumber write SetCreditCardNumber;
    property Salary: Currency read FSalary write SetSalary;
  end;

  TPersons = class(TObjectList<TPersonActiveRecord>);

implementation

uses
  DelphiSecureSQLDatabase.DataModule, System.SysUtils, Data.DB, FireDAC.Stan.Param;

{ TPersonActiveRecord }

procedure TPersonActiveRecord.Delete;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := DM.FDConnection;
    LQry.SQL.Text := Format(SQL_DELETE, [ID]);
    Connection.ResourceOptions.DirectExecute := True;
    LQry.ExecSQL;
  finally
    LQry.Free
  end;
end;

class procedure TPersonActiveRecord.DeleteAll;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := DM.FDConnection;
    LQry.SQL.Text := SQL_DELETE_ALL;
    Connection.ResourceOptions.DirectExecute := True;
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

class function TPersonActiveRecord.FillPersonList(const ASQL: string): TPersons;
var
  LQry: TFDQuery;
begin
  result := TPersons.Create(True);
  LQry := TFDQuery.Create(nil);

  try
    LQry.Connection := DM.FDConnection;
    LQry.SQL.Text := ASQL;
    LQry.Open();

    while (not LQry.Eof) do
    begin
      result.Add(LoadPerson(LQry));
      LQry.Next;
    end;

  finally
    LQry.Free;
  end;
end;

class function TPersonActiveRecord.Get(AID: Integer): TPersonActiveRecord;
var
  LQry: TFDQuery;
begin
  result := nil;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := DM.FDConnection;
    LQry.SQL.Text := Format(SQL_FIND_BY_PK, [AID]);
    LQry.Open();
    if (not LQry.Eof) then
      result := LoadPerson(LQry);
  finally
    LQry.Free;
  end;
end;

class function TPersonActiveRecord.GetAll: TPersons;
begin
  result := FillPersonList(SQL_FIND_ALL);
end;

procedure TPersonActiveRecord.Insert;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := DM.FDConnection;
    LQry.SQL.Text :=
      Format(SQL_INSERT, [FirstName, LastName, BirthDate, SocialSecurityNumber,
        CreditCardNumber, Salary]);
    Connection.ResourceOptions.DirectExecute := True;
    LQry.ExecSQL;
    FID := GetMaxID;
  finally
    LQry.Free
  end;
end;

class function TPersonActiveRecord.LoadPerson(
  AReader: TFDAdaptedDataSet): TPersonActiveRecord;
begin
  result := TPersonActiveRecord.Create;

  result.FID := AReader.Fields[0].AsInteger;
  result.FFirstName := AReader.Fields[1].AsString;
  result.FLastName := AReader.Fields[2].AsString;
  result.BirthDate := AReader.Fields[3].AsDateTime;
  result.FSocialSecurityNumber := AReader.Fields[4].AsString;
  result.FCreditCardNumber := AReader.Fields[5].AsString;
  result.FSalary := AReader.Fields[6].AsCurrency;
end;

procedure TPersonActiveRecord.SetCreditCardNumber(const AValue: string);
begin
  FCreditCardNumber := AValue;
end;

procedure TPersonActiveRecord.SetFirstName(const AValue: string);
begin
  FFirstName := AValue;
end;

procedure TPersonActiveRecord.SetBirthDate(const AValue: TDateTime);
begin
  FBirthDate := AValue;
end;

procedure TPersonActiveRecord.SetLastName(const AValue: string);
begin
  FLastName := AValue;
end;

procedure TPersonActiveRecord.SetSalary(const AValue: Currency);
begin
  FSalary := AValue;
end;

procedure TPersonActiveRecord.SetSocialSecurityNumber(const AValue: string);
begin
  FSocialSecurityNumber := AValue;
end;

procedure TPersonActiveRecord.Update;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := DM.FDConnection;
    LQry.SQL.Text := SQL_UPDATE;

    LQry.ParamByName('FirstName').DataType := ftstring;
    LQry.ParamByName('LastName').DataType := ftstring;
    LQry.ParamByName('BirthDate').DataType := ftDateTime;
    LQry.ParamByName('BirthDate').Size := 11;
    LQry.ParamByName('SocialSecurityNumber').DataType := ftFixedChar; // CHAR - non-Unicode
    LQry.ParamByName('SocialSecurityNumber').Size := 10;
    LQry.ParamByName('CreditCardNumber').DataType := ftFixedChar; // CHAR - non-Unicode
    LQry.ParamByName('CreditCardNumber').Size := 15;
    LQry.ParamByName('Salary').DataType := ftCurrency;
    LQry.ParamByName('ID').DataType := ftInteger;

    LQry.Prepare;

    LQry.ParamByName('FirstName').AsString := FirstName;
    LQry.ParamByName('LastName').AsString := LastName;
    LQry.ParamByName('BirthDate').AsDateTime := BirthDate;
    LQry.ParamByName('SocialSecurityNumber').AsString := SocialSecurityNumber;
    LQry.ParamByName('CreditCardNumber').AsString := CreditCardNumber;
    LQry.ParamByName('Salary').AsCurrency := Salary;
    LQry.ParamByName('ID').AsInteger := ID;

    LQry.ExecSQL;
  finally
    LQry.Free
  end;
end;

end.
