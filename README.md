# Metex

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `metex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:metex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/metex>.

## How to step run and learn

```sh
url= Metex.Worker.get_base_url "Bangkok"
a= HTTPoison.get(url) |> Metex.Worker.parse_resp


cities = ["Singapore" ,"Thailand", "Shanghai", "Hong kong", "Bangkok" , "Phuket"]
cities |> Enum.map(fn city -> Metex.Worker.temperature_of(city) end )



cities = ["Singapore" ,"Thailand", "Shanghai", "Hong kong", "Bangkok" , "Phuket"]
cities |> Enum.each(fn city ->
  pid = spawn(Metex.Worker, :loop, [])
  send(pid ,{self, city})
end )



cities = ["Singapore" ,"Thailand", "Shanghai", "Hong kong", "Bangkok" , "Phuket", "test"]
Metex.temperatures_of(cities)



```
