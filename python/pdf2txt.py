#!/usr/bin/env python
# https://pymupdf.readthedocs.io/en/latest/the-basics.html

import sys,os,click,logging
import pymupdf

logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG))

@click.command()
@click.option("--input_file", "ifile", required=True, type=click.Path(file_okay=True, dir_okay=False, exists=True), help="Input PDF file.")
@click.option("--output_file", "ofile", required=False, type=click.Path(file_okay=True, dir_okay=False), help="Output TXT file.")

def main(ifile, ofile):

  doc = pymupdf.open(ifile) # open a document
  out = open(ofile, "wb") if ofile else sys.stdout
  for page in doc: # iterate the document pages
    text = page.get_text().encode("utf8") # get plain text (is in UTF-8)
    out.write(text) # write text of page
    out.write(bytes((12,))) # write page delimiter (form feed 0x0C)
  out.close()

if __name__ == '__main__':
    main()

