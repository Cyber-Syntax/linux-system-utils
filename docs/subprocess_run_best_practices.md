
# Best Practices for Using `subprocess.run` in Python

This guide summarizes best practices for using the `subprocess.run` function, based on the [official Python documentation](https://docs.python.org/3/library/subprocess.html) (Python 3.12+).

## 1. Prefer `subprocess.run` for Simplicity and Safety

- Use `subprocess.run` for most use cases. It is safer and easier than older APIs like `os.system`, `os.spawn*`, or `os.popen`.
- For advanced needs, use `subprocess.Popen` directly.

## 2. Pass Arguments as a Sequence (List)

- Always pass the command and its arguments as a list (e.g., `["ls", "-l"]`).
- Avoid passing a single string unless you set `shell=True`.
- This prevents shell injection vulnerabilities and handles spaces/quoting safely.

## 3. Avoid `shell=True` Unless Necessary

- Only use `shell=True` if you need shell features (pipes, wildcards, variable expansion).
- If you must use `shell=True`, ensure all arguments are properly quoted/escaped (see `shlex.quote`).
- Never use `shell=True` with untrusted input.

## 4. Capture Output Safely

- Use `capture_output=True` to capture both stdout and stderr.
- Alternatively, use `stdout=subprocess.PIPE` and/or `stderr=subprocess.PIPE` for more control.
- Use `text=True` (or `encoding=...`) to get output as a string instead of bytes.

## 5. Handle Errors and Return Codes

- Set `check=True` to raise an exception (`subprocess.CalledProcessError`) if the command fails (non-zero exit code).
- Always handle exceptions: `OSError` (if the command is not found), `TimeoutExpired`, and `CalledProcessError`.

## 6. Use Timeouts

- Use the `timeout` parameter to avoid hanging processes.
- If a timeout occurs, the process is killed and a `TimeoutExpired` exception is raised.

## 7. Avoid Deadlocks with Pipes

- If using `stdout=PIPE` or `stderr=PIPE`, always read output using `.communicate()` or by capturing output with `subprocess.run`.
- Do not use `.stdout.read()` or `.stderr.read()` directly to avoid deadlocks.

## 8. Security Considerations

- Avoid `shell=True` with untrusted input to prevent shell injection.
- On Windows, be aware that batch files may be run in a shell regardless of arguments.
- Use fully qualified paths for executables when possible.

## 9. Environment and Working Directory

- Use the `env` parameter to set environment variables for the child process.
- Use the `cwd` parameter to set the working directory for the child process.

## 10. Example Usage

```python
import subprocess

# Simple command, capture output, check for errors
result = subprocess.run(["ls", "-l"], capture_output=True, text=True, check=True)
print(result.stdout)

# With timeout and error handling
try:
    subprocess.run(["sleep", "10"], timeout=5, check=True)
except subprocess.TimeoutExpired:
    print("Command timed out!")
except subprocess.CalledProcessError as e:
    print(f"Command failed: {e}")
```

## References

- [Python subprocess documentation](https://docs.python.org/3/library/subprocess.html)
- [Security Considerations](https://docs.python.org/3/library/subprocess.html#security-considerations)
- [shlex.quote](https://docs.python.org/3/library/shlex.html#shlex.quote)
