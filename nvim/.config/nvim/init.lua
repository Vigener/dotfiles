-- File-viewer nvim for termscope / herdr. Not an editing IDE.
-- Active: colorscheme + heading colors. Markdown markers stay as-is.

vim.o.termguicolors = true
vim.o.background = "dark"
vim.o.number = true
vim.o.mouse = "a"
vim.o.ignorecase = true
vim.o.smartcase = true

vim.cmd.colorscheme("catppuccin")

-- 0.12 markdown highlighting uses @markup.heading.*.
-- Bundled catppuccin only colors the old markdownH1..H6 groups.
local heading_links = {
  ["@markup.heading"] = "markdownH1",
  ["@markup.heading.1"] = "markdownH1",
  ["@markup.heading.2"] = "markdownH2",
  ["@markup.heading.3"] = "markdownH3",
  ["@markup.heading.4"] = "markdownH4",
  ["@markup.heading.5"] = "markdownH5",
  ["@markup.heading.6"] = "markdownH6",
  ["@markup.heading.1.markdown"] = "markdownH1",
  ["@markup.heading.2.markdown"] = "markdownH2",
  ["@markup.heading.3.markdown"] = "markdownH3",
  ["@markup.heading.4.markdown"] = "markdownH4",
  ["@markup.heading.5.markdown"] = "markdownH5",
  ["@markup.heading.6.markdown"] = "markdownH6",
}
for src, dest in pairs(heading_links) do
  vim.api.nvim_set_hl(0, src, { link = dest })
end

-- IME lives on MBA; nvim is on mini. Force ABC on enter / leave-insert.
-- Does not lock かな. herdr prefix ASCII switch is separate (client-side).
local mba_ime_last = 0
local function mba_ascii_ime()
  local now = vim.uv.now()
  if now - mba_ime_last < 80 then
    return
  end
  mba_ime_last = now
  vim.system({
    "ssh",
    "-o",
    "ConnectTimeout=1",
    "-o",
    "BatchMode=yes",
    "mac",
    "/opt/homebrew/bin/macism",
    "com.apple.keylayout.ABC",
    "0",
  }, { detach = true })
end

vim.api.nvim_create_autocmd({ "VimEnter", "InsertLeave", "CmdlineEnter", "FocusGained" }, {
  callback = mba_ascii_ime,
})

-- Parked 2026-08-15: render-markdown.nvim (document-render, conceals ### / -).
-- Clone stays on disk. Uncomment the block to try the luxury view again.
--
-- vim.pack.add({
--   "https://github.com/MeanderingProgrammer/render-markdown.nvim",
-- }, { confirm = false })
-- require("render-markdown").setup({
--   heading = {
--     sign = false,
--     icons = { "◆ ", "◇ ", "○ ", "• ", "• ", "• " },
--   },
--   code = { sign = false },
--   bullet = { icons = { "●", "○", "◆", "◇" } },
--   checkbox = {
--     unchecked = { icon = "☐ " },
--     checked = { icon = "☑ " },
--   },
-- })
