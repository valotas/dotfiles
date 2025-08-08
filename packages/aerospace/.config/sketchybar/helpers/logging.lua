local logging = {}

-- Log file path
local LOG_FILE = "/tmp/sketchybar.logs"

-- Helper function to append a log message with timestamp
function logging.log(message)
  local log_file = io.open(LOG_FILE, "a")
  if log_file then
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    log_file:write("[" .. timestamp .. "] " .. message .. "\n")
    log_file:close()
  end
end

-- Helper function to log a section header
function logging.log_section(section_name)
  local log_file = io.open(LOG_FILE, "a")
  if log_file then
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    log_file:write("[" .. timestamp .. "] === " .. section_name .. " ===\n")
    log_file:close()
  end
end

-- Helper function to log a section footer
function logging.log_section_end()
  local log_file = io.open(LOG_FILE, "a")
  if log_file then
    log_file:write("========================\n")
    log_file:close()
  end
end

-- Helper function to log any table data
function logging.log_table(table_name, data)
  logging.log_section(table_name)
  if type(data) == "table" then
    for key, value in pairs(data) do
      logging.log(key .. ": " .. tostring(value))
    end
  else
    logging.log(tostring(data))
  end
  logging.log_section_end()
end

return logging 