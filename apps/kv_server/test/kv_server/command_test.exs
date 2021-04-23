defmodule KVServer.CommandTest do
  use ExUnit.Case, async: true
  doctest KVServer.Command

  setup context do
    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

  test "run create command", %{registry: registry} do
    assert KVServer.Command.run({:create, "shopping"}, registry) == {:ok, "OK\r\n"}
  end

  test "run put command", %{registry: registry} do
    assert KVServer.Command.run({:get, "shopping", "potato"}, registry) == {:error, :not_found}

    {:ok, "OK\r\n"} = KVServer.Command.run({:create, "shopping"}, registry)
    {:ok, "OK\r\n"} = KVServer.Command.run({:put, "shopping", "potato", 9}, registry)

    assert KVServer.Command.run({:get, "shopping", "potato"}, registry) == {:ok, "9\r\nOK\r\n"}
  end

  test "run delete command", %{registry: registry} do
    {:ok, "OK\r\n"} = KVServer.Command.run({:create, "shopping"}, registry)
    {:ok, "OK\r\n"} = KVServer.Command.run({:put, "shopping", "potato", 9}, registry)

    assert KVServer.Command.run({:get, "shopping", "potato"}, registry) == {:ok, "9\r\nOK\r\n"}

    {:ok, "OK\r\n"} = KVServer.Command.run({:delete, "shopping", "potato"}, registry)

    KVServer.Command.run({:create, "bougy"}, registry)
    assert KVServer.Command.run({:get, "shopping", "potato"}, registry) == {:ok, "\r\nOK\r\n"}
  end
end
