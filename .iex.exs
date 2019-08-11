# https://github.com/code-shoily/mafinar.exs/blob/master/.iex.exs
IEx.configure(
  colors: [
    syntax_colors: [
      number: :light_yellow,
      atom: :light_cyan,
      string: :light_black,
      boolean: :red, 
      nil: [:magenta, :bright],
    ]
  ],
  history_size: 50,
  inspect: [
    pretty: true, 
    limit: :infinity,
    width: 80
  ]
)

