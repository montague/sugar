defmodule Web.Mixfile do
  use Mix.Project

  def project do
    [ app: :sugar,
      elixir: "~> 0.12.4-dev",
      version: "0.3.0-dev",
      name: "Sugar",
      source_url: "https://github.com/sugar-framework/sugar",
      homepage_url: "http://sugar-framework.github.io/",
      deps: deps(Mix.env) ]
  end

  def application do
    [
      applications: [:cowboy, :plug],
      mod: { Sugar.App, [] }
    ]
  end

  defp deps(:prod) do
    [
      { :mime, github: "dynamo/mime" },
      { :cowboy, github: "extend/cowboy" },
      { :plug,  github: "elixir-lang/plug" },
      { :plugs, github: "sugar-framework/plugs" },
      { :jsex, github: "talentdeficit/jsex" },
      { :templates, github: "sugar-framework/templates" },
      { :postgrex, github: "ericmj/postgrex" },
      { :ecto, github: "elixir-lang/ecto" }
    ]
  end

  defp deps(:docs) do
    deps(:prod) ++
      [ 
        { :ex_doc, github: "elixir-lang/ex_doc" } 
      ]
  end

  defp deps(_) do
    deps(:prod) ++
      [ 
        { :hackney, github: "benoitc/hackney", tag: "0.10.1" } 
      ]
  end
end
