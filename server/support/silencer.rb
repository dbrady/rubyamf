def silence_stderr
  old_stderr = STDERR.dup
  STDERR.reopen(PLATFORM =~ /mswin/ ? '/NUL:' : '/dev/null')
  STDERR.sync = true
  yield
ensure
  STDERR.reopen(old_stderr)
end