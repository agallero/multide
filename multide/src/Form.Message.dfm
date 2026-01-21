object FormMessage: TFormMessage
  Left = 0
  Top = 0
  Caption = 'FormMessage'
  ClientHeight = 135
  ClientWidth = 481
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PopupMode = pmAuto
  Position = poScreenCenter
  ShowInTaskBar = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  TextHeight = 15
  object ButtonPanel: TPanel
    Left = 0
    Top = 94
    Width = 481
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    ExplicitTop = 62
    ExplicitWidth = 471
    DesignSize = (
      481
      41)
    object ButtonOk: TButton
      Left = 203
      Top = 8
      Width = 75
      Height = 25
      Anchors = []
      Cancel = True
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
  end
  object MessagePanel: TPanel
    Tag = 1
    Left = 0
    Top = 0
    Width = 481
    Height = 94
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    ExplicitWidth = 471
    ExplicitHeight = 62
    object LblMessage: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 20
      Width = 441
      Height = 54
      Margins.Left = 20
      Margins.Top = 20
      Margins.Right = 20
      Margins.Bottom = 20
      Align = alClient
      Alignment = taCenter
      Caption = 'LblMessage'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      ExplicitWidth = 72
      ExplicitHeight = 19
    end
  end
end
