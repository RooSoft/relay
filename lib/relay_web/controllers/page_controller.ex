defmodule RelayWeb.PageController do
  use RelayWeb, :controller

  def home(conn, params) do
    text(conn, "yo")
  end
end
