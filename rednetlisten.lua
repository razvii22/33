
while true do
  local message = {os.pullEvent("message")}
  print(message[2])
end