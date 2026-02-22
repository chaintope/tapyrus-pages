---
layout: single
permalink: /colored-coin/spec
title: "Colored Coinプロトコル"
description: "Tapyrusの1stレイヤーでネイティブにサポートされるトークン機能。OP_COLORオペコードによりコンセンサスレベルでトークンの正当性を検証し、再発行可能トークン(C1)、非再発行トークン(C2)、NFT(C3)の3種類をサポート。"
header:
  og_image: /assets/images/colored-coin.png
---

Tapyrusでは、基軸通貨（TPC）以外のトークンを取引するために、Colored Coinと呼ばれる仕組みを採用しています。
これはブロックチェーンの1stレイヤーでネイティブにサポートされるトークン機能で、
コンセンサスレベルでトークンの正当性が検証されます。

### 1 Colored Coinの概要

ブロックチェーン上で基軸通貨以外のトークンを取り扱うには、各トークンを識別するためのIDが必要になります。
BitcoinベースのOpen Assets Protocolのような2ndレイヤープロトコルでは、トークンのIDを特定するために
発行トランザクションまでの履歴を遡る必要がありました。

Tapyrusでは、新しく`OP_COLOR` opcodeを導入し、コンセンサスレベルでトークンの識別と検証を行います。
これにより、各UTXOに直接Color IDが含まれるため、トランザクションを遡ることなく即座にトークンを識別できます。
これは特に軽量ノードにとって大きなメリットとなります。

### 2 OP_COLORと検証ルール

Colored Coinの検証は、スクリプトレベルとトランザクションレベルの2段階で行われます。

#### 2.1 OP_COLOR opcode

`OP_COLOR`（0xbc）は、トークンの発行、転送、焼却を可能にするopcodeです。

**スクリプトレベルの検証:**
1. スタックの最上位要素をColor IDとして解釈します
2. スタックが空の場合、スクリプトの評価は失敗します
3. Color IDが33バイトでない場合、スクリプトの評価は失敗します

#### 2.2 トランザクションレベルの検証

スクリプトの評価が成功した後、トランザクション全体で以下の検証が行われます。

**原資の確認:**
アウトプットで指定されたColor IDと同じIDを持つトークンが、インプットに含まれているか確認します。
これにより、持っていないトークンを勝手に作成することを防ぎます。

ただし、発行トランザクションの場合は例外で、インプットのscriptPubkey（C1）またはOutPoint（C2/C3）から
正しくColor IDが導出されていれば、新規トークンの作成が許可されます。

**量の保存:**
同じColor IDについて、インプットのトークン総量 ≥ アウトプットのトークン総量であることを確認します。
これにより、トークンを勝手に増やすこと（インフレーション）を防ぎます。

例えば、100トークン持っている場合、最大100トークンまでしか送れません。
50トークン送ると、残り50トークンは別のアウトプットでお釣りとして受け取るか、焼却されます。

**その他の条件:**
- C3タイプの場合、発行量は必ず1でなければなりません

### 3 Color ID

Color IDは、1バイトのタイプと32バイトのペイロードで構成されます：

```
Color ID = Type (1 byte) + Payload (32 bytes)
```

| タイプ | 名称 | ペイロードの生成方法 | 特徴 |
|--------|------|---------------------|------|
| 0xC1 | Reissuable | 発行インプットのscriptPubkeyのSHA256ハッシュ | 再発行可能なトークン |
| 0xC2 | Non-reissuable | 発行インプットのOutPointのSHA256ハッシュ | 再発行不可能なトークン |
| 0xC3 | NFT | 発行インプットのOutPointのSHA256ハッシュ | 発行量が1に限定されるNFT |

Table #1: Color IDのタイプ

#### 3.1 Reissuable Token（C1）

再発行可能なトークンです。Color IDは、インプットが参照するscriptPubkeyのSHA256ハッシュ値から生成されます。

```
Color ID = 0xC1 || SHA256(scriptPubkey)
```

![C1 Color ID導出](/assets/images/color-id-c1.svg)

同じscriptPubkeyを持つUTXOから、同じIDのトークンを何度でも発行できます。
これにより、特定のアドレス（スクリプト）の所有者が追加発行を行う権限を持つトークンを実現できます。

#### 3.2 Non-reissuable Token（C2）

再発行不可能なトークンです。Color IDは、インプットの参照値（OutPoint = TXID || index）のSHA256ハッシュ値から生成されます。

```
Color ID = 0xC2 || SHA256(OutPoint)
```

![C2 Color ID導出](/assets/images/color-id-c2.svg)

OutPointはブロックチェーン上で重複できないため、同じIDのトークンを再度発行することはできません。
発行時に総供給量が確定するトークンに適しています。

#### 3.3 NFT（C3）

Non-Fungible Token（NFT）です。C2と同様にOutPointからColor IDを生成しますが、発行量が必ず1に制限されます。

```
Color ID = 0xC3 || SHA256(OutPoint)
```

一意のデジタル資産を表現するのに適しています。

### 4 トークン操作

#### 4.1 発行（Issue）

新しいトークンを発行するには：

1. 任意のUTXOをインプットとして使用
2. Color IDを導出（タイプに応じてscriptPubkeyまたはOutPointから）
3. CP2PKHまたはCP2SHスクリプトを含むアウトプットを作成

![トークン発行](/assets/images/token-issue.svg)

#### 4.2 転送（Transfer）

トークンを転送するには：

1. 既存のトークンUTXOをインプットとして使用
2. 同じColor IDを持つアウトプットを作成
3. 手数料用のTPCインプットも必要

![トークン転送](/assets/images/token-transfer.svg)

**重要:** 入力のトークン総量 ≥ 出力のトークン総量である必要があります。

#### 4.3 焼却（Burn）

トークンを焼却（破棄）するには：

1. 焼却したいトークンUTXOをインプットとして使用
2. 手数料用のTPCインプットも必要
3. アウトプットにはTPCのお釣りのみ（トークンアウトプットなし）

![トークン焼却](/assets/images/token-burn.svg)

トークンアウトプットを作成しないことで、インプットのトークンは永久に消滅します。

### 5 スクリプトフォーマット

Colored Coinでは、2種類のスクリプトタイプがサポートされています。

#### 5.1 CP2PKH（Colored Pay to Public Key Hash）

通常のP2PKHスクリプトの先頭にColor IDと`OP_COLOR`を付加した形式です。

```
<Color ID> OP_COLOR OP_DUP OP_HASH160 <H(pubkey)> OP_EQUALVERIFY OP_CHECKSIG
```

#### 5.2 CP2SH（Colored Pay to Script Hash）

通常のP2SHスクリプトの先頭にColor IDと`OP_COLOR`を付加した形式です。

```
<Color ID> OP_COLOR OP_HASH160 <H(redeem script)> OP_EQUAL
```

### 6 アドレスフォーマット

CP2PKHおよびCP2SHアドレスは、53バイトのペイロードを使用します：

```
Payload = Color ID (33 bytes) + Pubkey Hash or Script Hash (20 bytes)
```

| フォーマット | Production Version | Development Version |
|-------------|-------------------|---------------------|
| CP2PKH | 0x01 | 0x70 |
| CP2SH | 0x06 | 0xC5 |

Table #2: アドレスバージョンバイト

### 7 トークンメタデータ（TIP20）

TIP20は、Colored Coinトークンにメタデータを紐付けるための標準仕様です。
これにより、ウォレットやアプリケーション間で一貫したトークン情報の表示が可能になります。

#### 7.1 メタデータの紐付け方法

メタデータはPay to Contract（P2C）アドレスを通じてトークンに紐付けられます。

1. **P2Cアドレスの導出**: ベースとなる公開鍵と正規化されたメタデータのハッシュを組み合わせて、P2C公開鍵を生成
2. **トークン発行**: P2Cアドレスに送金し、そのUTXOをトークン発行トランザクションのインプットとして使用
3. **暗号学的な紐付け**: このインプットからColor IDが導出されるため、メタデータとトークンが暗号学的に結び付けられます

この仕組みにより、メタデータが特定のColor IDに対して正当なものであることを暗号学的に検証できます。

![TIP20 メタデータ紐付けスキーム](/assets/images/tip20-scheme.svg)

#### 7.2 必須フィールド

| フィールド | 説明 | 制約 |
|-----------|------|------|
| name | トークンの名称 | 最大64文字 |
| symbol | トークンのシンボル（ティッカー） | 最大12文字 |

#### 7.3 オプションフィールド

| フィールド | 説明 |
|-----------|------|
| decimals | 小数点以下の桁数（0〜18） |
| description | トークンの説明 |
| icon | トークンのアイコン画像（HTTPS URLまたはData URI） |
| website | 公式ウェブサイト |
| issuer | 発行者情報 |
| terms | 利用規約へのリンク |
| properties | カスタム属性 |

NFTの場合は、`image`、`animation_url`、`external_url`、`attributes`（トレイト情報）などの追加フィールドも利用可能です。

#### 7.4 メタデータの検証

- メタデータはRFC 8785に基づいてJSON正規化され、決定論的なハッシュ計算が行われます
- P2Cの仕組みにより、メタデータが対応するColor IDに対して正当であることを検証できます

#### 7.5 メタデータの共有

メタデータは直接ブロックチェーンに登録されるわけではないため、オフチェーンで共有する必要があります。
共有方法は特に限定されていませんが、[Tapyrus Token Registry](https://github.com/chaintope/tapyrus-token-registry/)を利用することで、
メタデータを公開・共有できます。

**Token Registryへの登録方法:**

1. [tapyrus-token-registry](https://github.com/chaintope/tapyrus-token-registry/)リポジトリにアクセス
2. 「Token Registration」テンプレートを使用してIssueを作成
3. 必要な情報（Color ID、メタデータ、ベース公開鍵、発行トランザクションのOutPointなど）を入力
4. 入力内容がTIP20のルールに適合しているか自動検証される
5. 検証をパスするとレジストリに登録され、共有される

### 8 メリット

Tapyrus Colored Coinの主なメリット：

- **コンセンサスレベルでの検証**: トークンの正当性がネットワーク全体で検証される
- **即時識別**: UTXOを見るだけでColor IDを特定可能（トランザクション履歴の遡りが不要）
- **軽量ノード対応**: SPVノードでもトークンを安全に扱える
- **効率的なスペース利用**: 2ndレイヤープロトコルで必要だったMarker Outputが不要
- **柔軟なトークン設計**: 用途に応じてC1/C2/C3を選択可能

### 参考資料

- [Tapyrus Core - Colored Coin Documentation](https://github.com/chaintope/tapyrus-core/blob/master/doc/tapyrus/colored_coin.md)
- [TIP-0020: Token Metadata Standard](https://github.com/chaintope/tips/blob/main/tip-0020.md)
- [Tapyrus Token Registry](https://github.com/chaintope/tapyrus-token-registry/)
