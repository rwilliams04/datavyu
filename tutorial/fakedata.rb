require 'Datavyu_API.rb'

def rint(min, max)
	return rand(max - min) + min
end

def tinterval(time, stepsize)
	x =  rint(1 + (time - stepsize), time)
	y =  rint(1 + (time - stepsize), time)
	return [x, y].sort
end

begin
	# time gap in ms
	stepInterval = 5000;

	# codes to use for <toy> arg
	toy_codes = ["bunny", "car", "put", "open", "drink", "cookie", "eat", "bear"]

	# time steps in ms
	timeSteps = (stepInterval..(stepInterval * 100)).step(stepInterval)

	# create variable for child holding objects
	my_col = createNewVariable("holding","toy")
	
	# cycle through each time step and fill in cells with data
	timeSteps.each do |time|

		# make a new cell
		col_cell = my_col.make_new_cell()

		# pull a random toy
		toy = toy_codes[rand(8)]

		# create a time interval for holding duration
		on_off = tinterval(time, stepInterval)

		# assign on/off codes based on time interval
		col_cell.change_code("onset", on_off[0])
		col_cell.change_code("offset", on_off[1])

		# assign toy code to cell
		col_cell.change_code("toy", toy)

		# print info
		puts "toy: #{toy}; cell range: (#{on_off[0]}, #{on_off[1]})"

	end

	# set the column in datavyu
	setColumn(my_col)
	
end