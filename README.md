# RTTIPersistent Library for Delphi

このライブラリは、Delphi の `TPersistent` クラスを拡張して、実行時型情報 (RTTI) を用いた **自動代入** や **ファイル入出力** を実現するものです。以下のような機能を提供します：

## 特徴

- `TRTTIPersistent`
  - RTTIを利用して同一型のクラス同士でプロパティの自動コピーを実装（`Assign`）

- `TRTTIPersistentIni`
  - 上記を継承し、INI形式のファイルへの保存・読み込みを可能にしたクラス

- `TRTTIPersistentIniList<T>`
  - オブジェクトリスト（`TObjectList<T>`）に対応したINI保存・読込クラス
  - `AddNew`, `InsertNew`, `DeleteItem`, `Exchange`, `LoadFromFile`, `SaveToFile` などの便利メソッドを提供

## 使い方の例

### 1. 単一オブジェクトの保存・復元

```pascal
var
  Pos: TRTTIFormPosition;
begin
  Pos := TRTTIFormPosition.Create;
  try
    Pos.InitializeFromForm(Self);
    Pos.SaveToFile;
  finally
    Pos.Free;
  end;
```

### 2. リスト形式の保存・復元

```pascal
var
  List: TRTTIPersistentIniList<TSampleItem>;
begin
  List := TRTTIPersistentIniList<TSampleItem>.Create(True);
  try
    List.Filename := 'sample.ini';
    List.LoadFromFile;
    // 要素を編集...
    List.SaveToFile;
  finally
    List.Free;
  end;
```

## 注意点

- `Assign` は `TPersistent` ではなく、必要に応じて `TObjectList<T>` 型に対して別メソッドとして定義する必要があります（`AssignList` など）
- `LoadFromFile` はファイルが存在しない場合は `Clear` しない方が自然ですが、ファイルが読み込まれた場合には `Clear` を呼ぶべきです


## ライセンス

このライブラリは自由に利用・改変可能です。商用・非商用を問わずご活用ください。
