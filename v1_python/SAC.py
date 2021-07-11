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
from collections import namedtuple
from datetime import datetime

Movie = namedtuple("Movie", ["name", "url"])


def send_mail(movie, sender, password, recipient, cc):
    msg_content = """Ab sofort sollte es moeglich sein, auf
{}
Kinokarten fuer '{}' vorzubestellen.

Diese E-Mail wird nur einmal versandt.""".format(
        movie.url, movie.name
    )
    msg = EmailMessage()
    msg.set_content(msg_content)
    msg["Subject"] = "Für '" + movie.name + "' können jetzt Karten vorbestellt werden!"
    msg["From"] = sender
    msg["To"] = recipient
    if cc is not None:
        msg["Cc"] = cc

    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.ehlo()
    server.starttls()
    server.ehlo()
    server.login(sender, password)
    server.send_message(msg)
    cc_string = ""
    if cc is not None:
        cc_string = "und " + cc
    print("Email für", movie.name, "wurde an", recipient, cc_string, "gesendet.")


# Searches for tables on the webpage. If the page only contains one table it means that there are
# now screenings available for preorder.
def is_available(html_string):
    soup_available = BeautifulSoup(html_string, "html.parser")
    movies_tables = soup_available.find_all("div", class_="tx-spmovies-pi1-timetable")
    length_movies_tables = len(movies_tables)
    # Check that there is only 1 table, since you will be redirected to another page if the URL
    # provided doesn't lead anywhere. Then there might be more than 1 table.
    if length_movies_tables == 1:
        for table in movies_tables:
            children = table.findChildren("p", recursive=True)
            for child in children:
                txt = child.text
                if re.search("Wartungs", txt):
                    print("Wartungsarbeiten erkannt...")
                    return False
        return True
    return False


def check_movies(movies):
    print(
        datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "- Es wird nach neuen Vorstellungen gesucht...",
    )
    available_movies = []
    for movie in movies:
        response = requests.get(movie.url)
        if is_available(response.text):
            available_movies.append(movie)
    return available_movies


def list_upcoming(blacklist):
    url = "https://www.savoy-filmtheater.de/filmprogramm/coming-soon.html"
    response = requests.get(url)
    soup_coming_soon = BeautifulSoup(response.text, "html.parser")

    # Create a list of links for all upcoming movies
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
        if name in blacklist:
            continue
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
            name = "Name für " + movie + " konnte nicht ermittelt werden."

        if "-1.html" in link:
            link_with_1 = link
            link_without_1 = link.replace("-1.html", ".html")
        else:
            link_with_1 = link.replace(".html", "-1.html")
            link_without_1 = link
        m1 = Movie(name, link_with_1)
        m2 = Movie(name, link_without_1)
        list_name_url += [m1, m2]
    return list_name_url


def main(sender, password, recipient, cc, path_processed):
    # path_processed contains one URL per line. This URL was found in a previous execution of the
    # script and does not need to be sent again.
    with open(path_processed, "a+") as file_processed:
        file_processed.seek(0)
        list_processed_urls = file_processed.read().splitlines()
        upcoming = list_upcoming(list_processed_urls)
        available_movies = check_movies(upcoming)
        if len(available_movies) == 0:
            print("Keine URLs gefunden.")
        # Since a+ is used, the pointer is at the end of the file. In order to read lines from
        # the beginning we have to put it at the beginning.
        for movie in available_movies:
            if movie.url not in list_processed_urls:
                send_mail(movie, sender, password, recipient, cc)
                file_processed.write(movie.url + "\n")
            else:
                print("Für", movie.name, "wurde bereits eine E-Mail verschickt.")


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
    parser.add_argument(
        "-cc",
        "--cc",
        help="Another email address to which the message should be sent to.",
    )
    parser.add_argument(
        "-pp",
        "--path_processed",
        help="Path to the file containing the processed URLs.",
        required=True,
    )
    args = parser.parse_args()
    main(args.sender, args.password, args.recipient, args.cc, args.path_processed)
