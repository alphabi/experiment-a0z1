local prefix = 'bitdicts/'
local r = false
local bitwidth = 1
while arg[1] and arg[1]:sub(1, 1) == '-' do
  if arg[1] == '-r' then
    r = true
    table.remove(arg, 1)
  -- TODO: allow -x5 and -x6 for base 32 and base64
  -- perhaps also -x3 for octal, and x2 for completion?
  -- x1 discards all nonbinary characters
  elseif arg[1] == '-x' then
    bitwidth = 4
    table.remove(arg, 1)
  else
    io.stderr:write(string.format('Unrecognized option %q\n', arg[1]))
    os.exit(1)
  end
end

local hexbits = {}
for i = 0, 16 do
  hexbits[string.format('%x',i)] =
    (i     > 7 and '1' or '0') ..
    (i % 8 > 3 and '1' or '0') ..
    (i % 4 > 1 and '1' or '0') ..
    (i % 2 > 0 and '1' or '0')
end

local bits = arg[1]:gsub('%X','')

-- TODO: skip this under -x6 (the only base with X as a digit)
if bits:match('^0[xX]') then
  bits = bits:sub(3)
  bitwidth = 4
end

if bitwidth == 4 then
  bits = bits:lower():gsub('.', hexbits)
end

bits = bits:gsub('[^01]','')

local tips = {}

local function least(t)
  local lk, lv = next(t)
  local ck, cv = next(t, lk)
  while ck do
    if cv < lv then lk, lv = ck, cv end
    ck, cv = next(t, ck)
  end
  return lk
end
local function readtip(file)
  local tip = file:read()
  tips[file] = tip
  if not tip then file:close() end
end

for i = 1, #bits do
  local file = io.open(prefix .. bits:sub(r and i or 1, r and -1 or i))
  if file then readtip(file) end
end

local topfile = least(tips)
while topfile do
  print(tips[topfile])
  readtip(topfile)
  topfile = least(tips)
end
