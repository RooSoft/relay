defmodule RelayWeb.Live.Components.Filter do
  use Phoenix.Component

  def filter(assigns) do
    ~H"""
    <%= inspect(@filter) %>
    """
  end
end
