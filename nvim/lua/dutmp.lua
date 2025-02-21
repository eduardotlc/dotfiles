-- Created 2024-10-22 18:34:46
M = {}
function M.Get_video_metadata(file_path)
  if not file_path or file_path == "" then
    print("Error: No file path provided.")
    return nil
  end
  local cmd = string.format("ffprobe -v error -show_entries format_tags=category,grouping,artist,genre -of default=nw=1 " .. file_path)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  local words = {}
  for word in result:gmatch("%S+") do
    Tst = word:gsub("TAG:", "")
    table.insert(words, Tst)
  end
  local phrase = table.concat(words, " ")
  handle:close()
  return phrase
end

--function get_video_metadata(video_file)
  --local args = {
    --"ffprobe", "-v", "quiet", "-print_format", "json", "-show_format", video_file
  --}
  --local result = utils.subprocess({ args = args })

  --if result.status == 0 then
    --return utils.parse_json(result.stdout).format.tags or {}
  --else
    --msg.error("Failed to retrieve metadata for: " .. video_file)
    --return {}
  --end
--end
function get_specific_metadata()
  -- Run ffprobe and extract metadata
  local args = {
    "ffprobe",
    "-v", "quiet",
    "-print_format", "json",
    "-show_entries", "format_tags=category,grouping,genre,artist",
    mp.get_property("path")
  }

  local result = utils.subprocess({args = args})

  if result.status ~= 0 then
    return "Error running ffprobe"
  end

  -- Parse the JSON output from ffprobe
  local json = utils.parse_json(result.stdout)
  if not json or not json["format"] or not json["format"]["tags"] then
    return "No relevant metadata found"
  end

  local tags = json["format"]["tags"]
  local metadata_str = ""

  -- Extract only the desired metadata fields
  if tags["category"] then
    metadata_str = metadata_str .. "category: " .. tags["category"] .. "; "
  end
  if tags["grouping"] then
    metadata_str = metadata_str .. "grouping: " .. tags["grouping"] .. "; "
  end
  if tags["genre"] then
    metadata_str = metadata_str .. "genre: " .. tags["genre"] .. "; "
  end
  if tags["artist"] then
    metadata_str = metadata_str .. "artist: " .. tags["artist"] .. "; "
  end

  return metadata_str
end
--function M.get_specific_metadata(file_path)
  ---- Run ffprobe and extract metadata
  --local args = {
    --"ffprobe",
    --"-v", "quiet",
    --"-print_format", "json",
    --"-show_entries", "format_tags=category,grouping,genre,artist",
    --file_path,
  --}
  --if result.status ~= 0 then
    --return nil
  --end
  --local json = utils.parse_json(result.stdout)
  --if not json or not json["format"] or not json["format"]["tags"] then
    --return nil
  --end
  --local tags = json["format"]["tags"]
  --local metadata_str = ""
  --if tags["category"] then
    --metadata_str = metadata_str .. "category: " .. tags["category"] .. "; "
  --end
  --if tags["grouping"] then
    --metadata_str = metadata_str .. "grouping: " .. tags["grouping"] .. "; "
  --end
  --if tags["genre"] then
    --metadata_str = metadata_str .. "genre: " .. tags["genre"] .. "; "
  --end
  --if tags["artist"] then
    --metadata_str = metadata_str .. "artist: " .. tags["artist"] .. "; "
  --end
  --return metadata_str
--end
return M
--file_path = "/home/eduardotc/.gnupg/.p/zNcA9xB2_720p.mp4"
--Tst = Get_video_metadata("/home/eduardotc/.gnupg/.p/zNcA9xB2_720p.mp4")
--print(Tst)
