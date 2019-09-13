"""
mdBook preprocessor for expanding pystache variables.
For example {{github-repo-url}}/blob/{{git-blob-version}}/src/main/main.cpp
"""
import json
import sys

import pystache

CONF = {
    "git-blob-version": "8cdab059d22eb8f30e1408c2fbf0ae666fa231d9",
    "github-repo-url": "https://github.com/parallel-rust-cpp/shortcut-comparison",
    "ppc-url": "http://ppc.cs.aalto.fi",
    "rust-version-str": "1.37.0",
}
def has_key(s):
    return any(r'{{' + key + r'}}' in content for key in CONF)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "supports":
        sys.exit(0)
    _, book = json.load(sys.stdin)
    r = pystache.renderer.Renderer(escape=lambda s: s)
    for section in book["sections"]:
        content = section["Chapter"]["content"]
        if has_key(content):
            section["Chapter"]["content"] = r.render(content, CONF)
    json.dump(book, sys.stdout)
