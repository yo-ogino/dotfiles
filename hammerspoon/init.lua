local log = hs.logger.new('myLogger', 'debug')

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
  CMD = 104
}

mouseKeysPressed = {
  UP = false,
  DOWN = false,
  LEFT = false,
  RIGHT = false,
  SCROLL = false,
  LEFT_CLICK = false,
  RIGHT_CLICK = false,
  MIDDLE_CLICK = false,
  SPEEDUP = false
}

local initialMouseSpeed = 2
local maxMouseSpeed = 16
local accelarationRate = 1.03
local mouseSpeedUpRate = 2
local mouseSpeed = initialMouseSpeed
local scrollSpeed = 12
local scrollSpeedUpRate = 4

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
  elseif keyCode == KeyCode.L then
    return "MIDDLE_CLICK"
  elseif keyCode == KeyCode.CMD then
    return "SPEEDUP"
  else
    return nil
  end
end

-- MouseKeyが押されたときに状態を更新する
local function updateMouseKeysPressed(event)
  local keyCode = event:getKeyCode()
  local mouseKeyName = getMouseKeyName(keyCode)
  local flags = event:getFlags()


  if flags.cmd then
    mouseKeysPressed.SPEEDUP = true
  else
    mouseKeysPressed.SPEEDUP = false
  end

  if mouseKeyName ~= nil then
    if event:getType() == hs.eventtap.event.types.keyDown then
      mouseKeysPressed[mouseKeyName] = true
    else
      mouseKeysPressed[mouseKeyName] = false
    end
  end

  if mouseKeyName == "SPEEDUP" then
    log.d('keyCode: ' .. tostring(keyCode))
    log.d('mouseKeyName: ' .. tostring(mouseKeyName))
    log.d('flags: ' .. hs.inspect(flags))
    log.d('event:getType(): ' .. tostring(event:getType()))
    log.d('mouseKeysPressed: ' .. hs.inspect(mouseKeysPressed))
  end

end

-- いずれかのMouseKeyが押されているか
local function isAnyMouseKeyPressed(event)
  local mouseKeyName = getMouseKeyName(event:getKeyCode())
  local flags = event:getFlags()

  if mouseKeyName ~= nil and event:getType() == hs.eventtap.event.types.keyDown then
    return true
  end

  if flags.cmd then
    return true
  end

  return false
end

-- マウスの位置などを更新するTimer（eventtap内でやると連続入力時に遅延が発生するため、Timerを動かす）
local moveMouseTimer = hs.timer.new(0.01, function()
  local d = mouseKeysPressed.SPEEDUP and scrollSpeed * scrollSpeedUpRate or scrollSpeed

  if mouseKeysPressed.SCROLL then
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
    local currentPos = hs.mouse.getRelativePosition()
    local isCursorPressed = false
    local d = mouseKeysPressed.SPEEDUP and mouseSpeed * mouseSpeedUpRate or mouseSpeed

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

    if mouseSpeed <= maxMouseSpeed and isCursorPressed then
      mouseSpeed = mouseSpeed * accelarationRate
    elseif mouseSpeed > initialMouseSpeed and isCursorPressed == false then
        mouseSpeed = initialMouseSpeed
    end

    hs.mouse.setRelativePosition(currentPos)

    -- 左クリック中はドラッグイベントを発生させる
    if mouseKeysPressed.LEFT_CLICK then
      hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, hs.mouse.absolutePosition()):post()
    end
  end
end)

local mouseKeyWaitTimer = nil
mouseKeysTap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
  local keyCode = event:getKeyCode()
  local keyPressed = event:getType() == hs.eventtap.event.types.keyDown
  local eventProps = hs.eventtap.event.properties
  local repeating = event:getProperty(eventProps.keyboardEventAutorepeat)


  -- 無限ループを防ぐため、自前でセミコロンを発火させた場合はeventSourceUserDataに1をセットしている
  if event:getProperty(eventProps.eventSourceUserData) == 1 then
    return false
  end

  -- セミコロン入力時
  if keyCode == KeyCode.SEMICOLON and repeating == 0 then
    if keyPressed and mouseKeyWaitTimer == nil and mode == Mode.NORMAL then
      -- マウスモードのキー入力を待つタイマーが起動していなかったら起動する
      mouseKeyWaitTimer = hs.timer.doAfter(0.3, function()
        log.d('# mouseKeyWaitTimer expired')
        mouseKeyWaitTimer = nil
      end)
    else
      -- セミコロンが離されたとき、全ての状態をリセットする
      mode = Mode.NORMAL
      moveMouseTimer:stop()
      if mouseKeyWaitTimer then
        mouseKeyWaitTimer:stop()
        mouseKeyWaitTimer = nil

        -- 即座にキーを離した場合に通常のセミコロンのキーイベントを発生させる
        local mods = event:getFlags().shift and {"shift"} or {}
        local eventDown = hs.eventtap.event.newKeyEvent(mods, KeyCode.SEMICOLON, true)
        eventDown:setProperty(eventProps.eventSourceUserData, 1)
        eventDown:post()
        local eventUp = hs.eventtap.event.newKeyEvent(mods, KeyCode.SEMICOLON, false)
        eventUp:setProperty(eventProps.eventSourceUserData, 1)
        eventUp:post()
      end
    end

    return true

  -- キー入力タイマーが有効なときにマウスキーが押されたらマウスモードに移行する
  elseif mouseKeyWaitTimer ~= nil then
    if isAnyMouseKeyPressed(event) then
      mode = Mode.MOUSE_MOVE
      log.d('# Mouse mode')
      moveMouseTimer:start()
    end

    return true

  -- マウスモードのとき
  elseif mode == Mode.MOUSE_MOVE then
    updateMouseKeysPressed(event)

    if repeating == 0 then
      -- 左クリック
      if keyCode == KeyCode.J then
        if keyPressed then
          log.d('Left click')
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, hs.mouse.absolutePosition()):post()
        else
          log.d('Left click up')
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, hs.mouse.absolutePosition()):post()
        end

      -- 右クリック
      elseif keyCode == KeyCode.K then
        if keyPressed then
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseDown, hs.mouse.absolutePosition()):post()
        else
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseUp, hs.mouse.absolutePosition()):post()
        end

      -- ホイールクリック
      elseif keyCode == KeyCode.L then
        if keyPressed then
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.otherMouseDown, hs.mouse.absolutePosition(), 2):post()
        else
          hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.otherMouseUp, hs.mouse.absolutePosition(), 2):post()
        end
      end
    end

    return true
  end

  return false
end)

mouseKeysTap:start()