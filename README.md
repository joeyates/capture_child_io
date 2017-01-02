# CaptureChildIO

Provides `capture_child_io`, allowing you to capture a child process's output,
and control its input during tests.

# Authorship

The implementation of the private `do_capture_io` is a slightly adapted version
of the code in Elixir's standard library (ExUnit.CaptureIO).

## Installation

The package can be installed by adding `capture_child_io` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [{:capture_child_io, "~> 0.1.0"}]
end
```

The docs can be found at
[https://hexdocs.pm/capture_child_io](https://hexdocs.pm/capture_child_io).
