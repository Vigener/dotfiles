// Offline smoke: no package imports. Choose an installed Japanese font.
#set page(width: 148mm, height: 180mm, margin: 16mm, numbering: "1")
#set text(font: "Hiragino Sans", lang: "ja", size: 11pt)
#set heading(numbering: "1.")
= 日本語組版の確認
日本語、句読点、英数字 ABC 123。数式・図表・参照を確認します。
$ E = m c^2, quad integral_0^1 x^2 dif x = 1/3 $
#figure(rect(width: 65mm, height: 15mm, fill: blue.lighten(80%))[図の領域], caption: [簡単な図]) <diagram>
#figure(table(columns: 2, [項目], [値], [試行数], [12], [平均], [0.25]), caption: [確認用の表]) <values>
@diagram と @values を参照します。
#pagebreak()
= 二ページ目
改ページ後の日本語と参照：@diagram。
$ A = mat(1, 2; 3, 4), quad sum_(i=1)^n i = (n(n+1))/2 $
