from argparse import ArgumentParser

import SAC

import unittest

x_men_coming_soon = "data/coming_soon_x_men.html"


class TestSAC(unittest.TestCase):
    def test_wartungsarbeiten(self):
        with open(x_men_coming_soon, "r") as f:
            html = f.read()
            self.assertFalse(SAC.is_available(html))


if __name__ == "__main__":
    unittest.main()
