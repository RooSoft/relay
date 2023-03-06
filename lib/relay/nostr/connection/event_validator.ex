defmodule Relay.Nostr.Connection.EventValidator do
  @max_content_length Application.compile_env(:relay, :max_content_length, 102_400)
  @max_event_tags Application.compile_env(:relay, :max_event_tags, 2500)

  @doc """
  Makes sure an event's content size is less than the max in configuration settings

  ## Examples
      iex> Relay.Support.Generators.Values.string(16)
      ...> |> Relay.Nostr.Connection.EventValidator.validate_content_size()
      :ok

      iex> Relay.Support.Generators.Values.string(102_401)
      ...> |> Relay.Nostr.Connection.EventValidator.validate_content_size()
      {:error, "Content length of 102401 bytes is exceeding max length of 102400"}
  """
  @spec validate_content_size(String.t()) :: :ok | {:error, String.t()}
  def validate_content_size(content) when byte_size(content) > @max_content_length do
    message =
      ~s(Content length of #{byte_size(content)} bytes is exceeding max length of #{@max_content_length})

    {:error, message}
  end

  def validate_content_size(_content), do: :ok

  def validate_number_of_tags(tags) when length(tags) > @max_event_tags do
    message =
      ~s(Event containing #{Enum.count(tags)}, exceeding the maximum of  #{@max_event_tags})

    {:error, message}
  end

  def validate_number_of_tags(_), do: :ok
end
