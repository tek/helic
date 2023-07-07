# Unreleased

# 0.6.1.0

* Add cli option `--text` for the `yank` command as an alternative to stdin.

# 0.6.0.0

* Allow all agents to be disabled in the config file.

# 0.5.3.0

* Prevent events with timestamps older than the current history head from getting added to the history.

# 0.5.1.0

* Broadcast the matching event when executing `load`.

# 0.5.0.0

* Allow empty config files.
* Forcibly connect to a GTK display if none is currently open.

# 0.4.0.0

* Rewrite the GTK main loop effects for better resilience when no display is available (yet).

# 0.3.1.0

* Sanitize newlines when inserting events

# 0.3.0.0

* Add the `load` command that sets the clipboard to an event from the history.

# 0.2.0.0

* Add the `list` command that prints the current history.

# 0.1.0.0

* Initial release
