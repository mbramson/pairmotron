defmodule Pairmotron.Router do
  use Pairmotron.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :authenticate do
    plug Pairmotron.Plug.RequireAuthentication
  end

  pipeline :admin do
    plug Pairmotron.Plug.RequireAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", Pairmotron do
    pipe_through :browser

    resources "/registration", RegistrationController, only: [:new, :create]
    get "/forgot_password", PasswordResetController, :new
    post "/forgot_password", PasswordResetController, :create
    get "/forgot_password/reset/:token_string", PasswordResetController, :edit
    put "/forgot_password/reset/:token_string", PasswordResetController, :update

    get "/", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete
    delete "/logout", SessionController, :delete # Exadmin logout needs this
  end

  scope "/admin", Pairmotron do
    pipe_through [:browser, :authenticate, :admin]
    get "/", AdminController, :index
    resources "/users", AdminUserController
    resources "/groups", AdminGroupController
    resources "/projects", AdminProjectController
    resources "/user_groups", AdminUserGroupController
    resources "/group_membership_requests", AdminGroupMembershipRequestController
    put "/invitation_accept/:user_id/:group_membership_request_id", AdminInvitationAcceptController, :update
  end

  scope "/", Pairmotron do
    pipe_through [:browser, :authenticate]

    get "/profile", ProfileController, :show
    get "/profile/edit", ProfileController, :edit
    put "/profile/update/:id", ProfileController, :update
    resources "/projects", ProjectController

    get "/pairs", PairController, :index
    get "/pairs/:year/:week", PairController, :show

    get "/groups/:id/pairs", GroupPairController, :show
    get "/groups/:id/pairs/:year/:week", GroupPairController, :show
    delete "/groups/:id/pairs/:year/:week", GroupPairController, :delete
    resources "/groups/:group_id/invitations", GroupInvitationController, only: [:index, :new, :create, :update, :delete]
    resources "/invitations", UsersGroupMembershipRequestController, only: [:index, :create, :update, :delete]
    resources "/groups", GroupController
    delete "/groups/:group_id/users/:user_id", UserGroupController, :delete
    get "/groups/:group_id/users/:user_id", UserGroupController, :edit
    put "/groups/:group_id/users/:user_id", UserGroupController, :update

    get "/pair_retros/new/:pair_id", PairRetroController, :new
    resources "/pair_retros", PairRetroController, except: [:new]
  end

end
