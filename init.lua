require("hs.ipc")
-- Hebrew <-> Latin keyboard layout converter
-- Shortcut: Ctrl+Shift+H
-- Auto-detects direction based on input text

local hebrewToLatin = {
  ["ק"] = "e", ["ר"] = "r", ["א"] = "t", ["ט"] = "y", ["ו"] = "u",
  ["ן"] = "i", ["ם"] = "o", ["פ"] = "p", ["ש"] = "a", ["ד"] = "s",
  ["ג"] = "d", ["כ"] = "f", ["ע"] = "g", ["י"] = "h", ["ח"] = "j",
  ["ל"] = "k", ["ך"] = "l", ["ז"] = "z", ["ס"] = "x", ["ב"] = "c",
  ["ה"] = "v", ["נ"] = "b", ["מ"] = "n", ["צ"] = "m", ["ת"] = ",",
  ["ץ"] = ".", ["ף"] = ";", ["׳"] = "w", ["ּ"] = "q",
}

local latinToHebrew = {}
for heb, lat in pairs(hebrewToLatin) do
  latinToHebrew[lat] = heb
end

local function containsHebrew(text)
  -- Hebrew unicode block: U+0590–U+05FF
  return text:match("[\xD6\x90-\xD7\xBF]") ~= nil
end

local function convertText(text)
  if containsHebrew(text) then
    -- Hebrew → Latin
    local result = ""
    local i = 1
    while i <= #text do
      local byte1 = text:byte(i)
      if byte1 >= 0xD6 and byte1 <= 0xD7 then
        -- 2-byte UTF-8 Hebrew character
        local char = text:sub(i, i + 1)
        result = result .. (hebrewToLatin[char] or char)
        i = i + 2
      else
        result = result .. text:sub(i, i)
        i = i + 1
      end
    end
    return result
  else
    -- Latin → Hebrew
    local result = ""
    for i = 1, #text do
      local char = text:sub(i, i)
      result = result .. (latinToHebrew[char] or char)
    end
    return result
  end
end

hs.hotkey.bind({"ctrl", "shift"}, "H", function()
  local before = hs.pasteboard.getContents()
  hs.pasteboard.setContents("")
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.timer.doAfter(0.2, function()
    local text = hs.pasteboard.getContents()
    if not text or text == "" then
      hs.pasteboard.setContents(before or "")
      hs.alert.show("Hebrew Fixer: Kein Text markiert!")
      return
    end

    local converted = convertText(text)
    hs.pasteboard.setContents(converted)
    hs.eventtap.keyStroke({"cmd"}, "v")
    hs.timer.doAfter(0.1, function()
      hs.pasteboard.setContents(before or "")
    end)
  end)
end)
