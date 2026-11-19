#!/usr/bin/env python3
"""Test de `scripts/sources/strip_sel.py` sur un petit arbre synthétique (`fixture/`).

Lancement : python3 -I scripts/sources/tests/test_strip_sel.py
L'arbre d'exemple est écrit pour ce test : il ne contient aucun code de Stalwart.
"""

import importlib.util
import os
import shutil
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
SPEC = importlib.util.spec_from_file_location("strip_sel", os.path.join(HERE, "..", "strip_sel.py"))
strip_sel = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(strip_sel)


class StripSelTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="strip_sel_test_")
        self.root = os.path.join(self.tmp, "copy")
        shutil.copytree(os.path.join(HERE, "fixture"), self.root)

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def read(self, relative):
        with open(os.path.join(self.root, relative), encoding="utf-8") as handle:
            return handle.read()

    def exists(self, relative):
        return os.path.exists(os.path.join(self.root, relative))

    def test_untouched_copy_fails_the_check(self):
        check = strip_sel.check_tree(self.root)
        self.assertEqual(len(check["violations"]), 5, check["violations"])
        self.assertEqual(strip_sel.main([self.root, "--check"]), 1)

    def test_strip_removes_proprietary_parts_only(self):
        report = strip_sel.strip_tree(self.root, compare_ossify=True)

        self.assertEqual(
            sorted(report["deleted_files"]),
            ["crates/alpha/src/closed.rs", "crates/beta/src/lib.rs", "crates/beta/src/settings.yml"],
        )
        for name in report["deleted_files"]:
            self.assertFalse(self.exists(name), name)

        alpha = report["crates"]["alpha"]
        self.assertEqual((alpha["files_deleted"], alpha["files_with_snippets"], alpha["snippets_removed"]), (1, 2, 2))
        beta = report["crates"]["beta"]
        self.assertEqual((beta["files_deleted"], beta["snippets_removed"]), (2, 0))
        gamma = report["crates"]["gamma"]
        self.assertEqual((gamma["files_deleted"], gamma["snippets_removed"]), (0, 0))

        lib = self.read("crates/alpha/src/lib.rs")
        self.assertNotIn("closed", lib)
        self.assertIn("pub mod open;\npub mod other;\n", lib)
        self.assertIn("AGPL-3.0-only OR LicenseRef-SEL", lib)

        open_rs = self.read("crates/alpha/src/open.rs")
        self.assertNotIn("41", open_rs)
        self.assertNotIn("enterprise", open_rs)
        # L'extrait sous licence MIT est gardé en entier, marqueurs compris.
        self.assertIn("SPDX-License-Identifier: MIT", open_rs)
        self.assertIn("total += 1;", open_rs)
        self.assertEqual(open_rs.count("SPDX-SnippetBegin"), 1)
        self.assertEqual(open_rs.count("SPDX-SnippetEnd"), 1)

        # Fichiers sans partie propriétaire : inchangés à l'octet près.
        for name in ("crates/alpha/src/other.rs", "crates/gamma/src/lib.rs", "crates/alpha/Cargo.toml", "README.md"):
            with open(os.path.join(HERE, "fixture", name), "rb") as original, open(os.path.join(self.root, name), "rb") as copy:
                self.assertEqual(original.read(), copy.read(), name)

        # Seul écart attendu avec ossify.py : il ne lit que les fichiers `.rs`.
        self.assertEqual([item["file"] for item in report["ossify_differences"]], ["crates/beta/src/settings.yml"])

    def test_no_proprietary_marker_remains_after_strip(self):
        self.assertEqual(strip_sel.main([self.root]), 0)
        check = strip_sel.check_tree(self.root)
        self.assertEqual(check["violations"], [])
        # Mentions restantes : double licence (deux en-têtes, deux Cargo.toml) et fichiers listés.
        self.assertEqual(check["dual_licence_mentions"], 5)
        self.assertEqual(
            sorted(check["listed_files"]),
            ["LICENSES/LicenseRef-SEL.txt", "README.md", "resources/scripts/ossify.py"],
        )
        for relative in strip_sel.iter_files(self.root):
            for line in self.read(relative).split("\n"):
                self.assertIsNone(strip_sel.SEL_ONLY_LINE.match(line), f"{relative} : {line}")

    def test_strip_is_idempotent(self):
        self.assertEqual(strip_sel.main([self.root]), 0)
        before = {name: self.read(name) for name in strip_sel.iter_files(self.root)}
        second = strip_sel.strip_tree(self.root)
        self.assertEqual(second["deleted_files"], [])
        self.assertEqual(second["snippet_files"], [])
        self.assertEqual(before, {name: self.read(name) for name in strip_sel.iter_files(self.root)})

    def test_dry_run_changes_nothing(self):
        report = strip_sel.strip_tree(self.root, dry_run=True)
        self.assertEqual(len(report["deleted_files"]), 3)
        self.assertTrue(self.exists("crates/alpha/src/closed.rs"))
        self.assertIn("closed", self.read("crates/alpha/src/lib.rs"))

    def test_unterminated_snippet_is_removed_and_reported(self):
        path = os.path.join(self.root, "crates/gamma/src/lib.rs")
        with open(path, "a", encoding="utf-8") as handle:
            handle.write("// SPDX-SnippetBegin\n// SPDX-License-Identifier: LicenseRef-SEL\npub fn leaked() {}\n")
        self.assertEqual(strip_sel.main([self.root]), 1)
        self.assertNotIn("leaked", self.read("crates/gamma/src/lib.rs"))
        self.assertEqual(strip_sel.check_tree(self.root)["violations"], [])

    def test_unknown_mention_fails_the_check(self):
        strip_sel.strip_tree(self.root)
        with open(os.path.join(self.root, "crates/gamma/src/note.txt"), "w", encoding="utf-8") as handle:
            handle.write("Ce fichier relève de LicenseRef-SEL.\n")
        check = strip_sel.check_tree(self.root)
        self.assertEqual(len(check["violations"]), 1)
        self.assertIn("crates/gamma/src/note.txt:1", check["violations"][0])


if __name__ == "__main__":
    unittest.main()
