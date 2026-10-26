std = "lua51"
read_globals = {"mw", "unpack"}
cache = true
formatter = "default"
include_files = {"src/modules/**/*.lua", "*.luacheckrc"}
exclude_files = {"src/modules/_legacy", "src/modules/shared/_imported"}
-- ignore unused (i.e., frame/self)
ignore = {"212"}
max_line_length = false
