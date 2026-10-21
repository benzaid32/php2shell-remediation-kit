#!/usr/bin/env python3
"""Static checks for the business landing page."""

from html.parser import HTMLParser
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
INDEX = DOCS / "index.html"


class SiteParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids = []
        self.anchors = []
        self.local_refs = []
        self.controls = []
        self.labels = []
        self.has_lang = False
        self.title = []
        self.meta_description = ""
        self._in_title = False

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "html":
            self.has_lang = bool(attrs.get("lang"))
        if "id" in attrs:
            self.ids.append(attrs["id"])
        if tag == "a" and "href" in attrs:
            href = attrs["href"]
            if href.startswith("#") and len(href) > 1:
                self.anchors.append(href[1:])
            elif href and not href.startswith(("http://", "https://", "mailto:", "tel:", "javascript:")):
                self.local_refs.append(href)
        if tag in ("link", "script"):
            ref = attrs.get("href") or attrs.get("src")
            if ref and not ref.startswith(("http://", "https://", "//")):
                self.local_refs.append(ref)
        if tag in ("input", "select", "textarea"):
            self.controls.append(attrs)
        if tag == "label" and "for" in attrs:
            self.labels.append(attrs["for"])
        if tag == "title":
            self._in_title = True
        if tag == "meta" and attrs.get("name") == "description":
            self.meta_description = attrs.get("content", "")

    def handle_endtag(self, tag):
        if tag == "title":
            self._in_title = False

    def handle_data(self, data):
        if self._in_title:
            self.title.append(data)


def main():
    if not INDEX.exists():
        print(f"FAIL: missing {INDEX}")
        return 1

    html = INDEX.read_text(encoding="utf-8")
    parser = SiteParser()
    parser.feed(html)
    errors = []

    duplicates = sorted({item for item in parser.ids if parser.ids.count(item) > 1})
    if duplicates:
        errors.append(f"duplicate ids: {duplicates}")

    missing_anchors = sorted({item for item in parser.anchors if item not in parser.ids})
    if missing_anchors:
        errors.append(f"missing anchor targets: {missing_anchors}")

    checked_assets = set()
    for ref in parser.local_refs:
        clean = ref.split("#", 1)[0].split("?", 1)[0]
        if not clean or clean.startswith("//"):
            continue
        checked_assets.add(clean)
        if not (DOCS / clean).resolve().exists():
            errors.append(f"missing local asset: {clean}")

    if not parser.has_lang:
        errors.append("html lang missing")
    if not "".join(parser.title).strip():
        errors.append("title missing")
    if not parser.meta_description.strip():
        errors.append("meta description missing")

    for control in parser.controls:
        kind = control.get("type", "")
        if kind in ("hidden", "submit", "button", "checkbox"):
            continue
        control_id = control.get("id")
        if not control_id:
            errors.append(f"form control without id: {control}")
        elif control_id not in parser.labels:
            errors.append(f"form control without label: {control_id}")

    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1

    print(
        "Site checks passed: "
        f"{len(checked_assets)} local assets, "
        f"{len(parser.anchors)} anchors, "
        f"{len(parser.ids)} ids, "
        f"{len(parser.controls)} form controls"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
