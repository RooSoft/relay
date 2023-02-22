defmodule RelayWeb.Plugs.SocketDispatcher.Nip11Document do
  @nip_11_document Application.compile_env(:relay, :nip_11_document, [])

  def get() do
    nip_11_document =
      @nip_11_document
      |> Enum.into(%{})

    # limitation =
    #   Map.get(nip_11_document, :limitation, [])
    #   |> Enum.into(%{})

    %{
      name: Map.get(nip_11_document, :name, "default name"),
      description: Map.get(nip_11_document, :description, "default description"),
      pubkey: Map.get(nip_11_document, :pubkey, "default pubkey"),
      contact: Map.get(nip_11_document, :contact, "default contact"),
      supported_nips: Map.get(nip_11_document, :supported_nips, "default nips"),
      software: Map.get(nip_11_document, :software, "default software"),
      version: Mix.Project.config()[:version]
      # limitation: %{
      #   max_message_length: Map.get(limitation, :max_message_length, "default"),
      #   max_subscriptions: Map.get(limitation, :max_subscriptions, "default"),
      #   max_filters: Map.get(limitation, :max_filters, "default"),
      #   max_limit: Map.get(limitation, :max_limit, "default"),
      #   max_subid_length: Map.get(limitation, :max_subid_length, "default"),
      #   min_prefix: Map.get(limitation, :min_prefix, "default"),
      #   max_event_tags: Map.get(limitation, :max_event_tags, "default"),
      #   max_content_length: Map.get(limitation, :max_content_length, "default"),
      #   min_pow_difficulty: Map.get(limitation, :min_pow_difficulty, "default"),
      #   auth_required: Map.get(limitation, :auth_required, "default"),
      #   payment_required: Map.get(limitation, :payment_required, "default")
      # }
    }
    |> Jason.encode!()
  end
end
