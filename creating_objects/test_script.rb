
## We create and object File named seed_stock.

seed_stock = File.open("./files/seed_stock_data.tsv", "r")
seed_stock.each.next
data = Array.new.(puts seed_stock.each.next)
