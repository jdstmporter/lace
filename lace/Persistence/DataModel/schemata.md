#  Tables

## Pricking

pk          int
name        String
created     DTG
kind        string
grid        int (fk)

## Grid

pk          int
width       int
height      int
data        blob

## Line Layer

pk          int
parent      int (ref)
layer       int

### Line

pk          int
parent      int (ref)
x1          int
y1          int
x2          int
y2          int
