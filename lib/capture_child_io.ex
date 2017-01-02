defmodule CaptureChildIO do
  @moduledoc """
  Capture another process's stdout and provide its stdin (i.e. 
  substitude its group leader).

  This code supplements ExUnit.CaptureIO's `capture_io`.

  `capture_io` captures either the current process's :stdio, or any other
  'device', normally :stderr.
  
  `capture_child_io` takes a PID and captures its :stdio. The function returns
  the process's :stdout.
  Optionally, the input for the process can also be specified.

  ## Examples
  
      defmodule TestServer do
        use GenServer

        def handle_call(:puts_to_stdout, _from, nil) do
          IO.puts "from stdout"
          {:reply, :ok, nil}
        end
      end

      iex> {:ok, pid} = GenServer.start_link(TestServer, nil)
      iex> capture_child_io(pid, fn -> GenServer.call(pid, :puts_to_stdout) end)
      "from stdout\\n"

  ## Caveats

  1. No checks are made whether the PID's IO is already being captured, calling
    `capture_child_io` twice may result in unpredictable behaviour.
  2. If the calling process (normally a test) dies, the child process's IO
     is not restored to its previous state - though this should not matter
     as the child process will normally be a process started for the test
     itself.
  """
  def capture_child_io(pid, fun) do
    do_capture_io(pid, [], fun)
  end

  def capture_child_io(pid, input, fun) when is_binary(input) do
    do_capture_io(pid, [input: input], fun)
  end

  def capture_child_io(pid, options, fun) do
    do_capture_io(pid, options, fun)
  end

  defp do_capture_io(pid, options, fun) do
    prompt_config = Keyword.get(options, :capture_prompt, true)
    input = Keyword.get(options, :input, "")

    original_gl = Process.group_leader()
    {:ok, capture_gl} = StringIO.open(input, capture_prompt: prompt_config)
    try do
      Process.group_leader(pid, capture_gl)
      do_capture_io(capture_gl, fun)
    after
      if Process.alive?(pid) do
        Process.group_leader(pid, original_gl)
      end
    end
  end

  defp do_capture_io(string_io, fun) do
    try do
       _ = fun.()
      :ok
    catch
      kind, reason ->
        stack = System.stacktrace()
        _ = StringIO.close(string_io)
        :erlang.raise(kind, reason, stack)
    else
      :ok ->
        {:ok, output} = StringIO.close(string_io)
        elem(output, 1)
    end
  end
end
