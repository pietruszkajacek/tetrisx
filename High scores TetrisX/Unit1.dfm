object Form1: TForm1
  Left = 300
  Top = 107
  Width = 696
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 56
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Otworz'
    TabOrder = 0
    OnClick = OpenList
  end
  object Button2: TButton
    Left = 56
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Zapisz'
    TabOrder = 1
    OnClick = SaveList
  end
end
