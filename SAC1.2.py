"""
                                   Savoy Availability Checker

Scrapes the Coming Soon website for https://www.savoy-filmtheater.de in order to find movies that
are releasing soon. Then it checks whether there are screenings available for those movies. It sends
an email to the provided email address containing the name of the movies with available screenings. 
"""
import requests
from bs4 import BeautifulSoup

from pprint import pprint

import re
import smtplib
from argparse import ArgumentParser
from email.message import EmailMessage


# TODO: processed Vergleich vorher (beim Scrapen der URLs) moeglich?


def send_mail(name_url_pair, addr, password, to):
    m = "Ab sofort sollte es moeglich sein, auf {} Kinokarten fuer {} vorzubestellen. Diese E-Mail wird nur einmal versandt.".format(
        name_url_pair[1], name_url_pair[0]
    )
    msg = EmailMessage()
    msg.set_content(m)
    msg["Subject"] = (
        "Für" + name_url_pair[0] + "können jetzt Karten vorbestellt werden!"
    )
    msg["From"] = addr
    msg["To"] = to

    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.ehlo()
    server.starttls()
    server.ehlo()
    server.login(addr, password)
    server.send_message(msg)
    print("Email für", name_url_pair[0], "wurde an", addr, "gesendet.")
    return True


# Searches for tables on the webpage. If the page only contains one table it means that there are
# now screenings available for preorder.
def is_available(html_string, url):
    s = BeautifulSoup(html_string, "html.parser")
    tables = s.find_all("div", class_="tx-spmovies-pi1-timetable")
    l = len(tables)
    # print('URL ', url, ' hat ', l, ' Tabellen.')
    if l == 1:
        return True
    return False


def check_urls(urls):
    print("Es wird nach neuen Vorstellungen gesucht...")
    available_movies = []
    for (name, url) in urls:
        response = requests.get(url)
        if is_available(response.text, url):
            available_movies.append((name, url))
    return available_movies


def list_upcoming():
    url = "https://www.savoy-filmtheater.de/filmprogramm/coming-soon.html"
    response = requests.get(url)
    soup_coming_soon = BeautifulSoup(response.text, "html.parser")

    # Create a list of links for all upcoming movies - HOW EXACTLY? What is x, why is the ...savoy..
    # String necessary?
    list_movies = [
        "https://www.savoy-filmtheater.de/" + x["href"]
        for x in soup_coming_soon.find_all("a", href=True)
        if x.getText() == "Detailansicht"
    ]

    # A list of tuples containing the name of the movie and its URL. Since Savoy is not consistent,
    # we have to use two different URLs for one movie, either appending a -1 or removing it.
    list_name_url = []
    for movie in list_movies:
        link = movie.replace("coming-soon/", "")
        name = re.search("film/(.*).html", link)

        # If the name is not empty, make it pretty and add it to the list.
        if name is not None:
            name = (
                name.group(1)
                .replace("-1", "")
                .replace("-ov", "")
                .replace("-", " ")
                .title()
            )
        else:
            name = "Name für" + movie + "konnte nicht ermittelt werden."

        if "-1.html" in link:
            link_with_1 = link
            link_without = link.replace("-1.html", ".html")
        else:
            link_with_1 = link.replace(".html", "-1.html")
            link_without = link
        list_name_url += [(name, link_with_1), (name, link_without)]
    # pprint(res_list)
    return list_name_url


def main(addr, password, recipient):
    upcoming = list_upcoming()
    available = check_urls(upcoming)
    if len(available) > 0:
        # print("Die folgenden URLs sind verfügbar:", available)
        # processed.txt contains one URL per line. This URL was found in a previous execution of the
        # script and does not need to be sent again.
        with open("processed.txt", "a+") as file_processed:
            # Since a+ is used, the pointer is at the end of the file. In order to read lines from
            # the beginning we have to put it at the beginning.
            file_processed.seek(0)
            list_processed_urls = file_processed.read().splitlines()
            # print("Diese URLs wurden bereits verschickt:", p)
            count_mails = 0
            for (name, a) in available:
                # count_mails += 1
                if a not in list_processed_urls:
                    send_mail((name, a), addr, password, recipient)
                    file_processed.write(a + "\n")
                else:
                    print("Für", name, "wurde bereits eine E-Mail verschickt.")
            # print(
            #    "Es wurden E-Mails für ", count_mails, "neue Vorstellungen verschickt."
            # )

    else:
        print("Keine URLs gefunden.")


if __name__ == "__main__":
    parser = ArgumentParser("Savoy Availablity Checker")
    parser.add_argument(
        "-s", "--sender", help="The sender's email address.", required=True
    )
    parser.add_argument(
        "-p",
        "--password",
        help="The password for the sender's email address.",
        required=True,
    )
    parser.add_argument(
        "-r", "--recipient", help="The recipient email address.", required=True
    )
    args = parser.parse_args()
    main(args.sender, args.password, args.recipient)
