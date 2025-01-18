set terminal svg font "DejaVu Sans,12" size 600,400
set output "Project_Gutenberg_total_books.svg"

set xdata time
set timefmt "%Y-%m"
set xrange ["1994-01":]
set format x "%Y"
set key off

set tics nomirror
set grid
set border 3

# Wikipedia in many languages uses this file.
# To avoid translation, use emojis.
set xlabel "📅"  # Year
set ylabel norotate "📚"  # Number of Books

plot "Project_Gutenberg_total_books.data" using 1:2 \
     with line linetype rgbcolor "red" linewidth 2
