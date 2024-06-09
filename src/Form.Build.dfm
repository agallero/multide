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
  object MemoLog: TMemo
    Left = 136
    Top = 80
    Width = 281
    Height = 209
    Lines.Strings = (
      'MemoLog')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
end
