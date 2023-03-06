defmodule Relay.Nostr.Connection.EventValidator do
  @moduledoc """
  Event valdation to make sure it respects sane maximum defaults
  """

  @max_content_length Application.compile_env(:relay, :max_content_length, 102_400)
  @max_event_tags Application.compile_env(:relay, :max_event_tags, 2500)

  @doc """
  Makes sure an event's content size is less than the max in configuration settings

  ## Examples
      iex> Relay.Support.Generators.Values.string(16)
      ...> |> Relay.Nostr.Connection.EventValidator.validate_content_size(16)
      :ok

      iex> Relay.Support.Generators.Values.string(17)
      ...> |> Relay.Nostr.Connection.EventValidator.validate_content_size(16)
      {:error, "Content length of 17 bytes is exceeding max length of 16"}
  """
  @spec validate_content_size(String.t()) :: :ok | {:error, String.t()}
  def validate_content_size(content, max_content_length \\ @max_content_length)

  def validate_content_size(content, max_content_length)
      when byte_size(content) > max_content_length do
    message =
      ~s(Content length of #{byte_size(content)} bytes is exceeding max length of #{max_content_length})

    {:error, message}
  end

  def validate_content_size(_content, _max_content_length), do: :ok

  @doc """
  Make sure thare aren't too many tags in a given event, according to configuration settings

  ## Examples
      iex> []
      ...> |> Relay.Nostr.Connection.EventValidator.validate_number_of_tags()
      :ok

      iex> Relay.Support.Generators.Values.list(11)
      ...> |> Relay.Nostr.Connection.EventValidator.validate_number_of_tags(10)
      {:error, "Event containing 11, exceeding the maximum of 10"}
  """
  @spec validate_number_of_tags(list()) :: :ok | {:error, String.t()}
  def validate_number_of_tags(tags, max_event_tags \\ @max_event_tags)

  def validate_number_of_tags(tags, max_event_tags) when length(tags) > max_event_tags do
    message = ~s(Event containing #{Enum.count(tags)}, exceeding the maximum of #{max_event_tags})

    {:error, message}
  end

  def validate_number_of_tags(_tags, _max_event_tags), do: :ok
end
