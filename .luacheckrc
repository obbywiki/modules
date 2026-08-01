std = "lua51"
read_globals = {"mw", "unpack"}
cache = true
formatter = "default"
include_files = {"modules/**/*.lua", "*.luacheckrc"}
exclude_files = {"modules/_legacy", "modules/shared/_imported"}
-- ignore unused (i.e., frame/self)
ignore = {"212"}
max_line_length = false
