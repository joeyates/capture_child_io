defmodule CaptureChildIO.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :capture_child_io,
     version: @version,
     elixir: "~> 1.0",
     deps: deps(),
     name: "CaptureChildIO",
     source_url: "https://github.com/joeyates/capture_child_io",
     docs: [source_ref: "v#{@version}", main: "readme", extras: ["README.md"]],
     description: description(),
     package: package()]
  end

  def application do
    []
  end

  defp deps do
    [{:ex_doc,  ">= 0.0.0", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev}]
  end

  defp description do
    "Capture child processes' :stdio in tests"
  end

  defp package do
    [maintainers: ["Joe Yates"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/joeyates/capture_child_io"}]
  end
end
