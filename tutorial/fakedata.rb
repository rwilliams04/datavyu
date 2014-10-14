require 'Datavyu_API.rb'

# function to calculate a random value from range
def rint(min, max)
	return rand(max - min) + min
end

# function to make onset offset timestamps
def tinterval(onset, offset)
	x =  rint(onset + 1, offset - 1)
	y =  rint(onset + 1, offset - 1)
	return [x, y].sort
end

begin
	# number of trials as a range
	trialRange = (1..8).to_a

	# length of each trial in milliseconds
	trialLength = 1000 * 30

	# duration of holding time and adjuster
	holdDuration = 7500
	holdAdjust = holdDuration * 0.5

	# codes to use for <toy> arg
	toyCodes = ["bunny", "car", "put", "open", "drink", "cookie", "eat", "bear"]

	# trial onset time for each trial
	trialSteps = ((trialRange.min * trialLength)..(trialRange.max * trialLength)).step(trialLength)

	# create variable for trials
	trialsColumn = createNewVariable("trial", "word")

	# create variable for child holding objects
	holdingColumn = createNewVariable("holding", "toy")

	# trial iterator
	currentTrial = -1

	# start filling in trial column cells
	trialSteps.each do | tstart |

		# increase iterator
		currentTrial = currentTrial + 1

		# make new cell for trial column
		trialCell = trialsColumn.make_new_cell()

		# onset/offset adjustment
		onset = tstart - trialLength
		offset = tstart - 1

		# update cell codes
		trialCell.change_code("onset", onset)
		trialCell.change_code("offset", offset)
		trialCell.change_code("word", toyCodes[currentTrial])

		# nested time intervals for holding col
		randomHoldTime = rint(holdDuration-holdAdjust, holdDuration+holdAdjust)
		timeSteps = (onset..offset).step(randomHoldTime).to_a

		# start iterating through holding durations
		timeSteps.each do | hstart |

			# make a new cell
			toyCell = holdingColumn.make_new_cell()

			# pull a random toy
			toy = toyCodes[rand(8)]

			# make sure no overlap
			hend =  [hstart + randomHoldTime, offset].min

			# create a time interval for holding duration
			holdSpan = tinterval(hstart, hend)

			# assign on/off codes based on time interval
			toyCell.change_code("onset", holdSpan[0])
			toyCell.change_code("offset", holdSpan[1])

			# assign toy code to cell
			toyCell.change_code("toy", toy)

		end

	end

	# set the columns in datavyu
	setColumn(trialsColumn)
	setColumn(holdingColumn)
	
end
