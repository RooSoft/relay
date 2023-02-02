defmodule RelayWeb.PageController do
  use RelayWeb, :controller

  def home(conn, _params) do
    text(conn, "yo")
  end
end
