object frmAlwaysEncryptedMain: TfrmAlwaysEncryptedMain
  Left = 0
  Top = 8
  Caption = 'Delphi Secure SQL Database'
  ClientHeight = 827
  ClientWidth = 930
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 21
  object cpgAlwaysEncrypted: TCategoryPanelGroup
    Left = 0
    Top = 0
    Width = 930
    Height = 827
    VertScrollBar.Tracking = True
    Align = alClient
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -18
    HeaderFont.Name = 'Segoe UI'
    HeaderFont.Style = []
    TabOrder = 0
    StyleName = 'Windows'
    ExplicitWidth = 924
    ExplicitHeight = 810
    object cpUpdatePerson: TCategoryPanel
      Top = 517
      Height = 276
      Caption = 'Modify Person'
      TabOrder = 0
      ExplicitWidth = 920
      object lblBirthDate: TLabel
        Left = 650
        Top = 24
        Width = 67
        Height = 21
        Caption = 'Birth date'
      end
      object btnUpdate: TButton
        Left = 650
        Top = 167
        Width = 262
        Height = 30
        Caption = 'Update'
        TabOrder = 0
        OnClick = btnUpdateClick
      end
      object lbledtFirstName: TLabeledEdit
        Left = 12
        Top = 48
        Width = 289
        Height = 29
        EditLabel.Width = 73
        EditLabel.Height = 21
        EditLabel.Caption = 'First name'
        TabOrder = 1
        Text = ''
      end
      object lbledtLastName: TLabeledEdit
        Left = 333
        Top = 50
        Width = 262
        Height = 29
        EditLabel.Width = 71
        EditLabel.Height = 21
        EditLabel.Caption = 'Last name'
        TabOrder = 2
        Text = ''
      end
      object lbledtCreditCardNumber: TLabeledEdit
        Left = 333
        Top = 112
        Width = 262
        Height = 29
        EditLabel.Width = 135
        EditLabel.Height = 21
        EditLabel.Caption = 'Credit card number'
        TabOrder = 3
        Text = ''
      end
      object lbledtSalary: TLabeledEdit
        Left = 650
        Top = 112
        Width = 262
        Height = 29
        EditLabel.Width = 43
        EditLabel.Height = 21
        EditLabel.Caption = 'Salary'
        TabOrder = 4
        Text = ''
      end
      object lbledtSocialSecurityNumber: TLabeledEdit
        Left = 12
        Top = 112
        Width = 289
        Height = 29
        EditLabel.Width = 158
        EditLabel.Height = 21
        EditLabel.Caption = 'Social security number'
        TabOrder = 5
        Text = ''
      end
      object dtpBirthDate: TDateTimePicker
        Left = 650
        Top = 49
        Width = 262
        Height = 29
        Date = 45433.000000000000000000
        Time = 0.666134999999485400
        TabOrder = 6
      end
    end
    object cpQueryEncryptedData: TCategoryPanel
      Top = 229
      Height = 288
      Caption = 'Query encrypted data'
      TabOrder = 1
      ExplicitWidth = 920
      object pnlQueryEncryptedDataButtons: TPanel
        Left = 0
        Top = 213
        Width = 924
        Height = 49
        Align = alBottom
        TabOrder = 0
        ExplicitWidth = 918
        object btnOpenQuery: TButton
          Left = 650
          Top = 10
          Width = 258
          Height = 30
          Caption = 'Open query'
          TabOrder = 0
          OnClick = btnOpenQueryClick
        end
      end
      object dbgQueryEncryptedData: TDBGrid
        Left = 0
        Top = 0
        Width = 924
        Height = 159
        Align = alClient
        DataSource = dsQueryEncryptedData
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -16
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
      object memoSELECT: TMemo
        Left = 0
        Top = 159
        Width = 924
        Height = 54
        Align = alBottom
        Lines.Strings = (
          
            'SELECT ID, FirstName, LastName, BirthDate, SocialSecurityNumber,' +
            ' CreditCardNumber, Salary FROM dbo.Persons;')
        TabOrder = 2
        ExplicitWidth = 918
      end
    end
    object cpConnection: TCategoryPanel
      Top = 0
      Height = 229
      Caption = 'Connection FireDAC'
      TabOrder = 2
      ExplicitWidth = 920
      object lbledtDriverID: TLabeledEdit
        Left = 12
        Top = 48
        Width = 220
        Height = 29
        EditLabel.Width = 62
        EditLabel.Height = 21
        EditLabel.Caption = 'Driver ID'
        TabOrder = 0
        Text = ''
      end
      object lbledtServerName: TLabeledEdit
        Left = 264
        Top = 48
        Width = 220
        Height = 29
        EditLabel.Width = 88
        EditLabel.Height = 21
        EditLabel.Caption = 'Server name'
        TabOrder = 1
        Text = ''
      end
      object lbledtDatabaseName: TLabeledEdit
        Left = 516
        Top = 48
        Width = 220
        Height = 29
        EditLabel.Width = 107
        EditLabel.Height = 21
        EditLabel.Caption = 'Database name'
        TabOrder = 2
        Text = ''
      end
      object lbledtUserName: TLabeledEdit
        Left = 12
        Top = 106
        Width = 220
        Height = 29
        EditLabel.Width = 75
        EditLabel.Height = 21
        EditLabel.Caption = 'User name'
        TabOrder = 3
        Text = ''
      end
      object lbledtPassword: TLabeledEdit
        Left = 264
        Top = 106
        Width = 220
        Height = 29
        EditLabel.Width = 66
        EditLabel.Height = 21
        EditLabel.Caption = 'Password'
        PasswordChar = '*'
        TabOrder = 4
        Text = ''
      end
      object chkTrustServerCertificate: TCheckBox
        Left = 12
        Top = 150
        Width = 220
        Height = 32
        Caption = 'Trust server certificate'
        Checked = True
        Color = clBtnFace
        ParentColor = False
        State = cbChecked
        TabOrder = 5
      end
      object chkColumnEncryption: TCheckBox
        Left = 264
        Top = 150
        Width = 220
        Height = 32
        Caption = 'Column encryption'
        TabOrder = 6
      end
      object btnConnect: TButton
        Left = 650
        Top = 168
        Width = 258
        Height = 30
        Caption = 'Connect'
        TabOrder = 7
        OnClick = btnConnectClick
      end
    end
  end
  object dsQueryEncryptedData: TDataSource
    OnDataChange = dsQueryEncryptedDataDataChange
    Left = 852
    Top = 301
  end
end
