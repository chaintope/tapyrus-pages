---
layout: single
permalink: /core/
title: "Tapyrus Core"
---

Tapyrusは、任意のビジネスユースケースに応じて独自のブロックチェーンネットワークを構成可能なエンタープライズ向けのブロックチェーンです。
各ブロックチェーンネットワークは、ビジネスを推進するフェデレーションが管理するSigner Networkと、
誰もが参加可能な共有台帳ネットワークであるTapyrus Networkで構成されます。

![network](/assets/images/tapyrus-network-diagram.png)

## Signer Network {#signer-network}

Signer Networkは、ネットワークのセットアップ時に予め定められたフェデレーションのメンバーによって運営されます。
フェデレーションのメンバーはTapyrus Networkにブロードキャストされたトランザクションを収集、検証し、
有効なトランザクションを含むブロックを生成します。生成したブロックはTapyrus Networkにブロードキャストされます。

ブロックは、フェデレーションメンバーによるブロックに対するデジタル署名により作成されます。
このデジタル署名はブロックに`proof`としてセットされ、Tapyrus Networkの各フルノードは、この署名が有効か検証することでブロックの有効性を検証します。

### 署名鍵 {#signing-key}

ブロックの有効性検証を行う際の公開鍵は、フェデレーションメンバーの集約公開鍵を使用します。

チェーンのセットアップ段階で、フェデレーションの各メンバーは、それぞれブロックを承認するための楕円曲線暗号の鍵ペアを用意します。
これらの公開鍵をメンバー間で共有し、全メンバーの公開鍵を加算して集約公開鍵を生成します。
この集約公開鍵はパラメーターとしてチェーンのジェネシスブロックの`xfield`に埋め込まれ、
各フルノードは埋め込まれた集約公開鍵を使用して署名検証を行います。[^key-update]

### Signerノード {#signer-node}

Signer Networkを運営するためのノード実装として、[Tapyrus Signer](https://github.com/chaintope/tapyrus-signer/)を提供しています。
フルノードと一緒に実行することで、フェデレーションメンバーと通信し、ブロックの署名を完成させます。
この時、StinsonとStrobl(2001)による**検証可能で安全な分散Schnorr署名と(t, n)閾値署名方式**[^threshold]を基に、
各フェデレーションメンバーの秘密鍵を明かすことなく、集約公開鍵に対して有効なSchnorr署名を作成します。

※ Tapyrusのプロトコル上、有効なSchnorr署名が作成できればよく、Tapyrus Signer以外の実装も使用可能です。
{: .notice}

## Tapyrus Network {#tapyrus-network}

Tapyrus Network は誰もが参加可能な共有台帳ネットワークで、ジェネシスブロックから最新のブロックまでブロックチェーンのすべての
オンチェーンデータの提供、新規トランザクションの発行、伝播をサポートします。
Tapyrus のフルノード[Tapyrus Core](https://github.com/chaintope/tapyrus-core/)は、
Bitcoinの参照実装である[Bitcoin Core](https://github.com/bitcoin/bitcoin)をベースに、以下の変更を行ったノード実装です。

* コンセンサスアルゴリズムの変更
* トランザクションIDのマリアビリティの修正
* オラクルを利用したコントラクトのサポート
* Colored Coin機能のサポート

プロトコルの詳細や、機能については[Tapyrus Technical Overview](https://github.com/chaintope/tapyrus-core/blob/master/doc/tapyrus/Tapyrus_Technical_Overview_ja.pdf) を参照ください。

## セットアップ

### Tapyrus Core

各環境毎のTapyrus Coreのセットアップ方法は、以下のリンクを参照ください。

* [Tapyrus Coreノード構築方法（Ubuntu版）](/setup/ubuntu)
* [Tapyrus Coreノード構築方法（macOS版）](/setup/osx)
* [Tapyrus Coreノード構築方法（Docker版）](/setup/docker)
* [Tapyrus Coreノード devモード起動方法（MacOS/Ubuntu版）](/setup/dev-local)
* [Tapyrus Coreノード devモード起動方法（Docker版）](/setup/dev-docker)

[^key-update]: フェデレーションメンバーに変更がある場合、切り替わりのブロックの`xfield`にメンバー変更後の集約公開鍵がセットされ、それ以降のブロックでは更新された集約公開鍵を使用して署名検証が行われます。
[^threshold]: [http://cacr.uwaterloo.ca/techreports/2001/corr2001-13.ps](http://cacr.uwaterloo.ca/techreports/2001/corr2001-13.ps)
