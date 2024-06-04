unit DelphiSecureSQLDatabase.FMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, Vcl.CategoryButtons,
  DelphiSecureSQLDatabase.Interfaces, DelphiSecureSQLDatabase.MainPresenter,
  Vcl.CheckLst, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls, Vcl.ComCtrls;

type
  TfrmAlwaysEncryptedMain = class(TForm, IMainView)
    cpgAlwaysEncrypted: TCategoryPanelGroup;
    cpConnection: TCategoryPanel;
    lbledtDriverID: TLabeledEdit;
    lbledtServerName: TLabeledEdit;
    lbledtDatabaseName: TLabeledEdit;
    lbledtUserName: TLabeledEdit;
    lbledtPassword: TLabeledEdit;
    chkTrustServerCertificate: TCheckBox;
    chkColumnEncryption: TCheckBox;
    btnConnect: TButton;
    cpQueryEncryptedData: TCategoryPanel;
    pnlQueryEncryptedDataButtons: TPanel;
    dbgQueryEncryptedData: TDBGrid;
    memoSELECT: TMemo;
    dsQueryEncryptedData: TDataSource;
    btnOpenQuery: TButton;
    cpUpdatePerson: TCategoryPanel;
    btnUpdate: TButton;
    lbledtFirstName: TLabeledEdit;
    lbledtLastName: TLabeledEdit;
    lbledtCreditCardNumber: TLabeledEdit;
    lbledtSalary: TLabeledEdit;
    lbledtSocialSecurityNumber: TLabeledEdit;
    dtpBirthDate: TDateTimePicker;
    lblBirthDate: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOpenQueryClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure dsQueryEncryptedDataDataChange(Sender: TObject; Field: TField);
  private
    FAlwaysEncryptedMainPresenter: TAlwaysEncryptedMainPresenter;
    // View utility
    procedure SetConnection;
  public
    // Input (function)
    function GetDriverID: string;
    function GetServerName: string;
    function GetDatabaseName: string;
    function GetUserName: string;
    function GetPassword: string;
    function GetTrustServerCertificate: Boolean;
    function GetColumnEncryption: Boolean;
    function GetSELECTSQLText: string;
    function GetdsQueryEncryptedData: TDataSource;
    function GetFirstName: string;
    function GetLastName: string;
    function GetBirthDate: TDateTime;
    function GetSocialSecurityNumber: string;
    function GetCreditCardNumber: string;
    function GetSalary: Currency;
    // Output (procedure)
    procedure Connect;
    procedure OpenQuery;
    procedure UpdatePerson;
    procedure DisplayFirstName(AValue: string);
    procedure DisplayLastName(AValue: string);
    procedure DisplayBirthDate(AValue: TDateTime);
    procedure DisplaySocialSecurityNumber(AValue: string);
    procedure DisplayCreditCardNumber(AValue: string);
    procedure DisplaySalary(AValue: Currency);
    procedure DisplayMessage(AValue: string);
  end;

var
  frmAlwaysEncryptedMain: TfrmAlwaysEncryptedMain;

implementation

{$R *.dfm}

const
  APPTITLE = 'Delphi Secure SQL Database';

{ TfrmAlwaysEncryptedMain }

procedure TfrmAlwaysEncryptedMain.btnConnectClick(Sender: TObject);
begin
  Connect;
end;

procedure TfrmAlwaysEncryptedMain.btnOpenQueryClick(Sender: TObject);
begin
  OpenQuery;
end;

procedure TfrmAlwaysEncryptedMain.btnUpdateClick(Sender: TObject);
begin
  UpdatePerson;
end;

procedure TfrmAlwaysEncryptedMain.Connect;
begin
  FAlwaysEncryptedMainPresenter.Connect;
end;

procedure TfrmAlwaysEncryptedMain.DisplayCreditCardNumber(
  AValue: string);
begin
  lbledtCreditCardNumber.Text := AValue;
end;

procedure TfrmAlwaysEncryptedMain.DisplayFirstName(AValue: string);
begin
  lbledtFirstName.Text := AValue;
end;

procedure TfrmAlwaysEncryptedMain.DisplayBirthDate(AValue: TDateTime);
begin
  dtpBirthDate.DateTime := AValue;
end;

procedure TfrmAlwaysEncryptedMain.DisplayLastName(AValue: string);
begin
  lbledtLastName.Text := AValue;
end;

procedure TfrmAlwaysEncryptedMain.DisplayMessage(AValue: string);
begin
  Application.MessageBox(PChar(AValue), APPTITLE, MB_OK);
end;

procedure TfrmAlwaysEncryptedMain.DisplaySalary(AValue: Currency);
begin
  lbledtSalary.Text := AValue.ToString();
end;

procedure TfrmAlwaysEncryptedMain.DisplaySocialSecurityNumber(
  AValue: string);
begin
  lbledtSocialSecurityNumber.Text := AValue
end;

procedure TfrmAlwaysEncryptedMain.dsQueryEncryptedDataDataChange(
  Sender: TObject; Field: TField);
begin
  FAlwaysEncryptedMainPresenter.DisplayPerson;
end;

procedure TfrmAlwaysEncryptedMain.FormCreate(Sender: TObject);
begin
  FAlwaysEncryptedMainPresenter :=
    TAlwaysEncryptedMainPresenter.Create(Self);
end;

procedure TfrmAlwaysEncryptedMain.FormShow(Sender: TObject);
begin
  SetConnection;
end;

function TfrmAlwaysEncryptedMain.GetColumnEncryption: Boolean;
begin
  result := chkColumnEncryption.Checked;
end;

function TfrmAlwaysEncryptedMain.GetCreditCardNumber: string;
begin
  result := lbledtCreditCardNumber.Text;
end;

function TfrmAlwaysEncryptedMain.GetDatabaseName: string;
begin
  result := lbledtDatabaseName.Text;
end;

function TfrmAlwaysEncryptedMain.GetDriverID: string;
begin
  result := lbledtDriverID.Text;
end;

function TfrmAlwaysEncryptedMain.GetdsQueryEncryptedData: TDataSource;
begin
  result := dsQueryEncryptedData;
end;

function TfrmAlwaysEncryptedMain.GetFirstName: string;
begin
  result := lbledtFirstName.Text;
end;

function TfrmAlwaysEncryptedMain.GetBirthDate: TDateTime;
begin
  result := dtpBirthDate.DateTime;
end;

function TfrmAlwaysEncryptedMain.GetLastName: string;
begin
  result := lbledtLastName.Text;
end;

function TfrmAlwaysEncryptedMain.GetPassword: string;
begin
  result := lbledtPassword.Text;
end;

function TfrmAlwaysEncryptedMain.GetSalary: Currency;
begin
  result := StrToFloat(lbledtSalary.Text);
end;

function TfrmAlwaysEncryptedMain.GetSELECTSQLText: string;
begin
  result := memoSELECT.Text;
end;

function TfrmAlwaysEncryptedMain.GetServerName: string;
begin
  result := lbledtServerName.Text;
end;

function TfrmAlwaysEncryptedMain.GetSocialSecurityNumber: string;
begin
  result := lbledtSocialSecurityNumber.Text;
end;

function TfrmAlwaysEncryptedMain.GetTrustServerCertificate: Boolean;
begin
  result := chkTrustServerCertificate.Checked;
end;

function TfrmAlwaysEncryptedMain.GetUserName: string;
begin
  result := lbledtUserName.Text;
end;

procedure TfrmAlwaysEncryptedMain.OpenQuery;
begin
  FAlwaysEncryptedMainPresenter.OpenQuery;
end;

procedure TfrmAlwaysEncryptedMain.SetConnection;
begin
  lbledtDriverID.Text := 'MSSQL';
  lbledtServerName.Text := 'decision-making';
  lbledtDatabaseName.Text := 'AlwaysEncryptedDB';
  lbledtUserName.Text := 'Delphi_User';
  lbledtPassword.Text := 'DelphiDay2024!';
end;

procedure TfrmAlwaysEncryptedMain.UpdatePerson;
begin
  FAlwaysEncryptedMainPresenter.UpdatePerson;
end;

end.
