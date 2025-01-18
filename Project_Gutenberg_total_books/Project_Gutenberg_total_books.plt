set terminal svg font "Bitstream Vera Sans,12" size 600,400
set output "Project_Gutenberg_total_books.svg"

set xdata time
set timefmt "%Y-%m"
set xrange ["1994-01":"2015-11"]
set format x "%Y"
set key off
unset mxtics

set xtics nomirror
set ytics nomirror
set grid
set border 3

set xlabel "Year"
set ylabel "Number of Books"

plot "Project_Gutenberg_total_books.data" using 1:2 \
     with line linetype rgbcolor "red" linewidth 2
