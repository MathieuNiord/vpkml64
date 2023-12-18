(lang dune 3.5)

(name vpkml64)

(generate_opam_files true)

(source
 (github MathieuNiord/vpkml64))

(authors "LathErr0r")

(maintainers "LathErr0r")

(license MIT)

(package
 (name vpkml64)
 (synopsis "Windows utility to create Nintendo 64 ROM shortcuts")
 (description "A Windows utility that makes it easy to create Nintendo 64 ROM shortcuts through an automated process of scrapping, formatting and building")
 (depends ocaml dune)
 (tags
  ("PsVita" "Emulation" "Utility" "Windows" "Nintendo 64")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
