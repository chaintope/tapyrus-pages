# Tapyrus Guide

本リポジトリは、サイト https://site.tapyrus.chaintope.com/ のコンテンツを管理しています。

## コンテンツの追加・変更

Jekyllにより生成されたコンテンツは`docs`フォルダに反映されます。
Github Pagesの設定により`docs`以下をサイトとして公開するようになっているため、
コンテンツを追加・変更する場合は、`docs`以下も含めてPRを作成してください。

### コンテンツの作成

Jekyllベースで作成されているため、以下のコマンドでlocalhost:4000でサイトが起動します。

    $ bundle exec jekyll s

上記のコマンドでは`docs`以下のコンテンツのURLもすべてlocalhost:4000になるため、
PRを作成する際は、事前に以下のコマンドを実行しプロダクション用のURLを適用してください。

    $ bundle exec jekyll build
