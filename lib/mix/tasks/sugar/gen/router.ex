defmodule Mix.Tasks.Sugar.Gen.Router do
  use Mix.Task
  import Mix.Generator
  import Mix.Utils, only: [camelize: 1, underscore: 1]

  @shortdoc "Creates Sugar router files"
  @recursive true

  @moduledoc """
  """
  def run(args) do
    opts = OptionParser.parse(args)
    do_create_file elem(opts, 0)
  end

  def run_detached(assigns) do
    do_create_file assigns
  end

  defp do_create_file(_opts) do
    module = camelize atom_to_binary(Mix.project[:app])

    assigns = [
      app: Mix.project[:app], 
      module: module
    ]

    create_file "lib/#{underscore module}/router.ex", router_template(assigns)
  end

  embed_template :router, ~S"""
  defmodule Router do
    use Sugar.Router, plugs: [
        { Plugs.HotCodeReload, [] },
        { Plugs.StaticFiles, url: "/static", path: "priv/static" },

        # Uncomment the following line for session store
        # { Plugs.Session, name: "_sugar_session", adapter: Plugs.Session.Adapters.Ets },

        # Uncomment the following line for request logging,
        # and add 'applications: [:exlager],' to the application
        # Keyword list in your mix.exs
        # { Plugs.Logger, [] }
    ]

    # Uncomment the following line for request logging,
    # and add 'applications: [:exlager],' to the application
    # Keyword list in your mix.exs
    # plug Plugs.Logger

    # Define your routes here
    get "/", <%= @module %>.Controllers.Main, :index
  end
  """
end