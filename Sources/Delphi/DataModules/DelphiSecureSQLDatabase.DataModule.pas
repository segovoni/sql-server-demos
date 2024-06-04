unit DelphiSecureSQLDatabase.DataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL;

type
  TDM = class(TDataModule)
    FDConnection: TFDConnection;
    FDQrySelectEncryptedData: TFDQuery;
    FDQryUpdateEncryptedData: TFDQuery;
    FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink;
  private
  public
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
