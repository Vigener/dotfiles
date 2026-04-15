// ============================================================
// Typst レポートテンプレート
// ============================================================
// このテンプレートは大学のレポート作成に使える汎用的な構成です。
// 必要な部分を編集して使用してください。

// ============================================================
// 1. 基本的な文書設定
// ============================================================

// 用紙サイズの設定（a4, us-letter など）
#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),  // 余白の設定
)

// テキストの基本設定
#set text(
  lang: "ja",      // 日本語設定
  size: 11pt,      // 基本フォントサイズ
  // font: "Noto Serif CJK JP",  // フォント（システムに応じて変更）
)

// 段落の設定
#set par(
  justify: true,        // 両端揃え
  leading: 0.65em,      // 行間
  first-line-indent: 1em,  // 段落の字下げ
)

// 見出しの設定
#set heading(numbering: "1.1")  // 見出しに番号を付ける（1.1, 1.2 など） 1.aなども可能

// リンクの色設定
#show link: set text(fill: blue)

// ============================================================
// 2. カスタム関数・ユーティリティ
// ============================================================

// リンクを自動的に脚注化する機能
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// 参考文献セクション以降では脚注化を無効にするフラグ
#let in-references = state("in-references", false)

// URL毎の初出を記録（重複する脚注を防ぐ）
#let seen-urls = state("seen-urls", (:))

// URLと表示テキストのペアを記録（参考文献自動生成用）
#let url-details = state("url-details", (:))

// ============================================================
// ラベル・式参照マクロ（ページ内リンク／式番号付け用）
// 使い方の要点：
// - 見出しにラベルを付けるには、見出しの直後に `#label("my-id")` を置いてください。
// - 式にラベルを付けるには、式を出力するマクロ `#eq("eq-id")[ ... ]` を使ってください。
// - 参照は `#ref("eq-id")`（式番号）または `#xref("my-id")`（節番号）を使います。
// 例：`#eq("eq:bern")[$E = mc^2$]` → 後で `#ref("eq:bern")` と参照できます。

// 見出しラベル辞書（ラベル名 -> 見出し番号 例: "1.2"）
#let labels = state("labels", (:))

// 最後に表示された見出し要素を一時的に保持（`#label` から参照するため）
#let last-heading = state("last-heading", null)

// 式ラベル辞書（ラベル名 -> 番号）と式カウンタ
#let equations = state("equations", (:))
#let eq-counter = state("eq-counter", 0)

// 見出しにラベルを付ける（見出し直後に呼ぶ）
#let label(id) = {
  context {
    let h = last-heading.get()
    if h != null {
      let num = if h.has("number") { h.number } else { content-to-string(h.body) }
      labels.update(d => { d.insert(id, num); d })
    }
  }
}

// 式を出力しつつラベルを記録するマクロ
#let eq(id) = (body) => {
  context {
    // カウンタを進めてラベルに紐付け
    eq-counter.update(n => n + 1)
    let num = eq-counter.get()
    equations.update(d => { d.insert(id, num); d })

    // 見た目: 数式（中央）と右寄せの番号
    #figure(
      vcenter: true,
    )[
      #row(align: (center, right))[
        #math.equation(block: true)[body]
        #h(0.5em)
        #text(size: 10pt)[(#num)]
      ]
    ]
  }
}

// 式参照マクロ: 登録済みの式ラベルを番号付きで返す
#let ref(id) = {
  let d = equations.get()
  if id in d {
    let n = d.at(id)
    [式(#n)]
  } else {
    [式(??)]
  }
}

// 見出し参照（節参照）: 登録済みの見出しラベルを節番号で返す
#let xref(id) = {
  let d = labels.get()
  if id in d {
    let n = d.at(id)
    [節 #n]
  } else {
    [節 ??]
  }
}

// ========================================
// 参考文献のメタデータ定義
// ========================================
// 本文中に出現するリンクの順番で配列に格納します
// 配列のインデックスは0始まり：[0] = 1番目のリンク、[1] = 2番目のリンク、...
//
// 使い方:
// 1. 本文を書き、リンクを挿入する
// 2. PDFを生成して「引用したWebサイト・資料」セクションを確認
// 3. 各リンクに振られた番号を見て、メタデータを追加
//    （1番目のリンク → 配列の[0]、2番目 → [1]、...）
//
// メタデータの項目:
// - author: 著者・発行者
// - title: タイトル・記事名
// - publisher: 発行元・サイト名
// - date: 発行日・発行年
// - access-date: アクセス日（参照日）
//
#let reference-metadata = (
  // === 使用例 ===

  // [0] 1番目に出現するリンクのメタデータ
  (
    author: "厚生労働省",
    title: "2021年 国民生活基礎調査の概況",
    publisher: "厚生労働省",
    date: "2021",
    access-date: "2025-10-27",
  ),

  // [1] 2番目に出現するリンクのメタデータ
  (
    author: "山田太郎",
    title: "研究論文のタイトル",
    publisher: "学会誌名",
    date: "2024",
    access-date: "2025-10-27",
  ),

  // メタデータを追加しないリンクは従来通り簡易表示されます
  // 例: 3番目のリンクにメタデータなし → "3. https://example.com" と表示
)

#show heading: it => {
  // 「参考文献」という見出しが出たら脚注化を無効に
  if it.body == [参考文献] {
    in-references.update(true)
  }
  it
}

#show link: it => {
  it
  // 参考文献セクション内でない場合のみ脚注化
  context {
    if not in-references.get() and type(it.dest) == str and it.dest != content-to-string(it.body) {
      let url = it.dest
      let display-text = content-to-string(it.body)
      let urls-dict = seen-urls.get()

      // URL詳細を記録（表示テキスト付き）- 参考文献自動生成用
      url-details.update(d => {
        if url not in d {
          d.insert(url, display-text)
        }
        d
      })

      if url in urls-dict {
        // 既出のURLなら上付き数字で既存の脚注番号を参照
        super[#urls-dict.at(url)]
      } else {
        // 初出のURLなら脚注を作成し、番号を記録
        let next-num = urls-dict.len() + 1
        seen-urls.update(d => {
          d.insert(url, next-num)
          d
        })
        footnote(link(url, url))
      }
    }
  }
}

// ============================================================
// 3. タイトルページ（表紙）
// ============================================================

#align(center)[
  // タイトル
  #text(size: 20pt, weight: "bold")[
    レポートのタイトルをここに書く
  ]

  #v(0.5em)

  // サブタイトル（必要に応じて）
  #text(size: 14pt)[
    〜サブタイトルや副題〜
  ]

  #v(2em)

  // 著者情報
  #text(size: 12pt)[
    学籍番号: 202310970
  ]

  #text(size: 12pt)[
    氏名: 五十嵐 尊人
  ]

  #text(size: 12pt)[
    所属: 情報科学類
  ]

  #v(1em)

  #text(size: 12pt)[
    作成日: #datetime.today().display("[year]年[month]月[day]日")
  ]
]

// 改ページ（必要に応じてコメントアウト）
// #pagebreak()

// ============================================================
// 4. 本文
// ============================================================

= はじめに

ここに序論や背景を書きます。段落は自動的に字下げされます。

複数の段落を書く場合は、空行を入れることで段落が分かれます。

== サブセクション

見出しレベル2（==）はサブセクションになります。番号は自動的に「1.1」のように付与されます。

=== さらに細かい見出し

見出しレベル3（===）も使用できます。「1.1.1」のように番号が付きます。

= 本論

== テキストの装飾

*太字*、_イタリック_（日本語では効果が薄い）、`コード`のような装飾ができます。

#text(fill: red)[赤色のテキスト]や#text(size: 14pt)[サイズを変えたテキスト]も可能です。

== リストの書き方

箇条書きリスト：
- 項目1
- 項目2
  - ネストした項目
  - もう一つ
- 項目3

番号付きリスト：
+ 最初の項目
+ 二番目の項目
  + ネストした番号付き
  + さらにもう一つ
+ 三番目の項目

== 表の作成

簡単な表は以下のように作成できます：

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, center, center),
    [項目], [値1], [値2],
    [データA], [100], [200],
    [データB], [150], [250],
    [データC], [120], [180],
  ),
  caption: [実験結果の一覧表]
)

== 数式の書き方

インライン数式：変数 $x$ や $y = m x + b$ のように書けます。

ブロック数式：
$
E = m c^2
$

より複雑な数式：
$
integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2
$

連立方程式：
$
cases(
  x + y &= 5,
  2x - y &= 1
)
$

== 画像の挿入

画像を挿入するには以下のようにします：

```typst
#figure(
  image("path/to/image.png", width: 70%),
  caption: [図のキャプション]
)
```

実際の例（画像ファイルがある場合）：
// #figure(
//   image("figure1.png", width: 70%),
//   caption: [Copy-and-patch方式の概念図]
// )

== コードブロック

プログラムコードを表示する場合：

```python
def hello_world():
    print("Hello, World!")
    return 0
```

```rust
fn main() {
    println!("Hello, Rust!");
}
```

== 引用と脚注

外部リンクは自動的に脚注化されます：
#link("https://example.com")[例のウェブサイト]

同じURLを複数回参照しても、脚注は1つにまとまります：
#link("https://example.com")[もう一度参照]

手動で脚注を追加する場合：
ここに本文を書きます#footnote[ここに脚注の内容を書きます。]

== ブロック引用

引用文は以下のように表示できます：

#block(
  fill: luma(230),
  inset: 10pt,
  radius: 4pt,
)[
  「重要な引用文をここに書きます。長い引用の場合は、このようにブロックとして独立させると読みやすくなります。」
]

= 結論

本レポートでは〜について論じた。〜という結論に至った。

= 参考文献

参考文献セクションでは、リンクは脚注化されません。

// 本文中で引用したURL一覧を自動生成（脚注番号順、メタデータ付き）
#context {
  let urls = seen-urls.get()
  let details = url-details.get()

  if urls.len() > 0 {
    // URLを脚注番号順にソート
    let sorted-urls = urls.pairs().sorted(key: p => p.at(1))

    for (url, num) in sorted-urls {
      // 配列インデックスでメタデータが定義されているか確認（num-1でインデックス取得）
      let meta-index = num - 1
      if meta-index >= 0 and meta-index < reference-metadata.len() {
        let meta = reference-metadata.at(meta-index)
        // 学術的な引用形式で表示
        [#num. #meta.author. "#meta.title". #meta.publisher. #meta.date. #link(url), （参照#meta.access-date）]
      } else {
        // メタデータがない場合は従来通り
        let display = if url in details { details.at(url) } else { "" }

        if display != "" and display != url {
          [#num. #display \ #h(1.5em) #link(url)]
        } else {
          [#num. #link(url)]
        }
      }
      linebreak()
    }
  }
}

// 手動で追加する書籍・論文など（番号は自動継続）
// リンクを含むURL参照が全部で n 個あった場合、n+1 から番号が始まります
#context {
  let url-count = seen-urls.get().len()
  let next-num = url-count + 1

  // 以下に手動で参考文献を追加（例を参考に記述してください）
  // 番号は自動で振られるので、#next-num を使用します

  // === 使用例 ===
  // [#next-num. 著者名（年）『書籍名』出版社]
  // linebreak()
  // next-num = next-num + 1
  //
  // [#next-num. 論文著者. "論文タイトル". 学会誌名, Vol.1, No.1, pp.1-10, 発行年]
  // linebreak()

  [#next-num. 五十嵐 尊人（2025）『プログラミング言語実装論』情報科学出版]

}

// ============================================================
// 付録（必要に応じて）
// ============================================================

// #pagebreak()
// = 付録A：追加資料
//
// 補足的な情報や詳細なデータをここに記載します。

// ============================================================
// 使い方メモ（実際のレポートでは削除してください）
// ============================================================

/*
【基本的な使い方】

1. コンパイル方法：
   $ typst compile report_template.typ

2. 自動監視（ファイル保存時に自動コンパイル）：
   $ typst watch report_template.typ

3. PDF出力先を指定：
   $ typst compile report_template.typ output.pdf

【カスタマイズのポイント】

- タイトルページ：3章の内容を編集
- フォント変更：#set text(font: "...") で指定
- 余白調整：#set page(margin: ...) で変更
- 見出し番号形式：#set heading(numbering: "1.a") など
- 脚注機能ON/OFF：2章のshow link部分をコメントアウト

【よく使う構文】

- 見出し： = レベル1、== レベル2、=== レベル3
- 強調： *太字*、_イタリック_、`コード`
- リスト： - 箇条書き、+ 番号付き
- リンク： #link("URL")[表示テキスト]
- 画像： #image("path.png", width: 80%)
- 数式： $ 数式 $ （インライン）、改行で独立表示
- 改ページ： #pagebreak()
- 水平線： #line(length: 100%)
- 空白： #v(1em) 縦、#h(1em) 横

【トラブルシューティング】

- 日本語が表示されない → フォントを確認、またはデフォルトフォント使用
- 画像が表示されない → パスが正しいか確認（相対パス推奨）
- コンパイルエラー → エラーメッセージの行番号を確認
*/
