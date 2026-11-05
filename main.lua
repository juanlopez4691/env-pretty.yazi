--- @since 25.12.29
--- .env previewer: aligned KEY=VALUE pairs, dimmed comments.
---
--- Yazi's code previewer shows dotenv files as flat text, which makes long value
--- columns and comments hard to scan. This aligns the keys into a column and
--- dims comments, so the file reads like a config table while keeping every
--- original character of the values.
local M = {}

-- Files larger than this are left to the code previewer (not a real .env then).
local MAX_SIZE = 1 << 20
-- Key column is padded to the longest key, clamped to keep values readable.
local MIN_KEY, MAX_KEY = 0, 32

local KEY_COLOR = "yellow"
local EXPORT_COLOR = "darkgray"

local function capture(cmd, args)
	local out = Command(cmd):arg(args):env("LC_ALL", "C"):output()
	if not out or not out.status.success then
		return nil
	end
	return out.stdout
end

local function size_of(path)
	return tonumber((capture("wc", { "-c", path }) or ""):match("^%s*(%d+)")) or 0
end

-- Split a dotenv line into `export`, `KEY`, `VALUE`. Returns nil for blank lines,
-- comments and anything that is not a simple assignment.
local function parse(line)
	if line:match("^%s*$") or line:match("^%s*#") then
		return nil
	end
	local export, key, value = line:match("^%s*(export%s+)([%w_%.%-]+)%s*=%s*(.*)$")
	if not key then
		key, value = line:match("^%s*([%w_%.%-]+)%s*=%s*(.*)$")
		export = nil
	end
	if not key then
		return nil
	end
	return export, key, value
end

function M:peek(job)
	local path = tostring(job.file.path)
	if size_of(path) > MAX_SIZE then
		return require("code"):peek(job)
	end
	local text = capture("cat", { path })
	if not text then
		return require("code"):peek(job)
	end

	-- Split once up front: the key column width must not change while scrolling.
	local rows, width = {}, MIN_KEY
	for line in (text .. "\n"):gmatch("(.-)\r?\n") do
		local export, key, value = parse(line)
		rows[#rows + 1] = { raw = line, export = export, key = key, value = value }
		if key and #key > width then
			width = math.min(#key, MAX_KEY)
		end
	end

	local lines = {}
	local limit = job.area.h
	for i = job.skip + 1, math.min(#rows, job.skip + limit) do
		local row = rows[i]
		if not row.key then
			lines[#lines + 1] = ui.Line { ui.Span(row.raw):fg("darkgray") }
		else
			local key = #row.key > width and row.key:sub(1, width) or row.key
			lines[#lines + 1] = ui.Line {
				ui.Span(string.format("%-" .. width .. "s", key)):fg(KEY_COLOR),
				ui.Span(row.export and " (export)" or ""):fg(EXPORT_COLOR),
				ui.Span(" = "):fg("darkgray"),
				ui.Span(row.value),
			}
		end
	end

	if job.skip > 0 and #rows <= job.skip then
		ya.emit("peek", { math.max(0, #rows - limit), only_if = job.file.url, upper_bound = true, scope = job.scope })
	else
		ya.preview_widget(job, ui.Text(lines):area(job.area))
	end
end

local preview_skip = ya.sync(function(state)
	return cx.active.preview.skip
end)

function M:seek(job)
	local step = math.floor(job.units * job.area.h / 10)
	step = step == 0 and ya.clamp(-1, job.units, 1) or step
	ya.emit("peek", { math.max(0, preview_skip() + step), only_if = job.file.url })
end

return M
