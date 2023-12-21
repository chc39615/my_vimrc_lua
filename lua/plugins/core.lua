# 要在 lazy.nvim 載入前執行，才能設定 <leader> key
require("config").init()

return {
    { "folke/lazy.nvim", version = "*" },
}
