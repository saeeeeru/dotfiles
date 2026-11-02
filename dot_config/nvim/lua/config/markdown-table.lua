-- Markdown の pipe table を読むための補助
-- - render-markdown の custom handler として、表を wrap の影響を受けない virt_lines で描く
--   （元の行は conceal_lines で隠し、カーソルが乗った行だけ生表示になる）
-- - カーソル行を「見出し / 値」の縦並びで float に表示する
local M = {}

local ns = vim.api.nvim_create_namespace("markdown_table_record")
local dw = vim.fn.strdisplaywidth

local HL_HEAD = "RenderMarkdownTableHead"
local HL_ROW = "RenderMarkdownTableRow"
local HL_BORDER = "RenderMarkdownTableRow"

-- 表の解析 -----------------------------------------------------------------

local function cell_texts(bufnr, row_node)
	local cells = {}
	for child in row_node:iter_children() do
		if child:type() == "pipe_table_cell" then
			local text = vim.treesitter.get_node_text(child, bufnr)
			cells[#cells + 1] = vim.trim(text):gsub("\\|", "|")
		end
	end
	return cells
end

local function alignments(bufnr, delimiter_node)
	local result = {}
	for child in delimiter_node:iter_children() do
		if child:type() == "pipe_table_delimiter_cell" then
			local text = vim.trim(vim.treesitter.get_node_text(child, bufnr))
			local left, right = text:sub(1, 1) == ":", text:sub(-1) == ":"
			result[#result + 1] = (left and right) and "center" or (right and "right" or "left")
		end
	end
	return result
end

-- 表を { header, align, rows = { { line, cells } }, lines = { 表の全行 } } にする
local function parse_table(bufnr, table_node)
	local result = { header = {}, align = {}, rows = {}, lines = {} }
	for child in table_node:iter_children() do
		local t = child:type()
		local line = child:range()
		if t == "pipe_table_header" then
			result.header = cell_texts(bufnr, child)
			result.lines[#result.lines + 1] = line
		elseif t == "pipe_table_delimiter_row" then
			result.align = alignments(bufnr, child)
			result.lines[#result.lines + 1] = line
		elseif t == "pipe_table_row" then
			result.rows[#result.rows + 1] = { line = line, cells = cell_texts(bufnr, child) }
			result.lines[#result.lines + 1] = line
		end
	end
	return result
end

local function get_table_node(bufnr, row)
	local parser = vim.treesitter.get_parser(bufnr, "markdown", { error = false })
	if not parser then
		return nil
	end
	parser:parse({ row, row + 1 })

	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local col = (line:find("%S") or 1) - 1
	local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col }, lang = "markdown" })
	while node do
		if node:type() == "pipe_table" then
			return node
		end
		node = node:parent()
	end
	return nil
end

-- 表の描画 -----------------------------------------------------------------

-- インラインの装飾記号を外して、表示する文字だけにする
local function plain(text)
	return (
		text:gsub("%[(.-)%]%b()", "%1")
			:gsub("%*%*(.-)%*%*", "%1")
			:gsub("__(.-)__", "%1")
			:gsub("`([^`]*)`", "%1")
	)
end

-- 表示幅 width で折り返す。半角英数字の連続は 1 語として扱い、語の途中では切らない
local function wrap_text(text, width)
	local tokens = {}
	for _, ch in ipairs(vim.fn.split(text, "\\zs")) do
		local last = tokens[#tokens]
		if ch:match("^[%w%p]$") and last and last:match("^[%w%p]+$") then
			tokens[#tokens] = last .. ch
		else
			tokens[#tokens + 1] = ch
		end
	end

	local lines, cur, cur_w = {}, "", 0
	local function flush()
		lines[#lines + 1] = (cur:gsub("%s+$", ""))
		cur, cur_w = "", 0
	end
	local function push(piece, w)
		if cur_w + w > width and cur ~= "" then
			flush()
			if piece == " " then
				return
			end
		end
		cur, cur_w = cur .. piece, cur_w + w
	end

	for _, tok in ipairs(tokens) do
		local w = dw(tok)
		if w > width then
			for _, ch in ipairs(vim.fn.split(tok, "\\zs")) do
				push(ch, dw(ch))
			end
		else
			push(tok, w)
		end
	end
	flush()
	return lines
end

-- 列幅の合計を budget に収める。狭い列はそのまま残し、広い列を同じ上限で削る
local function fit_widths(natural, budget)
	local total = 0
	for _, w in ipairs(natural) do
		total = total + w
	end
	if total <= budget then
		return natural
	end

	local sorted = vim.deepcopy(natural)
	table.sort(sorted)
	local remaining, n, cap = budget, #sorted, 1
	for i, w in ipairs(sorted) do
		local share = math.floor(remaining / (n - i + 1))
		if w > share then
			cap = math.max(share, 1)
			break
		end
		remaining = remaining - w
	end

	local result = {}
	for i, w in ipairs(natural) do
		result[i] = math.min(w, cap)
	end
	return result
end

local function pad(text, width, align)
	local space = width - dw(text)
	if align == "right" then
		return string.rep(" ", space) .. text
	elseif align == "center" then
		local left = math.floor(space / 2)
		return string.rep(" ", left) .. text .. string.rep(" ", space - left)
	end
	return text .. string.rep(" ", space)
end

local function border_line(indent, widths, left, mid, right)
	local parts = {}
	for i, w in ipairs(widths) do
		parts[i] = string.rep("─", w + 2)
	end
	return { { indent .. left .. table.concat(parts, mid) .. right, HL_BORDER } }
end

-- 1 レコードを、セル内で折り返した複数の virt line にする
local function record_lines(indent, cells, widths, align, hl)
	local wrapped, height = {}, 1
	for i, w in ipairs(widths) do
		wrapped[i] = wrap_text(plain(cells[i] or ""), w)
		height = math.max(height, #wrapped[i])
	end

	local lines = {}
	for l = 1, height do
		local line = { { indent .. "│", HL_BORDER } }
		for i, w in ipairs(widths) do
			line[#line + 1] = { " " .. pad(wrapped[i][l] or "", w, align[i]) .. " ", hl }
			line[#line + 1] = { "│", HL_BORDER }
		end
		lines[#lines + 1] = line
	end
	return lines, height > 1
end

local function window_for(bufnr)
	local cur = vim.api.nvim_get_current_win()
	if vim.api.nvim_win_get_buf(cur) == bufnr then
		return cur
	end
	local win = vim.fn.bufwinid(bufnr)
	return win ~= -1 and win or cur
end

local function render_table(bufnr, tbl, indent_width, avail)
	local count = #tbl.header
	for _, r in ipairs(tbl.rows) do
		count = math.max(count, #r.cells)
	end

	local natural = {}
	for i = 1, count do
		local w = dw(plain(tbl.header[i] or ""))
		for _, r in ipairs(tbl.rows) do
			w = math.max(w, dw(plain(r.cells[i] or "")))
		end
		natural[i] = math.max(w, 1)
	end
	-- 罫線と左右の余白で 1 列あたり 3、右端の罫線で 1 を使う
	local widths = fit_widths(natural, avail - indent_width - (3 * count + 1))

	local indent = string.rep(" ", indent_width)
	local body, any_wrapped = {}, false
	for i, r in ipairs(tbl.rows) do
		local lines, wrapped = record_lines(indent, r.cells, widths, tbl.align, HL_ROW)
		any_wrapped = any_wrapped or wrapped
		body[i] = lines
	end

	local out = { border_line(indent, widths, "╭", "┬", "╮") }
	vim.list_extend(out, (record_lines(indent, tbl.header, widths, tbl.align, HL_HEAD)))
	out[#out + 1] = border_line(indent, widths, "├", "┼", "┤")
	for i, lines in ipairs(body) do
		-- 折り返したセルがあるときは、レコードの境目が分かるように行の間にも罫線を引く
		if i > 1 and any_wrapped then
			out[#out + 1] = border_line(indent, widths, "├", "┼", "┤")
		end
		vim.list_extend(out, lines)
	end
	out[#out + 1] = border_line(indent, widths, "╰", "┴", "╯")
	return out
end

local table_query

function M.parse(ctx)
	table_query = table_query or vim.treesitter.query.parse("markdown", "(pipe_table) @table")

	local win = window_for(ctx.buf)
	local avail = vim.api.nvim_win_get_width(win) - (vim.fn.getwininfo(win)[1] or { textoff = 0 }).textoff

	local marks = {}
	for _, node in table_query:iter_captures(ctx.root, ctx.buf) do
		local start_row, start_col = node:range()
		-- virt_lines は表の直前の行に下向きで付ける。直前の行が無い先頭の表は生表示のままにする
		if start_row > 0 then
			local tbl = parse_table(ctx.buf, node)
			local line = vim.api.nvim_buf_get_lines(ctx.buf, start_row, start_row + 1, false)[1] or ""
			local indent_width = dw(line:sub(1, start_col))

			marks[#marks + 1] = {
				conceal = false,
				start_row = start_row - 1,
				start_col = 0,
				opts = { virt_lines = render_table(ctx.buf, tbl, indent_width, avail) },
			}
			for _, row in ipairs(tbl.lines) do
				marks[#marks + 1] = {
					conceal = true,
					start_row = row,
					start_col = 0,
					opts = { end_row = row, conceal_lines = "" },
				}
			end
		end
	end
	return marks
end

-- レコード表示 -------------------------------------------------------------

local function render_record(buf, tbl, index)
	local record = tbl.rows[index]
	local lines, keys = {}, {}
	local count = math.max(#tbl.header, #record.cells)
	for i = 1, count do
		local key = tbl.header[i] or ("(列 " .. i .. ")")
		local value = record.cells[i] or ""
		keys[#keys + 1] = { line = #lines, len = #key }
		lines[#lines + 1] = key
		lines[#lines + 1] = "  " .. (value ~= "" and value or "—")
		if i < count then
			lines[#lines + 1] = ""
		end
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, k in ipairs(keys) do
		vim.api.nvim_buf_set_extmark(buf, ns, k.line, 0, { end_col = k.len, hl_group = "Title" })
	end
	return #lines
end

function M.show_record()
	local src_buf = vim.api.nvim_get_current_buf()
	local src_win = vim.api.nvim_get_current_win()
	local row = vim.api.nvim_win_get_cursor(src_win)[1] - 1

	local table_node = get_table_node(src_buf, row)
	if not table_node then
		vim.notify("カーソルが表の中にありません", vim.log.levels.INFO)
		return
	end
	local tbl = parse_table(src_buf, table_node)
	if #tbl.rows == 0 then
		vim.notify("表にデータ行がありません", vim.log.levels.INFO)
		return
	end

	local index = 1
	for i, r in ipairs(tbl.rows) do
		if r.line == row then
			index = i
			break
		end
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"

	local width = math.min(math.max(40, math.floor(vim.o.columns * 0.6)), vim.o.columns - 4)
	local max_height = math.floor(vim.o.lines * 0.7)
	local win

	local function title()
		return string.format(" 行 %d / %d ", index, #tbl.rows)
	end

	local function draw()
		local height = math.min(render_record(buf, tbl, index), max_height)
		vim.api.nvim_win_set_config(win, {
			relative = "editor",
			row = math.floor((vim.o.lines - height) / 2) - 1,
			col = math.floor((vim.o.columns - width) / 2),
			width = width,
			height = math.max(height, 1),
			title = title(),
			footer = " n/p: 次/前の行  q: 閉じる ",
			footer_pos = "right",
		})
		vim.api.nvim_win_set_cursor(win, { 1, 0 })
		-- 元の buffer のカーソルも同じ行に合わせ、閉じたあとに位置を見失わないようにする
		vim.api.nvim_win_set_cursor(src_win, { tbl.rows[index].line + 1, 0 })
	end

	local height = math.min(render_record(buf, tbl, index), max_height)
	win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = math.max(height, 1),
		style = "minimal",
		border = "rounded",
		title = title(),
	})
	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	vim.wo[win].breakindent = true
	draw()

	local function move(delta)
		local next_index = index + delta
		if next_index >= 1 and next_index <= #tbl.rows then
			index = next_index
			draw()
		end
	end

	local opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
	vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", opts)
	vim.keymap.set("n", "n", function() move(1) end, opts)
	vim.keymap.set("n", "p", function() move(-1) end, opts)
end

-- setup --------------------------------------------------------------------

function M.attach(bufnr)
	vim.keymap.set("n", "<leader>mr", M.show_record, {
		buffer = bufnr,
		desc = "Markdown table: show row as record",
	})
end

return M
