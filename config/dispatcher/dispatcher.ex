defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ],
    any: ["*/*"]
  ]

  define_layers [ :static, :resources, :services, :fall_back, :not_found ]

  options "/*path", _ do
    conn
    |> Plug.Conn.put_resp_header("access-control-allow-headers", "content-type,accept")
    |> Plug.Conn.put_resp_header("access-control-allow-methods", "*")
    |> send_resp(200, "{ \"message\": \"ok\" }")
  end

  # Run `docker-compose restart dispatcher` after updating
  # this file.

  ###############
  # STATIC
  ###############

  # self-service
  match "/index.html", %{layer: :static} do
    forward(conn, [], "http://frontend/index.html")
  end

  get "/assets/*path", %{layer: :static} do
    forward(conn, path, "http://frontend/assets/")
  end

  get "/@appuniversum/*path", %{layer: :static} do
    forward(conn, path, "http://frontend/@appuniversum/")
  end

  #################
  # FRONTEND PAGES
  #################

  # self-service
  match "/*path", %{layer: :fall_back, accept: %{html: true}} do
    # we don't forward the path, because the app should take care of this in the browser.
    forward(conn, [], "http://frontend/index.html")
  end

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
  match "/commune-approvals/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/commune-approvals/")
  end

  match "/agendapunten/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/agendapunten/")
  end

  match "/besluiten/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/besluiten/")
  end

  match "/behandelingen-van-agendapunt/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/behandelingen-van-agendapunt/")
  end

  match "/published-resources/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/published-resources/")
  end

  match "/adressen/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/adressen/")
  end

  match "/concepts/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/concepts/")
  end

  match "/concept-schemes/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/concept-schemes/")
  end

  match "/request-state-classifications/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/request-state-classifications/")
  end

  match "/bestuurseenheden/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/bestuurseenheden/")
  end

  match "/bestuurseenheid-classificatie-codes/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/bestuurseenheid-classificatie-codes/")
  end

  match "/werkingsgebieden/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/werkingsgebieden/")
  end

  match "/refusals/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/refusals/")
  end

  match "/grants/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/grants/")
  end

  match "/projects/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/projects/")
  end

  match "/cycling-requests/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/cycling-requests/")
  end

  match "/route-sections/*path", %{layer: :resources, accept: %{any: true}} do
    forward(conn, path, "http://resource/route-sections/")
  end

  #################################################################
  # Services
  #################################################################


  match "/example/*path", %{layer: :services, accept: %{any: true}} do
    forward(conn, path, "http://example/")
  end

  match "/cycling/*path", %{} do
    forward(conn, path, "http://cycling/")
  end

  match "/form-content/*path", %{layer: :services, accept: %{any: true}} do
    forward(conn, path, "http://form-content/")
  end

  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end

  #################################################################
  # LDES
  #################################################################
  get "/streams/ldes/*path" do
    forward(conn, path, "http://ldes-backend/ldes/")
  end

end
