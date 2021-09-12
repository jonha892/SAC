defmodule SAC.HTMLParser do
  require Logger
  use Timex

  alias SAC.{Util, ErrorHandling}

  def parse_response(%Finch.Response{body: body, headers: h, status: 200}) do
    Floki.parse_document body
  end

  def find_movies(:program, document) do
    #a_elements = Floki.find(document, "a")
    #hrefs = Floki.attribute(a_elements, "href")
    #filter_hrefs(hrefs)


    # regex
    #(,\\&q;slug\\&q;:\\&q;)(\*+)
    regex = ~r/(000\\&q;,\\&q;slug\\&q;:\\&q;)(.+?(?=\\&q;,\\&q;title\\&q;))/#(\\&q;,\\&q;title\\&q;)
    script_text = Floki.find(document, "#flebbe-state")
      |> Floki.raw_html
    movies = Regex.scan(regex, script_text)
    |> Enum.map(fn x -> Enum.at(x, 2) end)
    |> Enum.uniq

    possible_errors = movies |> Enum.filter(fn title -> String.contains?(title, [";", "\\"]) end)
    ErrorHandling.title_error(possible_errors)

    Logger.info "titles " <> inspect(movies)
    Logger.info inspect(Kernel.length(movies))
    movies
  end

  # TODO Logging
  def parse_movie(document, title) do
    title_pretty = Floki.find(document, "title") |> Floki.text |> Util.transform_title

    #date_regex = ~r/\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-4]):([0-5][0-9]):\d{2}.\d{3}(\\&q;,\\&q;slug\\&q;:\\&q;)free-guy/
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

#playtime = Floki.find(document, "movie-detail-page") |> Floki.find(".playtimes-movie-item-component") |> Floki.find("span") |> Floki.find(".time") |> Floki.text
#single_date = Floki.find(document, "movie-detail-page") |> Floki.find(".date-holder") |> Floki.find(".select-single") |> Floki.text |> String.trim
#multiple_playtimes = Floki.find(document, "movie-detail-page") |> Floki.find(".date-holder") |> Floki.find("option") |> Enum.map(fn x -> x |> Floki.text |> String.trim end)
