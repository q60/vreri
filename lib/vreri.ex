defmodule Vreri do
  def main(_) do
    parameters = "method=getQuote&format=text&lang=en"

    {:ok, code, _, client_ref} =
      :hackney.get(
        "https://api.forismatic.com/api/1.0/?" <> parameters,
        # headers
        [],
        # payload
        <<>>,
        # options
        []
      )

    case code do
      # if request succeeded
      200 ->
        {:ok, text} = :hackney.body(client_ref)
        quote = String.trim(text)

        case Regex.run(~r/\(.+\)/, quote, return: :index) do
          [captured | _] ->
            {author_start, len} = captured

            quote
            |> String.slice(0, author_start)
            |> String.trim()
            |> wrap()
            |> then(fn str -> "\"\e[94m\e[1m#{str}\e[0m\"" end)
            |> IO.puts()

            quote
            |> String.slice(author_start + 1, len - 2)
            |> String.trim()
            |> then(fn str -> "\e[93m#{str}\e[0m" end)
            |> IO.puts()

          _ ->
            quote
            |> String.trim()
            |> wrap()
            |> then(fn str -> "\"\e[94m\e[1m#{str}\e[0m\"" end)
            |> IO.puts()
        end

      # else ...
      _ ->
        IO.puts("\e[94m\e[1mHTTP error code:\e[0m \e[91m#{code}\e[0m")
        # exiting with non-zero status
        exit(1)
    end
  end

  def wrap(str, max_len \\ 40) do
    # splitting string
    wrap(0, String.split(str), [], max_len)
  end

  # resetting line length counter, adding newline char
  def wrap(acc, [h | t], res, max_len) when acc >= max_len do
    wrap(String.length(h), t, res ++ ["\n"] ++ [h], max_len)
  end

  # incrementing counter by length of current word
  def wrap(acc, [h | t], res, max_len) do
    wrap(acc + String.length(h), t, res ++ [h], max_len)
  end

  def wrap(_, [], res, _) do
    Enum.join(res, " ")
  end
end
