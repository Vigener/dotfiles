#import ".typst/template.typ": report
#import "@preview/physica:0.9.8": *

// #import "/assets/5-2/mpi_collective_tables.typ": collective_tables // 別のファイルからテーブルをインポートする例
#import "sample_tables.typ": sample_tables // 別のファイルからテーブルをインポートする例

#show: report.with(
  title: "レポート",
  // heading-numbering: "1.a", // 変更したい場合はここで指定
  // show-toc: true, // 先頭に目次を表示
  show-toc: false, // 先頭に目次を非表示
)

// #set math.equation(numbering: none) // 数式番号を非表示にする。デフォルトは有効なので、必要に応じてここで上書き。

= 
== サンプルテーブル

#figure(
  // sample_tables.at(0),at(0),
  // caption: sample_tables.at(0).at(1),
  sample_tables.at(0),
  caption: [sample 1($ f(x)= 2x$)],
  kind: table,
)

#align(center)[
  #grid(
    columns:2, 
    gutter: 1em,
    figure(sample_tables.at(0), caption: [sample 1], kind: table),
    figure(sample_tables.at(1), caption: [sample 2], kind: table)
  )
]

== ブラケットを簡単に書く(パッケージの使用例)

$
  ket("ψ") \ // |ψ⟩
  bra("φ") \ // ⟨φ|
  braket("ψ", "φ") \ // ⟨ψ|φ⟩
  ket(0) + ket(1) \ // |0⟩ + |1⟩
  mat(
    1,2;
    3,4;
  ) \ // 行列
  frac(1, 2) \ // 分数
  sqrt(2) \ // 平方根
$

== 役立つリンク

- #link("https://qiita.com/tomoyatajika/items/649884befe95c5f1dcea#%E6%95%B0%E5%BC%8F%E3%82%92--%E3%81%AE%E4%BD%8D%E7%BD%AE%E3%81%A7%E6%8F%83%E3%81%88%E3%81%9F%E3%81%84")[基本的な書き方]

- #link("https://qiita.com/key_271/items/8629980c4c1ff0e55f41")[便利パッケージと使用例の紹介]