local log = hs.logger.new('myLogger', 'debug')

-- マウスカーソルをアクティブウインドウ上に移動する。skhdから呼んでいる
hs.urlevent.bind("moveMouseToActiveWindow", function()
  local win = hs.window.frontmostWindow()
  if win then
      local f = win:frame()
      hs.mouse.absolutePosition(hs.geometry.point(f.x + f.w * 0.9, f.y + f.h * 0.8))
  end
end)

-- ウインドウの記憶&focus
savedWindows = {}
for _, key in ipairs({"D", "1", "2", "3"}) do
  local saveModifier = {"ctrl", "cmd", "shift"}
  -- Ctrl+Cmd+DはMacの調べる機能に割り当てられているため、KarabinerでOpt付きに変換している
  local focusModifier = key == "D" and {"ctrl", "cmd", "option"} or {"ctrl", "cmd"}

  hs.hotkey.bind(saveModifier, key, function()
    savedWindows[key] = hs.window.focusedWindow()
    hs.alert.show("Save window: " .. savedWindows[key]:title())
  end)

  hs.hotkey.bind(focusModifier, key, function()
    window = savedWindows[key]
    if window then
      window:focus()
    else
      hs.alert.show("No saved window")
    end
  end)
end

-- Xcode overrides（一部modifierが意図通り設定できないため）
xcodeHotkeys = {}
local function activateXcodeHotkey()
  if next(xcodeHotkeys) == nil then
    table.insert(xcodeHotkeys, hs.hotkey.bind({"ctrl", "cmd", "option", "shift"}, "H", function()
      hs.eventtap.keyStroke({"ctrl"}, "[")
    end))
  end
end
local function deactivateXcodeHotkey()
  for _, hotkey in ipairs(xcodeHotkeys) do
    hotkey:delete()
  end
  xcodeHotkeys = {}
end
local function watchXcode(name, eventType, app)
  if name == "Xcode" then
    if eventType == hs.application.watcher.activated then
      activateXcodeHotkey()
    else
      deactivateXcodeHotkey()
    end
  end
end
appWatcher = hs.application.watcher.new(watchXcode)
appWatcher:start()

-- 以下、マウスモード用
local Mode = {
  NORMAL = 0,
  MOUSE_MOVE = 1
}
mode = Mode.NORMAL

local KeyCode = {
  SEMICOLON = hs.keycodes.map[";"],
  H = hs.keycodes.map["h"],
  J = hs.keycodes.map["j"],
  K = hs.keycodes.map["k"],
  L = hs.keycodes.map["l"],
  I = hs.keycodes.map["i"],
  N = hs.keycodes.map["n"],
  M = hs.keycodes.map["m"],
  Q = hs.keycodes.map["q"],
  W = hs.keycodes.map["w"],
  E = hs.keycodes.map["e"],
  R = hs.keycodes.map["r"],
  T = hs.keycodes.map["t"],
  A = hs.keycodes.map["a"],
  S = hs.keycodes.map["s"],
  D = hs.keycodes.map["d"],
  F = hs.keycodes.map["f"],
  G = hs.keycodes.map["g"],
  Z = hs.keycodes.map["z"],
  X = hs.keycodes.map["x"],
  C = hs.keycodes.map["c"],
  V = hs.keycodes.map["v"],
  B = hs.keycodes.map["b"],
  COMMA = hs.keycodes.map[","],
  ESC = hs.keycodes.map["escape"],
  PERIOD = hs.keycodes.map["."],
  SLASH = hs.keycodes.map["/"],
}

local MouseProp = {
  INITIAL_SPEED = 1.2,
  MAX_SPEED = 4,
  ACCELARATION_RATE = 1.02,
  BOOST_RATE = 1.5,
  SCROLL_SPEED = 12,
  SCROLL_BOOST_RATE = 4
}
local mouseSpeed = MouseProp.INITIAL_SPEED

-- keyCodeからマウスのキー名を取得する
local function getMouseKeyName(keyCode)
  if keyCode == KeyCode.E then
    return "UP"
  elseif keyCode == KeyCode.D then
    return "DOWN"
  elseif keyCode == KeyCode.S then
    return "LEFT"
  elseif keyCode == KeyCode.F then
    return "RIGHT"
  elseif keyCode == KeyCode.H then
    return "SCROLL_LEFT"
  elseif keyCode == KeyCode.J then
    return "SCROLL_DOWN"
  elseif keyCode == KeyCode.K then
    return "SCROLL_UP"
  elseif keyCode == KeyCode.L then
    return "SCROLL_RIGHT"
  elseif keyCode == KeyCode.I then
    return "WARP"
  elseif keyCode == KeyCode.N then
    return "MIDDLE_CLICK"
  elseif keyCode == KeyCode.M then
    return "LEFT_CLICK"
  elseif keyCode == KeyCode.COMMA then
    return "RIGHT_CLICK"
  elseif keyCode == KeyCode.PERIOD then
    return "WARP"
  elseif keyCode == KeyCode.Q then
    return "Q"
  elseif keyCode == KeyCode.W then
    return "W"
  elseif keyCode == KeyCode.R then
    return "R"
  elseif keyCode == KeyCode.T then
    return "T"
  elseif keyCode == KeyCode.A then
    return "A"
  elseif keyCode == KeyCode.G then
    return "G"
  elseif keyCode == KeyCode.Z then
    return "Z"
  elseif keyCode == KeyCode.X then
    return "X"
  elseif keyCode == KeyCode.C then
    return "C"
  elseif keyCode == KeyCode.V then
    return "V"
  elseif keyCode == KeyCode.B then
    return "B"
  elseif keyCode == KeyCode.SLASH then
    return "BOOST"
  else
    return nil
  end
end
mouseKeysPressed = {}

-- MouseKeyが押されたときに状態を更新する
local function updateMouseKeysPressed(event)
  local mouseKeyName = getMouseKeyName(event:getKeyCode())

  if mouseKeyName ~= nil then
    if event:getType() == hs.eventtap.event.types.keyDown then
      mouseKeysPressed[mouseKeyName] = true
    else
      mouseKeysPressed[mouseKeyName] = false
    end
  end
end

-- いずれかのMouseKeyが押されているか
local function isAnyMouseKeyPressed(event)
  local mouseKeyName = getMouseKeyName(event:getKeyCode())

  if mouseKeyName ~= nil and event:getType() == hs.eventtap.event.types.keyDown then
    return true
  end

  return false
end

local function resetMouseKeysPressed()
  for key in pairs(mouseKeysPressed) do
    mouseKeysPressed[key] = false
  end
end

-- マウスの位置などを更新するTimer（eventtap内でやると連続入力時に遅延が発生するため、Timerを動かす）
local moveMouseTimer = hs.timer.new(0.01, function()
  if mouseKeysPressed.WARP then
      local currentWindow = hs.window.focusedWindow()
      if currentWindow then
        local frame = currentWindow:frame()

        if mouseKeysPressed.Q then -- TOP LEFT EDGE
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.02, y = frame.y + frame.h * 0.15})
        elseif mouseKeysPressed.W then -- TOP LEFT
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.25, y = frame.y + frame.h * 0.15})
        elseif mouseKeysPressed.UP then -- TOP CENTER
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.5, y = frame.y + frame.h * 0.15})
        elseif mouseKeysPressed.R then -- TOP RIGHT
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.75, y = frame.y + frame.h * 0.15})
        elseif mouseKeysPressed.T then -- TOP RIGHT EDGE
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.98, y = frame.y + frame.h * 0.15})
        elseif mouseKeysPressed.A then -- LEFT EDGE
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.02, y = frame.y + frame.h * 0.5})
        elseif mouseKeysPressed.LEFT then -- LEFT
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.25, y = frame.y + frame.h * 0.5})
        elseif mouseKeysPressed.DOWN then -- CENTER
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.5, y = frame.y + frame.h * 0.5})
        elseif mouseKeysPressed.RIGHT then -- RIGHT
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.75, y = frame.y + frame.h * 0.5})
        elseif mouseKeysPressed.G then -- RIGHT EDGE
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.98, y = frame.y + frame.h * 0.5})
        elseif mouseKeysPressed.Z then -- BOTTOM LEFT EDGE
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.02, y = frame.y + frame.h * 0.9})
        elseif mouseKeysPressed.X then  -- BOTTOM LEFT
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.25, y = frame.y + frame.h * 0.9})
        elseif mouseKeysPressed.C then -- BOTTOM CENTER
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.5, y = frame.y + frame.h * 0.9})
        elseif mouseKeysPressed.V then -- BOTTOM RIGHT
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.75, y = frame.y + frame.h * 0.9})
        elseif mouseKeysPressed.B then -- BOTTOM RIGHT EDGE
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.98, y = frame.y + frame.h * 0.9})
        end
    end
  else
    -- スクロール
    local d = mouseKeysPressed.BOOST and MouseProp.SCROLL_SPEED * MouseProp.SCROLL_BOOST_RATE or MouseProp.SCROLL_SPEED
    if mouseKeysPressed.SCROLL_UP then
      hs.eventtap.event.newScrollEvent({0, -d}, {}, 'pixel'):post()
    end
    if mouseKeysPressed.SCROLL_DOWN then
      hs.eventtap.event.newScrollEvent({0, d}, {}, 'pixel'):post()
    end
    if mouseKeysPressed.SCROLL_LEFT then
      hs.eventtap.event.newScrollEvent({-d, 0}, {}, 'pixel'):post()
    end
    if mouseKeysPressed.SCROLL_RIGHT then
      hs.eventtap.event.newScrollEvent({d, 0}, {}, 'pixel'):post()
    end

    -- カーソル
    local currentPos = hs.mouse.absolutePosition()
    local isCursorPressed = false
    local d = mouseKeysPressed.BOOST and MouseProp.MAX_SPEED * MouseProp.BOOST_RATE or mouseSpeed
    if mouseKeysPressed.UP then
      currentPos.y = currentPos.y - d
      isCursorPressed = true
    end
    if mouseKeysPressed.DOWN then
      currentPos.y = currentPos.y + d
      isCursorPressed = true
    end
    if mouseKeysPressed.LEFT then
      currentPos.x = currentPos.x - d
      isCursorPressed = true
    end
    if mouseKeysPressed.RIGHT then
      currentPos.x = currentPos.x + d
      isCursorPressed = true
    end
    if mouseSpeed <= MouseProp.MAX_SPEED and isCursorPressed then
      mouseSpeed = mouseSpeed * MouseProp.ACCELARATION_RATE
    elseif mouseSpeed > MouseProp.INITIAL_SPEED and isCursorPressed == false then
        mouseSpeed = MouseProp.INITIAL_SPEED
    end
    hs.mouse.absolutePosition(currentPos)

    -- 左クリック中はドラッグイベントを発生させる
    if mouseKeysPressed.LEFT_CLICK then
      hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, hs.mouse.absolutePosition()):post()
    end
  end
end)

-- マウスが乗っているウィンドウにフォーカスを移すためのTimer
local mouseFocusTimer = hs.timer.new(0.5, function()
    local mousePoint = hs.mouse.absolutePosition()

    local window = nil
    local windows = hs.window.orderedWindows()

    for _, win in ipairs(windows) do
      if hs.geometry.point(mousePoint):inside(win:frame()) then
        window = win
        break
      end
    end

    if window then
      window:focus()
    end
end)

local function enableMouseMode()
  mode = Mode.MOUSE_MOVE
  moveMouseTimer:start()
  mouseFocusTimer:start()

  hs.alert.show("Mouse mode started", { fillColor={red=0.1,green=0.8,blue=0.2,alpha=0.4} }, 1)

  hs.alert.show("Mouse mode", {
    strokeWidth  = 0,  -- ボーダーの幅
    fillColor    = { white = 0, alpha = 0.7 },  -- 塗りつぶしの色
    textColor    = { white = 1, alpha = 0.9 },  -- テキストの色
    textSize     = 18,  -- フォントサイズ
    radius       = 8,  -- 角丸
    atScreenEdge = 1,  --  0: screen center (default); 1: top edge; 2: bottom edge
  }
  , 3600)
end

local function resetMouseMode()
  mode = Mode.NORMAL
  moveMouseTimer:stop()
  mouseFocusTimer:stop()
  mouseSpeed = MouseProp.INITIAL_SPEED
  resetMouseKeysPressed()
  isShiftPressed = false

  hs.alert.closeAll()
  hs.alert.show("Mouse mode finished", { fillColor={red=0.8,green=0.2,blue=0.1,alpha=0.4} }, 1)
end

local mouseKeyWaitTimer = nil
local isShiftPressed = false -- 普通にカンマを入力したいときのためにshiftを直前に押したか状態管理
local clickState = 1
mouseKeysTap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
  local keyCode = event:getKeyCode()
  local keyPressed = event:getType() == hs.eventtap.event.types.keyDown
  local eventProps = hs.eventtap.event.properties
  local repeating = event:getProperty(eventProps.keyboardEventAutorepeat)
  local modifiers = event:getFlags()

  -- {shift = true} という構造のmodifiersをevent作成時に渡せる {"shift"}　という形に変換する
  local function modsForEventOpt()
    local mods = {}
    for k, v in pairs(modifiers) do
      if v then
        table.insert(mods, k)
      end
    end
    return mods
  end

  local function processMouseKeys()
    updateMouseKeysPressed(event)

    if repeating == 0 then
      local key = getMouseKeyName(keyCode)
      -- 左クリック
      if key == "LEFT_CLICK" then
        if keyPressed then
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, hs.mouse.absolutePosition(), modsForEventOpt()):setProperty(eventProps.mouseEventClickState, clickState):post()
        else
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, hs.mouse.absolutePosition(), modsForEventOpt()):setProperty(eventProps.mouseEventClickState, clickState):post()
          -- ダブルクリック扱いするためにclickStateをカウントアップする必要があるらしい
          clickState = clickState + 1
          hs.timer.doAfter(0.2, function()
            clickState = 1
          end)
        end

      -- 右クリック
      elseif key == "RIGHT_CLICK" then
        if keyPressed then
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseDown, hs.mouse.absolutePosition()):post()
        else
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseUp, hs.mouse.absolutePosition()):post()
        end

      -- ホイールクリック
      elseif key == "MIDDLE_CLICK" then
        if keyPressed then
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.otherMouseDown, hs.mouse.absolutePosition(), 2):post()
        else
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.otherMouseUp, hs.mouse.absolutePosition(), 2):post()
        end
      end
    end
  end

  -- 無限ループを防ぐため、自前でセミコロンを発火させた場合はeventSourceUserDataに1をセットしている
  if event:getProperty(eventProps.eventSourceUserData) == 1 then
    return false
  end

  if mode == Mode.NORMAL then
    if keyCode == KeyCode.SEMICOLON and repeating == 0 then
      if keyPressed then
        if mouseKeyWaitTimer == nil and mode == Mode.NORMAL then
          -- マウスモードのキー入力を待つタイマーが起動していなかったら起動する
          mouseKeyWaitTimer = hs.timer.doAfter(0.5, function()
            mouseKeyWaitTimer = nil
          end)
          if modifiers.shift then
            isShiftPressed = true
          end
        end
      else
        if mouseKeyWaitTimer then
          mouseKeyWaitTimer:stop()
          mouseKeyWaitTimer = nil

          -- 即座にキーを離した場合に通常のセミコロンのキーイベントを発生させる
          local mods = (isShiftPressed or modifiers.shift) and {"shift"} or {}
          local eventDown = hs.eventtap.event.newKeyEvent(mods, KeyCode.SEMICOLON, true)
          eventDown:setProperty(eventProps.eventSourceUserData, 1)
          eventDown:post()
          local eventUp = hs.eventtap.event.newKeyEvent(mods, KeyCode.SEMICOLON, false)
          eventUp:setProperty(eventProps.eventSourceUserData, 1)
          eventUp:post()
          isShiftPressed = false
        end
      end

      return true
    end

    -- キー入力タイマーが有効なときにマウスキーが押されたらマウスモードに移行する
    if mouseKeyWaitTimer ~= nil then
      processMouseKeys()

      if isAnyMouseKeyPressed(event) and mode ~= Mode.MOUSE_MOVE then
        enableMouseMode()
      end

      return true
    end
  end

  -- マウスモードのとき
  if mode == Mode.MOUSE_MOVE then
    processMouseKeys()

    if modifiers["ctrl"] and modifiers["cmd"] then
      resetMouseMode()
      return false
    end

    if keyPressed and (keyCode == KeyCode.ESC or keyCode == KeyCode.SEMICOLON) then
      resetMouseMode()
    end

    return true
  end

  return false
end)

mouseKeysTap:start()
