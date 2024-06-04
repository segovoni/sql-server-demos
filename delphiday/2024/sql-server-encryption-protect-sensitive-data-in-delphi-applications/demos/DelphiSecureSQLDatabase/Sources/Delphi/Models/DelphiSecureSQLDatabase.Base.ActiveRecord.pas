unit DelphiSecureSQLDatabase.Base.ActiveRecord;

interface

uses
  FireDAC.Comp.Client;

type

  TBaseActiveRecord = class
  public
    class var Connection: TFDConnection;
  protected
    const
      SQL_GET_MAX_ID = 'SELECT SCOPE_IDENTITY() as U';
    class function GetMaxID: Integer;
  end;

implementation

uses
  System.Variants;

{ TBaseActiveRecord }

class function TBaseActiveRecord.GetMaxID: Integer;
var
  LMaxID: Integer;
begin
  Result := -1;

  LMaxID := Connection.ExecSQLScalar(SQL_GET_MAX_ID);

  if (LMaxID <> Null) then
    Result := LMaxID;
  Connection.ResourceOptions.DirectExecute := False;
end;

end.
