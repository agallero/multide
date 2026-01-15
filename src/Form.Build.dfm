object FormBuild: TFormBuild
  Left = 0
  Top = 0
  Caption = 'Updating...'
  ClientHeight = 441
  ClientWidth = 624
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
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  TextHeight = 15
  object LabelProgress: TLabel
    Left = 527
    Top = 371
    Width = 3
    Height = 15
  end
  object MemoLog: TMemo
    Left = 0
    Top = 18
    Width = 624
    Height = 382
    Margins.Left = 12
    Margins.Top = 12
    Margins.Right = 12
    Margins.Bottom = 12
    Align = alClient
    Lines.Strings = (
      'MemoLog')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitWidth = 614
    ExplicitHeight = 350
  end
  object ProgressBar: TProgressBar
    Left = 0
    Top = 0
    Width = 624
    Height = 18
    Align = alTop
    Smooth = True
    TabOrder = 1
    ExplicitWidth = 614
  end
  object Panel1: TPanel
    Left = 0
    Top = 400
    Width = 624
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 2
    ExplicitTop = 368
    ExplicitWidth = 614
    DesignSize = (
      624
      41)
    object btnOk: TButton
      Left = 450
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      Enabled = False
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 440
    end
    object btnCancel: TButton
      Left = 531
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
      ExplicitLeft = 521
    end
    object btnLog: TButton
      Left = 531
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Logs...'
      TabOrder = 2
      Visible = False
      OnClick = btnLogClick
      ExplicitLeft = 521
    end
  end
  object Taskbar: TTaskbar
    TaskBarButtons = <>
    ProgressMaxValue = 100
    TabProperties = []
    Left = 584
    Top = 16
  end
end
