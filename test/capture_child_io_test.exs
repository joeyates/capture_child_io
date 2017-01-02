defmodule CaptureChildIOTest do
  defmodule TestServer do
    use GenServer

    def handle_call(:puts_to_stdout, _from, nil) do
      IO.puts "from stdout"
      {:reply, :ok, nil}
    end

    def handle_call(:get_line, _from, nil) do
      {:reply, {:ok, :io.get_line(">")}, nil}
    end
  end

  use ExUnit.Case
  import CaptureChildIO

  describe "child processes" do
    setup do
      {:ok, pid} = GenServer.start_link(TestServer, nil)

      on_exit fn -> Process.exit(pid, :normal) end

      [pid: pid]
    end

    test "can be captured", context do
      assert capture_child_io(context[:pid], fn ->
        :ok = GenServer.call(context[:pid], :puts_to_stdout)
      end) == "from stdout\n"
    end

    test "input can be provided, via options", context do
      capture_child_io(context[:pid], [input: "my input\n"], fn ->
        {:ok, line} = GenServer.call(context[:pid], :get_line)
        send self(), {:result, line}
      end)

      assert_received {:result, "my input\n"}
    end

    test "input can be provided as a parameter", context do
      capture_child_io(context[:pid], "my input\n", fn ->
        {:ok, line} = GenServer.call(context[:pid], :get_line)
        send self(), {:result, line}
      end)

      assert_received {:result, "my input\n"}
    end
  end
end
