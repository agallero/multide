object FormAddConfig: TFormAddConfig
  Left = 0
  Top = 0
  Caption = 'Add Configuration'
  ClientHeight = 167
  ClientWidth = 589
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    589
    167)
  TextHeight = 15
  object lblCopyFrom: TLabel
    Left = 8
    Top = 64
    Width = 136
    Height = 15
    Caption = 'Copy Configuration From'
  end
  object Panel1: TPanel
    Left = 0
    Top = 126
    Width = 589
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 1
    ExplicitTop = 91
    ExplicitWidth = 464
    DesignSize = (
      589
      41)
    object btnOk: TButton
      Left = 405
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 280
    end
    object btnCancel: TButton
      Left = 486
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 361
    end
  end
  object edConfigName: TLabeledEdit
    Left = 8
    Top = 24
    Width = 553
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 107
    EditLabel.Height = 15
    EditLabel.Caption = 'Configuration name'
    TabOrder = 0
    Text = ''
  end
  object csCopyFrom: TComboBox
    Left = 8
    Top = 85
    Width = 553
    Height = 23
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ExtendedUI = True
    TabOrder = 2
  end
end
