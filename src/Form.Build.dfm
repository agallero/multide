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
  OnCreate = FormCreate
  TextHeight = 15
  object LabelProgress: TLabel
    Left = 527
    Top = 371
    Width = 3
    Height = 15
  end
  object MemoLog: TMemo
    Left = 8
    Top = 30
    Width = 281
    Height = 209
    Lines.Strings = (
      'MemoLog')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object ProgressBar: TProgressBar
    Left = 48
    Top = 368
    Width = 473
    Height = 18
    TabOrder = 1
  end
  object Taskbar: TTaskbar
    TaskBarButtons = <>
    ProgressMaxValue = 100
    TabProperties = []
    Left = 584
    Top = 16
  end
end
