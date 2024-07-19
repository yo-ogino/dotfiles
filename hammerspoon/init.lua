local log = hs.logger.new('myLogger', 'debug')

-- マウスカーソルをアクティブウインドウ上に移動する。skhdから呼んでいる
hs.urlevent.bind("moveMouseToActiveWindow", function()
  log.d('moveMouseToWindowCenter')
  local win = hs.window.frontmostWindow()
  if win then
      local f = win:frame()
      local center = hs.geometry.point(f.x + f.w * 0.9, f.y + f.h * 0.8)
      hs.mouse.absolutePosition(center)
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
    log.d(hs.inspect(savedWindows))
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
  J = hs.keycodes.map["j"],
  K = hs.keycodes.map["k"],
  L = hs.keycodes.map["l"],
  I = hs.keycodes.map["i"],
  W = hs.keycodes.map["w"],
  X = hs.keycodes.map["x"],
  R = hs.keycodes.map["r"],
  V = hs.keycodes.map["v"],
  C = hs.keycodes.map["c"],
  A = hs.keycodes.map["a"],
  G = hs.keycodes.map["g"]
}

local MouseProp = {
  INITIAL_SPEED = 1.6,
  MAX_SPEED = 8,
  ACCELARATION_RATE = 1.02,
  SPEED_UP_RATE = 2,
  SCROLL_SPEED = 12,
  SCROLL_SPEED_UP_RATE = 4
}
local mouseSpeed = MouseProp.INITIAL_SPEED

-- keyCodeからマウスのキー名を取得する
local function getMouseKeyName(keyCode)
  if keyCode == hs.keycodes.map["e"] then
    return "UP"
  elseif keyCode == hs.keycodes.map["d"] then
    return "DOWN"
  elseif keyCode == hs.keycodes.map["s"] then
    return "LEFT"
  elseif keyCode == hs.keycodes.map["f"] then
    return "RIGHT"
  elseif keyCode == hs.keycodes.map["h"] then
    return "SCROLL"
  elseif keyCode == KeyCode.J then
    return "LEFT_CLICK"
  elseif keyCode == KeyCode.K then
    return "RIGHT_CLICK"
  elseif keyCode == KeyCode.I then
    return "MIDDLE_CLICK"
  elseif keyCode == KeyCode.L then
    return "SPEEDUP"
  elseif keyCode == KeyCode.W then
    return "MOVE_TOPLEFT"
  elseif keyCode == KeyCode.R then
    return "MOVE_TOPRIGHT"
  elseif keyCode == KeyCode.X then
    return "MOVE_BOTTOMLEFT"
  elseif keyCode == KeyCode.V then
    return "MOVE_BOTTOMRIGHT"
  elseif keyCode == KeyCode.C then
    return "MOVE_CENTER"
  elseif keyCode == KeyCode.A then
    return "MOVE_LEFT"
  elseif keyCode == KeyCode.G then
    return "MOVE_RIGHT"
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
  if mouseKeysPressed.MOVE_TOPLEFT or mouseKeysPressed.MOVE_BOTTOMLEFT
  or mouseKeysPressed.MOVE_BOTTOMRIGHT or mouseKeysPressed.MOVE_TOPRIGHT
  or mouseKeysPressed.MOVE_LEFT or mouseKeysPressed.MOVE_RIGHT
  or mouseKeysPressed.MOVE_CENTER then
    local currentWindow = hs.window.focusedWindow()

    if currentWindow then
        local frame = currentWindow:frame()

        if mouseKeysPressed.MOVE_TOPLEFT then
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.1, y = frame.y + frame.h * 0.1})
        elseif mouseKeysPressed.MOVE_BOTTOMLEFT then
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.1, y = frame.y + frame.h * 0.9})
        elseif mouseKeysPressed.MOVE_TOPRIGHT then
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.9, y = frame.y + frame.h * 0.1})
        elseif mouseKeysPressed.MOVE_BOTTOMRIGHT then
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.9, y = frame.y + frame.h * 0.9})
        elseif mouseKeysPressed.MOVE_LEFT then
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.2, y = frame.y + frame.h * 0.5})
        elseif mouseKeysPressed.MOVE_RIGHT then
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.8, y = frame.y + frame.h * 0.5})
        elseif mouseKeysPressed.MOVE_CENTER then
          hs.mouse.absolutePosition({x = frame.x + frame.w * 0.5, y = frame.y + frame.h * 0.5})
        end
    end
  end

  if mouseKeysPressed.SCROLL then
    local d = mouseKeysPressed.SPEEDUP and MouseProp.SCROLL_SPEED * MouseProp.SCROLL_SPEED_UP_RATE or MouseProp.SCROLL_SPEED

    if mouseKeysPressed.UP then
      hs.eventtap.event.newScrollEvent({0, -d}, {}, 'pixel'):post()
    end
    if mouseKeysPressed.DOWN then
      hs.eventtap.event.newScrollEvent({0, d}, {}, 'pixel'):post()
    end
    if mouseKeysPressed.LEFT then
      hs.eventtap.event.newScrollEvent({-d, 0}, {}, 'pixel'):post()
    end
    if mouseKeysPressed.RIGHT then
      hs.eventtap.event.newScrollEvent({d, 0}, {}, 'pixel'):post()
    end
  else
    local currentPos = hs.mouse.absolutePosition()
    local isCursorPressed = false
    local d = mouseKeysPressed.SPEEDUP and MouseProp.MAX_SPEED * MouseProp.SPEED_UP_RATE or mouseSpeed

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

local function resetMouseMode()
  mode = Mode.NORMAL
  moveMouseTimer:stop()
  mouseFocusTimer:stop()
  mouseSpeed = MouseProp.INITIAL_SPEED
  resetMouseKeysPressed()
  isShiftPressed = false
end

local mouseKeyWaitTimer = nil
local isShiftPressed = false -- 普通にカンマを入力したいときのためにshiftを直前に押したか状態管理
mouseKeysTap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
  local keyCode = event:getKeyCode()
  local keyPressed = event:getType() == hs.eventtap.event.types.keyDown
  local eventProps = hs.eventtap.event.properties
  local repeating = event:getProperty(eventProps.keyboardEventAutorepeat)

  local function processMouseKeys()
    updateMouseKeysPressed(event)

    if repeating == 0 then
      local key = getMouseKeyName(keyCode)
      -- 左クリック
      if key == "LEFT_CLICK" then
        if keyPressed then
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, hs.mouse.absolutePosition()):post()
        else
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, hs.mouse.absolutePosition()):post()
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

  -- セミコロン入力時
  if keyCode == KeyCode.SEMICOLON and repeating == 0 then
    resetMouseMode()
    if keyPressed and mouseKeyWaitTimer == nil and mode == Mode.NORMAL then
      -- マウスモードのキー入力を待つタイマーが起動していなかったら起動する
      mouseKeyWaitTimer = hs.timer.doAfter(0.5, function()
        log.d('# mouseKeyWaitTimer expired')
        mouseKeyWaitTimer = nil
      end)
      if event:getFlags().shift then
        isShiftPressed = true
      end
    else
      -- セミコロンが離されたとき、全ての状態をリセットする
      resetMouseMode()
      if mouseKeyWaitTimer then
        mouseKeyWaitTimer:stop()
        mouseKeyWaitTimer = nil

        -- 即座にキーを離した場合に通常のセミコロンのキーイベントを発生させる
        local mods = (isShiftPressed or event:getFlags().shift) and {"shift"} or {}
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
      mode = Mode.MOUSE_MOVE
      log.d('# Mouse mode')
      moveMouseTimer:start()
      mouseFocusTimer:start()

      hs.alert.show("Mouse mode", 1)
    end

    return true
  end

  -- マウスモードのとき
  if mode == Mode.MOUSE_MOVE then
    processMouseKeys()

    return true
  end

  return false
end)

mouseKeysTap:start()
