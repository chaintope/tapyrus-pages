---
layout: single
permalink: /guide/signer-network-overview
title: "Signer Networkの概要"
---

Tapyrus Signerはあくまで参照実装であり、有効なSchnorr署名が作成が可能であれば、必ずしもTapyrus Signerを利用する必要はありません。

## 閾値署名方式 {#threshold-signature-scheme}

Tapyrus Signer Network(TSN)の署名アルゴリズムは、"Provably Secure Distributed Schnorr Signatures and a (t, n) Threshold Scheme for Implicit Certificates"[^1]に基づいています。この署名方式では、n人の署名者のうちt人が協力しなければ署名が発行されません。


## BlockVSSの構成 {#blockvss-structure}
BlockVSSは2つのVSSシークレットを持っています。一つは候補ブロックに賛成するための署名を生成するキーで、もう一つは反対するための署名を生成するキーです。

- Blockvss[0]: 候補ブロックのSighash。
- Blockvss[1]: 候補ブロックに賛成するVSSのためのデータのオブジェクト。
  - parameter:　秘密分散パラメータを格納したオブジェクト。
    - threshold: 閾値の整数値 - 1
    - share_count: 署名者数の整数値
  - commitments: コミットメントの配列。コミットメントはsecp256k1曲線点でありxとyの座標を持ちます。
- Blockvss[2]: 賛成のシークレットシェア。secp256k1曲線のスカラー値をhex形式で表したものです。
- Blockvss[3] 反対のVSSの追加データのオブジェクト。フィールドのプロパティは賛成のVSSのデータのオブジェクトと同じです。
- Blockvss[4] 反対のVSSのシークレットシェア。secp256k1曲線のスカラー値をhex形式で表したものです。

*BlockVSSの例*
```javascript
{
  "Blockvss": [
    "d68e99f1135c6661f174f4bee7c9b94a1e7dbb0eb7609f0aea118340ffd05944",
    {
      "parameters": {
        "threshold": 1,
        "share_count": 3
      },
      "commitments": [
        {
          "x": "1fc491aef36b480160d71b099fe376e58fe0a915d0b382bb2c5daeb2f46665d2",
          "y": "d4ec3f9d4e5a7494447c9f97476abdc475376311e49b7ce6000f9d0640c08fe9"
        },
        {
          "x": "647d33c9bb32320e8b7476743577180021f36e95aa939a96896e7e5be89f08fe",
          "y": "6a68092234664285e4fd244623c406d8feead1e44c1be2b7272f77c733c4ab48"
        }
      ]
    },
    "23a7185d3f2b402ff54168b880da783a7535e55cbc3ad657e5da2f2336cb349c",
    {
      "parameters": {
        "threshold": 1,
        "share_count": 3
      },
      "commitments": [
        {
          "x": "1fc491aef36b480160d71b099fe376e58fe0a915d0b382bb2c5daeb2f46665d2",
          "y": "2b13c062b1a58b6bbb836068b895423b8ac89cee1b648319fff062f8bf3f6c46"
        },
        {
          "x": "4247c04efc03c0c94bb129715d2b8d6128018e607936d9e3075bbb87f411043e",
          "y": "fc8a579ca133a73ad27b0e9499b180c18fe51110beb8ebc90e18d12f2a490f4a"
        }
      ]
    },
    "972ad402adf631e5a52ffe14803a40b19c6f578678a57bc833364842cce9c68"
  ]
}
```

## LocalSigの構成 {#localsig-structure}

```javascript
{
  "Blocksig": [
    "d68e99f1135c6661f174f4bee7c9b94a1e7dbb0eb7609f0aea118340ffd05944",
    "218f1a47f87b48fa5ee77202fd14b15dbd04f8ef63834a56c1821f9b4ee842ed",
    "e645628bb53b9902f89771863037e99448069014ab99860b26a3a710a5f746df"
  ]
}
```



### ラウンド {#round}
Signer Networkのブロック生成はラウンド制で行います。  
ラウンドが開始する前に、ラウンドロビン方式で1つのSignerノードをラウンドマスターとして選出します。
ラウンドマスターは、候補ブロックを生成し、他のSignerノード（ラウンドメンバー）に候補ブロックを公開します。
候補ブロックを受信したラウンドメンバーは確認をおこない、候補ブロックの賛成・反対を判断し、各判断に対応したキーを用いて署名を付与する。
閾値以上の賛成署名が付与されると、ラウンドが成功し１つのブロックが生成されます。

各ラウンド開始時、タイマーがスタートする。各ラウンドの制限時間は65秒で、制限時間を過ぎるとラウンドは失敗し、次のラウンドが開始されます。
これにより、一部のSignerが停止している場合でも、閾値を超える署名が生成可能であればブロック生成が可能で、システムの可用性を高めることが可能です。

#### ラウンドマスターのフロー {#raund-master-flow}
1. 新しいラウンドを開始する
2. 候補ブロックを生成
3. 他のSignerノードに新しいブロックを公開（Redis Pub/Subを使用）
4. 署名発行プロトコル([以下](#signature-issuing-protocol)で説明)
5. ブロックの公開
  - ブロックがNGの場合、警告を記録
  - ブロックがOKの場合、次のステップへ


#### ラウンドメンバーのフロー {#raund-member-flow}
1. 新しいラウンドを開始する
2. 候補ブロックメッセージの受信を待つ
3. 候補ブロックの確認([以下](#signature-issuing-protocol)で説明)
  - ブロックがNGの場合、警告を記録
  - ブロックがOKの場合、次のステップへ


#### 署名発行のプロトコル {#signature-issuing-protocol}




[^1]: Stinson, D. R., & Strobl, R. (2001). Provably secure distributed schnorr signatures and a (T, n) threshold scheme for implicit certificates. In Lecture Notes in Computer Science (including subseries Lecture Notes in Artificial Intelligence and Lecture Notes in Bioinformatics) (Vol. 2119, pp. 417–434). Springer Verlag. https://doi.org/10.1007/3-540-47719-5_33