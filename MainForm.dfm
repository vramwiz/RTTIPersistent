object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = #12463#12521#12473#12398#20195#20837#12392#20445#23384#12392#35501#12415#36796#12415
  ClientHeight = 231
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 115
    Width = 505
    Height = 95
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 505
    Height = 115
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object Panel2: TPanel
      Left = 282
      Top = 1
      Width = 222
      Height = 113
      Align = alClient
      TabOrder = 0
      object Button3: TButton
        Left = 1
        Top = 87
        Width = 220
        Height = 25
        Align = alBottom
        Caption = #8593#12288#12501#12449#12452#12523#12363#12425#35501#12415#36796#12415
        TabOrder = 0
        OnClick = Button3Click
      end
      object Panel6: TPanel
        Left = 1
        Top = 17
        Width = 64
        Height = 70
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        object ListBox2: TListBox
          Left = 0
          Top = 0
          Width = 64
          Height = 70
          Align = alClient
          ItemHeight = 13
          TabOrder = 0
          OnClick = ListBox2Click
        end
      end
      object CheckBox2: TCheckBox
        Left = 88
        Top = 56
        Width = 97
        Height = 17
        Caption = 'CheckBox2'
        TabOrder = 2
      end
      object Edit2: TEdit
        Left = 88
        Top = 23
        Width = 121
        Height = 21
        TabOrder = 3
      end
      object Panel9: TPanel
        Left = 1
        Top = 1
        Width = 220
        Height = 16
        Align = alTop
        Caption = 'To'
        TabOrder = 4
      end
    end
    object Panel3: TPanel
      Left = 210
      Top = 1
      Width = 72
      Height = 113
      Align = alLeft
      TabOrder = 1
      object Button1: TButton
        Left = 1
        Top = 1
        Width = 70
        Height = 111
        Align = alClient
        Caption = #20195#20837' ->'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 209
      Height = 113
      Align = alLeft
      TabOrder = 2
      object Button2: TButton
        Left = 1
        Top = 87
        Width = 207
        Height = 25
        Align = alBottom
        Caption = #8595#12288#12501#12449#12452#12523#12395#20445#23384
        TabOrder = 0
        OnClick = Button2Click
      end
      object Panel5: TPanel
        Left = 1
        Top = 17
        Width = 64
        Height = 70
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        object ListBox1: TListBox
          Left = 0
          Top = 0
          Width = 64
          Height = 42
          Align = alClient
          ItemHeight = 13
          TabOrder = 0
          OnClick = ListBox1Click
        end
        object Panel7: TPanel
          Left = 0
          Top = 42
          Width = 64
          Height = 28
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 1
          object Button4: TButton
            Left = 0
            Top = 0
            Width = 33
            Height = 28
            Align = alLeft
            Caption = '+'
            TabOrder = 0
            OnClick = Button4Click
          end
          object Button5: TButton
            Left = 33
            Top = 0
            Width = 31
            Height = 28
            Align = alClient
            Caption = '-'
            TabOrder = 1
            OnClick = Button5Click
          end
        end
      end
      object Edit1: TEdit
        Left = 80
        Top = 23
        Width = 97
        Height = 21
        TabOrder = 2
        OnExit = CheckBox1Exit
      end
      object CheckBox1: TCheckBox
        Left = 80
        Top = 50
        Width = 97
        Height = 17
        Caption = 'CheckBox1'
        TabOrder = 3
        OnExit = CheckBox1Exit
      end
      object Panel8: TPanel
        Left = 1
        Top = 1
        Width = 207
        Height = 16
        Align = alTop
        Caption = 'From'
        TabOrder = 4
      end
    end
  end
  object ComboBox1: TComboBox
    Left = 0
    Top = 210
    Width = 505
    Height = 21
    Align = alBottom
    Style = csDropDownList
    TabOrder = 2
    OnChange = ComboBox1Change
  end
end
