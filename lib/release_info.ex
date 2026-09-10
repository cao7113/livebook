defmodule ReleaseInfo do
  ## Dig Release
  def info do
    vars = release_env_vars()
    rel_root = vars["RELEASE_ROOT"]

    if rel_root do
      init_file_cookie = File.read!(Path.join([rel_root, "releases/COOKIE"]))
      vars |> Map.put("RELEASE_COOKIE_FILE_VALUE", init_file_cookie)
    else
      vars
    end
  end

  def release_env_vars do
    ~w[
      RELEASE_ROOT
      RELEASE_NAME
      RELEASE_VSN
      RELEASE_PROG
      RELEASE_COMMAND
      RELEASE_DISTRIBUTION
      RELEASE_NODE
      RELEASE_COOKIE
      RELEASE_SYS_CONFIG
      RELEASE_VM_ARGS
      RELEASE_REMOTE_VM_ARGS
      RELEASE_TMP
      RELEASE_MODE
      RELEASE_BOOT_SCRIPT
      RELEASE_BOOT_SCRIPT_CLEAN
    ]
    |> Enum.into(%{}, fn env ->
      {env, System.get_env(env, nil)}
    end)
  end
end
