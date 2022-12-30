object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'NetStat GUI'
  ClientHeight = 420
  ClientWidth = 1014
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    1014
    420)
  PixelsPerInch = 96
  TextHeight = 13
  object btn_List: TButton
    Left = 103
    Top = 13
    Width = 75
    Height = 46
    Caption = 'Listar'
    TabOrder = 0
    OnClick = btn_ListClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 89
    Height = 51
    Caption = 'G'
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 22
      Width = 30
      Height = 13
      Caption = 'Porta:'
    end
    object edt_Port: TEdit
      Left = 41
      Top = 19
      Width = 40
      Height = 21
      NumbersOnly = True
      TabOrder = 0
      Text = '5000'
    end
    object CheckBox_Filter: TCheckBox
      Left = 8
      Top = 0
      Width = 97
      Height = 17
      Caption = 'Filtrar'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
  end
  object ListView_Connections: TListView
    Left = 8
    Top = 66
    Width = 998
    Height = 341
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Protocolo'
        Width = 58
      end
      item
        Caption = 'Endere'#231'o Local'
        Width = 95
      end
      item
        Caption = 'Porta'
        Width = 45
      end
      item
        Caption = 'Endere'#231'o Externo'
        Width = 120
      end
      item
        Caption = 'Estado'
        Width = 80
      end
      item
        Caption = 'PID'
        Width = 45
      end
      item
        Caption = 'Aplicativo'
        Width = 150
      end
      item
        AutoSize = True
        Caption = 'Localiza'#231#227'o'
      end>
    DoubleBuffered = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    PopupMenu = PopupMenu1
    TabOrder = 2
    ViewStyle = vsReport
    OnColumnClick = ListView_ConnectionsColumnClick
    OnCompare = ListView_ConnectionsCompare
  end
  object PopupMenu1: TPopupMenu
    Left = 432
    Top = 208
    object PMI_OpenFileFolder: TMenuItem
      Caption = 'Abrir local do arquivo'
      OnClick = PMI_OpenFileFolderClick
    end
    object PMI_FileProperties: TMenuItem
      Caption = 'Propriedades do arquivo'
      OnClick = PMI_FilePropertiesClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object PMI_KillProcess: TMenuItem
      Caption = 'Finalizar processo'
      OnClick = PMI_KillProcessClick
    end
  end
end