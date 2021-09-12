defmodule SAC.HTMLParser do
  require Logger
  use Timex

  alias SAC.{Util, ErrorHandling}

  def parse_response(%Finch.Response{body: body, headers: h, status: 200}) do
    Floki.parse_document body
  end

  def find_movies(:program, document) do
    # regex
    regex = ~r/(000\\&q;,\\&q;slug\\&q;:\\&q;)(.+?(?=\\&q;,\\&q;auditorium\\&q;))/
    script_text = Floki.find(document, "#flebbe-state")
      |> Floki.raw_html
    movies = Regex.scan(regex, script_text)
    |> Enum.map(fn x -> Enum.at(x, 2) end)
    |> Enum.uniq

    possible_errors = movies |> Enum.filter(fn title -> String.contains?(title, [";", "\\"]) end)
    if Kernel.length(possible_errors) > 0 do
      ErrorHandling.title_error(possible_errors)
    end

    Logger.info "titles " <> inspect(movies)
    Logger.info inspect(Kernel.length(movies))
    movies
  end

  # TODO Logging
  def parse_movie(document, title) do
    title_pretty = Floki.find(document, "title") |> Floki.text |> Util.transform_title

    date_regex = ~r/(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3})(\\&q;,\\&q;slug\\&q;:\\&q;)#{title}/
    script_text = Floki.find(document, "#flebbe-state")
      |> Floki.raw_html
    playtime_strings = Regex.scan(date_regex, script_text)
      |> Enum.map(fn x -> Enum.at(x, 1) end)
      |> Enum.uniq
      |> Enum.map(fn date_str -> String.slice(date_str, 0..-8) end)
    #Logger.info inspect(playtime_strings)

    # TODO splitwith, direkt ok entfernen
    playtimes = playtime_strings
      |> Enum.map(fn date_str -> Timex.parse(date_str, "{YYYY}-{0M}-{0D}T{h24}:{m}") end)
      |> Enum.split_with(fn {:error, _} -> true; _ -> false end)
    #Logger.info "Playtimes: " <> inspect(playtimes)

    case playtimes do
      {[], playtimes} ->
        playtimes = Enum.map(playtimes, fn {:ok, date} -> date end)
        playtimes = Enum.map(playtimes, fn date -> Timex.to_datetime(date, "Europe/Copenhagen") end)
        sorted_playtimes = Enum.sort(playtimes)
        #Logger.info "Playtimes sorted_playtimes: " <> inspect(sorted_playtimes)
        bookable = Kernel.length(playtimes) > 0
        movie = %{bookable: bookable, title_pretty: title_pretty, playtimes: sorted_playtimes, title: title}
        {:ok, movie}
      [errors, _] -> {:error, errors}
    end

  end

  defp filter_hrefs(hrefs) do
    # TODO refactor
    Enum.filter(hrefs, fn x -> String.match?(x, ~r/^\/movie\//) end) |> Enum.uniq |> Enum.map(fn s -> String.slice(s, 7..-1) end)
  end
end
