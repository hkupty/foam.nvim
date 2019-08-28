local foam = {}

foam.hist = {}
foam.opts = {}
foam.alt_bufs = {}
foam.folded = {}

foam.new_float = function(opt)

  local id = vim.api.nvim_open_win(
    opt.buffer,
    opt.enter or true, {
    relative = "win",
    win = opt.win,
    height = opt.height,
    width = opt.width,
    row = opt.row,
    col = opt.col
  })

  vim.api.nvim_win_set_option(id, "number", false)
  vim.api.nvim_win_set_option(id, "relativenumber", false)

  table.insert(foam.hist, id)
  foam.opts[id] = opt
end

foam.toggle = function(opt)
  local id = opt.id or foam.hist[#foam.hist]
  local cfg = vim.api.nvim_win_get_config(id)
  local opt = foam.opts[id]

  local toggled = cfg.height == 1

  if toggled then
    vim.api.nvim_win_set_config(id, {
        relative = "win",
        row = opt.row,
        col = opt.col,
        width = opt.width,
        height = opt.height
      })
    vim.api.nvim_win_set_buf(id, opt.buffer)
  else
    local alt_buf = foam.alt_bufs[id]
    if alt_buf == nil then
      alt_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(alt_buf, 0, -1, true, {opt.label})
      foam.alt_bufs[id] = alt_buf
    end
    vim.api.nvim_win_set_buf(id, alt_buf)
    -- FIXME After 0.4, the first set_option should fix this
    vim.api.nvim_win_set_option(id, "number", false)
    vim.api.nvim_win_set_option(id, "relativenumber", false)
    vim.api.nvim_win_set_config(id, {
        relative = "win",
        row = 0,
        col = 0,
        width = vim.api.nvim_call_function("strdisplaywidth", {opt.label, 0}),
        height = 1
      })

  end
end

-- HACK for debug
_G.foam = foam

return foam
