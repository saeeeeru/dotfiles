require("hs.ipc")
hs.autoLaunch(true)

local function isBuiltin(screen)
  local name = screen:name() or ""
  return name:find("Built%-in") ~= nil or name:find("内蔵") ~= nil
end

-- 論理解像度の幅の上限。27 インチ 4K で 2304x1296 HiDPI、MacBook 内蔵で 1800x1169 HiDPI になる
local MAX_WIDTH = 2304

local function isPreferred(m)
  return m.scale >= 2 and m.w <= MAX_WIDTH
end

-- HiDPI かつ幅が MAX_WIDTH 以下の中で作業領域が最大のモード。該当しないディスプレイでは全モードから選ぶ。
-- 同じ広さならリフレッシュレートが高いものを選ぶ
local function largestMode(screen)
  local modes, preferred = screen:availableModes(), {}
  for _, m in pairs(modes) do
    if isPreferred(m) then table.insert(preferred, m) end
  end
  if #preferred > 0 then modes = preferred end

  local best
  for _, m in pairs(modes) do
    if not best then
      best = m
    else
      local area, bestArea = m.w * m.h, best.w * best.h
      if area > bestArea
        or (area == bestArea and m.scale > best.scale)
        or (area == bestArea and m.scale == best.scale and m.freq > best.freq) then
        best = m
      end
    end
  end
  return best
end

local function maximizeResolution(screen)
  local best, cur = largestMode(screen), screen:currentMode()
  if best and (cur.w ~= best.w or cur.h ~= best.h or cur.scale ~= best.scale) then
    screen:setMode(best.w, best.h, best.scale, best.freq, best.depth)
  end
end

-- 外部ディスプレイを内蔵ディスプレイの真上・左右中央に置く
local function placeAbove(external, builtin)
  local b, e = builtin:fullFrame(), external:fullFrame()
  local dx = math.floor((e.w - b.w) / 2)
  if b.x == e.x + dx and b.y == e.y + e.h then return end
  -- primary の原点は (0, 0) 固定なので、primary でない方を動かす
  if external == hs.screen.primaryScreen() then
    builtin:setOrigin(e.x + dx, e.y + e.h)
  else
    external:setOrigin(b.x - dx, b.y - e.h)
  end
end

local function arrange()
  local screens = hs.screen.allScreens()
  for _, s in ipairs(screens) do maximizeResolution(s) end

  -- 解像度変更が反映されてから配置を計算する
  hs.timer.doAfter(2, function()
    local builtin, externals = nil, {}
    for _, s in ipairs(hs.screen.allScreens()) do
      if isBuiltin(s) then builtin = s else table.insert(externals, s) end
    end
    if builtin and #externals == 1 then placeAbove(externals[1], builtin) end
  end)
end

-- 自分の変更でも watcher が発火するので、まとめて 1 回だけ走らせる
local pending = hs.timer.delayed.new(3, arrange)
displayWatcher = hs.screen.watcher.new(function() pending:start() end):start()

hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "d", arrange)

arrange()
