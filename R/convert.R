#' Convert Fidus files to Jekyll
#'
#' @param fiduszipfile A Zip-File containing a downloaded html-book from fidus
#' @param tmpdir A string containing a tmp dir
#' @return A list of markdown files ready for jekyll and github in the output dir.



convert_fidus_to_github <- function(fiduszipfile = "handbuch.zip", tmpdir = "tmp/") {

  # This script automates the the process of passing html files
  # into the jekyll system. Its done for the handbook for infectious diseases

  # Unzip the file
  unzip(fiduszipfile, exdir = tmpdir)

  # This command lists all html files after deleting index.html
  htmlfiles <- list.files(tmpdir, pattern = "document.*\\.html$")

  # loop through all html files
  for (a in htmlfiles) {

      # a <- htmlfiles[5]

    # Get rid of the annoying error of a missing newline
    write("\n", paste0(tmpdir,a), append = T)

    # Getting the necessary information out of the html-file
    number <- strsplit(strsplit(a, "\\.")[[1]][1], "-")[[1]][2]
    newfilename <- paste0("chapter_", number, ".md")

    # read in the document
    document <- readLines(paste0(tmpdir,a))

    # Get document title
    title_line <- document[grep("<title", document)]
    title <- strsplit(strsplit(title_line, ">")[[1]][2], "<")[[1]][1]
    title <- sub("^.{0,3}", "", title)

    # Get content out of document
    document <- document[grep("<div class=\"article-part article-richtext article-body\">", document) ][1]
    document <- strsplit(document, "<div class=\"article-part article-richtext article-body\">")[[1]][2]

    write(document, paste0(tmpdir,"tmp.html"))
    write("",  paste0(tmpdir,"tmp.md"))
    rmarkdown::pandoc_convert(input = paste0("tmp.html"), to = "gfm", output = paste0("tmp.md"), wd = "tmp/")
    documentToAppend <- readLines(paste0(tmpdir,"tmp.md"))

    # remove the old file if it exists
    # if (file.exists(newfilename)) file.remove(newfilename)

    # the new file is created line by line. This is where the jekyll front matter is included
    write("---", newfilename)
    write("layout: page", file = newfilename, append = T)
    write(paste("title:", title), newfilename, append = T)
    write(paste("nav_order:", number), newfilename, append = T)
    write("---", newfilename, append = T)
    # write(paste("{{page.title}}"), newfilename, append = T)
    write(paste(" "), newfilename, append = T)
    write(paste("<details markdown=\"block\"> "), newfilename, append = T)
    write(paste("  <summary> "), newfilename, append = T)
    write(paste("      &#9658; Inhaltsverzeichnis Kapitel (ausklappbar) "), newfilename, append = T)
    write(paste("  </summary>"), newfilename, append = T)
    write(paste(" "), newfilename, append = T)
    write(paste("1. TOC"), newfilename, append = T)
    write(paste("{:toc}"), newfilename, append = T)
    write(paste(" </details>"), newfilename, append = T)
    write(paste(" "), newfilename, append = T)
    write(paste("   <p></p>"), newfilename, append = T)
    write(paste(" "), newfilename, append = T)
    write(paste(" "), newfilename, append = T)
    write(documentToAppend, newfilename, append = T)
  }

  # Copying all pictures to the docs folder
  pics <- list.files(tmpdir, pattern = ".png$")
  for (i in pics) {
    file.copy(paste0(tmpdir, i), i, overwrite = TRUE)
  }

  unlink(tmpdir, recursive = T) # Delete tmp dir

  }

