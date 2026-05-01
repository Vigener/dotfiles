#let sample_tables = (
  (
    align(center)[#table(
      columns: 2,
      align: (auto, auto),
      table.header([$x$], [$f(x)$]),
      table.hline(),
      [1], [2],
      [4], [8],
    )]
  ),
  (
    align(center)[#table(
      columns: 2,
      align: (auto, right),
      table.header([商品], [価格(税込)]),
      table.hline(),
      [りんご], [$100$円],
      [みかん], [$80$円],
    )]
  ),
)