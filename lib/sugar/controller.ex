defmodule Sugar.Controller do
  import Plug.Connection
  @moduledoc """
  All controller actions should have an arrity of 2, with the 
  first argument being a `Plug.Conn` representing the current 
  connection and the second argument being a `Keyword` list 
  of any parameters captured in the route path.

  Sugar bundles these response helpers to assist in sending a 
  response:

  - `render/2` - `conn`, `template` - sends a normal response.
  - `halt!/1` - `conn` - ends the response.
  - `not_found/1` - `conn` - sends a 404 (Not found) response.
  - `json/2` - `conn`, `data` - sends a normal response with
    `data` encoded as JSON.
  - `raw/1` - `conn` - sends response as-is. It is expected
    that status codes, headers, body, etc have been set by
    the controller action.

  #### Example

      defmodule Hello do
        use Sugar.Controller

        def index(conn, []) do
          render conn, "showing index controller"
        end

        def show(conn, args) do
          render conn, "showing page \#{args[:id]}"
        end
        
        def create(conn, []) do
          render conn, "page created"
        end

        def get_json(conn, []) do
          json conn, [message: "foobar"]
        end
      end
  """

  @doc """
  Macro used to add necessary items to a controller.
  """
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import unquote(Plug.Connection)
    end
  end

  @doc """
  Sends a normal response with `data` encoded as JSON.

  ## Arguments

  - `conn` - `Plug.Conn`
  - `data` - `Keyword|List`

  ## Returns

  `Tuple` - `{:ok, sent_response}`
  """
  def json(conn, data) do
    conn
      |> put_resp_content_type(MIME.Types.type("json"))
      |> send_resp_if_not_sent(200, JSEX.encode! data)
  end

  @doc """
  Sends response as-is. It is expected that status codes, 
  headers, body, etc have been set by the controller 
  action.

  ## Arguments

  - `conn` - `Plug.Conn`

  ## Returns

  `Tuple` - `{:ok, sent_response}`
  """
  def raw(conn) do
    conn |> send_resp
  end

  @doc """
  Sends a normal response.

  ## Arguments

  - `conn` - `Plug.Conn`
  - `template` - `String`
  - `opts` - `Keyword`

  ## Returns

  `Tuple` - `{:ok, sent_response}`
  """
  def render(conn, template, opts \\ []) do
    opts = [status: 200] |> Keyword.merge opts

    conn 
      |> put_resp_content_type(opts[:content_type] || MIME.Types.type("html")) 
      |> send_resp_if_not_sent(opts[:status], template)
  end

  @doc """
  Ends the response.

  ## Arguments

  - `conn` - `Plug.Conn`
  - `opts` - `Keyword`

  ## Returns

  `Tuple` - `{:ok, sent_response}`
  """
  def halt!(conn, opts \\ []) do
    opts = [status: 401, message: ""] |> Keyword.merge opts
    conn 
      |> send_resp_if_not_sent(opts[:status], opts[:message])
  end

  @doc """
  Sends a 404 (Not found) response.

  ## Arguments

  - `conn` - `Plug.Conn`

  ## Returns

  `Tuple` - `{:ok, sent_response}`
  """
  def not_found(conn, message \\ "Not Found") do
    conn 
      |> send_resp_if_not_sent(404, message)
  end

  @doc """
  Forwards the response to another controller action.

  ## Arguments

  - `conn` - `Plug.Conn`
  - `controller` - `Atom`
  - `action` - `Atom`
  - `args` - `Keyword`

  ## Returns

  `Tuple` - `{:ok, conn}`
  """
  def forward(conn, controller, action, args \\ []) do
    apply controller, action, [conn, args]
  end

  @doc """
  Redirects the response.

  ## Arguments

  - `conn` - `Plug.Conn`
  - `location` - `String`
  - `opts` - `Keyword`

  ## Returns

  `Tuple` - `{:ok, sent_response}`
  """
  def redirect(conn, location, opts \\ []) do
    opts = [status: 302] |> Keyword.merge opts
    conn 
      |> put_resp_header("Location", location) 
      |> send_resp_if_not_sent(opts[:status], "")
  end

  defp send_resp_if_not_sent(Plug.Conn[state: :sent] = conn, _, _) do
    conn
  end
  defp send_resp_if_not_sent(conn, status, body) do
    conn |> send_resp(status, body)
  end

end
