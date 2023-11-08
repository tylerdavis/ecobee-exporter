defmodule Ecobee.Storage do
  def put(key, value) do
    CubDB.put(Ecobee.CubDB, key, value)
  end

  def get(key) do
    CubDB.get(Ecobee.CubDB, key)
  end

  def clear do
    CubDB.clear(Ecobee.CubDB)
  end
end
