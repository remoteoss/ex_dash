defmodule Mix.Tasks.Docs.Dash do
  @moduledoc """
  Run ExDoc with a Dash Docs compatible formatter and output.

  """

  use Mix.Task

  alias Mix.Tasks.Docs
  alias ExDash.Store
  
  @requirements ["compile"]

  @type args :: [binary]

  @doc """
  Builds a Dash Docset for the current Mix project.

  ## Options

    * `--open`: opens the built docset in Dash following the build.
      Defaults to true unless the docset exists in the `/doc` dir before the run.
    * `--name NAME`: names the docset something other than the app name.
      Defaults to the project name, or (if an umbrella app) the `cwd` of the mix task
    * `--abbr ABBREVIATION`: the default abbreviation to search for your docs with.
      Default: first two characters of the project name. (i.e. `ex` for `ex_dash`).

  """
  @spec run(args) :: String.t
  def run(args \\ []) do
    {opts, _, _} =
      OptionParser.parse(args, switches: [open: :boolean, name: :string])

    name =
      Keyword.get(opts, :name)

    abbr =
      Keyword.get(opts, :abbr)

    Store.start_link()

    Store.set(:name, name)
    Store.set(:abbreviation, abbr)

    [doc_set_path] =
      Docs.run(["-f", ExDash])

    auto_open? =
      Keyword.get_lazy(opts, :open, fn ->
        Store.get(:is_new_docset)
      end)

    if auto_open? do
      IO.inspect(doc_set_path, label: :opening)
      System.cmd("open", [doc_set_path], [])
    end

    doc_set_path
  end
end
