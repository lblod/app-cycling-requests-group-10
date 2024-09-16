defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ],
    any: ["*/*"]
  ]

  @json %{ accept: %{ json: true } }
  @html %{ accept: %{ html: true } }

  define_layers [ :static, :resources, :services, :fall_back, :not_found ]

  # In order to forward the 'themes' resource to the
  # resource service, use the following forward rule:
  #
  # match "/themes/*path", @json do
  #   Proxy.forward conn, path, "http://resource/themes/"
  # end
  #
  # Run `docker-compose restart dispatcher` after updating
  # this file.

  #################################################################
  # Login logic
  #################################################################
  match "/mock/sessions/*path" do
    forward(conn, path, "http://mocklogin/sessions/")
  end

  match "/gebruikers/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/gebruikers/")
  end

  match "/accounts/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/accounts/")
  end

  match "/sessions/*path", %{layer: :services, accept: %{any: true}} do
    Proxy.forward(conn, path, "http://login/sessions/")
  end

  #################################################################
  # Resources
  #################################################################
  match "/gebruikers/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/decisions/")
  end


  #################################################################
  # Services
  #################################################################


  match "/example/*path", %{layer: :services, accept: %{any: true}} do
    forward(conn, path, "http://example/")
  end

  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
