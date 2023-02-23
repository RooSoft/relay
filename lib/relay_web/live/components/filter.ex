defmodule RelayWeb.Live.Components.Filter do
  use Phoenix.Component

  def filter(assigns) do
    ~H"""
    <div>
      <%= if @filter.authors != [] do %>
        <div class="">
          <%= Enum.count(@filter.authors) %> authors
        </div>
      <% end %>

      <%= if @filter.kinds != [] && @filter.kinds != nil do %>
        <div class="">
          kinds:
          <span class="text-sm">
            <%= inspect @filter.kinds %>
          </span>
        </div>
      <% end %>

      <%= if @filter.ids != [] do %>
        <div>ids: <%= @filter.ids %></div>
      <% end %>

      <div>
        <%= if @filter.since != nil do %>
          <span>
            since: <%= @filter.since %>
          </span>
        <% end %>

        <%= if @filter.until != nil do %>
          <span>
            until: <%= @filter.until %>
          </span>
        <% end %>

        <%= if @filter.limit != nil do %>
          <span>
            limit: <%= @filter.limit %>
          </span>
        <% end %>
      </div>

      <%= if @filter.e != [] do %>
        <div>
          e: <%= @filter.e %>
        </div>
      <% end %>

      <%= if @filter.p != [] do %>
        <div>
          p: <%= @filter.p %>
        </div>
      <% end %>
    </div>
    """
  end
end
