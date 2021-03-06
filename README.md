# TwilioAuth

This library implements validation for incoming requests from
Twilio, per the spec outlined at:

https://www.twilio.com/docs/api/security#validating-requests

## Installation

The package can be installed from hex by adding the following
to your project's `mix.exs`:

```elixir
  def deps do
    [{:twilio_auth, "~> 0.3.0"}]
  end
```

## Use

`TwilioAuth` is implemented as a [Plug](https://hexdocs.pm/plug/readme.html),
and can be activated by including it as part of an existing pipeline.

For example, in a Phoenix router:

```elixir

defmodule MyRouter do
  use Phoenix.Router

  pipeline :my_pipe do
    plug TwilioAuth, auth_token: YOUR_AUTH_TOKEN
  end

  scope "/twilio" do
    pipe_through :my_pipe

    # ...
  end
end
```

Importantly, `TwilioAuth` depends on query and body params having already
been fetched, so should always be used after `Plug.Parsers`.

The plug has two configuration options:

```
auth_token # authentication token provided by Twilio for your app's use
           # String.t | {atom(), atom()}
enabled    # boolean controlling whether auth is on (`true` by default)
```

`auth_token` allows either a string argument, or a 2-tuple that will be
evaluated at runtime to get an environment variable off of `Application`.

i.e.

```
# in config.exs
config :twilio_auth, auth_token: YOUR_AUTH_TOKEN

# in router
plug TwilioAuth, auth_token: {:twilio_auth, :auth_token}
```
