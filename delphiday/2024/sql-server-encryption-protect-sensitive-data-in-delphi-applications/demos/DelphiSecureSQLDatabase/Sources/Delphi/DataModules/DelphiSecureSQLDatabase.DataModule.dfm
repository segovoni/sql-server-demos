object DM: TDM
  Height = 399
  Width = 524
  PixelsPerInch = 144
  object FDConnection: TFDConnection
    Left = 96
    Top = 24
  end
  object FDQrySelectEncryptedData: TFDQuery
    AutoCalcFields = False
    Connection = FDConnection
    Left = 372
    Top = 24
  end
  object FDQryUpdateEncryptedData: TFDQuery
    Connection = FDConnection
    Left = 96
    Top = 120
  end
  object FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink
    Left = 96
    Top = 228
  end
end
