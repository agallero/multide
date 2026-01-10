object FormGlobalConfig: TFormGlobalConfig
  Left = 0
  Top = 0
  Caption = 'Global Configuration'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 400
    Width = 624
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    ExplicitTop = 368
    ExplicitWidth = 614
    DesignSize = (
      624
      41)
    object btnOk: TButton
      Left = 425
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 415
    end
    object btnCancel: TButton
      Left = 506
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 496
    end
  end
end
