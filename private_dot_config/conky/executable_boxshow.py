#!/usr/bin/env python3
from os.path import expanduser
import csv
import re

class BoxShow(object):
    MINE = ["26", "27", "28"]
    FAST = ["9", "42", "43", "44", "45"]
    SHARED = ["3", "19", "23", "29", "30"] + FAST

    def padWidth(self, string, width):
        return "".join([string, " " * (width - len(string))])

    def boxName(self, stats):
        box = stats["boxid"]
        style = "${color7}"
        if box in self.MINE:
            style += "${color2}"
        elif box in self.SHARED:
            style += "${color4}"
        if box in self.FAST:
            style += "${font monospace:size=24:style=Bold}"
        return "%sdev%s${font}${color}" % (style, self.padWidth(box, 2))

    def showBox(self, stats, rightSide):
        loadavg = stats["loadavg"].split()
        st = stats["shortstatus"]
        if rightSide and "(" in st:
            st = st.split("(")
            st = "(%s%s" % (st[1], st[0])
        result = [
            self.boxName(stats),
            loadavg[1],
            stats["connections"],
            st,
            ]
        if rightSide:
            result = result[::-1]
        return " ".join(result)

    def main(self, wraplen = 105, nonPrintable = re.compile(r"\$\{[^}]+}")):
        results = []
        length = 0
        with open(expanduser("~/.config/conky/boxstat.csv"), "r") as csvfile:
            reader = csv.DictReader(csvfile)
            rightSide = False
            for line in reader:
                stats = self.showBox(line, rightSide)
                length += len(nonPrintable.sub("", stats))
                if rightSide and length > wraplen:
                    results.append("\n")
                    rightSide = False
                    stats = self.showBox(line, rightSide)
                    length = 0
                results.append(stats)
                if rightSide or length > wraplen:
                    results.append("\n")
                    rightSide = False
                    length = 0
                else:
                    results.append("${alignr}")
                    rightSide = True
        print("".join(results))


if __name__ == "__main__":
    BoxShow().main()

