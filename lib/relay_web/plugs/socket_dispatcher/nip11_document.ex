defmodule RelayWeb.Plugs.SocketDispatcher.Nip11Document do
  @nip_11_document Application.compile_env(:relay, :nip_11_document, [])

  @max_frame_size Application.compile_env(:relay, :max_frame_size, 1024 * 1024 / 2)
  @max_subscriptions Application.compile_env(:relay, :max_subscriptions, 10)
  @max_filters Application.compile_env(:relay, :max_filters, 10)
  @max_content_length Application.compile_env(:relay, :max_content_length, 102_400)
  @max_event_tags Application.compile_env(:relay, :max_event_tags, 2500)
  @max_limit Application.compile_env(:relay, :max_limit, 5000)

  def get() do
    nip_11_document =
      @nip_11_document
      |> Enum.into(%{})

    limitation =
      Map.get(nip_11_document, :limitation, [])
      |> Enum.into(%{})

    %{
      name: Map.get(nip_11_document, :name, "default name"),
      description: Map.get(nip_11_document, :description, "default description"),
      pubkey: Map.get(nip_11_document, :pubkey, "default pubkey"),
      contact: Map.get(nip_11_document, :contact, "default contact"),
      supported_nips: Map.get(nip_11_document, :supported_nips, "default nips"),
      software: Map.get(nip_11_document, :software, "default software"),
      version: get_application_version(),
      limitation: %{
        max_message_length: Map.get(limitation, :max_message_length, @max_frame_size),
        max_subscriptions: Map.get(limitation, :max_subscriptions, @max_subscriptions),
        max_filters: Map.get(limitation, :max_filters, @max_filters),
        max_limit: Map.get(limitation, :max_limit, @max_limit),
        #   max_subid_length: Map.get(limitation, :max_subid_length, "default"),
        #   min_prefix: Map.get(limitation, :min_prefix, "default"),
        max_event_tags: Map.get(limitation, :max_event_tags, @max_event_tags),
        max_content_length: Map.get(limitation, :max_content_length, @max_content_length)
        #   min_pow_difficulty: Map.get(limitation, :min_pow_difficulty, "default"),
        #   auth_required: Map.get(limitation, :auth_required, "default"),
        #   payment_required: Map.get(limitation, :payment_required, "default")
      }
    }
    |> Jason.encode!()
  end

  defp get_application_version do
    case :application.get_key(:relay, :vsn) do
      {:ok, version} -> to_string(version)
      _ -> "unknown"
    end
  end
end
