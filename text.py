from argparse import ArgumentParser

import SAC

import unittest


class TestSAC(unittest.TestCase):
    def test_wartungsarbeiten(self, html_fn):
        with open(html_fn, "r") as f:
            html = f.read()
            self.assertTrue(SAC.is_available(html))


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("-h", "html", "HTML to be parsed")
    args = parser.parse_args()
    unittest.main()
