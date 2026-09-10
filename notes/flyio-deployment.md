# Livebook on Flyio

https://fly.io/docs/app-guides/livebook/
https://livebook-fly-up.fly.dev/

https://fly.io/docs/app-guides/livebook/#main-content-start

```
Speedrun
Create a fly.toml file with the contents in the next section.
fly launch --no-deploy
fly secrets set LIVEBOOK_PASSWORD="<my-super-sekrit-password>"
fly deploy --vm-size shared-cpu-2x --volume-initial-size 1
fly apps open
```

- Data volume
  - deploy only on one Fly Machine
  - Fly volumes don’t automatically synchronize across an app, so the simplest way to run Livebook with volume storage is as a single Machine, with the availability repercussions that implies. Other deployment configurations are beyond the scope of this guide, but Livebook does provide the option to connect with an object storage service.

- use a custom EPMD module

- LIVEBOOK_DISTRIBUTION 不支持sname，默认都是name，相当于 RELEASE_DISTRIBUTION=name|none（默认）

    # TODO: remove in v1.0
    if System.get_env("LIVEBOOK_DISTRIBUTION") == "sname" do
      IO.warn(
        ~s/Ignoring LIVEBOOK_DISTRIBUTION=sname, because short names are no longer supported./,
        []
      )
    end

- 使用 longnames
  defp get_node_name() do
    Application.get_env(:livebook, :node) || random_long_name()
  end

  defp random_long_name() do
    host =
      if Livebook.Utils.proto_dist() == :inet6_tcp do
        "::1"
      else
        "127.0.0.1"
      end

    :"livebook_#{Livebook.Utils.random_short_id()}@#{host}"
  end
- Livebook.Utils.proto_dist() 从 erl选项-proto_dist inet6_tcp中抽取值
- node配置方式 LIVEBOOK_NODE
    if node = Livebook.Config.node!("LIVEBOOK_NODE") do
      config :livebook, :node, node
    end
- cookie配置方式 LIVEBOOK_COOKIE
    config :livebook,
           :cookie,
           Livebook.Config.cookie!("LIVEBOOK_COOKIE") || Livebook.Utils.random_cookie()
    def cookie!(env) do
      if cookie = System.get_env(env) do
        String.to_atom(cookie)
      end
    end

- echo FLY_APP_NAME=$FLY_APP_NAME FLY_IMAGE_REF=$FLY_IMAGE_REF FLY_PRIVATE_IP=$FLY_PRIVATE_IP
