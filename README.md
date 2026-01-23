# Tapyrus Guide

本リポジトリは、サイト https://site.tapyrus.chaintope.com/ のコンテンツを管理しています。

## コンテンツの追加・変更

コンテンツを追加・変更する場合は、ソースファイルを編集して PR を作成してください。
`master` ブランチにマージされると、GitHub Actions により自動的にビルド・デプロイされます。

### ローカルでのプレビュー

Jekyll ベースで作成されているため、以下のコマンドで localhost:4000 でサイトが起動します。

    $ bundle install
    $ bundle exec jekyll serve