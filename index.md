---
layout: splash
permalink: /
title: "Tapyrus Guide - エンタープライズ向けブロックチェーン技術情報"
description: "Tapyrusブロックチェーンの技術情報サイト。Colored Coin、Tracking Protocol、API、ネットワーク構築など、エンタープライズ向けブロックチェーンの開発に必要な情報を提供。"
hidden: true
header:
  overlay_color: "#000"
  overlay_filter: "0.5"
  overlay_image: /assets/images/home.jpg
  actions:
    - label: "Technical Overview"
      url: "https://github.com/chaintope/tapyrus-core/blob/master/doc/tapyrus/Tapyrus_Technical_Overview.pdf"
      caption: "Photo credit: [**Unsplash**](https://unsplash.com)"
excerpt: >
  エンタープライズ向けハイブリッド型ブロックチェーン
feature_row:
  - image_path: /assets/images/tapyrus-logo.png
    alt: "Tapyrus"
    title: "Tapyrus"
    excerpt: "Tapyrusはビジネス要件に応じて構成可能な独自のエンタープライズブロックチェーンです。ネットワークには誰でも自由に参加でき、取引の作成や検証が行えます。
一方、ブロック生成や機能追加の権限は予め設定した管理者ネットワークに属するため、従来のパブリックブロックチェーンのガバナンスやファイナリティといった課題を解消します。"
    url: "/core/"
    btn_class: "btn--info"
    btn_label: "Learn more"
  - image_path: /assets/images/network.jpg
    alt: "Test Network"
    title: "Test Network"
    excerpt: "誰でもすぐにTapyrusの動作検証ができるよう、テスト用のネットワークおよび、そのネットワークで使用するコインを配布するfaucetを公開しています。"
    url: "/network/"
    btn_class: "btn--info"
    btn_label: "Learn more"
  - image_path: /assets/images/api.jpg
    alt: "Tapyrus API"
    title: "Tapyrus API"
    excerpt: "Tapyrus APIは、お客様のシステムにブロックチェーン機能を簡単に導入するために、chaintopeが提供するREST APIサービスです。
ブロックチェーンの専門知識を必要とです、一般的なWeb APIを利用してブロックチェーンの機能をシステムに組み込むことができます。"
    url: "/api/"
    btn_class: "btn--info"
    btn_label: "Learn more"
  - image_path: /assets/images/colored-coin.svg
    alt: "Colored Coin Protocol"
    title: "Colored Coinプロトコル"
    excerpt: "Tapyrusでは、基軸通貨（TPC）以外のトークンを1stレイヤーでネイティブにサポートしています。
OP_COLOR opcodeによりコンセンサスレベルでトークンの正当性が検証され、再発行可能/不可能なトークンやNFTを発行できます。"
    url: "/colored-coin/spec"
    btn_class: "btn--info"
    btn_label: "Learn more"
  - image_path: /assets/images/tracking-v1.svg
    alt: "Tracking Protocol v1"
    title: "Tracking Protocol v1"
    excerpt: "RSAアキュムレーターを使用して大量のアイテムIDを固定サイズに圧縮し、サプライチェーンなどでモノの移動を効率的にトラッキングするプロトコルです。"
    url: "/tracking/v1"
    btn_class: "btn--info"
    btn_label: "Learn more"
  - image_path: /assets/images/tracking-v2.svg
    alt: "Tracking Protocol v2"
    title: "Tracking Protocol v2"
    excerpt: "v1を拡張し、Vector Pedersen Commitmentを使用してアイテムの構成要素（部材の量など）も追跡可能にしたプロトコルです。量を秘匿したままの取引も実現できます。"
    url: "/tracking/v2"
    btn_class: "btn--info"
    btn_label: "Learn more"
---

{% include feature_row %}

### 更新情報

<ul>
  {% for post in site.posts %}
    <li>
      {%- assign date_format = site.minima.date_format | default: "%Y-%m-%-d" -%}
      <span class="post-meta">{{ post.date | date: date_format }}</span>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
